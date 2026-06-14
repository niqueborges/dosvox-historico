# O Modelo de Distribuição do DOSVOX (Taxonomia Nativa)

A análise da página oficial de downloads do DOSVOX 6.3 revela uma "documentação em forma de instaladores". Em vez de inferirmos a taxonomia apenas pelo código-fonte, podemos observar o que os próprios mantenedores consideravam essencial, acessório ou obsoleto através do empacotamento.

## 1. O Núcleo Operacional Mínimo (Completo ∩ Mini)
**Evidência:** 
A versão "DOSVOX 6.3 Mini" remove a vasta maioria dos aplicativos (Jogavox, mídias, etc.), mas preserva intencionalmente 3 jogos ("Jogo da Forca", "Desafio do Barão" e "Sudovox") e promete atender a "quem usa recursos básicos do sistema".

**Inferência:**
Este conjunto responde à pergunta: *"Do que um usuário básico precisa?"* O núcleo do sistema para o usuário final inclui o editor básico (`Edivox`/`Minied`), o shell de navegação e os mecanismos de síntese de voz nativa. 

**Hipótese Histórica:**
O instalador Mini é a definição dos autores sobre o **Núcleo Operacional Mínimo**, mas não necessariamente o **Núcleo Arquitetural** estrito de compilação. Os 3 jogos preservados provavelmente têm um valor pedagógico profundo (ex: o Sudovox para treinamento de malha numérica tátil, a Forca para ortografia), ou possuem amarras históricas tão grandes que não poderiam ser removidos.

## 1.5 A Zona Cinzenta (Reduzido - Mini)
**Evidência:**
Existe uma versão "Reduzida" que é menor que a "Completa", mas maior que a "Mini".

**Hipótese Histórica:**
Este delta revelará programas considerados importantes, mas não essenciais de sobrevivência. É provável que ferramentas ricas de acessibilidade que consomem muito espaço ou que foram desenvolvidas mais tardiamente residam aqui.
## 2. Conteúdo Removido (Acessórios e Peso)
**Evidência:**
As versões Reduzida e Mini explicitamente excluem:
- `Jogavox` e a maioria dos jogos.
- Pastas de áudio dos manuais, "mídias" e "músicas".
- 99% da pasta "Treino".
- Instalador do `K-Lite Codec Pack`.

**Inferência:**
Esses elementos representam a "gordura" do monólito. São acessórios valiosos para a experiência final, mas não estruturais para a arquitetura de acessibilidade.

## 3. Componentes Sob Demanda (Atualizações e Downloads)
**Evidência:**
A página instrui: *"Como esta versão não possui o programa jogavox, deverá ser baixado primeiro, usando a opção C A P jogavox."* e *"Os programas podem ser atualizados individualmente pela opção C A P ou C A V."*

**Inferência:**
O DOSVOX possui uma arquitetura de atualização em camadas. O sistema não era estático; ele implementava um "gerenciador de pacotes" interno (`C A P` / `C A V`) que permitia puxar programas e jogos da internet de forma modular.

## 4. O Ecossistema Externo (Third-Party)
**Evidência:**
Os motores SAPI 3, 4 e 5, além de sintetizadores profissionais como *DeltaTalk*, *Letícia F123*, *RealSpeak Raquel* e *Ivona*, são tratados em uma seção separada de "módulos de síntese de fala compatíveis" e exigem downloads e instaladores à parte.

**Inferência:**
Os autores sempre trataram a "Voz de Alta Qualidade" como um plugin externo (`Third-Party`). A base do sistema é desacoplada e independente dessas empresas, garantindo que se a empresa falir, o DOSVOX apenas pluga outro motor através da interface SAPI.

## 5. A Ruína Antiga (Geração 0)
**Evidência:**
A "Versão MS-DOS 1.6" é listada como **"obsoleta"**, ocupando 22.5 MB, requerendo emuladores modernos como o DOSBOX e dependendo explicitamente de configuração *SoundBlaster* nativa.

**Hipótese:**
Esta versão não é apenas um "commit antigo", é um Sítio Arqueológico totalmente separado que representa o DNA purista das Gerações 0 e 1, antes da abstração do `dvcrt` para Windows em 1998. Deve ser estudada em um repositório histórico isolado (`dosvox-msdos-history`).
