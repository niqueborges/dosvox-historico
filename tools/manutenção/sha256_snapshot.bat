@echo off

if not exist backups mkdir backups

certutil -hashfile backups\dosvox-historico.bundle SHA256

pause