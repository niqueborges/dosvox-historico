# Estado da investigação

## Objetivo

Documentar a história, arquitetura, evolução técnica e relevância do DOSVOX para fins de preservação digital e estudo histórico da computação brasileira.

---

## Confirmado

- O DOSVOX nasceu em 1993 na UFRJ.
- Marcelo Pimentel foi o primeiro usuário e colaborador relevante do projeto.
- O primeiro núcleo surgiu a partir do SoleArq, que evoluiu para o EDIVOX.
- O DOSVOX não é apenas um leitor de telas.
- O DOSVOX é um ecossistema de software especializado para pessoas cegas.
- O sistema possui mais de 70 programas distribuídos em módulos independentes.
- O projeto permanece ativo após mais de 30 anos.
- O DOSVOX gerou teses, dissertações, artigos científicos e pesquisas acadêmicas em diversas áreas.
- O projeto teve impacto direto na inclusão digital de milhares de pessoas cegas no Brasil e em países lusófonos.
- O sistema foi distribuído inicialmente em mídia física e posteriormente passou a ser distribuído gratuitamente pela Internet.
- O DOSVOX possui versões completas e versões reduzidas, indicando preocupação histórica com modularidade e distribuição.

---

## Conclusões técnicas já estabelecidas

### Arquitetura modular

Há evidências muito fortes de que o DOSVOX foi estruturado como um conjunto de executáveis independentes.

Exemplos:

- Edivox
- Webvox
- Cartavox
- Televox
- Calcuvox
- Monitvox
- Scriptvox
- Planivox
- Braivox

O menu principal funciona como ponto de entrada para os módulos.

A modularidade explica:

- manutenção por décadas;
- atualização individual de programas;
- instalação parcial do sistema;
- versões completa, reduzida e mini.

---

### Camada própria sobre Windows

O DOSVOX não substitui o Windows.

Ele cria uma camada de interação especializada para usuários cegos.

O usuário permanece no Windows, mas utiliza aplicações construídas segundo os princípios de acessibilidade do projeto.

---

### Conhecimento acumulado é mais valioso que a linguagem

A principal dificuldade para reproduzir o DOSVOX atualmente não parece ser tecnológica.

O obstáculo real é reproduzir:

- décadas de correções;
- conhecimento de acessibilidade;
- convenções de uso consolidadas;
- experiência acumulada da comunidade.

O patrimônio principal do projeto não é apenas o código-fonte.

É o conhecimento incorporado ao código.

---

### Projeto orientado à acessibilidade desde a concepção

O DOSVOX não adapta interfaces visuais tradicionais.

Ele parte de um modelo mental diferente.

Praticamente todos os programas foram concebidos para interação predominantemente por teclado e voz.

---

## Conclusões sobre o código-fonte

### O código-fonte provavelmente existe

É extremamente improvável que um projeto ativo por mais de 30 anos esteja sem código-fonte.

A existência de:

- novas versões;
- correções;
- atualizações individuais;
- novos módulos ao longo dos anos;

indica manutenção contínua.

---

### O código-fonte provavelmente é extenso

As evidências sugerem uma base de código acumulada durante décadas.

O projeto engloba:

- síntese de voz;
- navegação web;
- e-mail;
- edição de texto;
- jogos;
- multimídia;
- automação;
- braille;
- scripts;
- integração com Windows.

---

### O código-fonte provavelmente é heterogêneo

É improvável que todos os componentes tenham sido escritos na mesma linguagem.

O histórico sugere diferentes gerações tecnológicas ao longo dos anos.

---

### O código-fonte não precisa ser reescrito para permanecer útil

Uma reescrita completa provavelmente seria mais arriscada do que uma evolução incremental.

O valor do sistema está na estabilidade e no conhecimento acumulado.

---

## O que deixou de ser dúvida

### "Seria possível recriar o DOSVOX em outra linguagem?"

Resposta:

Sim, tecnicamente.

Mas seria necessário reconstruir décadas de conhecimento, comportamento e compatibilidade.

O desafio principal não é a linguagem.

---

### "A modularidade foi fundamental para a sobrevivência do projeto?"

Resposta:

As evidências apontam fortemente que sim.

A existência de módulos independentes, instalações parciais e atualizações individuais sugere que a modularidade foi um fator importante para a longevidade.

---

## Descobertas Recentes (Instalação C:\winvox)

- **Linguagem Principal:** A presença de pacotes `.bpl` (como `vcl60.bpl`, `rtl70.bpl`) confirma o uso massivo do Borland Delphi (versões 6 e 7) como fundação do sistema.
- **Ecossistema:** O DOSVOX se apoia ativamente em ferramentas _open source_ para processamento pesado: `ffmpeg` (áudio/vídeo), `tesseract` (OCR), `wget` (downloads), etc.
- **Quantidade:** Mapeados dezenas de executáveis cobrindo jogos, editores, leitores, internet e utilitários de sistema.

---

## Ainda em investigação

- Estrutura interna da DVCRT (código fonte e comunicação de baixo nível).
- Como foi a transição inicial (antes do Delphi, na época do DOS real).
- Forma exata de comunicação em tempo real entre módulos (sockets, pipes ou memória compartilhada).
- Processo de build e empacotamento.
- Organização interna das atualizações (`atuvox`).
- Existência de repositório público ou histórico de controle de versão.

---

## Hipótese principal da pesquisa

O DOSVOX deve ser entendido menos como um software único e mais como uma plataforma de acessibilidade construída incrementalmente ao longo de três décadas, composta por dezenas de módulos especializados integrados por uma camada comum de interação baseada em voz e teclado.
