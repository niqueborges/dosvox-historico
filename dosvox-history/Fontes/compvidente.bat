cd %1
if exist %1.dpr erase %1.pas
if exist \progra~1\borland\delphi6\bin\dcc32.exe goto :comp2000
if exist \progra~1\borland\Delphi7SE\bin\dcc32.exe goto :compd7
if exist \programas\borland\delphi6\bin\dcc32.exe goto :portugal

:compd7
\progra~1\Delphi7SE\bin\dcc32 -u\winvox\fontes\vidente;\winvox\fontes\tradutor;\winvox\fontes\lianetts;\progra~1\Delphi7SE\Imports %1
goto :fimcomp

:comp98
\arquiv~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\vidente;\winvox\fontes\tradutor;\winvox\fontes\lianetts;\arquiv~1\borland\Delphi6\Imports %1
goto :fimcomp

:portugal
\programas\borland\delphi6\bin\dcc32 -u\winvox\fontes\vidente;\winvox\fontes\tradutor;\winvox\fontes\lianetts;\arquiv~1\borland\Delphi6\Imports %1
goto :fimcomp

:comp2000
\progra~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\vidente;\winvox\fontes\tradutor;\winvox\fontes\lianetts;C:\progra~1\borland\Delphi6\Imports %1
goto :fimcomp


:fimcomp
if errorlevel 1 pause
if exist %1.dll move %1.dll \winvox
if exist %1.exe move %1.exe \winvox
cd \winvox\fontes

