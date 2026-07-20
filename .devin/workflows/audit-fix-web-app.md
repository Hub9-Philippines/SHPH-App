---
description: Deep-dive audit of missing/incomplete functionality in the SHPH web app repo, then implement the approved fix — designed as a single end-to-end run
---

# Skill: Audit & Fix Web App Gaps

**Goal:** In ONE run — locate the web app repo **dynamically** (never hardcode a path — every teammate has it cloned somewhere different on their own machine), scan it for missing/incomplete functionality, write a gap report (with local + GitLab locations so it's readable/clickable), present ranked suggestions, ask the USER **one** confirmation question, then immediately implement the approved fix(es). Minimize back-and-forth.

> ⚠️ **This workflow must never hardcode an absolute path** (e.g. `C:\Users\<name>\...`). Multiple developers run this skill from their own local clones at different locations. Always resolve the path fresh via Step -1 below.

---

## Repo Identity (fixed facts — paths are NOT fixed, remotes are)

| Repo | Folder Name | GitLab Remote |
|------|------------|----------------|
| Root (submodule parent) | `SHPH_web_version` (or similar — verify by remote, not name) | `https://gitlab.com/shph1/shph.git` |
| Backend (submodule) | `shph-api` | `https://gitlab.com/shph1/shph-api.git` |
| Frontend (submodule) | `shph-app` | `https://gitlab.com/shph1/shph-app.git` |

> Note: `grep_search`/`find_by_name` tools only work within the **current open workspace** (`SerbisyoPH`). Since the web app repo is a separate folder outside this workspace, use `run_command` with PowerShell `Select-String` / `Get-ChildItem` (or shell equivalents on macOS/Linux) to search it instead. Never use `grep_search`/`find_by_name` directly on paths outside the active workspace — they will error.

---

## Step -1 — Dynamically Locate the Web App Repo (always run first, never skip)

**Never assume or hardcode a path.** Resolve it fresh each run using this priority order:

1. **Check the local cache file** (per-developer, gitignored): `.devin/local/web-app-repo-path.txt` in this repo. If it exists, read it, then verify it's still valid:
   ```powershell
   Test-Path "<cached-path>\.git"; git -C "<cached-path>" remote get-url origin
   ```
   Confirm the remote URL matches `shph1/shph.git` (or `shph1/shph-api.git`/`shph1/shph-app.git` if the cache points at a submodule directly). If valid, use it and skip to Step 0.

2. **If no cache or it's invalid, auto-search common sibling locations** relative to this workspace's parent directory (most developers clone sibling projects side-by-side):
   ```powershell
   $parent = Split-Path -Parent (Get-Location)
   Get-ChildItem -Path $parent -Directory -Depth 1 -ErrorAction SilentlyContinue |
     Where-Object { Test-Path (Join-Path $_.FullName ".gitmodules") } |
     ForEach-Object {
       $remote = git -C $_.FullName remote get-url origin 2>$null
       if ($remote -match "shph1/shph(\.git)?$") { $_.FullName }
     }
   ```
   This looks for any sibling folder containing a `.gitmodules` file whose `origin` remote matches the SHPH web repo — regardless of what the folder is actually named locally.

3. **If still not found, ask the user once** via `ask_user_question` (or a direct question) for the absolute local path to their `SHPH_web_version` (or equivalently-named) checkout.

4. **Cache the resolved path** for future runs by writing it to `.devin/local/web-app-repo-path.txt` (create the `.devin/local/` folder if needed — it's gitignored, so this never leaks one developer's path to another). **Use `run_command`** (e.g. `New-Item -ItemType Directory -Force`, `Set-Content`) to create this file — the `write_to_file`/`edit` tools refuse to touch gitignored paths and will error.

From here on, refer to the resolved path as `$WebAppRepoPath` (root), `$WebAppRepoPath\shph-api`, and `$WebAppRepoPath\shph-app`. Substitute the real resolved value in every command below — do not paste a literal hardcoded path into any file you write (reports, code comments, etc.) except the final resolved value for that specific run's report header.

---

## Step 0 — Pull Latest Code First (mandatory, do this before anything else)

The local checkout can be behind the GitLab remote, and prior self-audit docs (Step 1) can also be stale relative to the local checkout. **Always sync all three repos (root + both submodules) before auditing**, otherwise findings may report already-fixed issues as gaps (this happened in a prior run).

```powershell
# Root repo
git -C "$WebAppRepoPath" pull

# Submodules (shph-api, shph-app) — update to latest tracked commits
git -C "$WebAppRepoPath" submodule update --remote --merge

# Or, if the submodules should follow their own default branch directly:
git -C "$WebAppRepoPath\shph-api" pull
git -C "$WebAppRepoPath\shph-app" pull
```

Run via `run_command` (these are read-only network operations — safe to auto-run). If `git pull` reports local uncommitted changes or diverged branches, **stop and surface this to the user** before proceeding — do not force-pull or discard local work.

After pulling, note the current commit hash of each repo (`git -C <path> rev-parse --short HEAD`) and include it in the gap report header (Step 4) so findings are timestamped against a known code state.

---

## Step 1 — Gather Existing Self-Audits (fastest signal, do this first)

The web app repo already contains prior audit documents — read these before grepping, they contain pre-analyzed, prioritized gaps:

| File | Contents |
|------|----------|
| `BIDDING_AUDIT_REPORT.md` (repo root) | On-demand bidding feature audit — P0-P3 prioritized requirements list, scores per category (Core Flow, Frontend, Backend, Tests, Security, Performance, Admin/Ops, Push/Notifications) |
| `shph-api/orm-audit-findings.md` | ORM/N+1 query audit — severity-ranked findings (CRITICAL/HIGH/MEDIUM/LOW) with file:line references and fix priority table |
| `UX_AUDIT_PROGRESS.md` (repo root) | UX responsiveness audit tracker — check if marked "ALL PRIORITIES COMPLETE" (if so, skip) |
| `O11Y_SETUP.md` | Observability/monitoring setup — check for gaps in error tracking, logging |
| `FEATURE_SPECS_SHPH-133-134.md` | Feature specs — compare against implementation for incomplete items |
| `CHANGELOG.md` | Recent changes — cross-reference to see what's already fixed since the audits above were dated |

**Action:** Read each file's executive summary + "Requirements List" / "Findings" / "Fix Priority" sections. Note the audit **dates** — cross-check `CHANGELOG.md` for entries after that date that may have already resolved the item (don't re-report fixed issues).

## Step 2 — Grep for Fresh Signals

Run via `run_command` (PowerShell), scoped to exclude vendored code (`djongo/`, `sqlparse_temp/`, `node_modules/`). Use the `$WebAppRepoPath` resolved in Step -1:

```powershell
# Backend (Python)
Get-ChildItem -Path "$WebAppRepoPath\shph-api\src\shph" -Recurse -Include "*.py" |
  Where-Object { $_.FullName -notmatch "djongo|sqlparse_temp" } |
  Select-String -Pattern "TODO|FIXME|XXX|HACK\b|NotImplementedError|not implemented|coming soon|mock fallback" |
  Select-Object Path,LineNumber,Line

# Frontend (Vue/TS)
Get-ChildItem -Path "$WebAppRepoPath\shph-app\src" -Recurse -Include "*.ts","*.vue" |
  Select-String -Pattern "TODO|FIXME|XXX|HACK\b|not implemented|coming soon|dummy data|mock data" |
  Select-Object Path,LineNumber,Line
```

Filter out false positives (CSS `placeholder` classes, HTML `placeholder=""` attributes, phone-number masks like `09XXXXXXXXX`).

## Step 3 — Cross-Check Against API Spec Coverage (if relevant)

If auditing backend completeness, compare `SHPH API.yaml` (in `SerbisyoPH` repo root) endpoint list against actual `shph-api/src/shph/*/views.py` implementations. Note any endpoints documented but not implemented, or implemented but undocumented.

## Step 4 — Compile the Gap Report

Write findings to `docs/web_app_gap_audit.md` in **this repo** (`SerbisyoPH`), structured as:

```markdown
# Web App Gap Audit — SHPH_web_version

> **Audited:** <date>
> **Repo (local, this machine):** `<resolved $WebAppRepoPath for this run>`
> **Repo (GitLab — canonical, same for everyone):** https://gitlab.com/shph1/shph.git (root) | shph-api.git | shph-app.git
> **Commit at audit time:** root `<hash>` | shph-api `<hash>` | shph-app `<hash>` (from Step 0 `git pull` + `rev-parse`)
>
> Note: the local path above is specific to the machine this audit ran on. Anyone opening this report on a different machine should rely on the **GitLab links** (`.../-/blob/main/<relative-path>`), not the local path.

## Summary Table
| Area | Status | Severity | Source |
|------|--------|----------|--------|
| ... | ... | P0/P1/P2/P3 | BIDDING_AUDIT_REPORT.md / orm-audit-findings.md / fresh grep |

## Detailed Findings
(one section per gap: description, file:line, GitLab-relative path, suggested fix, effort estimate)

## Suggested Fix Order
1. ...
2. ...
```

Every finding MUST include the file path relative to its repo AND a note of which repo it's in (`shph-api` or `shph-app`), so the user can open it directly or find it on GitLab at `https://gitlab.com/shph1/<repo>/-/blob/main/<relative-path>`.

## Step 5 — Present & Ask ONE Confirmation Question

Summarize the top 3-5 findings concisely in chat (bullets, severity-tagged). Then call `ask_user_question` **once** with the ranked options (e.g., top P0 items + "let me pick a custom one"). Do NOT ask multiple sequential clarifying questions — pack all necessary choices into this single call (use `allowMultiple: true` if more than one fix should be batched).

## Step 6 — Implement Immediately Upon Approval

Once the user selects option(s):
1. Open the exact file(s) referenced in the finding
2. Apply the fix following the web repo's own rules (`.cursorrules`, `AGENTS.md`):
   - Djongo-safe rules if touching `chat/` or nosql models
   - POST-over-GET pattern for new endpoints
   - `select_related`/`prefetch_related` for N+1 fixes
   - Top-level imports only
3. Run verification per `AGENTS.md` checklist:
   - `ruff check src/shph/` (backend) or `yarn lint` (frontend) — via `run_command`
   - `python -m py_compile` on modified `.py` files
4. Update `docs/web_app_gap_audit.md` — mark the item ✅ Resolved with commit/date note
5. Report back to the user with a concise summary of what changed and verification results — do not ask further questions unless the fix genuinely fails verification.

---

## Key Principle

This skill is optimized for **one pass**: gather → report → single decision point → implement → verify → done. Avoid re-confirming trivial sub-steps. Only stop and ask again if the implementation reveals a blocking ambiguity (e.g., missing credentials, conflicting requirement) that cannot be reasonably inferred.
