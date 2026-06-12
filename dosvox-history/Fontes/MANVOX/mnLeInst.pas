{--------------------------------------------------------}
{
{    Manual interativo do DOsvox
{
{    Módulo de ler instruçoes basicas
{
{    Autores: Otávio Moreira Meirelles
{
{    Em Maio de 2011
{
{--------------------------------------------------------}

unit mnLeInst;

interface

uses
  windows,
  dvcrt,
  dvwin,
  dvform,
  dvexec,
  sysutils,
  mnmsg;

procedure ler_instr_basicas;

implementation

var
    nomeArqBasicos: string;

 {---------------------------------------------------------------------------}
 {          --------------cria um arquivo temporário--------------           }
 {---------------------------------------------------------------------------}

function GetTempFile: String;
var
    tempFileName, tempPath: array[0..255] of Char;

begin
    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'man', 0, tempFileName);
    result := strPas (tempFileName);
end;

 {---------------------------------------------------------------------------}
 {              --------------Aprender teclado--------------                 }
 {---------------------------------------------------------------------------}

procedure processaTrechoArquivo (aLer: string);
var
    nomeLeitor, x: string;
    nomeTemp: string;
    arq, arqTemp: Textfile;
begin
    assignfile(Arq,nomeArqBasicos);
    {$I-}  reset(arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MNBASNAO', 2);  {'Arquivo basicos.cfg não foi encontrado'}
            mensagem ('MNOPCANC', 2);  {'Operação cancelada'}
            exit;
        end;

    while not eof (arq) do
        begin
            readln(Arq, x);
            if x = '[' + aLer + ']' then
                break;
        end;

    nomeTemp := getTempFile;
    assignFile (arqTemp, nomeTemp);
    rewrite (arqTemp);
    while not eof (arq) do
      begin
          readln(Arq, x);
          if (x <> '') and (x[1] = '[') then
               break;
          writeln (arqTemp, x);
      end;
    closefile (arq);
    closefile (arqTemp);

    mensagem ('MNLENDO', 0);   {'Lendo texto '}
    sintWriteln (aLer);
    writeln;
    mensagem ('MNSAIR', 1);   {'Para terminar, aperte ESC'}

    nomeLeitor := sintAmbiente ('MANVOX', 'LEITOR');
    if (nomeLeitor = '') then
        nomeLeitor := 'c:\winvox\levox.exe';

    executaProg(nomeLeitor, '.', nomeTemp);
    esperaProgVoltar;
    deleteFile (nomeTemp);
end;

{-----------------------------------------------------------------------------}
{                --------Menu ler Instruçôes Basicas--------                  }
{-----------------------------------------------------------------------------}

procedure ler_instr_basicas;
var
    arq : Textfile;
    x, aLer: string;
    n: integer;

const
    cod: array  [0..3] of char = (ESC, 'A', 'D', 'C');
begin
    clrscr;
    textBackground (BLUE);
    writeln (pegaTextoMensagem('MNINIC'));             {'Manual eletrônico do Dosvox'}
    textBackground (BLACK);
    writeln;

    nomeArqBasicos := sintAmbiente('MANVOX','BASICOS');
    if nomeArqBasicos = '' then
         nomeArqBasicos := 'c:\winvox\manual\basicos.cfg';

    assignfile(Arq,  nomeArqBasicos);
    {$I-} reset(arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('MNBASNAO', 2);  {'Arquivo basicos.cfg não foi encontrado'}
            mensagem ('MNOPCANC', 2);  {'Operação cancelada'}
            exit;
        end;

    mensagem ('MNESCBAS', 2);    {'Escolha com as setas a instrução básica e aperte enter'}

    popupMenuCria (wherex, wherey, 50, 25-wherey, RED);

    while not eof (arq) do
        begin
             readln (arq, x);
             if (x <> '') and (x[1] = '[') then           { procura no arquivo os '[' }
                begin
                   delete (x, 1, 1);
                   delete (x, length(x), 1);
                   popupMenuAdiciona ('', x);
                end;
        end;

    closefile (arq);

    n := popupMenuSeleciona;
    if n < 1 then
        begin
            mensagem ('MNDESIST', 1);   {'Desistiu'}
            exit;
        end;

    aLer := opcoesItemSelecionado;
    processaTrechoArquivo (aLer);
    writeln;
end;

end.
