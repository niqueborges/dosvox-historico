{--------------------------------------------------------}
{
{     Realiza uuencode ou uudecode de um arquivo
{
{     Autor: José Antonio Borges
{
{     Em Abril/95
{
{     Baseado no programa Simtel de Toad Hall
{
{--------------------------------------------------------}

program uuvox;
uses dvcrt, dvwin, uuenc;
const
    OK = 0;
    NOT_FOUND = 1;
    READ_ERROR = 2;
    WRITE_ERROR = 3;
    INVALID_FORMAT = 4;
    INCOMPL_FILE = 5;


{--------------------------------------------------------}
{                    inicializa‡„o
{--------------------------------------------------------}

procedure inicializa;
begin
    sintInic (0, '');
    sintWriteln ('Conversor de formato UUENCODE - transmissor UNIX');
    writeln;
end;

{--------------------------------------------------------}
{                      finaliza‡„o
{--------------------------------------------------------}

procedure finaliza;
begin
    sintWriteln ('Fim da conversão');
    sintFim;
end;

{--------------------------------------------------------}
{             controle geral do processamento
{--------------------------------------------------------}

procedure processa;
var
    c: char;
    result: integer;
    nomearq, narqout, s: string;
    arq: file;

begin
    sintWrite ('Qual o nome do arquivo: ');
    sintReadln (nomearq);
    if nomearq = '' then
        exit;

    assign (arq, nomearq);
    {$I-} reset (arq);  {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo inexistente');
            sintWriteln ('Programa cancelado');
            sintFim;
            halt;
        end;

    closeFile (arq);

    repeat
        sintWrite ('Tecle C para codificar D para decodificar');
        sintReadln (s);
        c := upcase (s[1]);

        case c of
            'C': begin
                     sintWriteln ('Qual o nome do arquivo de saida: ');
                     sintReadln (narqout);
                     if narqout = '' then
                         exit;

                     result := uuencode (nomearq, narqout);
                 end;

            'D': uudecode (nomearq);
        end;

    until c in ['C', 'D'];
end;

begin
    inicializa;
    processa;
    finaliza;
end.
