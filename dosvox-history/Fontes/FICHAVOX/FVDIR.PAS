{--------------------------------------------------------
{    Programa FichaVox
{   Operações com diretórios
{--------------------------------------------------------}

unit FVDir;

interface
    uses windows, dvcrt, dvWin , fvMsg;

    procedure abre_diretorio;
    procedure diretorio_atual;

implementation

{-----------------------------------------------------------------------}
{Imforma o diretório atual (diretório de Trabalho).}
{-----------------------------------------------------------------------}

procedure diretorio_atual;
var
    caminho: string;
    opc: char;

begin
    getdir (0, caminho);
    mensagem ('FVDIRATU',0);{O fichario atual é }
    sintWriteln (caminho);
    delay (50);
    mensagem ('FVPERSOL',0); {Quer que soletre, SIM ou NÃO?}
    opc := upcase (readkey);
    writeln;
    delay (100);
    if opc = 'S' then
        begin
            sintSoletra (caminho);
            delay (300);
        end
    else
        delay (100);
end;

{-----------------------------------------------------------------------}
{Função queabre um diretório (TRUE=aberto ou FALSE=não aberto).
{-----------------------------------------------------------------------}

function abrir_dir (diretorio: string): boolean;
begin
    {$i-}chdir (diretorio);{$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVNABFIC',1);
            {Desculpe, mas não consegui abrir o fichario.}
            abrir_dir := false;
        end
    else
        begin
            mensagem ('FVABRFIC',1); {Fichario aberto.}
            abrir_dir := true;
        end;
end;

{-----------------------------------------------------------------------}
{Cria um diretório, cria arquivo FICHAS.IND e pergunta se vai}
{ser o fichario (diretorio) de trabalho ou não.}
{-----------------------------------------------------------------------}

function criar_dir (diretorio: string): boolean;
var c: char;
begin
    {$i-}mkdir (diretorio);{$i+}
    if ioresult <> 0 then
        begin
            mensagem ('FVNCRDIR',1);
            {Desculpe, mas não consegui criar o fichario.}
            criar_dir := false;
            exit;
        end
    else
        begin
            mensagem ('FVCRIDIR',1); {Fichario criado.}
            criar_dir := true;

            mensagem ('FVDIRTRA', 0);
            {Deseja trabalhar neste fichario?}
            c := upcase (readkey);
            sintWriteln (c);
            if c = 'S' then
            begin
                if  abrir_dir (diretorio) then;
            end
            else
                mensagem ('OK',1);
        end;
end;

{-----------------------------------------------------------------------}
{Troca de fichario (diretório), caso não consiga pergunta se deseja criar.}
{-----------------------------------------------------------------------}

procedure abre_diretorio;
var
    diretorio, caminho: string;
    opc: boolean;
    c: char;

begin
    repeat
        mensagem ('FVNOVDIR', 0);
        {'Informe o diretório do fichario'}
        mensagem ('FVNOVDI1', 1);
        {  ou tecle ENTER para assumir fichário atual: }
        sintReadln (diretorio);
        if diretorio = '' then
            begin
                getdir (0, caminho);
                opc := true;
            end
        else
        if (diretorio='C:\') or (diretorio='c:\') or (diretorio='\') then
            begin
                getdir (0, caminho);
                opc := true;
                mensagem ('FVNPTNFI',1);
                {Desculpe, não é possivel trabalhar neste fichário.}
            end
        else
            begin
                opc := abrir_dir(diretorio);
                if opc = false then
                    begin
                        mensagem('FVPCRDIR', 0); {deseja criar este fichario?}
                        c := upcase (readkey);
                        sintWriteln (c);
                        if c = 'S' then
                            begin
                                opc := criar_dir(diretorio);
                            end;
                    end;
            end;
until opc = true;

end;

{--------------------------------------------------------}

end.
