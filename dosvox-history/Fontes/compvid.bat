cd %1
if exist %1.dpr erase %1.pas
if exist \progra~1\borland\delphi6\bin\dcc32.exe goto :comp2000

:comp98
\arquiv~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\vidente -u\winvox\fontes\tradutor;\winvox\fontes\lianetts %1
goto :fimcomp

:comp2000
\progra~1\borland\delphi6\bin\dcc32 -u\winvox\fontes\vidente -u\winvox\fontes\tradutor;\winvox\fontes\lianetts %1

:fimcomp
if errorlevel 1 pause
if exist %1.dll move %1.dll \
if exist %1.exe move %1.exe \
cd \winvox\fontes

