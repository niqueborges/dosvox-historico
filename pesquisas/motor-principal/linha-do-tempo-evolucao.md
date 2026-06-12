# Linha do Tempo e Evolução Tecnológica do Dosvox

Fiz uma varredura profunda no código-fonte (`.pas` e `.dpr`) em busca de padrões de linguagem, APIs específicas e bibliotecas que "denunciam" a época em que os módulos foram escritos. Aqui estão os achados e a reconstrução da linha do tempo evolutiva do sistema.

## Evidências Encontradas no Código

* **Código Turbo Pascal Herdado:** Encontrei **243 arquivos** que ainda utilizam o estilo de programação puramente procedural (sem declaração de `class`) e fazem manipulação de arquivos do jeito antigo do DOS (`Assign()`, `Reset()`, `Rewrite()`, `Close()`). Exemplos: `agFolhei.pas`, `GRAMOST.PAS`.
* **Código Delphi Clássico (Win32 API):** A vasta maioria das aplicações usa as diretivas clássicas de pacotes. Pelo menos **40 arquivos** fazem chamadas hard-coded à WinAPI (como `ShellExecute` e `CreateProcess` no `dosdir.pas` e `dosvox.dpr`).
* **Unicode / UTF-8:** Encontrei **39 arquivos** fazendo malabarismos com `WideString`, `UTF8Encode` e `UTF8Decode` (ex: `edEpub.pas`, `dosImgToTxt.pas`), indicando os desafios de processar textos web modernos e ePubs em compiladores Delphi mais antigos (provavelmente antes do Delphi 2009, que nativizou o Unicode).
* **Integração COM (Component Object Model):** Presente em **25 arquivos**. O uso de `ComObj` e `CreateOleObject` (ex: `edDoc.pas`, `pptfala.dpr`) prova como o sistema automatizou o Word e o PowerPoint "invisivelmente".
* **SAPI (Speech API da Microsoft):** Type Libraries importadas (`SpeechLib54_TLB.pas`) revelam a adaptação às vozes mais comerciais.
* **Integração OCR:** Os arquivos `dosconvert.pas` e `dosImgToTxt.pas` contêm chamadas diretas que invocam o **Tesseract**, para transformar imagens contendo texto em conteúdo falado.
* **Integração com Python:** O código fonte de **10 arquivos** (como `pyLocal.pas` e `mireprod.pas`) interage diretamente com scripts `.py` ou invoca utilitários empacotados em Python (como o famoso `yt-dlp` para baixar vídeos do YouTube na reprodução multimídia).
* **Componentes de Terceiros (Open-source):** O sistema substituiu antigos sockets próprios pela suíte **Synapse** (em 33 arquivos, como `blcksock.pas`, `ftpsend.pas`) para garantir conexões seguras por internet, e o motor **BASS** (`bass.pas`) para áudio multicanal.

---

## Reconstrução da Linha do Tempo Evolutiva

Ao observar essas camadas tectônicas de código, é possível reconstruir as eras de desenvolvimento da arquitetura do Dosvox:

### 1. A Era Fundamental (Anos 90) - *Turbo Pascal & MS-DOS*
* **Características:** O código nasceu no MS-DOS. Os programas baseados em `Assign/Reset` e loops textuais puros vêm dessa época.
* **Sobreviventes:** Lógica de mini-jogos, manipuladores de agenda antigos e processadores de formulário simples. Eles foram "transportados" para o Windows intactos graças à emulação visual que analisamos anteriormente (`dvcrt.pas`).

### 2. A Era de Migração (Anos 2000 - 2005) - *Delphi & Win32*
* **Características:** O sistema migra forçadamente para o Windows. Nasce a interface que conhecemos hoje. 
* **Componentes Chave:** Adoção pesada do Delphi 6 e Delphi 7. O sistema começa a gerenciar janelas reais do Windows, cria ponteiros para `ShellExecute` (para abrir outros programas) e foca na robustez das mensagens do SO (`messages.pas`).

### 3. A Era da Comunicação & Multimídia (2005 - 2012) - *Terceiros e COM*
* **Características:** Os usuários cegos precisavam usar a Web rica, abrir e-mails e anexos complexos (MP3, Word).
* **Componentes Chave:** O Dosvox passa a "hackear" o Microsoft Office injetando scripts **COM/OLE** para extrair texto de .doc e .ppt. A internet se expande no código usando a biblioteca **Synapse** (TCP/IP e e-mail). Surge o suporte ao **SAPI** para abandonar vozes robóticas antigas e utilizar vozes fluentes instaladas no Windows.

### 4. A Era da Modernização e IA (2012 - Presente) - *Python, OCR e Unicode*
* **Características:** A internet muda para HTTPS, os textos passam a ter emojis/Unicode (UTF-8), as páginas web se tornam inavegáveis apenas por texto simples, e os usuários precisam ler PDFs baseados em imagem.
* **Componentes Chave:** Os desenvolvedores injetam adaptadores **Unicode** no código legado para não quebrar a acentuação. Ao invés de escrever tudo em Pascal, eles passam a funcionar como "Maestros" orquestrando tecnologias de ponta em background:
  - Disparam o **Tesseract (OCR)** para ler imagens e PDFs que eram inacessíveis.
  - Invocam scripts **Python** e o `yt-dlp` para conseguir reproduzir YouTube e trabalhar com lógicas de matemática falada de forma inteligente.
