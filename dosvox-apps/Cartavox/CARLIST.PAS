{-------------------------------------------------------------}
{
{           Cartavox - produz lista de cartas
{
{-------------------------------------------------------------}

unit carList;

interface

uses
    dvcrt,
    dvWin,
    sysUtils,
    windows,
    carCopia,
    carEst,
    carMsg,
    carUtil,
    carTela,
    dvform,
    carVars;

procedure montaListaDeCartas (extensao: string; tipo: char);
procedure desmontaListaDeCartas;
procedure ordenarLista (s: string; ordemInversa, falar: boolean);
procedure escolheOrdenacao ( folheiaRecebidas: boolean);
procedure removeCartasDuplicadas (falaMensagem: boolean); {}
procedure apagaArquivosTemporarios;

implementation

{--------------------------------------------------------}
{       ordena pelo metodo quick sort
{--------------------------------------------------------}

procedure Sort(l, r: Integer; ordemInversa: boolean);
var
    i, j: integer;
    x: string;
    ppes: PEstrutura;
begin
    i := l;
    j := r;

    ppes := regLido[(l+r) div 2];
    x := ppes^.carta^.aux;
    x := semAcentos (x);

    repeat
        if ordemInversa then
            begin
                while semAcentos (regLido[i]^.carta^.aux) > x do
                    i := i + 1;
                while x > semAcentos (regLido[j]^.carta^.aux) do
                    j := j - 1;
            end
        else
            begin
                while semAcentos (regLido[i]^.carta^.aux) < x do
                    i := i + 1;
                while x < semAcentos (regLido[j]^.carta^.aux) do
                    j := j - 1;
            end;

        if i <= j then
            begin
                ppes := regLido[i];
                regLido[i] := regLido[j];
                regLido[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then Sort(l, j, ordemInversa);
    if i < r then Sort(i, r, ordemInversa);
end;

{       Ordena recebendo um longint.        }

procedure SortLongInt(l, r: Integer; ordemInversa: boolean);
var
    i, j: integer;
    x: longInt;
    ppes: PEstrutura;

begin
    i := l;
    j := r;

    ppes := regLido[(l+r) div 2];
    x := ppes^.carta^.auxLongInt;
    repeat
        if ordemInversa then
            begin
                while regLido[i]^.carta^.auxLongInt > x do
                    i := i + 1;
                while x > regLido[j]^.carta^.auxLongInt do
                    j := j - 1;
            end
        else
            begin
                while regLido[i]^.carta^.auxLongInt < x do
                    i := i + 1;
                while x < regLido[j]^.carta^.auxLongInt do
                    j := j - 1;
            end;

        if i <= j then
            begin
                ppes := regLido[i];
                regLido[i] := regLido[j];
                regLido[j] := ppes;
                i := i + 1;
                j := j - 1;
            end;
    until i > j;

    if l < j then SortLongInt(l, j, ordemInversa);
    if i < r then SortLongInt(i, r, ordemInversa);
end;

{--------------------------------------------------------}
{       Ordena as cartas recebendo o parametro de ordenação
{--------------------------------------------------------}

procedure ordenarLista (s: string; ordemInversa, falar: boolean);
var
    i, p: integer;
    hora, minu, segu, dia, mes, ano, aux: string;
    selecionado: boolean;
begin
    if numRegs <= 1 then exit;

    if falar then
        begin
            if s = 'datahora' then
                msgBaixo ('CTORDLIC')  {'Ordenando a lista de cartas pela data de chegada ...'}
            else
            if s = 'date' then
                msgBaixo ('CTORDLIE')  {'Ordenando a lista de cartas pela data de envio ...'}
            else
            if s = 'subject' then
                msgBaixo ('CTORDASS')  {'Ordenando a lista de cartas pelo assunto...'}
            else
            if (s = 'from') or (s = 'to_') then
                msgBaixo ('CTORDNOM')  {'Ordenando a lista de cartas pelo nome...'}
            else
            if s = 'tamanho' then
                msgBaixo ('CTORDTAM');  {'Ordenando a lista de cartas pelo tamanho...'}
        end;
    while sintFalando do waitMessage;

    if (s <> 'tamanho') and (s <> 'datahora') then
        for i := 1 to numRegs do
            if not regLido [i]^.carta^.preenchido then
                begin
                    selecionado := regLido [i]^.selecionado;
                    carregaArqPreencheCabPrin ( i);
                    regLido [i]^.selecionado := selecionado;
                    if clek and ((i mod 500) = 0) then sintclek;
                    if keypressed then quantasCartasDoTotal (i, numRegs);
                end;

    if s = 'date' then
        for i := 1 to numRegs do
            begin
                aux := regLido[i]^.carta^.date;
                ano := convertedata(aux,false);
                ano := trim (copy (ano, pos ('/', ano)-2, 10));
                p := pos ('/', ano);
                dia := copy (ano, 1, p - 1);
                if length (dia) = 1 then dia := '0' + dia;
                delete (ano, 1, p);
                p := pos ('/', ano);
                mes := copy (ano, 1, p - 1);
                if length (mes) = 1 then mes := '0' + mes;
                delete (ano, 1, p);
                if length (ano) > 4 then ano := copy (ano, 1, 4);
                ano := ano + mes + dia;
                p := pos (':', aux);
                hora := trim (copy (aux, p - 2, 2));
                if length (hora) = 1 then hora:= '0' + hora;
                delete (aux, 1, p);
                p := pos (':', aux);
                minu := copy (aux, 1, p-1);
                if length (minu) = 1 then minu := '0' + minu;
                delete (aux, 1, p);
                segu := trim (copy (aux, 1, 2));
                if length (segu) = 1 then segu := '0' + segu;
                hora := hora + minu + segu;
                regLido[i]^.carta^.aux := ano + hora;
            end
    else
    if s = 'datahora' then
        for i := 1 to numRegs do
            regLido[i]^.carta^.auxLongInt := regLido [i]^.carta^.datahora
    else
    if s = 'subject' then
        for i := 1 to numRegs do
            regLido[i]^.carta^.aux := regLido[i]^.carta^.subject
    else
    if s = 'from' then
        for i := 1 to numRegs do
            begin
                regLido[i]^.carta^.aux := regLido[i]^.carta^.from;
                deletaAspas (regLido[i]^.carta^.aux);
                deletaMenorMaior (regLido[i]^.carta^.aux);
            end
    else
    if s = 'to_' then
        for i := 1 to numRegs do
            begin
                regLido[i]^.carta^.aux := regLido[i]^.carta^.to_;
                deletaAspas (regLido[i]^.carta^.aux);
                deletaMenorMaior (regLido[i]^.carta^.aux);
            end
    else
    if s = 'tamanho' then
        for i := 1 to numRegs do
            regLido[i]^.carta^.auxLongInt := regLido[i]^.carta^.tamanho
    else
    if s = 'message-id' then
        for i := 1 to numRegs do
            regLido[i]^.carta^.aux := regLido[i]^.carta^.message_id
    else
    if s = 'posServ' then
        for i := 1 to numRegs do
            regLido[i]^.carta^.auxLongInt := regLido[i]^.posServ;

    if (s = 'datahora') or (s = 'tamanho') or (s = 'posServ') then
        sortLongInt (1, numRegs, ordemInversa)
    else
        sort (1, numRegs, ordemInversa);

    if falar then
        msgBaixo ('CTOKORD');  {'Ok, cartas ordenadas.'}
end;

{-------------------------------------------------------------}
{       Escolhe o tipo de ordenação da lista de cartas
{-------------------------------------------------------------}

procedure escolheOrdenacao (folheiaRecebidas: boolean);

    procedure ajuda;
    begin
        telaFolheamentoCartas;
        textBackground(BLUE);
        if not keypressed then
            mensagem ('CTAJOR00', 2);  {'Os tipos de ordenação são:'}
        textBackground(BLACK);

        mensagem ('CTAJOR01', 1);  {'C - Data de chegada'}
        mensagem ('CTAJOR02', 1);  {'E - Data de Envio'}
        mensagem ('CTAJOR03', 1);  {'A - Assunto'}
        mensagem ('CTAJOR04', 1);  {'N - Nome'}
        mensagem ('CTAJOR05', 1);  {'T - Tamanho'}
        mensagem ('CTAJOR06', 1); {'I - Inversa'}
        clreol;
        writeln;
        if keypressed and (readkey <> ESC) then
            begin
                limpaBufTec;
                readkey;
            end;
        limpaBufTec;
    end;

    function selSetasFolheia: char;
    var
        n: integer;
    const
        tabOrd: string [6] = 'CEANTI';
    begin
        popupMenuCria (35, wherey, 50, 6, RED);
        MenuAdiciona ('CTAJOR01'); {'C - Data de chegada'}
        MenuAdiciona ('CTAJOR02');  {'E - Data de Envio'}
        MenuAdiciona ('CTAJOR03');  {'A - Assunto'}
        MenuAdiciona ('CTAJOR04');  {'N - Nome'}
        MenuAdiciona ('CTAJOR05');  {'T - Tamanho'}
        MenuAdiciona ('CTAJOR06');  {'I - Inversa'}
        n := popupMenuSeleciona;
        if (n > 0) and (n <= 6) then
            selSetasFolheia := tabOrd [n]
        else
            selSetasFolheia := ' ';
    end;

var c, c2: char;
begin
    telaFolheamentoCartas;
    writeln;
    writeln;

    mensagem ('CTQUATOR', 1); {'Qual o tipo de ordenação?'}
    mensagem ('CTF1AJUD', 0); {'F1 ajuda '}
    sintLeTecla (c, c2);
    writeln;

    if (c = #0) and (c2 in [BAIX, CIMA]) then
        c := selSetasFolheia
    else
    if c = #0 then
        begin
            ajuda;
            escolheOrdenacao(folheiaRecebidas);
            exit;
        end;

    case upcase (c) of
        'C': ordenarLista ('datahora', ordemInversa, true);
        'E': ordenarLista ('date', ordemInversa, true);
        'N': if folheiaRecebidas then
                    ordenarLista ('from', ordemInversa, true)
             else
                    ordenarLista ('to_', ordemInversa, true);
        'A': ordenarLista ('subject', ordemInversa, true);
        'T': ordenarLista ('tamanho', ordemInversa, true);
        'I': begin
                    ordemInversa := not ordemInversa;
                    ordenarLista ('datahora', ordemInversa, true);
             end
    else
        if c <> ESC then
            mensagem ('CTOPCINV', 2)   {'Opção inválida'}
        else
            mensagem ('CTDESIST', 2); {'Desistiu'}
    end;
end;

{--------------------------------------------------------}
{       monta lista de cartas
{--------------------------------------------------------}

procedure montaListaDeCartas (extensao: string; tipo: char);
var
    DirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError: integer;
    nomeArq: string;
    contaAtual: boolean;

label proximoArq;

begin
    numRegs := 0;

    if (tipo in [^N, ^L, ^F, ^T, ^P]) and (prefixoNomeArq <> '') then
        contaAtual := true
    else
        contaAtual := false;

    strPcopy (ext, '*.'+extensao);
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while (DosError = 0) and (numRegs < maxCartas) do
        begin
            nomeArq := trim(dirInfo.name);
            if contaAtual and
            (prefixoNomeArq <> copy (nomeArq, 1, length(prefixoNomeArq))) then
                goto proximoArq;

            if (upcase (tipo) in ['L', ^L]) and
            (upcase (nomeArq[length (nomeArq) - 4]) <> 'M') then
                goto proximoArq
            else
                if (upcase (tipo) in ['N', ^N]) and
                (upcase (nomeArq[length (nomeArq) - 4]) = 'M') then
                    goto proximoArq;

            if  agruparPorAssunto and
              (upcase (tipo) in ['N', ^N]) and
              (upcase (nomeArq[length (nomeArq) - 4]) in ['M', 'G']) then
                    goto proximoArq;

            numRegs := numregs + 1;
            regLido [numRegs] := inicializaPEstrutura;
            regLido [numRegs]^.carta := inicializaPCarta;
            regLido [numRegs]^.carta^.nomArqCarta := nomeArq;
            regLido [numRegs]^.carta^.dataHora := dirInfo.Time;
            regLido [numRegs]^.carta^.tamanho := dirInfo.size;
proximoArq:
            dosError := FindNext (DirInfo);
        end;
end;

{-------------------------------------------------------------}
{       Desmonta a lista das cartas
{-------------------------------------------------------------}

procedure desmontaListaDeCartas;
begin
    while numRegs > 0 do
        begin
            regLido[numRegs]^.carta^.partesCarta.free;
            dispose (regLido[numRegs]);
            numRegs := numregs - 1;
        end;
end;

{-------------------------------------------------------------}
{       Apaga as cartas não lidas duplicadas do diretório.
{-------------------------------------------------------------}

procedure removeCartasDuplicadas (falaMensagem: boolean); {}
var
    c : char;
    dirAtual: string;
    nCar, numCarremov: integer;
    bipMudo: boolean;

    procedure apagaCartaIgual;
    var
    nCarApagar: integer;
label apagarCartaVazia;
    begin
        nCarApagar := nCar;
        if regLido [nCar]^.carta^.tamanho = 0 then goto apagarCartaVazia;
        if not ( regLido[nCar]^.carta^.tamanho = regLido[nCar - 1]^.carta^.tamanho ) then exit;

        if not regLido [nCar]^.carta^.preenchido then
            carregaArqPreencheCabPrin ( nCar);
        if not regLido [nCar - 1]^.carta^.preenchido then
            carregaArqPreencheCabPrin (nCar - 1);

        if trim (regLido[nCar]^.carta^.message_id) = '' then exit;
        if (regLido[nCar]^.carta^.message_id = regLido[nCar - 1]^.carta^.message_id) and
           (regLido[nCar]^.carta^.date = regLido[nCar - 1]^.carta^.date) and
           (regLido[nCar]^.carta^.subject = regLido[nCar - 1]^.carta^.subject) and
           (regLido[nCar]^.carta^.from = regLido[nCar - 1]^.carta^.from) then
            begin
            apagarCartaVazia:
                if apagaCarta ( nCarApagar, true) then
                    numCarRemov := numCarRemov + 1;
            end;
        if not bipMudo then
            if (nCar mod 200) = 0 then sintclek;
    end;

begin
    numCarRemov := 0;
    bipMudo := false;
    getDir (0, dirAtual);
    {$I-}  chdir (dirRecebe);  {$I+}
    if ioresult <> 0 then ;
    montaListaDeCartas ('CAR', 'N');
    if falaMensagem then {}
    begin
            msgBaixo ('CTENAPDU'); {'Tecle ENTER para apagar as cartas duplicadas não lidas'}
            c := readkey;
            if c <> ENTER then
                begin
                    msgBaixo ('CTDESIST'); {'Desistiu'}
                    exit;
                end;
            msgBaixo ('CTAPCADU'); {'Apagando cartas duplicadas  não lidas ...'}
        end;
    if numRegs < 2 then exit;

    ordenarLista ('tamanho', false, false);

    for nCar := numRegs downto 2 do
        begin
            apagaCartaIgual;
            if keypressed then
                begin
                    bipMudo := not bipMudo;
                    limpabuftec;
                end;
        end;

    if falaMensagem then {}
        if numCarRemov = 0 then
            begin
                mensagem ('CTOK', 0); {'OK'}
                write (', ');
                mensagem ('CTNACHEI', 1); {'Não achei'}
            end
        else
        if numCarRemov = 1 then
            mensagem ('CTOKAPA', 1) {'Ok, carta apagada'}
        else
        if numCarRemov > 1 then
            begin
                mensagem ('CTOKAPAS', 0); {'Ok, cartas apagadas'}
                sintWriteln (' '+ intToStr(numCarRemov));
            end;
    desmontaListaDeCartas;
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;
    limpabuftec;
end;

{-------------------------------------------------------------}
{       Apaga os arquivos *.$$$ e *.tmp do diretório de cartas recebidas
{-------------------------------------------------------------}

procedure apagaArquivosTemporarios;
var
    DirInfo: TSearchRec;
    ext: array [0..10] of char;
    dosError: integer;
    nomeArq, s, dirAtual: string;
begin
    getDir(0, dirAtual);
    {$I-}  chdir (dirRecebe);  {$I+}
    if ioresult <> 0 then  exit;

    strPcopy (ext, '*.*');
    dosError := FindFirst (ext, FaArchive, DirInfo);
    while DosError = 0 do
        begin
            nomeArq := trim(dirInfo.name);
            s := uppercase (copy (nomeArq, length(nomeArq) - 3, 4));
            if (s = '.$$$') or (s = '.TMP') then
                if not deletaArquivo(nomeArq) then break;
            dosError := FindNext (DirInfo);
        end;
    {$I-}  chdir (dirAtual);  {$I+}
    if ioresult <> 0 then;

    deletaArquivo(dirRecebe+ '\$.html');
    deletaArquivo(dirRecebe+ '\$.htm');
    deletaArquivo(dirEnvia + '\$.html');
    deletaArquivo(dirEnvia+ '\$.htm');
    deletaArquivo(dirEnvia+ '\$2.$');
//    deletaArquivo(dirEnvia+ '\$.$');
end;

{-------------------------------------------------------------}
begin
end.
