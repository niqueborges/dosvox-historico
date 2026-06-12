{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de tratamento de arquivos
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plarq;
interface
uses
    dvcrt, dvwin, dvarq, sysUtils, classes,
    plvars, plmsg, plcelula, pltela, plcomp, plcalc;

procedure novaPlanilha (inic: boolean);
function carregaPlanilha (nomeArq: string): boolean;
function carregaCSV (nomeArq: string): boolean;
function guardaPlanilha (nomeArq: string): boolean;

procedure LeArquivo (importando: boolean);
procedure GravaArquivo;
procedure GravaTexto;
procedure NovoNome (extensao: string; var nomeArq: string);
function ExportaArquivo (nomeArq: string): boolean;

implementation

{--------------------------------------------------------}
{               pergunta nome do arquivo
{--------------------------------------------------------}

procedure NovoNome (extensao: string; var nomeArq: string);
var
    s: string;
begin
    pergunta ('PLQUENOM');    {'Qual o nome do arquivo da planilha? '}

    s := obtemNomeArqMasc(10, '*.' + extensao);
    s := trim (s);

    if ansiUpperCase (copy (s, length (s)-3, 4)) = '.' + extensao then
         delete (s, length (s)-3, 4);
    if s <> '' then
        s := s + '.' + extensao
    else
        begin
            pergunta ('');
            informa ('PLDESIS');
            exit;
        end;

    nomeArq := s;
end;

{--------------------------------------------------------}
{                  cria uma nova planilha
{--------------------------------------------------------}

procedure novaPlanilha (inic: boolean);
var c: char;
    x, y: integer;
begin
    if inic then
        begin
            for y := 1 to MAXLINPLAN do
                plan [y] := NIL;
        end
    else
        begin
            gotoxy (1, 2);
            mensagem ('PLCNFNOV');
            c := readkey;
            if upcase(c) <> 'S' then
                begin
                    mensagem ('PLDESIS');
                    exit;
                end;

            for y := 1 to MAXLINPLAN do
                if plan[y] <> NIL then
                    for x := 1 to MAXCELLINHA do
                        removeCelula (x, y);
        end;

    xatual := 1;
    yatual := 1;
    nomePlan := '';
    getdir (0, nomeDir);
    nomeArq := '';

    xceltela := 1;
    yceltela := 1;

    for x := 1 to MAXCELLINHA do
        col[x].largColuna := 15;

    with blocoAtual do
        begin
            xbloco1 := 0;
            xbloco2 := 0;
            ybloco1 := 0;
            ybloco2 := 0;
        end;

    alterouTodaTela := true;
    tipoRecalc := porLinha;

    cabecalho;
    mostraTela;
end;

{--------------------------------------------------------}
{              carrega a planilha de disco
{--------------------------------------------------------}

{$I-}

function carregaPlanilha (nomeArq: string): boolean;

var arq: text;

     function leCelula (x, y: integer): boolean;
     var s: string;
         c: char;
         erro: integer;
         processando: boolean;

     begin
         leCelula := false;

         criaCelula (x, y);    { completar: verificar quant. memoria }

         processando := true;
         repeat
             readln (arq, s);
             c := s[1];
             delete (s, 1, 1);

             with plan[y]^.cel[x]^ do
                 begin

                     case c of
                     'C':  begin
                               conteudo := s;
                           end;

                     'T':  begin
                               val (s, tipo, erro);
                               if tipo = form then tipoResultComput := 2;
                               if erro <> 0 then exit;
                           end;

                     'F':  begin
                               val (s, formato, erro);
                               if erro <> 0 then exit;
                           end;
                     'D':  begin
                               val (s, casasDec, erro);
                               if erro <> 0 then exit;
                           end;
                     'I':  begin
                               val (s, alinhamento, erro);
                               if erro <> 0 then exit;
                           end;
                     'V':  begin
                               while (s <> '') and (s[1] = ' ') do
                                   delete (s, 1, 1);
                               val (s, valor, erro);
                               if erro <> 0 then exit;
                           end;
                     'R':  begin
                               val (s, tipoResultComput, erro);
                               if erro <> 0 then exit;
                           end;

                     '@':  processando := false;

                     else
                         exit;
                     end;
                 end;

         until not processando;
         leCelula := true;
     end;

var
    x, y: integer;
    s: string;

label erro, fim;

begin
    informa ('PLLENDO');  {'Lendo planilha... '}

    carregaPlanilha := false;
    if nomeArq = '' then
        begin
            informa ('PLERRNOM');   {'Nome de arquivo incorreto'}
            exit;
        end;

    assign (arq, nomeArq);
    reset (arq);
    if ioresult <> 0 then
        begin
            informa ('PLARQNAO');   {'Arquivo não existe'}
            exit;
        end;

    while not eof (arq) do
        begin
            readln (arq, s);
            if ioresult <> 0 then goto erro;

            if s = '*NOMEPLAN' then
                 begin
                     readln (arq, nomeplan);
                     if nomePlan = '' then nomePlan := nomeArq;
                     if ioresult <> 0 then goto erro;
                 end

            else

            if s = '*POSICAO' then
                begin
                    readln (arq, xatual, yatual);
                    if ioresult <> 0 then goto erro;
                end

            else

            if s = '*TELA' then
                begin
                    readln (arq, xceltela, ycelTela, ultxTela);
                    if ioresult <> 0 then goto erro;
                end

            else

            if s = '*BLOCO' then
                begin
                    with blocoAtual do
                         readln (arq, xbloco1, ybloco1, xbloco2, ybloco2);
                    if ioresult <> 0 then goto erro;
                end

            else

            if s = '*RECALC' then
                begin
                    readln (arq, tipoRecalc);
                    if ioresult <> 0 then goto erro;
                end

            else

            if s = '*COLUNAS' then
                begin
                    readln (arq) {MAXCELLINHA};
                    if ioresult <> 0 then goto erro;

                    for x := 1 to MAXCELLINHA do
                        begin
                            readln (arq, col[x].largColuna);
                            if ioresult <> 0 then goto erro;
                        end;
                end

            else

            if s = '*' then
                begin
                    readln (arq, x, y);
                    if ioresult <> 0 then goto erro;

                    if not leCelula (x, y) then
                        goto erro;
                end;
        end;

    close (arq);
    if ioresult <> 0 then goto erro;

    carregaPlanilha := true;
    goto fim;

erro:
    close (arq);
    if ioresult <> 0 then
                ;
    gotoxy (1, 2);
    mensagem ('PLERRLEI');
    if readkey = #0 then if readkey = #0 then;

fim:
    cabecalho;
    mostraCabColunas;
    mostraTela;
    setWindowTitle('Planivox ' + nomePlan);
end;

{$I+}

{--------------------------------------------------------}
{       carrega texto separado por ponto-e-vírgula
{--------------------------------------------------------}

{$I-}

function carregaCSV (nomeArq: string): boolean;
var arq: textFile;
    campo, s: string;
    x, y: integer;
    ok: boolean;
    linhas: TStringList;
label erro, fim;
begin
    carregaCSV := false;
    if not fileExists (nomeArq) then
        begin
            informa ('PLARQNAO');   {'Arquivo não existe'}
            exit;
        end;

    linhas := TStringList.Create;
    linhas.LoadFromFile(nomeArq);

    ok := true;
    for y := 1 to linhas.Count do
        begin
            if y > MAXLINPLAN then
                 begin
                     informa ('PLERMAXI');  {'Excedido tamanho máximo para importação'}
                     goto erro;
                 end;

            s := linhas[y-1];

            x := 0;

            while s <> '' do
                begin
                    x := x + 1;

                    campo := '';
                    while (s <> '') and (s[1] <> ';') do
                        begin
                            campo := campo + s[1];
                            delete (s, 1, 1);
                        end;
                    if s <> '' then
                        delete (s, 1, 1);   // remove ptvg

                    if x > MAXCELLINHA then continue;  // previne problemas

                    if (campo <> '') then
                        begin
                            ok := formataCelula (x, y, campo);
                            if campo [1] = '=' then
                                ok := ok and compilaFormula (x, y, campo);
                        end
                    else
                        if campo = '' then
                            removeCelula(x, y)
                        else
                            formataCelula (x, y, campo);
                end;

        end;

    if not ok then
        informa ('PLERREXP');    {'Expressão mal formada'}

    recalcular;

    close (arq);
    if ioresult <> 0 then goto erro;

    carregaCSV := true;
    linhas.Free;
    goto fim;

erro:
    if readkey = #0 then readkey;

fim:
    delete (nomeArq, length(nomeArq)-3, 4);
    nomeArq := nomeArq + '.PLA';

    cabecalho;
    mostraCabColunas;
    mostraTela;
end;

{$I+}

{--------------------------------------------------------}
{               guarda a planilha em disco
{--------------------------------------------------------}

{$I-}

function guardaPlanilha (nomeArq: string): boolean;

var arq: text;

     function gravaCelula (x, y: integer): boolean;
     begin
         gravaCelula := false;
         with plan[y]^.cel[x]^ do
             begin
                 if conteudo <> '' then    writeln (arq, 'C', conteudo);
                 if ioresult <> 0 then exit;

                 if tipo <> nada then      writeln (arq, 'T', tipo);
                 if ioresult <> 0 then exit;

                 if formato <> 0 then      writeln (arq, 'F', formato);
                 if ioresult <> 0 then exit;

                 if casasDec <> 0 then     writeln (arq, 'D', casasDec);
                 if ioresult <> 0 then exit;

                 if alinhamento <> 0 then        writeln (arq, 'I', alinhamento);
                 if ioresult <> 0 then exit;

                 if valor <> 0 then        writeln (arq, 'V', valor);
                 if ioresult <> 0 then exit;

                 if tipoResultComput <> 0 then      writeln (arq, 'R', tipoResultComput);
                 if ioresult <> 0 then exit;

                 writeln (arq, '@');
                 if ioresult <> 0 then exit;
             end;

         gravaCelula := true;
     end;

var
    x, y: integer;
label erro;

begin
    informa ('PLGRVAND');   {'Gravando planilha'}

    guardaPlanilha := false;
    if nomeArq = '' then
        begin
            gotoxy (1, 2);
                informa ('PLERRNOM');    {'Nome de arquivo incorreto'}
            exit;
        end;

    assign (arq, nomeArq);
    rewrite (arq);
    if ioresult <> 0 then
        begin
erro:
            close (arq);
            if ioresult <> 0 then
                ;
            informa ('PLERRESC');    {'Erro de escrita no disco'}
            exit;
        end;

    writeln (arq, '*NOMEPLAN');
    if ioresult <> 0 then goto erro;
    writeln (arq, nomeplan);
    if ioresult <> 0 then goto erro;

    writeln (arq, '*POSICAO');
    if ioresult <> 0 then goto erro;
    writeln (arq, xatual, ' ', yatual);
    if ioresult <> 0 then goto erro;

    writeln (arq, '*TELA');
    if ioresult <> 0 then goto erro;
    writeln (arq, xceltela, ' ', ycelTela, ' ', ultxTela);
    if ioresult <> 0 then goto erro;

    writeln (arq, '*BLOCO');
    if ioresult <> 0 then goto erro;
    with blocoAtual do
        writeln (arq, xbloco1, ' ', ybloco1, ' ', xbloco2, ' ', ybloco2);
    if ioresult <> 0 then goto erro;

    writeln (arq, '*RECALC');
    if ioresult <> 0 then goto erro;
    writeln (arq, tipoRecalc);
    if ioresult <> 0 then goto erro;

    writeln (arq, '*COLUNAS');
    if ioresult <> 0 then goto erro;
    writeln (arq, MAXCELLINHA);
    if ioresult <> 0 then goto erro;

    for x := 1 to MAXCELLINHA do
        begin
            writeln (arq, col[x].largColuna);
            if ioresult <> 0 then goto erro;
        end;

    for y :=1 to MAXLINPLAN do
        for x := 1 to MAXCELLINHA do
            if existeCelula (x, y) then
                begin
                    writeln (arq, '*');
                    if ioresult <> 0 then goto erro;
                    writeln (arq, x, ' ', y);
                    if ioresult <> 0 then goto erro;
                    if not gravaCelula (x, y) then
                        goto erro;
                end;

    close (arq);
    if ioresult <> 0 then goto erro;

    informa ('PLOK');
    guardaPlanilha := true;
end;

{$I+}

{--------------------------------------------------------}
{                   le uma planilha
{--------------------------------------------------------}

procedure LeArquivo (importando: boolean);
var
    x, y: integer;
    c: char;
label gravar, pula;

begin
    for y := 1 to MAXLINPLAN do      { ve se planilha vazia }
        if plan[y] <> NIL then
            goto gravar;
    goto pula;

gravar:
    pergunta ('PLQUERGV');    {'Posso gravar esta planilha? '}
    c := readkey;
    case upcase (c) of
        #$1b:  begin
                   mensagem ('PLDESIS');   {'Desistiu'}
                   exit;
               end;

        'S':   gravaArquivo;
    end;

pula:
    for y := 1 to MAXLINPLAN do
        if plan[y] <> NIL then
            for x := 1 to MAXCELLINHA do
                removeCelula (x, y);

    if importando then
        begin
            novoNome ('CSV', nomeArq);
            if nomeArq <> '' then
                if carregaCSV (nomeArq) then
                    informa ('PLLIDA');
        end
    else
        begin
            novoNome ('PLA', nomeArq);
            if nomeArq <> '' then
                if carregaPlanilha (nomeArq) then
                    informa ('PLLIDA');
        end;
end;

{--------------------------------------------------------}
{                   grava uma planilha
{--------------------------------------------------------}

procedure GravaArquivo;
begin
    if nomeArq = '' then
        novoNome ('PLA', nomeArq);
    if guardaPlanilha (nomeArq) then
        informa ('PLGRAVAD');   {'Planilha gravada'}
end;

{--------------------------------------------------------}
{             Exporta arquivo em formato CSV
{--------------------------------------------------------}
{$I-}

function ExportaArquivo (nomeArq: string): boolean;

var arq: text;

     function gravaCelula (x, y: integer): boolean;
     begin
         gravaCelula := false;
         with plan[y]^.cel[x]^ do
             begin
                 if conteudo <> '' then    writeln (arq, 'C', conteudo);
                 if ioresult <> 0 then exit;

                 if tipo <> nada then      writeln (arq, 'T', tipo);
                 if ioresult <> 0 then exit;

                 if formato <> 0 then      writeln (arq, 'F', formato);
                 if ioresult <> 0 then exit;

                 if casasDec <> 0 then     writeln (arq, 'D', casasDec);
                 if ioresult <> 0 then exit;

                 if alinhamento <> 0 then        writeln (arq, 'I', alinhamento);
                 if ioresult <> 0 then exit;

                 if valor <> 0 then        writeln (arq, 'V', valor);
                 if ioresult <> 0 then exit;

                 writeln (arq, '@');
                 if ioresult <> 0 then exit;
             end;

         gravaCelula := true;
     end;

var
    x, y: integer;
    maxx, maxy: integer;
    nomeCsv: string;
    c: char;

label erro;

begin
    informa ('PLEXPORT');   {'Exportando planilha'}

    ExportaArquivo := false;

    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;

    maxy := y;
    if maxy <= 0 then
        begin
            informa ('PLVAZIA');    // planilha está vazia
            exit;
        end;

    maxx := 0;
    for y :=1 to maxy do
        for x := 1 to MAXCELLINHA do
            if existeCelula (x, y) then
                if maxx < x then maxx := x;

    nomeCsv := nomeArq;
    if nomeCsv = '' then nomeCSV := 'planivox.CSV'
    else
        begin
            delete (nomeCsv, length (nomeCsv)-3, 4);
            nomeCsv := nomeCsv + '.CSV';
        end;

    pergunta ('PLEDICSV');    {'Editore o nome do arquivo .CSV'}
    c := sintEditaCampo (nomeCsv, wherex, wherey, 255, 80, true);
    if c = ESC then
        begin
            informa ('PLDESIS');  {'Desistiu'}
            exit;
        end;

    assign (arq, nomeCsv);
    rewrite (arq);
    if ioresult <> 0 then
        begin
erro:
            close (arq);
            if ioresult <> 0 then
                ;
            informa ('PLERRESC');    {'Erro de escrita no disco'}
            exit;
        end;

    for y :=1 to maxy do
        begin
            for x := 1 to maxx do
                begin
                    if existeCelula (x, y) then
                        write (arq, plan[y]^.cel[x]^.conteudo);
                    if ioresult <> 0 then goto erro;
                    if x <> maxx then write (arq, ';');
                    if ioresult <> 0 then goto erro;
                end;
            writeln (arq);
            if ioresult <> 0 then goto erro;
        end;

    close (arq);
    if ioresult <> 0 then goto erro;

    informa ('PLOK');
    ExportaArquivo := true;
end;
{$I+}

{--------------------------------------------------------}
{             Grava arquivo em formato Texto
{--------------------------------------------------------}

{$I-}
procedure GravaTexto;
var nomeTxt: string;
    arq: textFile;
    maxx, maxy, x, y, acum: integer;
    s, saida: string;
    c: char;
    coluna: array [1..MAXCELLINHA] of integer;
label erro;
begin
    pergunta ('PLEDITXT');    {'Editore o nome do arquivo TXT'}
    nomeTxt := '';
    c := sintEditaCampo (nomeTxt, 1, wherey+1, 255, 80, true);
    if (c = ESC) or (nomeTxt = '') then
        begin
            informa ('PLDESIS');  {'Desistiu'}
            exit;
        end;

    if pos ('.', nomeTxt) = 0 then
        nomeTxt := nomeTxt + '.txt';

    assign (arq, nomeTxt);
    rewrite (arq);
    if ioresult <> 0 then
        begin
erro:
            close (arq);
            if ioresult <> 0 then
                ;
            informa ('PLERRESC');    {'Erro de escrita no disco'}
            exit;
        end;

    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;
    maxy := y;
    if maxy = 0 then maxy := 1;

    maxx := 1;
    for y :=1 to maxy do
        for x := maxx to MAXCELLINHA do
            if existeCelula(x, y) then  maxx := x;

    acum := 1;
    for x := 1 to MAXCELLINHA do
        begin
            coluna[x] := acum;
            acum := acum + col[x].largColuna;
        end;

    for y :=1 to maxy do
        begin
            saida := '';
            for x := 1 to maxx do
                begin
                    if existeCelula (x, y) then
                        s := criaStringSaida(x, y)
                    else
                        s := '';

                    if length (saida) >= coluna[x] then
                        delete (saida, coluna[x], 9999)
                    else
                        while length (saida) < coluna[x]-1 do
                            saida := saida + ' ';

                    saida := saida + s;
                end;

            writeln (arq, saida);
            if ioresult <> 0 then goto erro;
        end;

    close (arq);
    if ioresult <> 0 then goto erro;

    informa ('PLOK');
end;
{$I+}

end.

