@echo off

if not exist backups mkdir backups

git bundle create backups\dosvox-historico.bundle --all

echo.
echo Bundle criado em backups\dosvox-historico.bundle
pause