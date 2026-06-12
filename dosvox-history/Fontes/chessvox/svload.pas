unit svload;

interface
uses dvcrt, dvwin, sysUtils, dvarq, dvForm, defs, data, parse, xadmsg;

procedure saveGame;
procedure loadSavedGame;
procedure saveForStudy;
procedure debugSet;
procedure debugRecord (s: string);

implementation

(* save the game on a file *)

procedure saveGame;
var nomeArq: string;
    arq: file;
label erro;
begin
    garanteEspacoTela (10);
    mensagem ('XDNOMSVX', 1);   //'Qual o nome do arquivo .svx? ');
    nomeArq := obtemNomeArqMasc(10, '*.svx');
    if nomeArq = '' then
        begin
            mensagem ('XDDESIST', 1);   //'Desistiu...');
            exit;
        end;

    assign (arq, nomeArq);
    {$I-} rewrite(arq, 1); {$I+}
    if ioresult <> 0 then goto erro;
    {$I-} blockWrite(arq, firstVar, integer(@(lastVar)) - integer(@(firstVar)));  {$I+}
    if ioresult <> 0 then goto erro;
    close (arq);
    exit;

erro:
    mensagem ('XDERRGRV', 1);   //'Erro ao gravar');
    close (arq);
end;

(* load the saved game *)

procedure loadSavedGame;
var nomeArq: string;
    arq: file;
label erro;
begin
    garanteEspacoTela (10);
    mensagem ('XDNOMSVX', 1);   //'Qual o nome do arquivo .svx? ');
    nomeArq := obtemNomeArqMasc(10, '*.svx');
    if nomeArq = '' then
        begin
            mensagem ('XDDESIST', 1);   //'Desistiu...');
            exit;
        end;

    assign (arq, nomeArq);
    {$I-} reset (arq, 1); {$I+}
    if ioresult <> 0 then goto erro;
    {$I-} blockRead (arq, firstVar, integer(@(lastVar)) - integer(@(firstVar)));  {$I+}
    if ioresult <> 0 then goto erro;
    close (arq);
    exit;

erro:
    mensagem ('XDERRLEI', 1);   //'Erro ao ler');
    close (arq);
end;

(* save the game (in text format) for study *)

procedure saveForStudy;
var c, c2: char;
    nomeArq: string;
    i: integer;
    arq: textFile;
label erro;
begin
    mensagem ('XDDESGRV', 0);   //'Deseja gravar para futuro estudo? ');
    sintLeTecla (c, c2);
    if (upcase(c) = 'N') or (c = ESC) then exit;
    writeln;

    garanteEspacoTela (10);
    mensagem ('XDNOMXAD', 1);   //'Qual o nome do arquivo .xad? ');
    nomeArq := obtemNomeArqMasc(10, '*.xad');
    if nomeArq = '' then
        begin
            mensagem ('XDDESIST', 1);   //'Desistiu...');
            exit;
        end;

    assign (arq, nomeArq);
    rewrite(arq);

    write(arq, ' 8  ');
    for i := 0 to 63 do
        begin
            case color[i] of
                EMPTY: write(arq, ' . ');
                LIGHT: write(arq, ' ' + piece_char[piece[i]] + ' ');
                DARK:  write(arq, ' ' + lowerCase (piece_char[piece[i]])+ ' ');
            end;
            if (((i + 1) mod 8) = 0) and (i <> 63) then
                begin
                    writeln(arq);
                    write(arq, ' ', 7 - ROW(i), '  ');
                end;
        end;
    writeln(arq);
    writeln(arq, '     a  b  c  d  e  f  g  h');

    writeln(arq, '------------------------------------------');

    if hply <> 0 then
        begin
            for i := hply-1 downto 0 do
                writeln(arq, move_str(hist_dat[i].m.b));
        end;
    CloseFile (arq);
end;

(* debug file preparation *)

procedure debugSet;
var arqDebug: textFile;
begin
    debugging := not debugging;
    if debugging then
        begin
            mensagem ('XDCRIDBG', 1);   //'Criando arquivo para debug');
            assignFile (arqDebug, 'chessvox.dbg');
            rewrite(arqDebug);
            closeFile (arqDebug);
        end
    else
        mensagem ('XDDBGFIM', 1);   //'Debug finalizado');
end;

(* write a debug record *)

procedure debugRecord (s: string);
var arqDebug: textFile;
begin
    if not debugging then exit;

    assignFile (arqDebug, 'chessvox.dbg');
    {$I-} append (arqDebug);  {$I-}
    if ioresult <> 0 then
        rewrite(arqDebug);
    writeln(arqDebug, s);
    closeFile (arqDebug);
end;


end.

