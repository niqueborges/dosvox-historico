unit mtMsg;
interface

uses dvWin, dvCrt;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';

    if nomeArq = 'MTINIC' then
        s:= 'METRONOMO VOX - V. 1.0'
    else
    if nomeArq = 'MTCONFIM' then
        s:= 'Confirma o fim do programa ? '
    else
    if nomeArq = 'MTFIM' then
        s:= 'Fim do programa'
    else
    if nomeArq = 'MTOPTEC' then
        s:= 'Opções nas teclas : '
    else
    if nomeArq = 'MTF1' then
        s:= 'F1, ajuda'
    else
    if nomeArq = 'MTF2' then
        s:= 'F2, grava modelo'
    else
    if nomeArq = 'MTF4' then
        s:= 'F4, informa diapasão'
    else
    if nomeArq = 'MTF6' then
        s:= 'F6, informa novo valor'
    else
    if nomeArq = 'MTF8' then
        s:= 'F8, informa hora'
    else
    if nomeArq = 'MTF9' then
        s:= 'F9, informa novos efeitos'
    else
    if nomeArq = 'MTCTLF9' then
        s:= 'Control F9, modelos pré-definidos'
    else
        if nomeArq = 'MTBARR1' then
        s:= 'Barra de espaço, informa valor BPM atual'
    else
    if nomeArq = 'MTSET' then
        s:= 'Setas, cima e baixo, acresce ou decresce valor em 1 BPM'
    else
    if nomeArq = 'MTPG' then
        s:= 'PGUP ou PGDOWN, acresce ou decresce valor em 10 BPM'
    else
    if nomeArq = 'MTESC1' then
        s:= 'ESC, termina o programa'
    else
    if nomeArq = 'MTQUAL' then
        s:= 'Qual sua opção ? '
    else
    if nomeArq = 'MTA' then
        s:= 'A -- nota LA'
    else
    if nomeArq = 'MTB' then
        s:= 'B -- nota SI'
    else
    if nomeArq = 'MTD' then
        s:= 'D -- nota RÉ'
    else
    if nomeArq = 'MTE' then
        s:= 'E -- nota MI'
    else
    if nomeArq = 'MTG' then
        s:= 'G -- nota SOL'
    else
    if nomeArq = 'MTX' then
        s:= 'X -- nota MI (oitavada)'
    else
    if nomeArq = 'MTM' then
        s:= 'M -- acorde MI maior'
    else
    if nomeArq = 'MTS' then
        s:= 'S -- acorde SOL maior'
    else
    if nomeArq = 'MTBARR2' then
        s:= 'Barra de espaço -- todas as cordas'
    else
    if nomeArq = 'MTR' then
        s:= 'R -- ativa ação repetida'
    else
    if nomeArq = 'MTESC2' then
        s:= 'ESC, retorna ao metrônomo'
    else
    if nomeArq = 'MTINFNOT' then
        s:= 'Informe a nota desejada, F1 ajuda : '
    else
    if nomeArq = 'MTINFBPM' then
        s:= 'Informe BPM, sugiro 60 : '
    else
    if nomeArq = 'MTINFCOM' then
        s:= 'Informe unidade de compasso'
    else
    if nomeArq = 'MTINFBTQ' then
        s:= 'Pressione : B - binário / T - ternário / Q - Quaternário'
    else
    if nomeArq = 'MTOKF1' then
        s:= 'OK, F1 ajuda'
    else
    if nomeArq = 'MTARQINE' then
        s:= 'Arquivo que contém os efeitos não existe'
    else
    if nomeArq = 'MTESCSET' then
        s:= 'Escolha com as setas, F1 ajuda'
    else
    if nomeArq = 'MTTRTM' then
        s:= 'Informe o novo efeito para a marcação do tempo : '
    else
    if nomeArq = 'MTTRCO' then
        s:= 'Informe o novo efeito para a marcação do compasso : '
    else
    if nomeArq = 'MTTRMO' then
        s:= 'Informe o novo modelo : '
    else
    if nomeArq = 'MTENV1' then
        s:= 'F5, busca efeito'
    else
    if nomeArq = 'MTENV2' then
        s:= 'CTRL+F5, busca de novo'
    else
    if nomeArq = 'MTENV3' then
        s:= 'PGUP, anda 5 na fila'
    else
    if nomeArq = 'MTENV4' then
        s:= 'PGDN, volta 5 na fila'
    else
    if nomeArq = 'MTENV5' then
        s:= 'HOME, vai para o início da fila'
    else
    if nomeArq = 'MTENV6' then
        s:= 'END, vai para o final da fila'
    else
    if nomeArq = 'MTENV7' then
        s:= 'CTRL+ENTER, testa o som a ser tocado'
    else
    if nomeArq = 'MTNAOINI' then
        s:= 'Não consta arquivo com essa inicial'
    else
    if nomeArq = 'MTBUSEFE' then
        s:= 'Digite uma letra : '
    else
    if nomeArq = 'MTAPTF1' then
        s:= 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'MTVALBPM' then
        s:= 'Valor BPM = '
    else
    if nomeArq = 'MTPAUATI' then
        s:= ' -- PAUSE ATIVADA'
    else
    if nomeArq = 'MTPAUDES' then
        s:= ' -- PAUSE DESATIVADA'
    else
    if nomeArq = 'MTASSPAD' then
        s:= 'Deseja assumir esse modelo como padrão ? '
    else
    if nomeArq = 'MTDESIST' then
        s:= 'Desistiu'
    else
    if nomeArq = 'MODPAD' then
        s:= 'OK, assumido'
    else
    if nomeArq = 'MTRETOR' then
        s:= 'OK, retornando ao metrônomo'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
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
