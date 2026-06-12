@echo off

rem ------- teste das rotinas basicas ----------

cd ttrad
call ..\comp oi
erase \winvox\oi.exe

rem ------- principais ----------

call comp ttrad
call comp dosvox
call comp atuvox
call comp edivox
call comp txtword
call comp minied
call comp sapiutil
call comp sapi4cnf
call comp listavox
call comp imprivox

call comp lembretevox

rem ------- lianetts ----------

cd lianetts
call ..\comp lianelib
REM cd lianetts
REM call ..\comp mbr
xcopy \winvox\lianelib.dll \winvox\lianetts /Q /R /K /Y
REM move \winvox\lianelib.dll \winvox\fontes\lianetts\testes /c /q /h /k /y

rem ------- utilitarios ----------

call comp brlServer
call comp calcuvox
call comp cheqvox
call comp fichavox
call comp agenvox
call comp televox
call comp levox
call comp clockvox
call comp agenda
call comp formvox
call comp ligavox
call comp planivox
call comp powervox
call comp pptfala
call comp traduvox
call comp timervox
call comp criaicon
call comp hardvox
call comp pyvox
call comp cdrec
call comp monit32
call comp digitavox

call comp scripvox
call comp sc
cd sc
call ..\comp scb
call comp pptvox

rem call comped matvox
rem call comp finanvox

rem ------- Pasta Util ----------

cd util
call ..\comp fechawin
cd util
call ..\comp ajustaIni
cd util
call ..\comp mimevox
cd util
call ..\comp uuvox
REM cd util
REM call ..\comp geradon
cd util
call ..\comp dvtxt
cd util
call ..\comp cartex

rem ------- jogos ---------

call comp forcavox
call comp forca2
call comp x3vox
call comp catavox
call comp ichinvox
call comp questvox
call comp suecavox
call comp sudovox
call comp memovox
call comp colossal
call comp pacienci
call comp mistuvox
call comp nimvox
call comp senhavox
call comp squentin
call comp piratvox
call comp contavox
call comp letrix
call comp vidavox
call comp casino
call comp govox
call comp profeta
call comp sortevox
call comp baronvox
call comp memojogo
call comp lunarvox
call comp letravox
call comp chessvox
call comp cruzavox
call comp jogavox
rem call comp batnaval

call comp curiosovox
call comp palavrox

rem ------- multimidia -------

call comp manvox
call comp midiavox
cd midiavox
call ..\comp mcictl
cd midiavox
call ..\comp minimid

call comp minigrav
cd minigrav
call ..\comp testamic
cd minigrav
call ..\comp juntawav
call comp tmix
call comp mixervox

rem call comp txtmp3
call comp cdmp3
call comp metrovox
call comp convsons

rem ------- adaptativos -------

call comp ocrvox2
call comp cronovox
call comp desliga

rem ------ braille -------

call comp braivox

rem ------ rede -------

call comp papovox
call comp tnetvox
call comp webvox
call comp miniweb
call comp sitiovox
call comp cartavox
call comp imaputil
REM call comp twitvox
call comp voxtube
call comp voxnews
call comp googlevox
call comp recado
call comp radio50
call comp wifivox
call comp ediponte
call comp pontevox
call comp dicio

cd cartavox
call ..\comp prelista

call comp ftpvox
call comp intervox
call comp mataspam
call comp miniweb
call comp mircvox

call comp dialup
call comp epubvox

goto :fim

rem ------ obsoletos --------

rem call comp desenvox
rem call comp discavox
rem call comp wwwvox
rem call comp wordutil
rem comp discavox\uuvox
rem comp discavox\mimevox
rem call comp papovox\listasit
rem call comp servfala
rem call comp telemark
rem call comp telemark\accessdv
rem call \comp util\convrm
rem call comp hook\captxt
rem call comp hook\qwscap
rem call comp hook\cdwav

:fim
\winvox\ttrad Fim do processamento
