{--------------------------------------------------------}
{
{    Planilha eletronica VOX
{
{    Modulo de tratamento de blocos
{
{    Autor:  Jose' Antonio Borges
{
{    Em dezembro/96
{
{--------------------------------------------------------}

unit plbloco;
interface
uses
    dvcrt, dvwin, dvmidi,
    sysUtils,
    plvars, plmsg, pltela, plcomp, plcelula, plcalc;

function blocoValido: boolean;
function blocoVazio: boolean;
function emBloco (x, y: integer): boolean;

procedure desmarcaBloco;
procedure inicioBloco;
procedure fimBloco;
procedure apagaBloco;
procedure copiaBloco;
procedure moveBloco;
procedure FormatoBloco;
procedure JustificaBloco;

procedure insereLinha;
procedure insereColuna;
procedure removeLinha;
procedure removeColuna;
procedure insereEmbaixo;
procedure removeEmbaixo;
procedure ordenaBloco;
procedure textualizaBloco;
procedure numeraAutoBloco;
procedure musicalizaBloco;

implementation

{--------------------------------------------------------}
{ Atribui automaticamente valores ao bloco
{--------------------------------------------------------}

procedure numeraAutoBloco;
var valInic, intervalo: real;
    c: char;
    erro: integer;
    s: string;
    x, y: integer;
label desistiu;
begin
    if not blocoValido then
    begin
        informa ('PLPFBLK'); {'Por favor, marque antes o bloco desejado'}
        exit;
    end;

    pergunta ('PLVALINI'); {'Informe o valor inicial: '}
    c := sintEditaCampo (s, 1, wherey, 255, 80, true);
    if c = ESC then
        begin
desistiu:   informa ('PLDESIST');
            exit;
        end;

    val (s, valInic, erro);
    if erro <> 0 then
    begin
        informa ('PLCALINT'); {'Não pude calcular o intervalo, operação cancelada'}
        exit;
    end;

    pergunta ('PLINFINT'); {'Informe o intervalo desejado : '}
    c := sintEditaCampo (s, 1, wherey, 255, 80, true);
    writeln;
    if c = ESC then goto desistiu;

    val (s, intervalo, erro);
    if erro <> 0 then
    begin
        informa ('PLCALINT'); {'Não pude calcular o intervalo, operação cancelada'}
        exit;
    end;

{--------------------------------------------------------}

    with blocoAtual do
        begin

        xAtual:= xBloco1;
        yAtual:= yBloco1;

        for y:= 1 to ((yBloco2 - yBloco1) + 1) do
        begin
            for x:= 1 to ((xBloco2 - xBloco1) + 1) do
            begin
                s:= FloatToStr (valInic);
                formataCelula (xAtual, yAtual, s);
                xAtual:= xAtual + 1;
                valInic := valInic + intervalo;
            end;
            xAtual:= xBloco1;
            yAtual:= yAtual + 1;
        end;

        xAtual:= xBloco1;
        yAtual:= yBloco1;

        mostraTela;
        informa ('PLOK');
    end;
end;

{--------------------------------------------------------}
{            acerta um bloco e informa se valido
{--------------------------------------------------------}

function blocoValido: boolean;
var temp: integer;
label erro;
begin
    with blocoAtual do
        begin
            if xbloco1 <= 0 then goto erro;
            if xbloco2 <= 0 then goto erro;
            if xbloco1 > MAXCELLINHA then goto erro;
            if xbloco2 > MAXCELLINHA then goto erro;

            if xbloco1 > xbloco2 then
                begin
                    temp := xbloco1;
                    xbloco1 := xbloco2;
                    xbloco2 := temp;
                end;

            if ybloco1 > ybloco2 then
                begin
                    temp := ybloco1;
                    ybloco1 := ybloco2;
                    ybloco2 := temp;
                end;
        end;

    blocoValido := true;
    exit;

erro:
    blocoValido := false;
    mensagem ('PLBLKINV');
end;

{--------------------------------------------------------}
{                 verifica se bloco vazio
{--------------------------------------------------------}

function blocoVazio: boolean;
var x, y: integer;
begin
    blocoVazio := true;
    with blocoAtual do
        for y := ybloco1 to ybloco2 do
            begin
                if plan[y] <> NIL then
                    with plan[y]^ do
                        for x := xbloco1 to xbloco2 do
                             if cel[x] <> NIL then
                                 begin
                                     blocoVazio := false;
                                     exit;
                                 end;
            end;

end;

{--------------------------------------------------------}
{          informa se posição está dentro de bloco
{--------------------------------------------------------}

function emBloco (x, y: integer): boolean;
begin
    with blocoAtual do
        emBloco := (x >= xbloco1) and (x <= xbloco2) and
                   (y >= ybloco1) and (y <= ybloco2);

end;

{--------------------------------------------------------}
{                     desmarca o bloco
{--------------------------------------------------------}

procedure desmarcaBloco;
begin
    with blocoAtual do
        begin
            xbloco1 := 0;
            ybloco1 := 0;
        end;
    mostraTela;
    informa ('PLBLKDSM');   {'Bloco desmarcado'}
end;

{--------------------------------------------------------}
{            marca o inicio do bloco corrente
{--------------------------------------------------------}

procedure inicioBloco;
begin
    with blocoAtual do
        begin
            xbloco1 := xatual;
            ybloco1 := yatual;
        end;
    mensagem ('PLBLKINI');
end;

{--------------------------------------------------------}
{              marca o fim do bloco corrente
{--------------------------------------------------------}

procedure fimBloco;
begin
    with blocoAtual do
        begin
            xbloco2 := xatual;
            ybloco2 := yatual;
        end;
    mensagem ('PLBLKFIM');
end;

{--------------------------------------------------------}
{                troca o formato do bloco
{--------------------------------------------------------}

procedure ApagaBloco;
var x, y: integer;
begin
    if not blocoValido then exit;
    with blocoAtual do
        for y := ybloco1 to ybloco2 do
            for x := xbloco1 to xbloco2 do
                 removeCelula (x, y);

    mensagem ('PLBLKAPA');
    alterouTodaTela := true;
end;

{--------------------------------------------------------}
{                troca o formato do bloco
{--------------------------------------------------------}

procedure FormatoBloco;
var
    c1, c2: char;
    x, y: integer;
    f: byte;
    s: string;
    n, erro: integer;

label deNovo;
begin
    if not blocoValido then exit;

    pergunta ('PLQUAFOR');  {'Qual o formato ? '}

    sintLeTecla (c1, c2);
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpFor;

    case upcase(c1) of
        'G': f := geral;
        '$': f := dinheiro;
        'N': f := numerico;
        'C': f := cientifico;
        'D': f := data;
        ESC:
              begin
                  informa ('PLDESIS');   {'Desistiu'}
                  exit;
              end;
    else
        informa ('PLMINVAL');   {'Opção inexistente'}
        exit;
    end;

    pergunta ('PLNCASAS');  {'Se número, quantas decimais? '}
    sintReadln (s);
    n := 0;
    if s <> '' then
        begin
            val (s, n, erro);
            if (erro <> 0) or (n < 0) or (n > 9) then
                begin
                    informa ('PLMINVAL');   {'Opção inexistente'}
                    exit;
                end;
        end;

    alterouTodaTela := true;

    with blocoAtual do
      begin
        for y := ybloco1 to ybloco2 do
            begin
                for x := xbloco1 to xbloco2 do
                    begin
                        if not existeCelula (x, y) then
                            criaCelula (x, y);
                        with plan[y]^.cel[x]^ do
                            begin
                                formato := f;
                                casasDec := n;
                            end;
                    end;
            end;
      end;
end;

{--------------------------------------------------------}
{               justifica celulas de um bloco
{--------------------------------------------------------}

procedure JustificaBloco;
var
    x, y: integer;
    c1, c2: char;
label deNovo;

begin
    if not blocoValido then exit;

    pergunta ('PLQUAJUS');  {'Qual a justificativa ? '}

    sintLeTecla (c1, c2);
    if c1 = ESC then
        exit;
    if c1 <> #0 then writeln;

    if (c1 = #0) and ((c2 = CIMA) or (c2 = BAIX)) then
        c1 := selSetasOpJus;

    alterouTodaTela := true;

    with blocoAtual do
      begin
        for y := ybloco1 to ybloco2 do
            begin
                for x := xbloco1 to xbloco2 do
                    begin
                        if not existeCelula (x, y) then
                            criaCelula (x, y);

                        with plan[y]^.cel[x]^ do
                            begin
                                if not existeCelula (x, y) then
                                    criaCelula (x, y);

                                with plan[y]^.cel[x]^ do
                                    begin
                                        alinhamento := alinhamento and not (centrada + alinDir + alinEsq);
                                        case upcase(c1) of
                                            'A': ;
                                            'E': alinhamento := alinhamento or alinEsq;
                                            'D': alinhamento := alinhamento or alinDir;
                                            'C': alinhamento := alinhamento or centrada;
                                        else
                                            begin
                                                informa ('PLMINVAL');   {'Opção inexistente'}
                                                alterouTodaTela := true;
                                                exit;
                                            end;
                                        end;
                                    end;
                            end;

                    end;
            end;
      end;
end;

{--------------------------------------------------------}
{                   insere linha
{--------------------------------------------------------}

procedure insereLinha;
var maxy, x, y: integer;
begin
    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;
    maxy := y;
    if maxy = 0 then maxy := 1;
    if maxy = MAXLINPLAN then maxy := MAXLINPLAN-1;

    for y := maxy downto yatual do
        plan[y+1] := plan[y];
    plan[yatual] := NIL;

    for y := 1 to maxy+1 do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, 0, 1,
                               1, yatual, MAXCELLINHA, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLLININS');   {'Linha inserida'}
end;

{--------------------------------------------------------}
{                 remove linha
{--------------------------------------------------------}

procedure removelinha;
var maxy, x, y: integer;
begin
    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;
    maxy := y;
    if maxy = 0 then maxy := 1;

    for x := 1 to MAXCELLINHA do
        removeCelula(x, yatual);
    for y := yatual to maxy-1 do
        plan[y] := plan[y+1];
    plan[maxy] := NIL;

    for y := 1 to maxy-1 do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, 0, -1,
                               1, yatual, MAXCELLINHA, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLLINREM');   {'Linha removida'}
end;

{--------------------------------------------------------}
{                   insere coluna
{--------------------------------------------------------}

procedure insereColuna;
var x, y, maxy: integer;
begin
    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;
    maxy := y;
    if maxy = 0 then maxy := 1;

    for y := 1 to maxy do
        if plan[y] <> NIL then
            begin
                removeCelula(MAXCELLINHA, y);
                for x := 25 downto xatual do
                    plan[y]^.cel[x+1] := plan[y]^.cel[x];
                plan[y]^.cel[xatual] := NIL;
            end;

    for y := 1 to maxy do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, 1, 0,
                               xatual, 1, MAXCELLINHA, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLCOLINS');   {'Coluna inserida'}
end;

{--------------------------------------------------------}
{                 remove coluna
{--------------------------------------------------------}

procedure removeColuna;
var maxy, x, y: integer;
begin
    for y := MAXLINPLAN downto 1 do
        if plan[y] <> NIL then break;
    maxy := y;
    if maxy = 0 then maxy := 1;

    for y := 1 to maxy do
        if plan[y] <> NIL then
            begin
                removeCelula(xatual, y);
                for x := xatual to 25 do
                    plan[y]^.cel[x] := plan[y]^.cel[x+1];
                plan[y]^.cel[MAXCELLINHA] := NIL;
            end;

    for y := 1 to maxy do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, -1, 0,
                               xatual, 1, MAXCELLINHA, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLCOLREM');   {'Coluna removida'}
end;

{--------------------------------------------------------}
{                   insere embaixo
{--------------------------------------------------------}

procedure insereEmbaixo;
var x, y: integer;
begin
    x := xatual;
    for y := 4999 downto yatual do
        begin
            if existeCelula(x, y+1) then
                removeCelula(x, y+1);
            if existeCelula (x, y) then
                begin
                    criaCelula(x, y+1);
                    plan[y+1]^.cel[x]^ := plan[y]^.cel[x]^;
                end;
        end;

    removeCelula(xatual, yatual);

    for y := 1 to MAXLINPLAN do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, 0, 1,
                               xatual, yatual, xatual, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLINSBAI');   {'Inserido embaixo'}
end;

{--------------------------------------------------------}
{                   remove embaixo
{--------------------------------------------------------}

procedure removeEmbaixo;
var x, y: integer;
begin
    x := xatual;
    for y := yatual to 4999 do
        begin
            if existeCelula(x, y) then
                removeCelula(x, y);
            if existeCelula (x, y+1) then
                begin
                    criaCelula(x, y);
                    plan[y]^.cel[x]^ := plan[y+1]^.cel[x]^;
                end;
        end;

    removeCelula(xatual, MAXLINPLAN);

    for y := 1 to MAXLINPLAN do
        if plan[y] <> NIL then
            begin
                for x := 1 to MAXCELLINHA do
                     if existeCelula(x, y) and (plan[y]^.cel[x]^.tipo = form) then
                         plan[y]^.cel[x]^.conteudo := relocaFormula(
                               plan[y]^.cel[x]^.conteudo, 0, -1,
                               xatual, yatual, xatual, MAXLINPLAN);
            end;

    reCalcular;
    informa ('PLREMBAI');   {'Removido embaixo'}
end;

{--------------------------------------------------------}
{        ve se ao copiar bloco não vai estourar
{--------------------------------------------------------}

function copiaCabeNaPlanilha (xat, yat: integer): boolean;
var dx, dy, xb2, yb2: integer;
begin
    copiaCabeNaPlanilha := false;
    with blocoAtual do
        begin
            dx := xat-xbloco1;
            dy := yat-ybloco1;
            xb2 := xbloco2 + dx;
            yb2 := ybloco2 + dy;
            if (xb2 > MAXCELLINHA) or (yb2 > MAXLINPLAN) then
                begin
                    informa ('PLNAOCAB');   {'Não cabe na planilha'}
                    exit;
                end;
        end;
    copiaCabeNaPlanilha := true;
end;

{--------------------------------------------------------}
{                     copia um bloco
{--------------------------------------------------------}

procedure copiaBloco;
var x, y, dx, dy: integer;
begin
    if not blocoValido then exit;
    if not copiaCabeNaPlanilha (xatual, yatual) then exit;

    with blocoAtual do
    begin
        dx := xatual-xbloco1;
        dy := yatual-ybloco1;

        if (dx <  0) and (dy <  0) then
            begin
                for y := yatual to yatual+(ybloco2-ybloco1+1)-1 do
                    for x := xatual to xatual+(xbloco2-xbloco1+1)-1 do
                        begin
                            removeCelula(x, y);
                            criaCelula(x, y);
                            if existeCelula(x-dx, y-dy) then
                                begin
                                    criaCelula(x, y);
                                    plan[y]^.cel[x]^ := plan[y-dy]^.cel[x-dx]^;
                                end;
                        end;
            end
        else
        if (dx <  0) and (dy >= 0) then
            begin
                for y := yatual+(ybloco2-ybloco1+1)-1 downto yatual do
                    for x := xatual to xatual+(xbloco2-xbloco1+1)-1 do
                        begin
                            removeCelula(x, y);
                            criaCelula(x, y);
                            if existeCelula(x-dx, y-dy) then
                                begin
                                    criaCelula(x, y);
                                    plan[y]^.cel[x]^ := plan[y-dy]^.cel[x-dx]^;
                                end;
                        end;
            end
        else
        if (dx >= 0) and (dy <  0) then
            begin
                for y := yatual to yatual+(ybloco2-ybloco1+1)-1 do
                    for x := xatual+(xbloco2-xbloco1+1)-1 downto xatual do
                        begin
                            removeCelula(x, y);
                            criaCelula(x, y);
                            if existeCelula(x-dx, y-dy) then
                                begin
                                    criaCelula(x, y);
                                    plan[y]^.cel[x]^ := plan[y-dy]^.cel[x-dx]^;
                                end;
                        end;
            end
        else
        if (dx >= 0) and (dy >= 0) then
            begin
                for y := yatual+(ybloco2-ybloco1+1)-1 downto yatual do
                    for x := xatual+(xbloco2-xbloco1+1)-1 downto xatual do
                        begin
                            removeCelula(x, y);
                            if existeCelula(x-dx, y-dy) then
                                begin
                                    criaCelula(x, y);
                                    plan[y]^.cel[x]^ := plan[y-dy]^.cel[x-dx]^;
                                end;
                        end;
            end;
    end;
    reCalcular;
end;

{--------------------------------------------------------}
{                     move um bloco
{--------------------------------------------------------}

procedure moveBloco;
var x, y: integer;
begin
    if not blocoValido then exit;
    if not copiaCabeNaPlanilha (xatual, yatual) then exit;

    copiaBloco;
    with blocoAtual do
        begin
            for y := ybloco1 to ybloco2 do
                for x := xbloco1 to xbloco2 do
                    if emBloco (x, y) then
                        removeCelula(x, y);
        end;
    reCalcular;
end;

{--------------------------------------------------------}
{                  ordena o bloco
{--------------------------------------------------------}

procedure ordenaBloco;
var x, y, y2, posMenor: integer;
    menor: real;
    menorAlfa: string;
    temp: pointer;

begin
    if not blocoValido then exit;

    with blocoAtual do
    begin
        for y := ybloco1 to ybloco2-1 do
            begin
                menor := plan[y]^.cel[xbloco1].valor;
                menorAlfa := plan[y]^.cel[xbloco1].conteudo;
                posMenor := y;

                for y2 := y+1 to ybloco2 do
                    with plan[y2]^.cel[xbloco1]^ do
                        begin
                            if valor < menor then
                                begin
                                    posMenor := y2;
                                    menor := valor;
                                    menorAlfa := #255;
                                end
                            else
                                if valor = 0 then
                                    if (conteudo < menorAlfa) and (menorAlfa <> #255) then
                                         begin
                                             posMenor := y2;
                                             menorAlfa := conteudo;
                                         end;

                        end;

                for x := xbloco1 to xbloco2 do
                    begin
                        temp := plan[y]^.cel[x];
                        plan[y]^.cel[x] := plan[posMenor]^.cel[x];
                        plan[posMenor]^.cel[x] := temp;
                    end;
            end;
        end;

    reCalcular;
    informa ('PLOK');
end;

{--------------------------------------------------------}
{         transforma fórmulas do bloco em texto
{--------------------------------------------------------}

procedure textualizaBloco;
var x, y: integer;
begin
    if not blocoValido then exit;

    with blocoAtual do
        for y := ybloco1 to ybloco2 do
            for x := xbloco1 to xbloco2 do
                begin
                     if existeCelula(x, y) then
                          with plan[y]^.cel[x]^ do
                              if tipo = FORM then
                                  begin
                                      tipo := NUMERO;
                                      if (valor <= 9999999) and
                                             (valor - trunc(valor) = 0) then
                                          str (valor:0:0, conteudo)
                                      else
                                          str (valor:0:casasDec, conteudo);      { completar }
                                  end;
                end;

    mostraTela;
    informa ('PLOK');
end;

procedure meuTocaNota(escala, valor, durNota: integer);
var n: integer;
begin
    if (durNota <= 0) or (durNota < 10) then durNota := 1000;
    n := (escala * 12) + valor;
    if n < 0 then
        begin
            escala := 0;
            valor := 0;
        end
    else
    if n > 108 then
        begin
            escala := 0;
            valor := 108;
        end;

    tocaNota(escala, valor, durNota);
end;

{--------------------------------------------------------}
{             toca as células do bloco
{--------------------------------------------------------}

procedure musicalizaBloco;
var x, y: integer;
    escalaZero, durNota: integer;
    c1, c2: char;
    varrePorColuna: boolean;
label fim;
begin
    if not blocoValido then exit;

    pergunta ('PLDURNOT');  {'Qual a duração da nota em milis (50 a 2000)? '}
    sintReadint (durNota);
    if durNota > 2000 then durNota := 100;

    pergunta ('PLESCALA');  {'Número da escala (0 a 7)? '}
    sintReadint (escalaZero);
    if escalaZero > 20 then escalaZero := 4;

    varrePorColuna := true;
    with blocoAtual do
        if (xbloco1 <> xbloco2) and (ybloco1 <> ybloco2) then
            begin
                pergunta ('PLVARREC');  {'Varrer por linha ou por coluna (L ou C) ? '}
                sintLeTecla (c1, c2);
                if c1 = ESC then exit;
                if upcase(c1) <> 'C' then
                     varrePorColuna := false;
            end;

    abreMidi(0);
    if varrePorColuna then
        begin
            with blocoAtual do
                for x := xbloco1 to xbloco2 do
                    for y := ybloco1 to ybloco2 do
                        begin
                             if existeCelula(x, y) then
                                  with plan[y]^.cel[x]^ do
                                        begin
                                            if (tipo = NUMERO) or ((tipo=FORM) and (tipoResultComput=NUMERO)) then
                                                meuTocaNota(escalaZero, round(valor), durNota);
                                            if keypressed then
                                                if readkey = ESC then
                                                    goto fim;
                                          end;
                        end;
        end
    else
        begin
            with blocoAtual do
                for y := ybloco1 to ybloco2 do
                    for x := xbloco1 to xbloco2 do
                        begin
                             if existeCelula(x, y) then
                                  with plan[y]^.cel[x]^ do
                                        begin
                                            if (tipo = NUMERO) or ((tipo=FORM) and (tipoResultComput=NUMERO)) then
                                                meuTocaNota(escalaZero, round(valor), durNota);
                                            if keypressed then
                                                if readkey = ESC then
                                                    goto fim;
                                          end;
                        end;
        end;

fim:
    mostraTela;
    informa ('PLOK');
    fechaMidi;
end;

end.
