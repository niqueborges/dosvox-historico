{--------------------------------------------------------}
{    Conversor de formatos de som
{    Por José Antonio Borges
{    Em 29/05/98
{   Atualizado por Neno Henrique Albernaz em 17/08/2023
{--------------------------------------------------------}

program convsons;
uses
  windows,
  dvcrt,
  dvwin,
  dvArq,
  dvForm,
  gramost in '..\minigrav\gramost.pas',
  comsg,
  classes,
  sysutils;

var
    nomeDirArq: string;
    narq: integer;
    velocidade, bitsPorAmostra, canais: integer;
    nomesArqs: TStringList;

label fim;

{--------------------------------------------------------}

function achaNumArqs (nomeDirArq: string): integer;
var
    buscado: TSearchRec;
    numArqs: integer;
    dosError: integer;
begin
    nomesArqs := TStringList.create;
    if fileExists (nomeDirArq) then
        begin
            numArqs := 1;
            nomesArqs.Add(nomeDirArq);
        end
    else
        begin
            numArqs := 0;
            dosError := FindFirst ('*.WAV', FAARCHIVE, buscado);
            while dosError = 0 do
                begin
                    nomesArqs.Add(buscado.FindData.cFileName);
                    dosError := FindNext(buscado);
                    inc(numArqs);
                end;
        end;

    result := numArqs;
end;

{--------------------------------------------------------}

function pegaVelocidadeFinal(var velocidade: integer): char;
var n: integer;
begin
    velocidade := 0;
    popupMenuCria(40, wherey, 15, 3, RED);
        popupMenuAdiciona('', '11025');
        popupMenuAdiciona('', '22050');
        popupMenuAdiciona('', '44100');
    n := popupMenuSeleciona;

    if n = 0 then
        result := ESC
    else
        begin
            if n = 1 then velocidade := 11025
            else if n = 2 then velocidade := 22050
            else if n = 3 then velocidade := 44100;
            result := #0;
        end;
end;

{--------------------------------------------------------}

function pegaBitsPorAmostra(var bitsPorAmostra: integer): char;
var n: integer;
begin
    bitsPorAmostra := 0;
    popupMenuCria(40, wherey, 15, 2, RED);
        popupMenuAdiciona('', '8');
        popupMenuAdiciona('', '16');
    n := popupMenuSeleciona;

    if n = 0 then
        result := ESC
    else
        begin
            if n = 1 then bitsPorAmostra := 8
            else if n = 2 then bitsPorAmostra := 16;
            result := #0;
        end;
end;

{--------------------------------------------------------}

function pegaCanais (var canais: integer): char;
var n: integer;
begin
    canais := 0;
    popupMenuCria(40, wherey, 15, 2, RED);
        popupMenuAdiciona('', '1');
        popupMenuAdiciona('', '2');
    n := popupMenuSeleciona;

    if n = 0 then
        result := ESC
    else
        begin
            canais := n;
            result := #0;
        end;
end;

{--------------------------------------------------------}

function inicializa: boolean;
var
    c: char;
    s: string;

begin
    result := false;
    ScreenSize.y := 15;
    sintInic (0, sintAmbiente ('CONVSONS', 'DIRCONVSONS', '@\som\convsons'));

    sintFalaPont := false;
    mensagem ('COINIC', 2);  {'Conversor de formatos de Som'}
    while sintFalando do;

    mensagem ('COINFDIRARQ', 1);  {'Informe nome do diretório ou arquivo a converter'}
    nomeDirArq := obtemNomeArqMasc (5, '*.wav');

    if (nomeDirArq = '') or (teclaObtemNomeArq = ESC) then exit;

    if not fileExists (nomeDirArq) then
        begin
            {$I-} chDir (nomeDirArq);  {$I+}
            if ioresult <> 0 then
                begin
                    mensagem ('CODIRARQNAO', 1); {'Diretório ou arquivo inexistente'}
                    exit;
                end;
        end
    else
    if maiuscansi(extractFileExt(nomeDirArq))  <> '.WAV' then
        begin
            mensagem ('CODEVWAV', 1);      {'Deve ser arquivo WAV.'}
            exit;
        end;

    mensagem ('COVELOC', 0);  {'Velocidade final (sugiro 11025, 22050 ou 44100): '}
    c := sintEditaCampo (s, 1, wherey, 5, 80, true);
    if (c = BAIX) or (c = CIMA) then
        c := pegaVelocidadeFinal(velocidade)
    else
    if (c = ESC) or (trim(s) = '') then
        exit
    else
        velocidade := strToInt(s);
    if (c = ESC) or (velocidade = 0) then exit;

    mensagem ('COBITS', 0);   {'Bits por amostra (8 ou 16): '}
    s := '';
    c := sintEditaCampo (s, 1, wherey, 2, 80, true);
    if (c = BAIX) or (c = CIMA) then
        c := pegaBitsPorAmostra(bitsPorAmostra)
    else
    if (c = ESC) or (trim(s) = '') then
        exit
    else
        bitsPorAmostra := strToInt(s);
    if (c = ESC) or (bitsPorAmostra = 0) then exit;

    mensagem ('COCANAIS', 0); {'Canais (1 ou 2):'}
    c := sintReadKey;
    writeln (c);
    if c = #0 then
        c := pegaCanais (canais)
    else
    if (c = ESC) or (not (c in ['1', '2'])) then
        exit
    else
        canais := strToInt(c);
    if (c = ESC) or (canais = 0) then exit;

    narq := achaNumArqs (nomeDirArq);
    mensagem ('CONUMARQ', 0);   {'Número de arquivos a converter: '}
    sintWriteln (intToStr (narq));

    result := true;
end;

{--------------------------------------------------------}

procedure converteArquivo (n: integer);
var nomeArq: string;
    som, som2: TAmostras;
begin
    nomeArq := nomesArqs [n];
    writeln (nomeArq);

    som := TAmostras.Create;
    som.leArquivo(nomeArq);

    som2:= TAmostras.Create;
    som2.reAmostra (som, velocidade);
    som2.bitsPorAmostra := bitsPorAmostra;
    som2.canais := canais;
    som.Free;
    som := som2;
    // som2 := NIL;

    if not som.gravaArquivo(nomeArq) then
        begin
            mensagem ('COERRGRG', 0);  {'Erro de gravação: '}
            sintWriteln (nomeArq);
            writeln;
            mensagem ('COAPTENT', 1);  {'Aperte enter'}
            readln;
        end;
end;

{--------------------------------------------------------}

procedure finaliza (falar: boolean);
begin
    nomesArqs.Free;
    writeln;
    if falar then mensagem ('COOK', 1);   {'OK'}
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

var i: integer;
begin
    if not  inicializa then
        finaliza (false);
    for i := 0 to narq-1 do
        converteArquivo (i);
    finaliza (true);
end.
