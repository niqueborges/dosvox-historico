# Guia de Preservação Histórica do Dosvox (Visão de 50 Anos)

Se o objetivo é colocar o Dosvox em uma "cápsula do tempo" digital para que pesquisadores da computação e da sociologia o estudem no ano de 2076, nem todos os arquivos têm o mesmo valor. 

Ignorando o tamanho em disco, a preservação deve focar no que torna o sistema **único** na história da Interação Humano-Computador (IHC) e da Acessibilidade.

---

### 1. Essencial para Preservar a Arquitetura (O "DNA" do Sistema)
Estes são os artefatos que, se perdidos, tornariam impossível entender *como* o Dosvox funcionava por debaixo dos panos. Eles contêm a propriedade intelectual inestimável do projeto.

* **Diretório `\Fontes` (Especialmente o núcleo `dvcrt.pas`, `dvwin.pas`, `dvform.pas`):** 
  * *Justificativa:* Eles contêm a lógica genial que fez a ponte entre a velha programação procedimental do DOS e as APIs modernas do Windows. Sem isso, a arquitetura do "Emulador Textual + Buffer de Voz" morre.
* **Algoritmos de Braille e Tradução (`dvtradut.pas`, `blb2txt.exe`):**
  * *Justificativa:* A matemática e as regras gramaticais embutidas ali para converter Português Brasileiro escrito em código Braille (e vice-versa) são um patrimônio da engenharia de acessibilidade brasileira.
* **A Estrutura do `dosvox.ini` (pasta `\iniOriginal`):**
  * *Justificativa:* O arquivo de configuração mestre dita o mapa de atalhos de teclado (a letra "T" abre o Webvox, a letra "J" abre os Jogos). Preservar esse mapa é preservar o paradigma de navegação do usuário cego.

### 2. Importante para Reconstrução Histórica (O "Espírito" e a UX)
Estes arquivos não são o motor do sistema, mas são as vitrines culturais que mostram como a comunidade cega interagia, jogava e aprendia.

* **Diretórios de Treinamento e Manuais (`\Treino`, `\Manual`):**
  * *Justificativa:* Em 50 anos, a forma como os humanos aprendem a usar computadores terá mudado drasticamente. Os tutoriais interativos em áudio e texto do Dosvox mostram o esforço pedagógico pioneiro de ensinar um cego a teclar sem usar um mouse.
* **Identidade Sonora e Sínteses Antigas (`\som`, `\midias` e motor `lianetts`):**
  * *Justificativa:* A "voz" robótica do Dosvox e os efeitos sonoros de interface (como o barulho de máquina de escrever ao teclar, ou os bipes de erro) são icônicos. O *Sound Design* aqui foi fundamental para dar feedback sem depender da visão.
* **O Diretório de Jogos (`\Jogavox`, `\Colossal`):**
  * *Justificativa:* Jogos baseados puramente em áudio, tabuleiro de texto e aventura narrativa (MUD) são peças de museu interativas importantíssimas que provam que o acesso ao lazer sempre andou junto à produtividade.

### 3. Reproduzível por Software de Terceiros (O Músculo Terceirizado)
São vitais para o Dosvox funcionar hoje, mas em termos de preservação histórica, eles são lixo na cápsula do tempo, pois os pesquisadores do futuro já terão acesso a isso em repositórios globais da internet.

* **Binários de Terceiros e DLLs C/C++ (`ffmpeg.exe`, `tesseract.exe`, `bass.dll`, `sqlite3.dll`, `libeay32.dll`):**
  * *Justificativa:* O Tesseract é do Google/HP, o FFMpeg e o OpenSSL são bibliotecas mundiais de código aberto. A história preservará essas tecnologias independentemente do Dosvox.
* **Type Libraries da Microsoft SAPI (`SpeechLib_TLB.pas`):**
  * *Justificativa:* Pertencem à história do Windows e da Microsoft, não à engenharia local da UFRJ.
* **Projetos Open-Source Acoplados (Ex: pasta `\Fontes\tradutor\synapse`, `yt-dlp`):**
  * *Justificativa:* São módulos de terceiros (Python ou componentes Delphi) que o Dosvox apenas "tomou emprestado" para acessar a internet ou lidar com sockets. 

### 4. Dados do Usuário e Arquivos Descartáveis (O Ruído)
Coisas que devem ser jogadas fora (ou tratadas com anonimização/purga) antes de congelar o sistema em um repositório de museu computacional.

* **Pastas de Usuário (`\Agenda`, `\fichario`, `\recados`, `\Lixeira`):**
  * *Justificativa:* Contêm dados pessoais voláteis de quem operava a máquina (neste caso, a unidade C: local). Não compõem a arquitetura de software, sendo apenas os bancos de dados criados em tempo de execução.
* **Sobejos de Compilação (`~pas`, `.old`, `.bak`, `.tmp`, pastas de cache como `\midias\cache`):**
  * *Justificativa:* São apenas lixo gerado pelos IDEs (Delphi/Python) ou arquivos temporários de internet. Não possuem valor arquitetônico ou de UX.
