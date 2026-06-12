chcp 65001

REM --- Exclui tudo que nao vai na versao Dosvox mini
REM --- Necessario o arquivo \wv\Apague_wv_mini.bat na mesma pasta
REM --- Por Neno Albernaz
REM --- Em 03/04/2025

REM --- Exclui o instalador \wv_exter\Instaladores\K-Lite_Codec_Pack_*.exe

erase \wv_exter\Instaladores\K-Lite_Codec_Pack_*.exe /F /Q

REM --- Exclui as pastas que vao na versao mini do Dosvox em \wv_mini:

rmdir /S /Q \wv_mini\Cdmp3
rmdir /S /Q \wv_mini\Colossal
rmdir /S /Q \wv_mini\cruzadas
rmdir /S /Q \wv_mini\fichario
rmdir /S /Q \wv_mini\Fontes
rmdir /S /Q \wv_mini\Ichinvox
rmdir /S /Q \wv_mini\Instaladores
rmdir /S /Q \wv_mini\Jogavox
rmdir /S /Q \wv_mini\jogavox_modelos
rmdir /S /Q \wv_mini\Manual\audios
rmdir /S /Q \wv_mini\midias
rmdir /S /Q \wv_mini\MPV
rmdir /S /Q \wv_mini\Musicas
rmdir /S /Q \wv_mini\Pptvox
rmdir /S /Q \wv_mini\recados
rmdir /S /Q \wv_mini\sox
rmdir /S /Q "\wv_mini\Treino\Notícias"
rmdir /S /Q "\wv_mini\Treino\Piadas"
rmdir /S /Q "\wv_mini\Treino\Poemas"
rmdir /S /Q "\wv_mini\Treino\Receitas culinárias"
rmdir /S /Q "\wv_mini\Treino\Tecnologia e aprendizagem"
rmdir /S /Q "\wv_mini\Treino\Vozes noturnas"
rmdir /S /Q \wv_mini\tesseract-ocr

erase "\wv_mini\treino\5 Lições para a Vida.txt" /F /Q
erase "\wv_mini\treino\acróstico do dosvox de Neise cavini - por Vitor Alberto.mp3" /F /Q
erase "\wv_mini\treino\20 Dicas a quem queira ajudar um deficiente visual.txt" /F /Q
erase "\wv_mini\treino\características e limitações das pessoas com deficiência.txt" /F /Q
erase "\wv_mini\treino\Desejo Ardente.txt" /F /Q
erase "\wv_mini\treino\Funk do Dosvox.mp3" /F /Q
erase "\wv_mini\treino\Imaputil.txt" /F /Q
erase "\wv_mini\treino\Letras dos Beatles.txt" /F /Q
erase "\wv_mini\treino\Lixo - Luis Fernando Veríssimo.txt" /F /Q
erase "\wv_mini\treino\Noturno.mid" /F /Q
erase "\wv_mini\treino\Peripécias de Pedro Paulo - Tudo em P.txt" /F /Q

REM --- Remove alguns arquivos que nao sao apagados junto com os programas:

erase \wv_mini\manual\lame.txt /F /Q
erase \wv_mini\manual\Cdwav.txt /F /Q
erase \wv_mini\manual\Lynx.txt /F /Q
erase \wv_mini\manual\WWWVox.txt /F /Q
erase \wv_mini\manual\audios.cfg /F /Q
erase \wv_mini\manual\basicos.cfg /F /Q
erase \wv_mini\manual\porCategoria.cfg /F /Q
erase \wv_mini\manual\Dublavox.txt /F /Q

erase \wv_mini\digitavox\Relatorios\*.* /F /Q
erase \wv_mini\digitavox\Usuarios\*.* /F /Q
erase \wv_mini\lixeira\*.* /F /Q

REM --- Exclusao dos arquivos que pertencem a \wv_exter:

erase \wv_mini\ASCIIMathML.js /F /Q
erase \wv_mini\blb2txt.dic /F /Q
erase \wv_mini\blb2txt.exe /F /Q
erase \wv_mini\CreateCD.exe /F /Q
erase \wv_mini\faad.exe /F /Q
erase \wv_mini\gzip.exe /F /Q
erase \wv_mini\lame_enc.dll /F /Q
erase \wv_mini\libeay32.dll /F /Q
erase \wv_mini\libssl32.dll /F /Q
erase \wv_mini\msvcr100.dll /F /Q
erase \wv_mini\msvcr120.dll /F /Q
erase \wv_mini\OPENSSL.EXE /F /Q
erase \wv_mini\PDFtoPrinter.exe /F /Q
erase \wv_mini\rtl60.bpl /F /Q
erase \wv_mini\rtl70.bpl /F /Q
erase \wv_mini\sqlite3.dll /F /Q
erase \wv_mini\ssleay32.dll /F /Q
erase \wv_mini\unzip.exe /F /Q
erase \wv_mini\vcl60.bpl /F /Q
erase \wv_mini\vcl70.bpl /F /Q
erase \wv_mini\zip.exe /F /Q

REM --- Exclusao dos arquivos que pertencem a \wv_exter32 ou \wv_exter64:

erase \wv_mini\7z.dll /F /Q
erase \wv_mini\7z.exe /F /Q
erase \wv_mini\ffmpeg.exe /F /Q
erase \wv_mini\ffplay.exe /F /Q
erase \wv_mini\lame.exe /F /Q
erase \wv_mini\pdftotext.exe /F /Q
erase \wv_mini\psftp.exe /F /Q
erase \wv_mini\wget.exe /F /Q
erase \wv_mini\yt-dlp.exe /F /Q

REM -- Exclusao dos arquivos que nao vao em \wv_mini:

erase \wv_mini\lixeira\*.* /F /Q
rmdir /S /Q \wv_mini\som\dosvox50\rapido
rmdir /S /Q \wv_mini\som\Letripal

erase \wv_mini\*.atu /F /Q
erase \wv_mini\*.zip /F /Q
erase \wv_mini\arqfonte.ini /F /Q
erase \wv_mini\dosvox.ini /F /Q
erase \wv_mini\recasino.txt /F /Q
erase \wv_mini\fontes\dif /F /Q

erase \wv_mini\bass.dll /F /Q
erase \wv_mini\basshls.dll /F /Q
erase \wv_mini\bass_aac.dll /F /Q
erase \wv_mini\upgrade.pro /F /Q
erase \wv_mini\Access.mdl /F /Q
erase \wv_mini\apelidos.ini /F /Q
erase \wv_mini\borlndmm.dll /F /Q
erase \wv_mini\compac.bat /F /Q
erase \wv_mini\Comsaci.ini /F /Q
erase \wv_mini\dvinstal.exe /F /Q
erase \wv_mini\DVKBM32.DLL /F /Q
erase \wv_mini\FDRead.exe /F /Q
erase \wv_mini\FUNDO.JPG /F /Q
erase \wv_mini\FUNDO2.JPG /F /Q
erase \wv_mini\HWMonitor.exe /F /Q
erase \wv_mini\HWMONITOR.TXT /F /Q
erase \wv_mini\HWMONITOR.TXT /F /Q
erase \wv_mini\LETRAWIN.EXE /F /Q
erase \wv_mini\lhttsptb.exe /F /Q
erase \wv_mini\mbr.exe /F /Q
erase \wv_mini\mbrola35.exe /F /Q
erase \wv_mini\msbloque.ini /F /Q
erase \wv_mini\normalvox.ini /F /Q
erase \wv_mini\ohphone.exe /F /Q
erase \wv_mini\OpenH323.dll /F /Q
erase \wv_mini\PAPO.EXE /F /Q
erase \wv_mini\Pptvox.mdl /F /Q
erase \wv_mini\pptvox2.exe /F /Q
erase \wv_mini\pptvox32.exe /F /Q
erase \wv_mini\PTLib.dll /F /Q
erase \wv_mini\PWLib.dll /F /Q
erase \wv_mini\spchapi.exe /F /Q
erase \wv_mini\txtmp3.exe /F /Q
erase \wv_mini\unins000.dat /F /Q
erase \wv_mini\unins000.exe /F /Q
erase \wv_mini\webselec.ini /F /Q
erase \wv_mini\brasil.chq /F /Q
erase \wv_mini\lignomes.txt /F /Q
erase \wv_mini\zipa.bat /F /Q
erase \wv_mini\zipatudo.bat /F /Q

REM --- Exclusao dos programas e suas partes que nao vao no Dosvox mini:

REM call  Apague_wv_mini baronvox
REM call  Apague_wv_mini forcavox
REM call  Apague_wv_mini sudovox

call  Apague_wv_mini domivox

call  Apague_wv_mini agenvox
call  Apague_wv_mini cartex
call  Apague_wv_mini casino
call  Apague_wv_mini catavox
call  Apague_wv_mini cdmp3
call  Apague_wv_mini cdrec
call  Apague_wv_mini cheqvox
call  Apague_wv_mini chessvox
call  Apague_wv_mini clockvox
call  Apague_wv_mini colossal
call  Apague_wv_mini contavox
call  Apague_wv_mini convsons
call  Apague_wv_mini criaicon
call  Apague_wv_mini cronovox
call  Apague_wv_mini cruzavox
call  Apague_wv_mini curiosovox
call  Apague_wv_mini dialup
call  Apague_wv_mini dicio
call  Apague_wv_mini dvtxt
call  Apague_wv_mini fichavox
call  Apague_wv_mini forca2
call  Apague_wv_mini formvox
call  Apague_wv_mini ftpvox
call  Apague_wv_mini govox
call  Apague_wv_mini hardvox
call  Apague_wv_mini ichinvox
call  Apague_wv_mini intervox
call  Apague_wv_mini jogavox
call  Apague_wv_mini juntawav
call  Apague_wv_mini letravox
call  Apague_wv_mini letrix
call  Apague_wv_mini ligavox
call  Apague_wv_mini lunarvox
call  Apague_wv_mini manvox
call  Apague_wv_mini mcictl
call  Apague_wv_mini memojogo
call  Apague_wv_mini memovox
call  Apague_wv_mini metrovox
call  Apague_wv_mini mimevox
call  Apague_wv_mini minigrav
call  Apague_wv_mini minimid
call  Apague_wv_mini miniweb
call  Apague_wv_mini mircvox
call  Apague_wv_mini mistuvox
call  Apague_wv_mini nimvox
call  Apague_wv_mini pacienci
call  Apague_wv_mini palavrox
call  Apague_wv_mini papovox
call  Apague_wv_mini piratvox
call  Apague_wv_mini pontevox
call  Apague_wv_mini pptvox
call  Apague_wv_mini prelista
call  Apague_wv_mini profeta
call  Apague_wv_mini pyvox
call  Apague_wv_mini questvox
call  Apague_wv_mini radio50
call  Apague_wv_mini recado
call  Apague_wv_mini scb
call  Apague_wv_mini senhavox
call  Apague_wv_mini sitiovox
call  Apague_wv_mini sortevox
call  Apague_wv_mini squentin
call  Apague_wv_mini suecavox
call  Apague_wv_mini televox
call  Apague_wv_mini testamic
call  Apague_wv_mini timervox
call  Apague_wv_mini tnetvox
call  Apague_wv_mini twitvox
call  Apague_wv_mini uuvox
call  Apague_wv_mini vidavox
call  Apague_wv_mini voxnews
call  Apague_wv_mini wifivox
call  Apague_wv_mini x3vox
rmdir /S /Q \wv_mini\som\3x3vox

c:\winvox\ttrad Fim do processamento
