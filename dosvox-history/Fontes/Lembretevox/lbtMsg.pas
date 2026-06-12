{--------------------------------------------------------}
{       Mensagens do programa.
{--------------------------------------------------------}

unit lbtMsg;
interface

uses
    windows, dvcrt, dvWin, dvLenum, sysutils,
    lbtVars;

function centralizaFrase (frase: string): string;
function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure msgBaixo (nomeArq: string);
procedure soletra(s: string; nlf: integer);
procedure inicFala;
procedure limpaBaixo (y: integer);
function pegaDirDosvox: string;

implementation

var
    dirSons: string;

{-------------------------------------------------------------}

function centralizaFrase (frase: string): string;
var t, i: integer;
begin
    frase := trim (frase);
    t := length (frase);
    if t < 80 then
        begin
            t := (80 - t) div 2;
            for i := 1 to t do frase := ' ' + frase;
            while length (frase) < 80 do frase := frase + ' ';
        end;

    result := frase;
end;

{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin

    if      nomeArq = 'LBTSISTOP'       then s := 'Lembretevox - Gerenciador de lembretes diários'
    else if nomeArq = 'LBTVERSAO'       then s := ' - Versão '
    else if nomeArq = 'LBTOQDESE'       then s := 'Lembretevox, o que deseja?'
    else if nomeArq = 'LBTUSESETA'       then s := 'Use as setas para conhecer as opções.'
    else if nomeArq = 'LBTHJDIADE'      then s := 'Hoje é dia de'
    else if nomeArq = 'LBTFALTA'        then s := 'Falta '
    else if nomeArq = 'LBTFALTAM'       then s := 'Faltam '
    else if nomeArq = 'LBTDIAPA'        then s := 'dia para'
    else if nomeArq = 'LBTDIASPA'       then s := 'dias para'
    else if nomeArq = 'LEMBRETES'       then s := 'Lembretes'
    else if nomeArq = 'LBTLISLEMB'      then s := 'Listagem de lembretes'
    else if nomeArq = 'LBTUMMOMENTO'    then s := 'Um momento ...'
    else if nomeArq = 'LBTAJUDA_SELEC'  then s := 'Selecione com as setas e tecle opção (ou F9 para menu).'
    else if nomeArq = 'LBTAJNOF9'       then s := 'Tecle F9 para listar as opções.'
    else if nomeArq = 'LBTCONFIG'       then s := 'Lembretevox - Configuração'
    else if nomeArq = 'LBTEDITCONF'       then s := 'Editore as configurações, ao finalizar tecle ESC'
    else if nomeArq = 'LBTOK'           then s := 'Ok ! '
    else if nomeArq = 'LBTSELECS'       then s := 'selecionados'
    else if nomeArq = 'LBTSELEC'        then s := 'selecionado'
    else if nomeArq = 'LBTDE'       then s := 'de'
    else if nomeArq = 'LBTOPCINV'       then s := 'Opção inválida.'
    else if nomeArq = 'LBTDESAPLE'      then s := 'Deseja apagar o lembrete (S/N)? '
    else if nomeArq = 'LBTSIMNAO'       then s := ' (S/N)? '
    else if nomeArq = 'LBTDESIST'       then s := 'Desistiu'
    else if nomeArq = 'LBTQUATXT'       then s := 'Qual o texto?'
    else if nomeArq = 'LBTACHEI'        then s := 'Achei'
    else if nomeArq = 'LBTNACHEI'       then s := 'Não Achei'

    // Ajuda principal do Lembretevox.
    else if nomeArq = 'LBTAJGERF'       then s := '  F   - falar lembretes'
    else if nomeArq = 'LBTAJGERL'       then s := '  L   - listar lembretes'
    else if nomeArq = 'LBTAJGERI'       then s := '  I   - inserir lembrete'
    else if nomeArq = 'LBTAJGERC'       then s := '  C   - configurar'
    else if nomeArq = 'LBTAJGERESC'     then s := '  ESC - terminar'

    // Ajuda de listar lembretes.
    else if nomeArq = 'LBTAJLIS1'       then s := '                 I        - inserir lembrete'
    else if nomeArq = 'LBTAJLIS2'       then s := '                 A        - apagar'
    else if nomeArq = 'LBTAJLIS3'       then s := '                 E        - editar'
    else if nomeArq = 'LBTAJLIS4'       then s := '                 S        - falar dia'
    else if nomeArq = 'LBTAJLIS5'       then s := '            L ou Enter    - falar lembretes'
    else if nomeArq = 'LBTAJLIS6'       then s := '                 Q        - falar quantos'
    else if nomeArq = 'LBTAJLIS7'       then s := '                 Direita  - falar lembrete'
    else if nomeArq = 'LBTAJLIS8'       then s := '          Ctrl + Direita  - soletrar lembrete'
    else if nomeArq = 'LBTAJLIS9'       then s := '                 Esquerda - falar data lembrete'
    else if nomeArq = 'LBTAJLIS10'      then s := '          Ctrl + C        - copiar lembrete'
    else if nomeArq = 'LBTAJLIS11'      then s := '  Ctrl + Shift + C        - copiar lembrete e data'
    else if nomeArq = 'LBTAJLIS12'      then s := '                 F4       - configurar'
    else if nomeArq = 'LBTAJLIS13'      then s := '                 F5       - buscar'
    else if nomeArq = 'LBTAJLIS14'      then s := '                 Ctrl + F5- repetir busca'
    else if nomeArq = 'LBTAJLIS15'      then s := '                 F6       - recarregar lista'

    //  Mensagens das configurações.
    else if nomeArq = 'LBTFALALEMB'     then s := 'Falar lembrete'
    else if nomeArq = 'LBTARQLEMB'      then s := 'Arquivo do lembrete'
    else if nomeArq = 'LBTQTDDIAS'      then s := 'Quantidade de dias'
    else if nomeArq = 'LBTORDEMINV'     then s := 'Falar na ordem inversa'
    else if nomeArq = 'LBTQTDLEMB'      then s := 'Lembretes diários'
    else if nomeArq = 'LBTSONELE'       then s := 'Sonorizar entre lembretes'
    else if nomeArq = 'LBTTEMPLE'       then s := 'Tempo entre lembretes'
    else if nomeArq = 'LBTFALASEMA'     then s := 'Falar dia da semana'
    else if nomeArq = 'LBTTPORDLE'      then s := 'Ordenar lista por tipo'
    else if nomeArq = 'LBTDIASLIST'     then s := 'Dias listar'
    else if nomeArq = 'LBTFALMENSA'     then s := 'Falar todas as mensagens'

    // Tipos de lembretes.
    else if nomeArq = 'LBTDATAFI'       then s := 'Data'
    else if nomeArq = 'LBTDIARIO'       then s := 'Diário'
    else if nomeArq = 'LBTSEMANAL'      then s := 'Semanal'
    else if nomeArq = 'LBTMENSAL'       then s := 'Mensal'
    else if nomeArq = 'LBTANUAL'        then s := 'Anual'

    else if nomeArq = 'LBTSELTPLE'      then s := 'Selecione com as setas verticais o tipo de lembrete'
    else if nomeArq = 'LBTSELDIASEM'    then s := 'Selecione com as setas verticais o dia da semana'
    else if nomeArq = 'LBTDOMINGO'      then s := 'Domingo'
    else if nomeArq = 'LBTSEGUNDA'      then s := 'Segunda-feira'
    else if nomeArq = 'LBTTERCA'        then s := 'Terça-feira'
    else if nomeArq = 'LBTQUARTA'       then s := 'Quarta-feira'
    else if nomeArq = 'LBTQUINTA'       then s := 'Quinta-feira'
    else if nomeArq = 'LBTSEXTA'        then s := 'Sexta-feira'
    else if nomeArq = 'LBTSABADO'       then s := 'Sábado'
    else if nomeArq = 'LBTDIGILEMB'     then s := 'Digite o lembrete, depois  tecle Enter'
    else if nomeArq = 'LBTNAOADEX'      then s := 'Não pude adicionar, excedeu o número de lembretes diários de '
    else if nomeArq = 'LBTEDITDATA'     then s := 'Edite a data do lembrete, depois  tecle Enter'
    else if nomeArq = 'LBTDATAINVA'     then s := 'Data inválida'
    else if nomeArq = 'LBTEDITDIME'     then s := 'Edite o dia e o mês  do lembrete, depois  tecle Enter'
    else if nomeArq = 'LBTEDITDIA'      then s := 'Edite o dia do lembrete, depois  tecle Enter'
    else if nomeArq = 'LBTDIAINVA'      then s := 'Dia inválido, deve ser entre 1 e 31'
    else if nomeArq = 'LBTNAOTLEM'      then s := 'Não tem lembretes até '
    else if nomeArq = 'LBTEDITLEM'      then s := 'Edite o lembrete, depois  tecle Enter. ESC cancela.'
    else if nomeArq = 'LBTLEMBINV'      then s := 'Lembrete inválido,não pode deixar em branco ou ter menos que 3 caracteres.'

    else
        s := '--> Mensagem inválida: ' + nomeArq;

    result := s;
end;

{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);

end;

{--------------------------------------------------------}

procedure msgBaixo (nomeArq: string);
var y: integer;
begin
    textBackGround (BLACK);
    if wherey = 25 then
        begin
             clreol;
             writeln;
        end;

    y := wherey;

    gotoxy (1, 25);
    clreol;

    if nomeArq <> '' then
        begin
            textBackground (RED);
            gotoxy (80-length(pegaTextoMensagem (nomeArq)), 25);
            mensagem (nomeArq, 0);
            textBackground (BLACK);
        end;

    gotoxy (0, y);
end;

{--------------------------------------------------------}

procedure soletra(s: string; nlf: integer);
var i: integer;
begin
     write (s);
     for i := 1 to nlf do
         writeln;
     for i := 1 to length (s) do
         sintSoletra (s[i]);
end;

{--------------------------------------------------------}

procedure inicFala;
begin
    dirSons := sintAmbiente ('LEMBRETEVOX', 'DIRLEMBRETEVOX', '@\som\lembretevox');
    sintinic (0, dirSons);
end;

{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to 25 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}

function pegaDirDosvox: string;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';

    result := dirDosvox;
end;

{--------------------------------------------------------}

begin
end.
