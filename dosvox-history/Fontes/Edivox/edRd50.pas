{-------------------------------------------------------------}
{
{       Chama o programa Radio50
{
{       Autor: Neno Henrique da Cunha Albernaz
{
{       Em 23de Março de 2022
{
{-------------------------------------------------------------}

unit edRd50;

interface

uses
    windows,
    dvcrt,
    sysutils,
    dvwin,
    dvexec,
    classes,
    comobj,
    activex,
    edMensag,
    edTela,
    edVars;

procedure trataRadio;

implementation

{--------------------------------------------------------}
{       Chama programa externo que toca rádio
{--------------------------------------------------------}

procedure chamarRadio50 (radio: string; comTocador: boolean);
var
    nomeProg: string;
begin
    nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\radio50.exe';
    if comTocador then
        radio := 'comTocador ' + radio;

    if executaProg (nomeProg, '', radio) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            limpaBufTec;
            sintclek;
        end
    else
        fala ('EDPRONEN');  {'Programa não encontrado'}
end;

{--------------------------------------------------------}

procedure tocarRadio (comTocador: boolean);
var
    campo, radio: string;
    x1, x2: integer;
const
    espurios: set of char = ['<', '"', '(', '{', '[', '-', '=', '.', '_',
                             '>', '*', '!', '?', ')', '}', ']'];
begin
    campo := trim(texto[posy]);
    if campo = '' then
        begin
            fala ('EDNEXEC');    {'Não pude executar'}
            exit;
        end;

    x1 := posx;
    while (x1 > 1) and (campo[x1-1] <> ' ') do
       x1 := x1 - 1;
    x2 := posx;
    while (x2 < length(campo)) and (campo[x2] <> ' ') do
        x2 := x2 + 1;
    if (x2 <= length(campo)) and (campo[x2] = ' ') then x2 := x2 - 1;
    radio := copy (campo, x1, x2-x1+1);

    while (radio <> '') and (radio[1] in espurios) do
        delete (radio, 1, 1);
    while (radio <> '') and (radio[length(radio)] in espurios) do
        delete (radio, length(radio), 1);

    if radio = '' then
        fala ('EDNEXEC')    {'Não pude executar'}
    else
        chamarRadio50 (radio, comTocador);
end;

{--------------------------------------------------------}

procedure trataRadio;
var
    c1, c2: char;

label deNovo;
begin
    fala ('EDOPCAO'); {'Qual opcao? '}
    c1 := leTeclaMaiusc(c2);

deNovo:
    escreveTela;

    case c1 of
        'R', 'E': tocarRadio (c1 = 'E');
        #$0: begin
                c1 := ajuda (c2, 'EDAJFR', 3);
                goto deNovo;
            end;
      #$1b: begin
                fala ('EDDESIST');
                exit;
            end
    else
        sintBip;
    end;
end;

{--------------------------------------------------------}

begin
end.
