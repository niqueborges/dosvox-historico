cd %1
if exist %1.dpr erase %1.pas

if exist c:\arquiv~1\borland\delphi6\bin\dcc32.exe goto :arquiv1
if exist c:\arquiv~2\borland\delphi6\bin\dcc32.exe goto :arquiv2
if exist c:\progra~1\borland\delphi6\bin\dcc32.exe goto :progra1
if exist c:\progra~2\borland\delphi6\bin\dcc32.exe goto :progra2
if exist c:\delphi\dcc32.exe goto :delphi

:arquiv1
c:\arquiv~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\tradutor;\winvox\fontes\lianetts;\winvox\fontes\sc\sc_interp;C:\arquiv~1\borland\Delphi6\Imports %1
goto :fim

:arquiv2
c:\arquiv~2\borland\delphi6\bin\dcc32 -u\winvox\fontes\tradutor;\winvox\fontes\lianetts;\winvox\fontes\sc\sc_interp;C:\arquiv~2\borland\Delphi6\Imports %1
goto :fim

:progra1
c:\progra~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\tradutor;\winvox\fontes\lianetts;\winvox\fontes\sc\sc_interp;C:\progra~1\borland\Delphi6\Imports %1
goto :fim

:progra2
c:\progra~2\borland\delphi6\bin\dcc32 -u\winvox\fontes\tradutor;\winvox\fontes\lianetts;\winvox\fontes\sc\sc_interp;C:\progra~2\borland\Delphi6\Imports %1
goto :fim

:delphi
c:\delphi\dcc32 -u\winvox\fontes\tradutor;\winvox\fontes\lianetts;\winvox\fontes\sc\sc_interp;C:\progra~2\borland\Delphi6\Imports %1
goto :fim

:fim
REM if errorlevel 1 pause
if exist %1.dll move %1.dll \winvox
if exist %1.exe move %1.exe \winvox
cd \winvox\fontes
