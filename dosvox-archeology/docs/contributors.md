# Arqueologia Sociotécnica: Genealogia dos Autores

O código do DOSVOX não é o resultado do trabalho isolado de uma única pessoa, mas sim o produto de um "Mutirão". Entender o software exige entender a rede de atores que o moldaram em diferentes períodos.

Esta genealogia mapeia as contribuições sociais e técnicas ao longo das eras:

## Antonio Borges (O Idealizador e Arquiteto)
- **Papel:** Professor da UFRJ, idealizador do projeto e orquestrador do ecossistema.
- **Contribuições Técnicas:** Desenvolveu o conversor R-2R inicial para produzir som de baixo custo. Escreveu o primeiro tradutor fonético (G0 - 1987), que formaria a fundação da voz sintética, além do gerenciador base e do `SoleArq`. Foi o arquiteto do "Kernel 77".

## Marcelo Pimentel (O Paciente Zero e Co-criador)
- **Papel:** Aluno cego de informática da UFRJ (1993).
- **Contribuições Técnicas:** Sua necessidade impulsionou o projeto. Testou, ajudou a conceber o modelo interativo sem tela e validou as primeiras ferramentas (como o `SoleArq` e a estrutura que daria origem ao `Edivox`). O fluxo de experiência do usuário nasceu para atendê-lo.

## Diogo Fujio Takano (A Engenharia Física)
- **Papel:** Engenheiro do NCE.
- **Contribuições Técnicas:** Transformou o protótipo inicial (uma "aranha" de fios perigosa montada por Antonio) em um hardware confiável, adicionando eletrônica de segurança e amplificação para tornar o sintetizador R-2R viável no uso diário.

## Orlando José Rodrigues Alves
- **Papel:** Programador avançado do NCE (In memoriam).
- **Contribuições Técnicas:** Trouxe sofisticação ao sistema primitivo com a criação do programa `Vox`. Desenvolveu complexas rotinas em Assembly para criar a funcionalidade de "leitor de telas" residente via interrupção (ALT+ESC), permitindo que Marcelo finalmente lesse o compilador MS-DOS.

## O "Mutirão Vox" (A Explosão do Ecossistema)
- **Papel:** Alunos de computação gráfica e desenvolvedores voluntários.
- **Contribuições Técnicas:** Foram a força motriz que transformou um mero leitor de telas em uma plataforma. Foram responsáveis pela "sedimentação" arquitetural: em vez de alterar o núcleo, empilharam centenas de pequenos programas especialistas. Desenvolveram versões de jogos ancestrais e utilitários de comunicação (`Televox`).

## Luiz Cândido Pereira Castro & Katia (A Distribuição e Suporte)
- **Papel:** Usuários iniciais que se tornaram distribuidores logísticos e suporte.
- **Contribuições:** Embora não atrelados diretamente ao desenvolvimento do `Kernel`, a operação deles permitiu que o DOSVOX saísse do NCE e atingisse milhares de máquinas no Brasil através da replicação de disquetes, o que consolidou a base de usuários e guiou as futuras atualizações.
