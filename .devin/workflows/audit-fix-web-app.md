---
description: Deep-dive audit of missing/incomplete functionality in the SHPH web app repo, then implement the approved fix — designed as a single end-to-end run
---

# Skill: Audit & Fix Web App Gaps

**Goal:** In ONE run — scan the web app repo (`SHPH_web_version`) for missing/incomplete functionality, write a gap report (with local + GitLab locations so it's readable/clickable), present ranked suggestions, ask the USER **one** confirmation question, then immediately implement the approved fix(es). Minimize back-and-forth.

---

## Repo Locations (always include these in the report header)

| Repo | Local Path | GitLab Remote |
|------|-----------|----------------|
| Root (submodule parent) | `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version` | `https://gitlab.com/shph1/shph.git` |
| Backend (`shph-api`) | `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version\shph-api` | `https://gitlab.com/shph1/shph-api.git` |
| Frontend (`shph-app`) | `C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version\shph-app` | `https://gitlab.com/shph1/shph-app.git` |

> Note: `grep_search`/`find_by_name` tools only work within the **current open workspace** (`SerbisyoPH`). Since the web app repo is a separate folder, use `run_command` with PowerShell `Select-String` / `Get-ChildItem` to search it instead. Never use `grep_search` directly on paths outside the active workspace — it will error.

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

Run via `run_command` (PowerShell), scoped to exclude vendored code (`djongo/`, `sqlparse_temp/`, `node_modules/`):

```powershell
# Backend (Python)
Get-ChildItem -Path "<web-repo>\shph-api\src\shph" -Recurse -Include "*.py" |
  Where-Object { $_.FullName -notmatch "djongo|sqlparse_temp" } |
  Select-String -Pattern "TODO|FIXME|XXX|HACK\b|NotImplementedError|not implemented|coming soon|mock fallback" |
  Select-Object Path,LineNumber,Line

# Frontend (Vue/TS)
Get-ChildItem -Path "<web-repo>\shph-app\src" -Recurse -Include "*.ts","*.vue" |
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
> **Repo (local):** C:\Users\Pol\Desktop\DEV\StartUp\SHPH_web_version
> **Repo (GitLab):** https://gitlab.com/shph1/shph.git (root) | shph-api.git | shph-app.git

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
