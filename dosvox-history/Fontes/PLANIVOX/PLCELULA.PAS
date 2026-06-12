{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de geracao das celulas
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plcelula;
interface
uses
    dvCrt, dvWin, dvForm,
    sysutils, dvLeNum,
    plvars, plmsg, pltela, plcomp, plcalc;


procedure removeCelula (x, y: integer);
function existeCelula (x, y: integer): boolean;
procedure criaCelula (x, y: integer);
function formataCelula (x, y: integer; s: string): boolean;
function editaCelula (x, y: integer): char;
procedure vaiParaCelula;

procedure falaCelula (x, y: integer);
procedure falaRestoLinha (x, y: integer);
procedure falaRestoPlan (x, y: integer);
procedure statusCelula (x, y: integer);

procedure formatoCelula;
procedure larguraCelula;
procedure apagaCelula;
procedure justificaCelula;
procedure carimbaCelula;
procedure moveCelula;

procedure procuraCelula (proxima: boolean);
function selSetasOpFor: char;
function selSetasOpJus: char;

implementation

uses plbloco;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var procura: string;

{--------------------------------------------------------}
{                    remove uma celula
{--------------------------------------------------------}

procedure removeCelula (x, y: integer);
var i: integer;
begin
    if plan [y] = NIL then exit;
    if (x > MAXCELLINHA) or (plan [y]^.cel[x] = NIL) then exit;

    with plan [y]^ do
        begin
            dispose (cel[x]);
            cel[x] := NIL;
            for i := 1 to MAXCELLINHA do
                if cel[i] <> NIL then exit;
        end;

{--- se nao sobrou ninguem na linha ---}

    dispose (plan [y]);
    plan [y] := NIL;
end;

{--------------------------------------------------------}
{                    cria uma celula
{--------------------------------------------------------}

function existeCelula (x, y: integer): boolean;
begin
    existeCelula := (x <= MAXCELLINHA) and
                    (plan[y] <> NIL) and
                    (plan[y]^.cel[x] <> NIL);
end;

{--------------------------------------------------------}
{                    cria uma celula
{--------------------------------------------------------}

procedure criaCelula (x, y: integer);
var i: integer;
begin
    if x > MAXCELLINHA then
        begin
            if not keypressed then
                sintBip;
            exit;
        end;

    if existeCelula (x, y) then
        removeCelula(x, y);

    if plan [y] = NIL then   {--- linha nova ---}
        begin
            new (plan[y]);
            with plan[y]^ do
                begin
                    for i := 1 to MAXCELLINHA do
                        cel[i] := NIL;
                end;
        end;

    new (plan[y]^.cel[x]);
    with plan[y]^.cel[x]^ do
        begin
            conteudo := '';
            valor    := 0;
            tipo     := nada;
            formato  := geral;
            casasDec := 2;
            alinhamento := 0;
            resultComput := '';
            tipoResultComput := 0;
        end;
end;

{--------------------------------------------------------}
{                   formata uma celula
{--------------------------------------------------------}

function formataCelula (x, y: integer; s: string): boolean;

{--------------------------------------------------------}

    procedure criaCelulaAlfa (s: string);
    begin
        with plan[y]^.cel[x]^ do
            begin
                conteudo := s;
                tipo     := letras;
            end;
    end;

{--------------------------------------------------------}

    function numerico (s: string): boolean;
    var i, inic: integer;
    begin
       numerico := true;
       inic := 1;
       if s[1] = '-' then inic := inic + 1;
       for i := inic to length(s) do
           if not (s[i] in ['0'..'9', '.', ',']) then
               begin
                   numerico := false;
                   exit;
               end;
    end;

{--------------------------------------------------------}

    procedure criaCelulaNumerica (s: string);
    var copia: string;
        i, erro: integer;
        lido: real;

    begin
        copia := s;
        for i := 1 to length (copia) do
            if copia[i] = ',' then copia[i] := '.';
        val (copia, lido, erro);
        if erro <> 0 then
            begin
                gotoxy (1, 3);
                mensagem ('PLERRNUM');
                exit;
            end;

        with plan[y]^.cel[x]^ do
            begin
                valor := lido;
                tipo := numero;
            end;
    end;

{--------------------------------------------------------}

begin
    if x > MAXCELLINHA then
        begin
            formataCelula := false;
            exit;
        end;

    formataCelula := true;
    s := trimRight (s);

    if s = '' then
        begin
            removeCelula (x, y);
            informa ('PLLIMPA');
            exit;
        end;

    if not existeCelula (x, y) then
        criaCelula (x, y);

    criaCelulaAlfa (s);
    if numerico (s) then
        criaCelulaNumerica (s);
end;

{--------------------------------------------------------}
{                    edita uma celula
{--------------------------------------------------------}

function editaCelula (x, y: integer): char;
var s: string;
    c: char;
    ok: boolean;
begin
    if x > MAXCELLINHA then
        begin
            result := ENTER;
            exit;
        end;

    if existeCelula (x, y) then
        begin
            s := plan[y]^.cel[x]^.conteudo;
            informa ('PLPODEDI');
        end
    else
        begin
            s := '';
            informa ('PLCRIE');
        end;

    ok := false;
    repeat
        c := sintEditaCampo (s, 1, 3, 80, 80, true);
        if c <> ESC then
            if (s <> '') and (s[1] = '=') then
                begin
                    ok := formataCelula (x, y, s);
                    ok := ok and compilaFormula (x, y, s);
                    if ok then
                        begin
                            recalcular;
                            falaCelula (x, y);
                        end;
                end
            else
                begin
                    ok := formataCelula (x, y, s);
                    recalcular;
                end;
    until ok or (c = ESC);

    mostraLinha (yatual);

    if (c = ENTER) then
        informa ('PLOK')   {'OK'}
    else
        if (c = ESC) then
            informa ('PLDESIS');   {'Desistiu'}

    editaCelula := c;
end;

{--------------------------------------------------------}
{                        fala celula
{--------------------------------------------------------}

procedure falaCelula (x, y: integer);
var s: string;
begin
    if x > MAXCELLINHA then
        exit;

    if (plan[y] <> NIL) and (plan[y]^.cel[x] <> NIL) then
        begin
            with plan[y]^.cel[x]^ do
                case tipo of
                    nada: sintClek;

                    letras: if conteudo = '' then
                                sintClek
                            else
                                sintetiza (conteudo);

                    numero: begin
                                if (valor <= 9999999) and
                                    (valor - trunc(valor) = 0) then
                                         str (valor:8:0, s)
                                     else
                                        str(valor:8:casasDec, s);
                                sintetiza (s);
                            end;

                    form:   if tipoResultComput = letras then
                                sintetiza (resultComput)
                            else
                                begin
                                     if (valor <= 9999999) and
                                        (valor - trunc(valor) = 0) then
                                         str (valor:8:0, s)
                                     else
                                         str (valor:8:casasDec, s);
                                    sintetiza ('='+s);
                                end;
                end;
        end
    else
        sintclek;

    if falaPosCel then
        begin
            sintSoletra (chr (x-1+ord('a')));
            sintetiza (numeroParaString(y));
        end;
end;

{--------------------------------------------------------}
{                 fala resto da linha
{--------------------------------------------------------}

procedure falaRestoLinha (x, y: integer);
var ult: integer;
begin
    if plan[y] = NIL then
        begin
           sintclek; sintclek;
        end
    else
        begin
            ult := MAXCELLINHA;
            while (ult >= 1) and (plan[y]^.cel[ult] = NIL) do
                ult := ult - 1;

            if ult = 0 then
                begin
                    sintclek; sintclek;
                end;

            while (x <= ult) and (not keypressed) do
                begin
                    if plan[y]^.cel[x] <> NIL then
                         falaCelula (x, y);
                    x := x + 1;
                end;
        end;

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                  fala resto da planilha
{--------------------------------------------------------}

procedure falaRestoPlan (x, y: integer);
var ultLin: integer;
label achou;
begin
    falaRestoLinha (x, y);

    for ultLin := MAXLINPLAN downto y+1 do
        if plan[ultlin] <> NIL then goto achou;

    ultLin := y-1;

achou:
    while (y <= ultLin) and not keypressed do
        begin
            x := 1;
            y := y + 1;
            falaRestoLinha (x, y);
        end;

    while keypressed do readkey;
end;

{--------------------------------------------------------}
{                mostra status da celula
{--------------------------------------------------------}

procedure statusCelula (x, y: integer);
begin
    if x > MAXCELLINHA then
        exit;

    gotoxy (1, 2);
    if (plan[y] <> NIL) and (plan[y]^.cel[x] <> NIL) then
        begin
            with plan[y]^.cel[x]^ do
                 write ('tipo:', tipo, ' tresu:', tipoResultComput, ' form:', formato,
                        ' casadec:', casasDec, ' alin:', alinhamento, ' val:', valor:8:2 );
        end
    else
        sintWrite ('Nula');
end;

{--------------------------------------------------------}
{            Informa opções no menu formato de celula
{--------------------------------------------------------}

function selSetasOpFor: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'g$ncd';
begin
    popupMenuCria (wherex, wherey, 16, 5, MAGENTA);
    MenuAdiciona ('PLGAJUF1');  {'  G - Geral'}
    MenuAdiciona ('PLGAJUF2');  {'  $ - Dinheiro'}
    MenuAdiciona ('PLGAJUF5');  {'  N - Numérico'}
    MenuAdiciona ('PLGAJUF3');  {'  C - Científico'}
    MenuAdiciona ('PLGAJUF4');  {'  D - Data'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpFor := tabLetrasOpcoes[n]
    else
        selSetasOpFor := ENTER;
end;

{--------------------------------------------------------}
{        seleciona opção de formato com as setas
{--------------------------------------------------------}

procedure formatoCelula;
var c1, c2: char;
    s: string;
    i, erro: integer;
begin
    pergunta ('PLQUAFOR');  {'Qual o formato ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;
    if c1 = ESC then
        exit;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpFor;

    if not existeCelula (xatual, yatual) then
        criaCelula (xatual, yatual);
    with plan[yatual]^.cel[xatual]^ do
        case upcase(c1) of
            'G': formato := geral;
            '$': formato := dinheiro;
            'N': formato := numerico;
            'C': formato := cientifico;
            'D': formato := data;
        else
            informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
        end;

    pergunta ('PLNCASAS');  {'Se número, quantas decimais? '}
    sintReadln (s);
    if s <> '' then
        begin
            val (s, i, erro);
            if (erro = 0) and (i >= 0) and (i < 9) then
                plan[yatual]^.cel[xatual]^.casasDec := i;
        end;
end;

{--------------------------------------------------------}
{            especifica a largura da coluna
{--------------------------------------------------------}

procedure larguraCelula;
var larg, erro: integer;
    s: string;
begin
    pergunta ('PLQLARG');  {'Qual a largura da célula ? '}
    sintReadln (s);
    if s = '' then
        mensagem ('PLDESIS')
    else
        begin
            val (s, larg, erro);
            if (erro <> 0) or (larg > 75) or (larg < 1) then
               begin
                   gotoxy (50, 3);
                   mensagem ('PLERRNUM');
                   exit;
               end
            else
               begin
                   col[xatual].largColuna := larg;
                   mostraTela;
               end;
        end;

end;

{--------------------------------------------------------}
{                    apaga esta celula
{--------------------------------------------------------}

procedure apagaCelula;
begin
    removeCelula (xatual, yatual);
    mostraLinha (yatual);
end;

{--------------------------------------------------------}
{            Informa opções no menu justifica celula
{--------------------------------------------------------}

function selSetasOpJus: char;
var n: integer;
const
    tabLetrasOpcoes: string = 'aedc';
begin
    popupMenuCria (wherex, wherey, 16, 8, MAGENTA);
    MenuAdiciona ('PLGAJUJ1');  {'  A - Alto'}
    MenuAdiciona ('PLGAJUJ2');  {'  E - Esquerda'}
    MenuAdiciona ('PLGAJUJ3');  {'  D - Direita'}
    MenuAdiciona ('PLGAJUJ4');  {'  C - Centro'}
    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpJus := tabLetrasOpcoes[n]
    else
        selSetasOpJus := ENTER;
end;

{--------------------------------------------------------}
{                 seleciona opção de justificativa com as setas
{--------------------------------------------------------}

procedure justificaCelula;
var c1, c2: char;
begin
    pergunta ('PLQUAJUS');  {'Qual a justificativa ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpJus;

    if not existeCelula (xatual, yatual) then
        criaCelula (xatual, yatual);
    with plan[yatual]^.cel[xatual]^ do
        case upcase(c1) of
            'A': alinhamento := 0;
            'E': alinhamento := alinEsq;
            'D': alinhamento := alinDir;
            'C': alinhamento := centrada;
            ESC: ;
        else
            informa ('PLOPINV');  {'Opção inválida, aperte F1 para ajuda'}
        end;
end;

{--------------------------------------------------------}
{                 carimba celula em bloco
{--------------------------------------------------------}

procedure carimbaCelula;
var c: char;
    x, y: integer;
    celulaExiste: boolean;
    porig, pdest: PCELULA;
    s: string;

begin
    celulaExiste := (plan[yatual] <> NIL) and
                    (plan[yatual]^.cel[xatual] <> NIL);

    if celulaExiste then
        porig := plan[yatual]^.cel[xatual]
    else
        porig := NIL;

    if not blocoValido then
        exit;

    if not blocoVazio then
        begin
            gotoxy (1, 3);
            mensagem ('PLCNFCOP');
            c := readkey;
            if upcase(c) <> 'S' then
                begin
                    mensagem ('PLDESIS');
                    exit;
                end;
        end;

    with blocoAtual do
        for y := ybloco1 to ybloco2 do
          for x := xbloco1 to xbloco2 do
            begin
                if (x <> xatual) or (y <> yatual) then
                  begin
                      removeCelula (x, y);
                      if celulaExiste then
                          criaCelula (x, y);

                      pdest := plan[y]^.cel[x];

                      if porig^.tipo = form then
                          begin
                              s := relocaFormula (porig^.conteudo,
                                   x-xatual, y-yatual,
                                   1, 1, MAXLINPLAN, MAXCELLINHA);
                              pdest^.conteudo := s;
                          end
                      else
                          pdest^.conteudo := porig^.conteudo;

                      pdest^.valor    := porig^.valor;
                      pdest^.tipo     := porig^.tipo;
                      pdest^.formato  := porig^.formato;
                      pdest^.casasDec := porig^.casasdec;
                      pdest^.alinhamento    := porig^.alinhamento;
                  end;

            end;

    reCalcular;
    mensagem ('PLCELCOP');
    alterouTodaTela := true;
end;

{--------------------------------------------------------}
{                   move celula de lugar
{--------------------------------------------------------}

procedure moveCelula;
var s: string;
    c: char;
    xdest, ydest: integer;
    porig, pdest: PCELULA;
    celulaExiste, celulaDestExiste: boolean;

begin
    gotoxy (1, 3);
    clreol;
    gotoxy (1, 2);
    mensagem ('PLCELDST');
    s := '';
    c := sintEditaCampo (s, wherex, wherey, 10, 10, true);
    porig := NIL;

    if c = #$1b then
        begin
            mensagem ('PLDESIS');
            exit;
        end;

    if compilaCelula (s, xdest, ydest) then
        begin
            celulaExiste := (plan[yatual] <> NIL) and
                            (plan[yatual]^.cel[xatual] <> NIL);

            if celulaExiste then
                porig := plan[yatual]^.cel[xatual];


            celulaDestExiste := (plan[ydest] <> NIL) and
                                (plan[ydest]^.cel[xdest] <> NIL);

            if celulaDestExiste then
                begin
                    gotoxy (1, 3);
                    mensagem ('PLCNFCOP');
                    c := readkey;
                    if upcase(c) <> 'S' then
                        begin
                            mensagem ('PLDESIS');
                            exit;
                        end;
                end;

                if (xdest <> xatual) or (ydest <> yatual) then
                  begin
                      removeCelula (xdest, ydest);

                      if celulaExiste then
                          criaCelula (xdest, ydest);

                      pdest := plan[ydest]^.cel[xdest];

                      if porig^.tipo = form then
                          begin
                              s := relocaFormula (porig^.conteudo,
                                   xdest-xatual, ydest-yatual,
                                   1, 1, MAXLINPLAN, MAXCELLINHA);
                              pdest^.conteudo := s;
                          end
                      else
                          begin
                              pdest^.conteudo := porig^.conteudo;
                          end;

                      pdest^.valor    := porig^.valor;
                      pdest^.tipo     := porig^.tipo;
                      pdest^.formato  := porig^.formato;
                      pdest^.casasDec := porig^.casasdec;
                      pdest^.alinhamento    := porig^.alinhamento;

                      removeCelula (xatual, yatual);

                      gotoxy (1, 3);
                      mensagem ('PLCELMOV');

                      { completar ... relocar referencias a ela }
                  end;

            end;

    alterouTodaTela := true;
end;

{--------------------------------------------------------}
{                    Procura conteúdo em uma célula
{--------------------------------------------------------}

procedure procuraCelula (proxima: boolean);
var
    x, y, xini, yant: integer;
    achou: boolean;
label ok;
begin
    if not proxima then
        begin
            pergunta ('PLPROCUR');    {'Informe o conteúdo a procurar: '}
            sintReadln (procura);
        end;

    if procura = '' then
        begin
            informa ('PLDESIST');   {'Desistiu...'}
            exit;
        end;

    xini := xAtual+1;
    yant := yAtual;
    y := yAtual;

    achou := false;
    repeat
        for x:= xini to MAXCELLINHA do
            if existeCelula (x, y) then
                with plan[y]^.cel[x]^ do
                    begin
                        case tipo of
                            form:
                                achou := (pos (procura, floatToStr (valor)) <> 0) or
                                         (pos (procura, conteudo) <> 0);
                            numero:
                                achou := trim(procura) = trim (floatToStr (valor));
                        else
                                achou := pos (procura, conteudo) <> 0;
                        end;

                        if achou then goto ok;
                    end;

        x := 1;
        y := y + 1;
        xini := 1;
    until achou or (y > MAXLINPLAN);

ok:
    if achou then
        begin
            xAtual:= x;
            yAtual:= y;
            mostraLinha (yant);
            mostraLinha (yatual);

            informa ('PLACHEI');
            falaCelula (xatual, yatual);
        end
    else
        informa ('PLNACHEI');    {'Não achei'}
end;

{--------------------------------------------------------}
{                 vai para certa célula
{--------------------------------------------------------}

procedure vaiParaCelula;
var x, y, yant: integer;
    erro: integer;
    s: string;
    c: char;
begin
    yant := yatual;

    pergunta('PLQUALCE');  {'Qual célula? '}
    sintReadln (s);
    if s = '' then exit;

    c := upcase(s[1]);
    if c in ['A'..'Z'] then
        begin
            x := ord(c) - ord('A') + 1;
            delete (s, 1, 1);
            val (s, y, erro);

            if erro = 0 then
                begin
                    xatual := x;
                    yatual := y;
                    mostraLinha (yant);
                    mostraLinha (yatual);
                    falaCelula (xatual, yatual);
                    exit;
                end;
        end;

    informa ('PLNACHEI');    {'Não achei'}
end;


end.

