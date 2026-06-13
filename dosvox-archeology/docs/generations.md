# As Gerações do Código-Fonte do DOSVOX

A estratificação do DOSVOX se revela nas datas e cabeçalhos encontrados nos arquivos principais da infraestrutura. A suspeita de que o sistema **"quase nunca foi reescrito, apenas sedimentado"** é confirmada pela presença simultânea de camadas de diferentes décadas rodando juntas no mesmo executável.

Podemos dividir a evolução do sistema nestas gerações observadas:

## Geração 0 (1987)
- **Foco:** Algoritmos fonéticos e de tradução.
- **Evidência:** O cabeçalho de `dvtradut.pas` indica "Data de criação: Julho de 1987". Um artefato que antecede o próprio DOSVOX.

## Geração 1 (1994)
- **Foco:** DOSVOX original (Ambiente DOS).
- **Evidência:** Arquivos antigos em Turbo Pascal puro e a adaptação do `dvtradut.pas` para o DOSVOX por J. A. Borges em 1994.

## Geração 2 (1998)
- **Foco:** Migração para Windows e orquestração base.
- **Evidência:** Criação da `dvwin.pas` em Jan/1998. Início do modelo de abstração WinAPI/SAPI.

## Geração 3 (2001)
- **Foco:** Biblioteca de componentes e formulários dinâmicos.
- **Evidência:** `dvform.pas` (Agosto de 2001) encapsulando lógica de menus, edição de campos com voz e interface padronizada.

## Geração 4 (2005–2012)
- **Foco:** Internet, Office, SAPI e Multimídia avançada.
- **Evidência:** Adoção de clientes FTP, integração com e-mail estruturado e APIs de voz modernas da Microsoft (SAPI4/5).

## Geração 5 (2012–Presente)
- **Foco:** Unicode, OCR, Python, HTTPS e adaptação à web moderna.
- **Evidência:** Incorporação explícita de `yt-dlp`, `Tesseract`, `ffmpeg`, Python (`pyvox`) e bibliotecas como `Synapse` atualizadas para lidar com APIs REST.

A linha do tempo no código é a prova de que a "cidade antiga" do DOSVOX construiu por cima das fundações de 1987 sem nunca precisar destruí-las.
