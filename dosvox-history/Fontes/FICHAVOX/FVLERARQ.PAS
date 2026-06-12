{--------------------------------------------------------}
{    Programa FichaVox}
{ Lendo as fichas}
{--------------------------------------------------------}

unit fvLerArq;

interface

    uses windows, dvcrt, dvWin, fvMsg, dvExec, fvVars;

    procedure LerArquivo (nomeArqAux: string);

implementation

{----------------------------------------------------------------------}
{   Le um arquivo texto.}
{----------------------------------------------------------------------}

procedure LerArquivo (nomeArqAux: string);
var     nomeLeitor: string;
begin
    mensagem ('FVABRELE',1);  {'Abrindo leitor'}
    while sintFalando do;
    nomeLeitor := sintAmbiente ('DOSVOX', 'LEITOR');
    if nomeLeitor = '' then nomeLeitor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\LEVOX.EXE';
    while sintFalando do;
    getDir (0, caminho);
    if executaProg (nomeLeitor, caminho, nomeArqAux) < 32 then
        begin
            mensagem ('FVENAEDI',1);{'Não foi possível executar esse programa, erro #'}
            exit;
        end;
    esperaProgVoltar;
    while sintFalando do;
    while keypressed do readkey;
    sintBip;
end;

{----------------------------------------------------------------------}

end.
