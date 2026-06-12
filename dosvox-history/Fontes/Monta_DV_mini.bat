REM --- Monta a pasta \wv_mini com o Dosvox mínimo
REM --- Necessário o arquivo wv_mini_Limpa.bat na mesma pasta
REM --- Por Neno Albernaz
REM --- Em 01/04/2025

REM --- Exclui a pasta do Dosvox mínimo para gerar uma nova:

rmdir /S /Q \wv_mini

REM --- Copia a pasta \wv da geração do setup para \wv_mini:

call DELBAK.BAT
xcopy \wv\*.* \wv_mini /d /s /e /c /q /h /k /y /i

REM --- Exclui tudo que não vai na versão Dosvox mini

call wv_mini_Limpa.bat
