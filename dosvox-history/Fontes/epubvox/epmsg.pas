unit epmsg;
interface

uses
    SysUtils, dvcrt, dvWin, dvLenum, dvForm;

procedure mensagem (nomeArq: string; nlf: integer);
function pegaTextoMensagem (nomeArq: string): string;
procedure soletra(s: string; nlf: integer);
procedure limpaBaixo (y: integer);
procedure menuAdiciona (cod: string);
function pergunta (msg: string; npula: integer; cor: integer): char;
procedure msgMuda (nomeArq: string; nlf: integer);
function trocaBarra(dir: String): String;

implementation

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
   if      nomeArq = 'EPUBVOX'  then s := 'EPUBVOX - Versão '
   else if nomeArq = 'EPFIM'    then s := 'Fim do EPUBVOX'
   else if nomeArq = 'EPQOPCAO' then s := 'Selecione a opção com as setas:'
   else if nomeArq = 'EPQNEPUB' then s := 'Informe o nome do livro:'
   else if nomeArq = 'EPNLIVRO' then s := 'Livro: '   
   else if nomeArq = 'EPNENCON' then s := 'Pasta vazia ou nenhum arquivo selecionado.'
   else if nomeArq = 'EPCONFIR' then s := 'Confirma o fim do Epubvox? '
// else if nomeArq = 'EPDFAULT' then s := 'Manter a configuração padrão?(S/N) '
   else if nomeArq = 'EPNAO' then s := 'Não'
   else if nomeArq = 'EPSIM' then s := 'Sim'
   else if nomeArq = 'EPNLVTXT' then s := 'Informe o nome do arquivo de texto a salvar: '
   else if nomeArq = 'EPPROCES' then s := 'Extraindo arquivo EPUB  '
   else if nomeArq = 'EPERRODC' then s := 'Descompactador não pôde ser executado.'
   else if nomeArq = 'EPFPROCE' then s := 'Fim da extração'

   else if nomeArq = 'EPERRORN' then s := 'Nome de arquivo inválido.'
   else if nomeArq = 'EPERRORE' then s := 'Tipo de arquivo não suportado.'
   else if nomeArq = 'EPERRORC' then s := 'Erro ao copiar dados do arquivo.'
   else if nomeArq = 'EPERRORZ' then s := 'Erro na extração do arquivo'
   else if nomeArq = 'EPSAIDAD' then s := 'Será salvo no diretório atual.'
   else if nomeArq = 'EPIMAGTB' then s := 'Extrai imagens também? '
   else if nomeArq = 'EPEXTIMG' then s := 'Extraindo as imagens.'

   else if nomeArq = 'EPERRIMG' then s := 'Diretório de imagens não pôde ser criado'
   else if nomeArq = 'EPLOCALS' then s := 'Livro salvo em: '
   else if nomeArq = 'EPEDIVOX' then s := 'Voltando para o Edivox'
//   else if nomeArq = 'xxxxxx' then s := 'xxxxxx'


   else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{              dá uma mensagem sem falar
{--------------------------------------------------------}

procedure msgMuda (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;
end;

{--------------------------------------------------------}
{              dá uma mensagem falando
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if (nomeArq <> '') and (existeArqSom (nomearq)) then
        sintSom (nomearq)
    else
        sintetiza (s);

    while sintFalando do keypressed;
end;

{--------------------------------------------------------}
{               Soletra uma string
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
{             Limpa as linhas que estao abaixo
{--------------------------------------------------------}

procedure limpaBaixo (y: integer);
var i: integer;
begin
    for i := y to currentWindow.Bottom - 1 do
        begin
            gotoxy (1, i);
            clreol;
        end;
    gotoxy (1, y);
end;

{--------------------------------------------------------}
{       adiciona ao menu (rotina de conveniência)
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

{--------------------------------------------------------}
{                faz uma pergunta
{--------------------------------------------------------}

function pergunta (msg: string; npula: integer; cor: integer): char;
var c, c2: char;
begin
    textBackground (cor);
    mensagem (msg, 0);
    textBackground (BLACK);
    sintLeTecla (c, c2);
    pergunta := upcase(c);

    if c <> #$0 then
        begin
            c := upcase (c);
            gotoxy(wherex-1,wherey);
            ClrEol;
        end;
    gotoxy(wherex,wherey);
end;

{--------------------------------------------------------}
{               Inverte barras
{--------------------------------------------------------}

function trocaBarra(dir: String): String;
begin
    result := StringReplace(dir, '/', '\', [rfReplaceAll, rfIgnoreCase]);
end;

end.


