cd %1
if exist %1.dpr erase %1.pas

if exist \arquiv~1\borland\delphi6\bin\dcc32.exe goto :arquiv1
if exist \arquiv~2\borland\delphi6\bin\dcc32.exe goto :arquiv2
if exist \progra~1\borland\delphi6\bin\dcc32.exe goto :progra1
if exist \progra~2\borland\delphi6\bin\dcc32.exe goto :progra2


:arquiv1
\arquiv~1\borland\delphi6\bin\dcc32 -uc:\winvox\fontes\tradutor;c:\winvox\fontes\tradutor;c:\winvox\fontes\lianetts;c:\winvox\fontes\edivox;c:\winvox\fontes\sc\sc_interp;C:\arquiv~1\borland\Delphi6\Imports %1
goto :fim

:arquiv2
\arquiv~2\borland\delphi6\bin\dcc32 -uc:\winvox\fontes\tradutor;c:\winvox\fontes\tradutor;c:\winvox\fontes\lianetts;c:\winvox\fontes\edivox;c:\winvox\fontes\sc\sc_interp;C:\arquiv~2\borland\Delphi6\Imports %1
goto :fim

:progra1
\progra~1\borland\delphi6\bin\dcc32 -uc:\winvox\fontes\tradutor;c:\winvox\fontes\tradutor;c:\winvox\fontes\lianetts;c:\winvox\fontes\edivox;c:\winvox\fontes\sc\sc_interp;C:\progra~1\borland\Delphi6\Imports %1
goto :fim

:progra2
\progra~2\borland\delphi6\bin\dcc32 -uc:\winvox\fontes\tradutor;c:\winvox\fontes\tradutor;c:\winvox\fontes\lianetts;c:\winvox\fontes\edivox;c:\winvox\fontes\sc\sc_interp;C:\progra~2\borland\Delphi6\Imports %1
goto :fim



:fim
if errorlevel 1 pause
if exist %1.dll move %1.dll \winvox
if exist %1.exe move %1.exe \winvox
cd \winvox\fontes

