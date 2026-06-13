unit sumsg;

interface
uses dvcrt, dvwin, suvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

const
    CRLF = #$0d + #$0a;
    
{--------------------------------------------------------}
{              descobre o texto da mensagem              }
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'GONG' then
        s := ''
    else
    if nomeArq = 'SUINIC' then
        s := 'Benvindo ao jogo de Sudoku VOX, versão '
    else
    if nomeArq = 'SUDESEJA' then
        s := 'Deseja Instruções? '
    else
    if nomeArq = 'SUINSTR1' then
        s := 'Sudoku é o quebra-cabeça mais popular do mundo atual.' + CRLF +
             CRLF +
             'O jogo consta de um quadrado com 9 por 9 células.' + CRLF +
             'Cada célula receberá um número de 1 a 9.' + CRLF +
             CRLF +
             'O quadrado, por sua vez, é dividido em nove áreas de 3 por 3,' + CRLF +
             'denominadas grelhas.' + CRLF +
             CRLF +
             'Quando o jogo começa, algumas células já estão preenchidas com números' + CRLF +
             '(chamados de pistas).' + CRLF +
             CRLF +
             'O objetivo do jogo é preencher todas as outras células com números de 1 a 9,' + CRLF +
             'obedecendo só a três regras básicas.' + CRLF +
             CRLF +
             'Numa linha não podem existir números repetidos.' + CRLF +
             'Numa coluna também não.' + CRLF +
             'Numa grelha também não.' + CRLF +
             CRLF
    else
    if nomeArq = 'SUINSTR2' then
        s := 'Use as setas para andar pelas células, e o computador falará seu conteúdo.' + CRLF +
             CRLF +
             'Se a célula for uma pista (que você não pode mudar) será emitido um bip' + CRLF +
             CRLF +
             'Home e end vão para o início ou fim da linha.' + CRLF +
             'Page Up e Page down vão para a primeira e última linha.' + CRLF +
             CRLF +
             'Aperte L para ler a linha do cursor, C para coluna tecle ou G para grelha.' + CRLF +
             'Para preencher uma célula, tecle o número desejado.  Para apagar, espaço.' + CRLF +
             CRLF +
             'Se você é bem experiente (ou tem a mente privilegiada)' + CRLF +
             'não precisará usar mais comandos.' + CRLF +
             'Mas se você ainda está aprendendo a jogar, há muitas facilidades adicionais,' + CRLF +
             'que você pode conhecer através de um menu acionado por F9.' + CRLF + CRLF
    else
    if nomeArq = 'SUAPTENT' then
        s := 'Aperte enter para continuar...'
    else
    if nomeArq = 'SUAPF1' then
        s := 'Aperte F1 para ler manual'
    else
    if nomeArq = 'SUAPF9' then
        s := 'F9 para opções'
    else
    if nomeArq = 'SUJOGINI' then
        s := 'Jogo iniciado'
    else
    if nomeArq = 'SUCONFLI' then
        s := 'Conflitos '
    else
    if nomeArq = 'SUNALIN' then
        s := 'linha '
    else
    if nomeArq = 'SUNACOL' then
        s := 'coluna '
    else
    if nomeArq = 'SUNAGREL' then
        s := 'grelha'
    else
    if nomeArq = 'SUNAOPOS' then
        s := 'Não posso alterar pistas'
    else
    if nomeArq = 'SUSALVO' then
        s := 'Arquivo gravado'
    else
    if nomeArq = 'SUERRGRV' then
        s := 'Erro de gravação'
    else
    if nomeArq = 'SUARQNAO' then
        s := 'Arquivo com o jogo não existe'
    else
    if nomeArq = 'SUFIM' then
        s := 'Fim do jogo Sudovox'
    else
    if nomeArq = 'SUFALTA' then
        s := 'Falta '
    else
    if nomeArq = 'SUNADA' then
        s := 'Nada'
    else
    if nomeArq = 'SUPOSICI' then
        s := 'Posicionei no ponto fácil'
    else
    if nomeArq = 'SULIN' then
        s := 'linha '
    else
    if nomeArq = 'SUCOL' then
        s := ' coluna '
    else
    if nomeArq = 'SUARQFIN' then
        s := 'Arquivo com a solução final'
    else
    if nomeArq = 'SUTEMPO' then
        s := 'Tempo gasto: '
    else
    if nomeArq = 'SUABAND' then
        s := 'Quer abandonar o jogo? '
    else
    if nomeArq = 'SUDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'SUQUERZE' then
        s := 'Quer zerar o que entrou? '
    else
    if nomeArq = 'SUQUERCA' then
        s := 'Quer mesmo que eu calcule? '
    else
    if nomeArq = 'SUPARABE' then
        s := 'Parabéns, desafio completado!'
    else
    if nomeArq = 'SUFOGOS' then
        s := '*** Fogos de artifício! ***'
    else
    if nomeArq = 'SUNUMBUS' then
        s := 'Número a buscar  '
    else
    if nomeArq = 'SUFIMTAB' then
        s := 'Fim do tabuleiro'
    else
    if nomeArq = 'SUCELVAZ' then
        s := ' células vazias'
    else
    if nomeArq = 'SUOCORRE' then
        s := ' em '
    else
    if nomeArq = 'SUNIVEL' then
        s := 'Qual o nível: fácil, médio ou difícil? '
    else
    if nomeArq = 'SUESCSET' then
        s := 'Escolha com as setas o sudoku desejado'
    else
    if nomeArq = 'SUQUERCT' then
        s := 'Quer continuar jogo anteriormente iniciado? '
    else
    if nomeArq = 'SUIMPOSS' then
        s := 'Dados levam a impossibilidade.'

    else
    if nomeArq = 'SUFUN_L' then
        s := 'L - falta na linha'
    else
    if nomeArq = 'SUFUN_C' then
        s := 'C - falta na coluna'
    else
    if nomeArq = 'SUFUN_G' then
        s := 'G - falta na grelha'
    else
    if nomeArq = 'SUFUN_F' then
        s := 'F - falta aqui'
    else
    if nomeArq = 'SUFUN_A' then
        s := 'A - auto escolha (preguiçosos)'
    else
    if nomeArq = 'SUFUN_I' then
        s := 'I - informa cursor'
    else
    if nomeArq = 'SUFUN_T' then
        s := 'T - informa tempo'
    else
    if nomeArq = 'SUFUN_E' then
        s := 'E - estatística'
    else
    if nomeArq = 'SUFUN_Z' then
        s := 'Z - zera o Sudoku'
    else
    if nomeArq = 'SUFUN_DL' then
        s := '$ - calcula a solução'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem                     }
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

end.

