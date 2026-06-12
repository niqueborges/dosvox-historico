{--------------------------------------------------------}
{                  AGENVOX - rotinas auxiliares
{--------------------------------------------------------}

unit agUtil;

interface

uses dvCrt, dvWin,
    winDows, winprocs, wintypes, sysUtils, mmsystem,
    agVars, agMsg;

function int2 (x: byte): string;
function int2str (v: longint): string;
function maiusc (s: string): string;
function trocaDir (s: string): boolean;
function existeGrupo (s: string): boolean;
function semAcentos (s: string): string;
function calcDias (dd, mm, aa: integer): longint;
procedure tocaEfeito (arqEfeito: string);
procedure tocaTudo (nomeDisp: string; c: char);
procedure sintTecla (var c1, c2: char);

implementation

const
    tabint: array [0..9] of char = ('0','1','2','3','4','5','6','7','8','9');

{-------------------------------------------------------------}

function int2 (x: byte): string;
begin
    int2 := tabint [x div 10] + tabint [x mod 10];
end;

{-------------------------------------------------------------}

function int2str (v: longint): string;
var s: string;
begin
    s := '';
    while v <> 0 do
         begin
             s := tabint [v mod 10] + s;
             v := v div 10;
         end;
    if s = '' then
        int2Str := '0'
    else
        int2Str := s;
end;

{-------------------------------------------------------------}

function maiusc (s: string): string;
var s2: string;
    i: integer;
begin
    s2 := s;
    for i := 1 to length (s) do
        s2 [i] := upcase (s[i]);
    maiusc := s2;
end;

{-------------------------------------------------------------}

function trocaDir (s: string): boolean;
begin

    trocaDir:= false;

    dirTemp:= dirTrab + s;

    {$I-} chDir (dirTemp); {$I+}
    if ioResult <> 0 then
        begin
            mkDir (dirTemp);
            if ioResult <> 0 then
                exit;
            chDir (dirTemp);
            if ioResult <> 0 then
                exit;
        end;

    trocaDir:= true;

end;

{-------------------------------------------------------------}

function existeGrupo (s: string): boolean;
var arq: text;
label erro;
begin

    existeGrupo:= false;

    if s = '' then
        goto erro;

    assign (arq,s);
    {$i-} reset (arq); {$i+}
    if IOresult <> 0  then
        goto erro;
    close (arq);
    existeGrupo:= true;
    exit;

    erro:
        mensagem ('AGNAOESP', 1);  {'Grupo de trabalho não foi especificado'}

end;

{--------------------------------------------------------}
{     transforma cadeia em maiusculos nao acentuados
{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}
{Calcula o dia da semana
{--------------------------------------------------------}

function calcDias (dd, mm, aa: integer): longint;
var l: longint;
    i: integer;
const
    tabmes: array [1..12] of integer =
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
    l := aa * longint(365);
    for i := 0 to aa-1 do
        if (i mod 4) = 0 then l := l + 1;
    for i := 1 to mm-1 do
        l := l + tabMes [i];
    if ((aa mod 4) = 0) and (mm > 2) then
        l := l + 1;
    l := l + dd;

    calcDias := l;
end;

{--------------------------------------------------------}
{Toca efeito trocando a velocidade da síntese
{--------------------------------------------------------}

procedure tocaEfeito (arqEfeito: string);
begin

    sintVeloc (1);
    sintSom ((arqEfeito));
    while sintFalando do waitMessage;
    sintVeloc (velocidadeDosvox);

end;

{--------------------------------------------------------}
{Toca qualquer extensão
{--------------------------------------------------------}

procedure tocaTudo (nomeDisp: string; c: char);
var ret : longInt;

Function EnviaComandoMCI (cmd : string) : LongInt;
var comando : array [0..127] of char;
    erro: longint;
    retorno: array [0..255] of char;
begin

    strPCopy (comando, cmd);
    erro := mciSendString(comando, retorno, 127, 0);
    EnviaComandoMCI := erro;
    keyPressed;
end;

begin

    if not trocaDir (dir_sonsDoDespertador) then
        exit;

    checkBreak:= false;

    delay (250);

    if c = 'P' then
        begin
            ret := enviaComandoMCI ('open ' + nomedisp + ' alias disp1')
                   or enviaComandoMCI ('play disp1 from 1');
            bipSpeaker (5000);
            if ret <> 0 then
                sintWriteln ('Erro: não consegui executar os comandos open e play');
        end;

    if c = 'S' then
        begin
            ret:= enviaComandoMCI ('stop disp1') or
                  enviaComandoMCI ('close disp1');
            bipSpeaker (5000);
            if ret <> 0 then
                sintWriteln ('Erro: não consegui executar os comandos stop e close');
        end;

    checkBreak:= true;

    if not trocaDir (dir_agenda) then
        exit;

end;

{--------------------------------------------------------}
{                 le uma tecla, ecoando
{--------------------------------------------------------}

procedure sintTecla (var c1, c2: char);
begin
    while sintFalando do waitMessage;     { permite fechamento do dispositivo de som }
    c2 := ' ';
    c1 := readkey;
    if c1 = #0 then c2 := readkey;

    if (c1 <> GOTFOCUS) and (c1 <> NOFOCUS) then
        if c1 in [#32..#126, #127..#255] then
            begin
                sintCarac (c1);
                write (c1);
            end;
end;

end.
