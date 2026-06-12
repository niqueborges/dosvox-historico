{-------------------------------------------------------------}
{
{       Rotinas de mensagens do Atuvox
{       Por Neno Albernaz - neno@intervox.nce.ufrj.br
{       Em 25/07/2021
{
{-------------------------------------------------------------}

unit atuMsg;

interface

uses
    dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure inicFala;

implementation

{-------------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'ATUINIC'         then s := 'Atualizar configuração por arquivo .ATU'
    else if nomeArq = 'ATUARQMUDANCA' then s := 'Informe o nome do arquivo que contém as mudanças'
    else if nomeArq = 'ATUATUNEC'     then s := 'Nenhum arquivo .ATU foi selecionado.'
    else if nomeArq = 'ATUARQNAOEX'   then s := 'Arquivo não existe, sinto muito.'
    else if nomeArq = 'ATUREALTERASN' then s := 'Deseja realterar itens anteriormente criados?'
    else if nomeArq = 'ATUDESIST'     then s := 'Desistiu...'
    else if nomeArq = 'ATUCHAVEINVAL' then s := 'Chave inválida'
    else if nomeArq = 'ATUOK'         then s := 'Ok ! '

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

procedure inicFala;
var dirSons: string;
begin
    dirSons := sintAmbiente ('ATUVOX', 'DIRATUVOX');
    if dirSons = '' then
        begin
            dirSons := sintAmbiente('DOSVOX', 'PGMDOSVOX');
            if dirSons = '' then dirSons := '@';
            dirSons := dirSons + '\som\atuvox';
            sintGravaAmbiente ('ATUVOX', 'DIRATUVOX', dirSons);
            if sintAmbiente ('DOSVOX', 'PROG.ATU') = '' then
                sintGravaAmbiente ('DOSVOX', 'PROG.ATU', '@\atuvox.exe');
        end;
    sintinic (0, dirSons);
end;

{--------------------------------------------------------}

begin
end.
