{--------------------------------------------------------}
{
{    I Ching-VOX - Módulo de interatividade
{
{    Autor: José Antonio Borges
{
{    Em 24/06/97
{
{--------------------------------------------------------}

unit ichInter;
interface
    uses dvcrt, dvWin, dvExec, ichVars, ichTela, ichDisco;

procedure interacao;

implementation

var arqLeit: text;

{--------------------------------------------------------}
{                 ajuda da interacao
{--------------------------------------------------------}

procedure ajuda;
var y: integer;

begin
    for y := 4 to 25 do
        begin
            gotoxy (1, y);
            clreol;
        end;

    gotoxy (1, 6);
    writeln ('As opcoes sao:');
    writeln ('    D - exibe Diagnóstico');
    writeln ('    L - exibe Linhas Móveis');
    writeln ('    P - exibe Prognóstico');
    writeln ('    G - Grava o texto completo comentado');
    writeln ('    R - Resumo técnico');
    writeln ('    N - Nova consulta');
    writeln ('    F - Fim');
    writeln;
    writeln ('Dica: pense no Diagnóstico como sendo um retrato da Situação Atual,');
    writeln ('      nas Linhas Móveis como sendo Conselhos ou Comentários');
    writeln ('      e no Prognóstico como sendo a Situação Futura ou Resposta');

    sintSom ('ICAJUDA');
    sintSom ('ICDICA');

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                le o arquivo de leitura
{--------------------------------------------------------}

procedure leArqLeit;
var s: string;

    procedure sint (s: string);
    var s2: string;
        i: integer;
    begin
        s2 := '';
        i := 1;
        while i <= length (s) do
            begin
                case s[i] of
                    '.':  begin
                              sintetiza (s2);
                              s2 := '';
                              while sintFalando do;
                              delay (1200);
                          end;

                    ';', ':':  begin
                              sintetiza (s2);
                              s2 := '';
                              while sintFalando do;
                              delay (800);
                          end;

                    ',':  begin
                              sintetiza (s2);
                              s2 := '';
                              while sintFalando do;
                              delay (500);
                          end;
                else
                    s2 := s2 + s[i];
                end;

                i := i + 1;
            end;

        if s2 <> '' then
            sintetiza (s2);
    end;

label fim;
begin
    reset (arqLeit);
    while not eof (arqLeit) do
        begin
            if keypressed then
                goto fim;

            readln (arqLeit, s);
            if s = '*JULGAMENTO' then
                begin
                    sintSom ('ICPIN');
                    sintSom ('ICJULG');
                    delay (500);
                end
            else
            if s = '*IMAGEM' then
                begin
                    delay (500);
                    sintSom ('ICIMAG');
                    delay (500);
                end
            else
                sint (s);
        end;
fim:
    close (arqLeit);

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                    exibe arquivo
{--------------------------------------------------------}

procedure exibeArquivo (nomearq: string);
var
    nomeProg, nomeDir: string;
    status: integer;

begin
    nomeProg := sintAmbiente ('ICHINVOX', 'LEITOR');
    if nomeProg = '' then
         nomeProg := '\WINVOX\LEVOX.EXE';

    getdir (0, nomeDir);

    status := executaProg (nomeProg, nomeDir, nomearq);

    if status > 32 then
        esperaProgVoltar
    else
        begin
            writeln ('Erro ao executar o LEVOX: ', status);
            sintSom ('ICERRDOS');
        end;
end;

{--------------------------------------------------------}
{                exibe Julgamento e Imagem
{--------------------------------------------------------}

procedure mostraEssencia (hexa: integer; tipo: string);
var
    s: string;
begin
    telaBasica;
    gotoxy (1, 5);

    writeln (Tipo, ': ', hexa, ' - ', nomeHexagrama [hexa]);
    writeln;

    str (hexa, s);
    if not abreArqTexto ('ICH' + s + '.TXT') then
        exit;

{===== Julgamento =====}

    assign (arqLeit, '$.$$$');
    rewrite (arqLeit);

    while (not eof (arqTexto)) and (copy (s, 1, 7) <> '*JULGAM') do
         readln (arqTexto, s);

    if eof (arqTexto) then
         begin
             writeln ('Arquivo de textos ICH'+s+'.TXT danificado.  Reinstale o programa');
             sintSom ('ICARQDAN');
             exit;
         end;

    repeat
        readln (arqTexto, s);
    until s <> '';

    textBackground (BLUE);
    write ('JULGAMENTO');
    writeln (arqLeit, '*JULGAMENTO');
    textBackground (BLACK);
    writeln;

    repeat
        writeln (s);
        writeln (arqLeit, s);
        if eof (arqTexto) then
            s := ''
        else
            readln (arqTexto, s);
    until copy (s, 1, 7) = '';

{===== Imagem =====}

    writeln;
    while (not eof (arqTexto)) and (copy (s, 1, 7) <> '*IMAGEM') do
         readln (arqTexto, s);

    if eof (arqTexto) then
         begin
             writeln ('Arquivo de textos ICH'+s+'.TXT danificado.  Reinstale o programa');
             sintSom ('ICARQDAN');
             exit;
         end;

    repeat
        readln (arqTexto, s);
    until s <> '';

    textBackground (BLUE);
    write ('IMAGEM');
    writeln (arqLeit, '*IMAGEM');
    textBackground (BLACK);
    writeln;

    repeat
        writeln (s);
        writeln (arqLeit, s);
        if eof (arqTexto) then
            s := ''
        else
            readln (arqTexto, s);
    until copy (s, 1, 7) = '';

    close (arqTexto);
    writeln;

    str (hexa, s);
    sintSom ('ICHEX' + s);

    close (arqLeit);
    leArqLeit;
    erase (arqLeit);
end;

{--------------------------------------------------------}
{                  exibe diagnostico
{--------------------------------------------------------}

procedure exibeDiagnostico;
var c: char;
begin
    sintSom ('ICDIAG');
    mostraEssencia (hexaDiag, 'DIAGNÓSTICO');

    while keypressed do readkey;
    textBackground (RED);
    write ('Deseja explicações (S/N) ? ');
    sintSom ('ICQUEREX');
    textBackground (BLACK);
    c := readkey;
    write (c);
    sintCarac (c);
    if c = #$0 then c := readkey;
    if upcase (c) <> 'S' then
        begin
            write (#$0d);
            clreol;
            exit;
        end;


{===== explicacao detalhada =====}

    assign (arq, '$.$$$');
    rewrite (arq);
    if gravaDiagnostico (false) then
        begin
            close (arq);
            exibeArquivo ('$.$$$');
            telaBasica;
        end;
    erase (arq);
end;

{--------------------------------------------------------}
{                 exibe as linhas moveis
{--------------------------------------------------------}

procedure exibeLinhasMoveis;
var buscado, s: string;
    i: integer;
    cancelou: boolean;

    {--------------------------------------------------------}

    procedure listaLinhaMovel (i: integer);
    var n: string;
        c: char;

    label deNovo, cancela;

    begin
        reset (arqTexto);

        s := '';
        if i = 0 then  n := 'T'
                 else  str (i, n);

        buscado := '*' + n;
        while (not eof (arqTexto)) and (copy (s, 1, 2) <> buscado) do
            readln (arqTexto, s);

        repeat
            readln (arqTexto, s);
        until s <> '';

        textBackground (BLUE);
        write (s);
        textBackground (BLACK);
        writeln;

        s := ' ';

        assign (arqLeit, '$.$$$');
        rewrite (arqLeit);
        while not eof (arqTexto) and (copy (s, 1, 1) <> '') do
            begin
                 readln (arqTexto, s);
                 if (copy (s, 1, 1) <> '') then
                     begin
                         writeln (s);
                         writeln (arqLeit, s);
                     end;
            end;

        close (arqLeit);

deNovo:
        if n <> 'T' then
            begin
                sintNum (linDiag [i]);
                sintSom ('ICNA');
                sintSom (tabOrdem[i]);
                sintSom ('ICPOSIC');
            end
        else
            begin
                sintNum (linDiag [i]);
                sintSom ('ICEMTOD');
            end;

        leArqLeit;

        writeln;
        textBackground (RED);
        write ('Aperte uma tecla...');
        sintSom ('ICAPTEC');

        textBackground (BLACK);
        c := readkey;
        if c = #$1b then
            begin
                cancelou := true;
                goto cancela;
            end;

        if c = #$0  then 
            begin
                c := readkey;
                if c = CIMA then
                    begin
                        gotoxy (1, wherey-1);
                        goto deNovo;
                    end;
            end;

cancela:
        write (#$0d);
        clreol;

        erase (arqLeit);
        close (arqTexto);
    end;

    {--------------------------------------------------------}

var c: char;
begin
    telaBasica;
    gotoxy (1, 5);

    window (1, 5, 80, 24);

    writeln ('LINHAS MÓVEIS (MUTAÇÕES)');
    writeln;
    sintSom ('ICMUTAC');

    str (hexaDiag, s);
    if not abreArqTexto ('ICH' + s + '.TXT') then
        begin
            window (1, 1, 80, 25);
            exit;
        end;

    close (arqTexto);

    s := '';

    cancelou := false;
    case tipoMutacao of

        MUTACAO_USUAL:

            for i := 1 to 6 do
                if (linDiag[i] = 6) or (linDiag[i] = 9) then
                    begin
                        listaLinhaMovel (i);
                        if cancelou then
                             begin
                                 window (1, 1, 80, 25);
                                 exit;
                             end;
                    end;


        MUTACAO_TOTAL:
            listaLinhaMovel (0);

        MUTACAO_FIXA:
            begin
                writeln ('Nenhuma');
                sintSom ('ICNENHUM');
            end;
    end;

    window (1, 1, 80, 25);

    while keypressed do readkey;
    gotoxy (1, 24);
    textBackground (RED);
    write ('Deseja explicações (S/N) ? ');
    sintSom ('ICQUEREX');
    textBackground (BLACK);
    c := readkey;
    write (c);
    sintCarac (c);
    if c = #$0 then c := readkey;
    if upcase (c) <> 'S' then
        begin
            write (#$0d);
            clreol;
            exit;
        end;

{===== explicacao detalhada =====}

    assign (arq, '$.$$$');
    rewrite (arq);
    if gravaLinhas then
        begin
            close (arq);
            exibeArquivo ('$.$$$');
            telaBasica;
        end;
    erase (arq);
end;

{--------------------------------------------------------}
{                  exibe o prognostico
{--------------------------------------------------------}

procedure exibePrognostico;
var c: char;
begin
    sintSom ('ICPROG');
    mostraEssencia (hexaProg, 'PROGNÓSTICO');

    while keypressed do readkey;
    textBackground (RED);
    write ('Deseja explicações (S/N) ? ');
    sintSom ('ICQUEREX');
    textBackground (BLACK);
    c := readkey;
    write (c);
    sintCarac (c);
    if c = #$0 then c := readkey;

    if upcase (c) <> 'S' then
        begin
            write (#$0d);
            clreol;
            exit;
        end;


{===== explicacao detalhada =====}

    assign (arq, '$.$$$');
    rewrite (arq);
    if gravaPrognostico (false, true) then
        begin
            close (arq);
            exibeArquivo ('$.$$$');
            telaBasica;
        end;
    erase (arq);
end;

{--------------------------------------------------------}
{                controle da interacao
{--------------------------------------------------------}

procedure interacao;
var c: char;
    processando: boolean;
begin
    processando := true;
    outraConsulta := false;

    while keypressed do readkey;

    while processando do
        begin
            gotoxy (1, 24);
            textBackground (RED);
            write ('Qual sua opção (aperte F1 para ajuda): ');
            textBackground (BLACK);
            sintSom ('ICPIN');
            sintSom ('ICOPCAO');
            clreol;
            c := readkey;
            write (c);
            sintCarac (c);

            gotoxy (1, 21);  clreol;
            gotoxy (1, 22);  clreol;
            gotoxy (1, 23);  clreol;
            gotoxy (1, 24);  clreol;

            if c = #0 then
                 begin
                     readkey;
                     ajuda;
                 end
            else
                case upcase(c) of
                    'D':  exibeDiagnostico;
                    'L':  exibeLinhasMoveis;
                    'P':  exibePrognostico;
                    'G':  gravaTudo;
                    'R':  exibeTelaResumo;
                    'N':  begin
                               processando := false;
                               outraConsulta := true;
                          end;
                    ESC,
                    'F':  processando := false;
                else
                    ajuda;
                end;
        end;

    gotoxy (1, 24);
    clreol;
end;

end.
