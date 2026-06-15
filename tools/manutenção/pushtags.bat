@echo off

git push github --tags
git push gitlab --tags
git push codeberg --tags

echo.
echo Tags sincronizadas.
pause