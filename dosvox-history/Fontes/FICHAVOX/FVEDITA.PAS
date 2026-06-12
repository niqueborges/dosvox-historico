{--------------------------------------------------------}
{    Programa FichaVox
{    Editando as fichas
{--------------------------------------------------------}

unit fvEdita;

interface

    uses windows, dvcrt, dvWin, fvMsg, dvExec, fvVars;

    procedure editarArquivo (nomeArqAux: string);

implementation

{----------------------------------------------------------------------}
{   Edita um arquivo}
{----------------------------------------------------------------------}

procedure editarArquivo (nomeArqAux: string);
var nomeEditor: string;
begin
    mensagem ('FVABREDI',1);  {'Abrindo editor'}
    while sintFalando do;
    nomeEditor := sintAmbiente ('DOSVOX', 'EDITOR');
    if nomeEditor = '' then nomeEditor := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\EDIVOX.EXE';
    while sintFalando do;
    getDir (0, caminho);
    if executaProg (nomeEditor, caminho, nomeArqAux) < 32 then
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
