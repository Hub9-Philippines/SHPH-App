@echo off
cd /d E:\Dev\SHPH
call flutter analyze > E:\Dev\SHPH\.analyze_out.txt 2>&1
echo ANALYZE_DONE >> E:\Dev\SHPH\.analyze_out.txt
