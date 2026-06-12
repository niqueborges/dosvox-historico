chcp 65001

REM     Exclui arquivos e pastas de \wv para deixar preparado para gerar o setup da vers�o reduzida do Dosvox
REM Por Neno Albernaz
REM     Em 04/04/2025

REM Pastas excluidas de \wv para gerar a versao reduzida do Dosvox:

rmdir /S /Q \wv\Jogavox
rmdir /S /Q \wv\Manual\audios
rmdir /S /Q \wv\midias

REM Pastas e arquivos excluidos de \wv\Treino

rmdir /S /Q "\wv\Treino\Notícias"
rmdir /S /Q "\wv\Treino\Piadas"
rmdir /S /Q "\wv\Treino\Poemas"
rmdir /S /Q "\wv\Treino\Receitas culinárias"
rmdir /S /Q "\wv\Treino\Tecnologia e aprendizagem"
rmdir /S /Q "\wv\Treino\Vozes noturnas"

erase "\wv\treino\5 Lições para a Vida.txt" /F /Q
erase "\wv\treino\acróstico do dosvox de Neise cavini - por Vitor Alberto.mp3" /F /Q
erase "\wv\treino\20 Dicas a quem queira ajudar um deficiente visual.txt" /F /Q
erase "\wv\treino\características e limitações das pessoas com deficiência.txt" /F /Q
erase "\wv\treino\Desejo Ardente.txt" /F /Q
erase "\wv\treino\Funk do Dosvox.mp3" /F /Q
erase "\wv\treino\Imaputil.txt" /F /Q
erase "\wv\treino\Letras dos Beatles.txt" /F /Q
erase "\wv\treino\Lixo - Luis Fernando Veríssimo.txt" /F /Q
erase "\wv\treino\Noturno.mid" /F /Q
erase "\wv\treino\Peripécias de Pedro Paulo - Tudo em P.txt" /F /Q

REM Arquivo excluido de \wv_exter\Instaladores

erase \wv_exter\Instaladores\K-Lite_Codec_Pack_*.exe /F /Q

mdir \wv\Jogavox

call wv_Limpa.bat
