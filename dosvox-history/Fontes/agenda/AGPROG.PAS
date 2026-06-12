{--------------------------------------------------------}
{        AGENVOX - chamada de outros executáveis
{--------------------------------------------------------}

unit agprog;

interface

uses dvcrt, dvWin, dvexec,
    windows, shellApi, sysutils,
    agUtil, agVars, agMsg;

procedure abreBlocoDeNotas;
procedure abreCalculadora;
procedure abreTelefones;
procedure fazBackup;

implementation

{--------------------------------------------------------}
{         Abre editor especificado pelo usuário
{--------------------------------------------------------}

procedure abreBlocoDeNotas;
var nomeProg, nomeArq: string;
begin

    if not trocaDir (dir_bloco) then
        exit;

    nomeProg := sintAmbiente ('AGENDA', 'BLOCOPROG');
    nomeArq:= '"Bloco da Agenda"';

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\edivox.exe';

    delay (500);
    if executaProg (nomeProg, '', nomeArq) < 32 then;
        esperaProgVoltar;
    delay (1000);

    tocaEfeito ('agVolta');

end;

{--------------------------------------------------------}
{       Abre calculadora especificada pelo usuário
{--------------------------------------------------------}

procedure abreCalculadora;
var nomeProg: string;
begin

    nomeProg := sintAmbiente ('AGENDA', 'CALCPROG');

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\calcuvox.exe';

    delay (500);
    if executaProg (nomeProg, '', '') < 32 then;
        esperaProgVoltar;
    delay (1000);

    tocaEfeito ('agVolta');

end;

{--------------------------------------------------------}
{                  Abre o TELEVOX ou similar
{--------------------------------------------------------}

procedure abreTelefones;
var nomeProg, nomeArq: string;
begin

    if not trocaDir (dir_telefones) then
        exit;

    nomeProg := sintAmbiente ('AGENDA', 'TELEPROG');
    nomeArq:= '"Telefones da Agenda"';

    if nomeProg = '' then
        nomeProg:= 'c:\winvox\televox.exe';

    delay (500);
    if executaProg (nomeProg, '', nomeArq) < 32 then;
        esperaProgVoltar;
    delay (1000);

    tocaEfeito ('agVolta');

end;

{--------------------------------------------------------}
{        Efetua backup no diretório especificado
{--------------------------------------------------------}

procedure fazBackup;
var parametros: string;
begin

    mensagem ('AGBK', 1);    {'Efetuando backup'}

    parametros := ' /c xcopy /y /f /h /s . ' + dirTrab_bk;

    delay (500);
    if executaProg ('command', '.', parametros) < 32 then;
        esperaProgVoltar;
    delay (1000);

    mensagem ('AGBKOK', 1);    {'Backup concluído'}

    tocaEfeito ('agVolta');

end;

end.
