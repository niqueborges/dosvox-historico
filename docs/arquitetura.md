# Arquitetura Comprovada

Inicialmente, tínhamos a hipótese de que o DOSVOX não era um programa único. O inventário da instalação do DOSVOX (`C:\winvox`) comprovou essa teoria. O DOSVOX é um orquestrador, um ecossistema de dezenas de aplicações construídas sobre bibliotecas compartilhadas e motores externos.

## Núcleo e Linguagem

A análise de pacotes e dependências (arquivos `.bpl`) atestou que a espinha dorsal gráfica e operacional foi desenvolvida principalmente em **Borland Delphi** (especificamente evidências apontam para as versões 6 e 7 através dos pacotes `vcl60.bpl` e `vcl70.bpl`).

O motor principal que conecta o usuário aos programas é o `dosvox.exe`.

## Bibliotecas Compartilhadas (Delphi)

- DvCrt
- DvWin
- DvForm
- DvWav
- DvHora
- DvExec
- DvString

## Integrações de Terceiros

Para evitar "reinventar a roda" em problemas complexos de software, a arquitetura orquestra, em _background_, utilitários consagrados do mundo de TI e código aberto, filtrando a saída visual em voz:
- **Áudio/Vídeo:** `ffmpeg.exe`, `ffplay.exe`, `lame.exe`
- **Reconhecimento Óptico (OCR):** `tesseract-ocr`
- **Internet:** `wget.exe`, `psftp.exe`
- **Banco de Dados:** `sqlite3.dll`
- **Leitura de PDF:** `pdftotext.exe`

## Aplicações identificadas

- Edivox
- Webvox
- Traduvox
- Agenda
- Calculvox
- Forcavox
- Televox
- Midiavox
- Voxnews
- Voxtube