{--------------------------------------------------------}
{
{    Agenda Eletrônica VOX
{
{    Autor: Jose' Antonio Borges
{
{    Em 14/4/94
{
{--------------------------------------------------------}

program agenvox;

uses dvCrt, dvWin, dvHora, dvForm, sysutils,
     agDados,
     agMensag,
     agEstDad,
     agArq;

{--------------------------------------------------------}
{               mutreta para descobrir o dia
{--------------------------------------------------------}

function descobreDia (dia, mes, ano: word): word;
begin
    descobreDia := dayOfWeek (EncodeDate(ano, mes, dia));
end;

{--------------------------------------------------------}
{                      mostra o dia
{--------------------------------------------------------}

procedure mostraUmDia (dia, mes, ano: integer);
var x, y: integer;
begin
    x := wherex;
    y := wherey;
    gotoxy (1, 12);   clreol;
    write (diaPorExtenso(dia, mes, ano));

    falaDiaQualquer (dia, mes, ano);

    gotoxy (x, y);
end;

{--------------------------------------------------------}
{                     inicializacao
{--------------------------------------------------------}

procedure inicializa;
var
    segundo, cent: word;
begin
    clrscr;
    SintInic (0, sintAmbiente('AGENVOX', 'DIRAGENVOX'));

    limpaTela;

    gotoxy (1, 9);
    mensagem ('AGINIC', 1);
    dvcrt.getDate (ano, mes, dia, diaSemana);
    dvcrt.getTime (hora, minuto, segundo, cent);

    inicEstrDados;
    leAgenda;
end;

{--------------------------------------------------------}
{                   seleciona um dia
{--------------------------------------------------------}

procedure selecDia;
const
    NUMEROS: set of char = ['0'..'9'];
var
    linha, s: string;
    ok: boolean;
    posCarac, i, erro: integer;

label errou, fim, okdia, okmes;

begin
    ok := false;
    limpaBaixo;

    repeat
        gotoxy (1, 13);
        clreol;
        textBackground (blue);
        mensagem ('AGINFDIA', 1);
        textBackground (black);
        clreol;

        sintReadln (linha);
        linha := linha + '@';

        if not (linha[1] in NUMEROS) then goto errou;

        posCarac := 1;
        for i := 2 to length(linha) do
            if not (linha[i] in NUMEROS) then
                begin
                    dia := 9999;
                    s := copy (linha, 1, i-posCarac);
                    val (s, dia, erro);
                    posCarac := i+1;
                    if erro <> 0      then goto errou;
                    if linha[i] = '@' then goto fim;
                    goto okdia;
                end;
okdia:
        if not (linha[posCarac] in NUMEROS) then goto errou;
        for i := posCarac+1 to length(linha) do
            if not (linha[i] in NUMEROS) then
                begin
                    s := copy (linha, posCarac, i-posCarac);
                    val (s, mes, erro);
                    posCarac := i+1;
                    if erro <> 0      then goto errou;
                    if linha[i] = '@' then goto fim;
                    goto okmes;
                end;
okmes:
        if not (linha[posCarac] in NUMEROS) then goto errou;
        for i := posCarac+1 to length(linha) do
            if not (linha[i] in NUMEROS) then
                begin
                    s := copy (linha, posCarac, i-posCarac);
                    val (s, ano, erro);
                    // posCarac := i+1;
                    if erro <> 0      then goto errou;
                    if linha[i] <> '@' then goto errou;
                    goto fim;
                end;
fim:
        ok := true;

        if ano <= 99 then
            if ano >= 83 then
                ano := ano + 1900
            else
                ano := ano + 2000;

        if (ano < 1900) or (ano >= 2100)
            or (mes < 1) or (mes > 12) then ok := false
        else
        if (dia < 1) or (dia > 31) then ok := false
        else
        if (mes in [4, 6, 9, 11]) and (dia > 30) then ok := false
        else
        if (mes = 2) and (dia > 29) then ok := false
        else
        if (mes = 2) and (dia = 29) and ((ano mod 4) <> 0) then ok := false;

errou:
        if not ok then
            mensagem ('AGERRDIA', 1);
    until ok;

    mostraUmDia (dia, mes, ano);
end;

{--------------------------------------------------------}
{                   seleciona uma hora
{--------------------------------------------------------}

procedure selecHora;
const
    NUMEROS: set of char = ['0'..'9'];
var
    linha, s: string;
    ok: boolean;
    posCarac, i, erro: integer;

label errou, fim, okHora, okMin;

begin
    ok := false;
    limpaBaixo;

    repeat
        gotoxy (1, 13);
        clreol;
        mensagem ('AGINFHOR', 1);

        sintReadln (linha);

        minuto := 0;
        linha := linha + '@';

        if not (linha[1] in NUMEROS) then goto errou;

        posCarac := 1;
        for i := 2 to length(linha) do
            if not (linha[i] in NUMEROS) then
                begin
                    hora := 9999;
                    s := copy (linha, 1, i-posCarac);
                    val (s, hora, erro);
                    posCarac := i+1;
                    if erro <> 0      then goto errou;
                    if linha[i] = '@' then goto fim;
                    goto okhora;
                end;
okhora:
        if not (linha[posCarac] in NUMEROS) then goto errou;
        for i := posCarac+1 to length(linha) do
            if not (linha[i] in NUMEROS) then
                begin
                    s := copy (linha, posCarac, i-posCarac);
                    val (s, minuto, erro);
                    posCarac := i+1;
                    if erro <> 0      then goto errou;
                    if linha[i] <> '@' then goto errou;
                end;

fim:
        ok := true;

        if ano <= 99 then
            if ano >= 83 then
                ano := ano + 1900
            else
                ano := ano + 2000;

        if (ano < 1900) or (ano >= 2100)
            or (mes < 1) or (mes > 12) then ok := false
        else
        if (dia < 1) or (dia > 31) then ok := false
        else
        if (mes in [4, 6, 9, 11]) and (dia > 30) then ok := false
        else
        if (mes = 2) and (dia > 29) then ok := false
        else
        if (mes = 2) and (dia = 29) and ((ano mod 4) <> 0) then ok := false;

errou:
        if not ok then
            mensagem ('AGERRHOR', 1);
    until ok;
end;

{--------------------------------------------------------}
{                   mostra um compromisso
{--------------------------------------------------------}

procedure mostraComprom;
var
    poslista: PLISTA;
    s: string;
    i: integer;
begin
    falaHoraQualquer (hora, minuto);

    gotoxy (1, 15);
    write (hora:2, ':');
    str (minuto:2, s);
    if s[1] = ' ' then s[1] := '0';
    write (s, ' - ');

    if buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        begin
            with poslista^ do
                begin
                    if poslista^.marcaComprom <> ' ' then
                        for i := 1 to 5 do sintBip;

                    s := copy (textoComprom, 1, 72);
                    sintWrite (s);
                end;
        end
    else
        mensagem ('AGLIVRE', 1);
end;

{--------------------------------------------------------}
{                   insere um compromisso
{--------------------------------------------------------}

procedure insereComprom;
var texto: string;
    poslista: PLISTA;
    cod: char;

begin
    selecHora;

    if buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        begin
            gotoxy (1, 14);
            mensagem ('AGDUPLI', 1);
	    exit;
        end;

    gotoxy (1, 15);
    textBackground (blue);
    mensagem ('AGDIGITE', 1);
    textBackground (black);

    texto := '';
    cod := sintEdita (texto, 1, 16, 250, true);
    if (cod = ESC) or (texto = '') then
        begin
            gotoxy (1,16);  clreol;
            writeln; clreol;
            mensagem ('AGIGNORA', 1);
            exit;
        end;

    if insereEstrDados (dia, mes, ano, hora, minuto, texto, poslista) then
        begin
            gotoxy (1, 19);
            mensagem ('AGINSER', 1);
        end;
end;

{--------------------------------------------------------}
{                   remove um compromisso
{--------------------------------------------------------}

procedure removeComprom;
var poslista: PLISTA;
    s: string;
    c, c2: char;
begin
    limpaBaixo;
    mensagem ('AGOPREM', 1);

    selecDia;
    selecHora;

    if buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        begin

            with poslista^ do
                begin
                    gotoxy (1, 16);
                    mensagem ('AGCONFRM', 1);
                    s := copy (textoComprom, 1, 72);
                    sintWriteln (s);
                end;

            sintLeTecla (c, c2);

            if upcase (c) = 'S' then
                begin
		    if not removeEstrDados (dia, mes, ano, hora, minuto) then
			 ;
		    mensagem ('AGREMOV', 1);

                end
        end
    else
        begin
	    writeln;
	    mensagem ('AGLIVRE', 1);
        end;
end;

{--------------------------------------------------------}
{                 folheia os compromissos
{--------------------------------------------------------}

procedure folheiaComprom (var poslista: PLISTA);
var campo: string;
    cod, c, c2: char;
    s, codorig, coddia: string;
    i: integer;
begin
    gotoxy (1, 13);
    mensagem ('AGPODEDI', 1);

    repeat
        with poslista^ do
            begin
                dia := diaComprom;
                mes := mesComprom;
                ano := anoComprom;
                hora   := horaComprom;
                minuto := minComprom;
                campo  := textoComprom;
            end;

        codorig := copy (codifica (dia, mes, ano, hora, minuto), 1, 8);

        limpaBaixo;
        gotoxy (1, 15);
        write (hora:2, ':');
        str (minuto:2, s);
        if s[1] = ' ' then s[1] := '0';
        write (s, ' - ');
        falaHoraQualquer (hora, minuto);

        if poslista^.marcaComprom <> ' ' then
            for i := 1 to 5 do sintBip;

        cod := sintEdita (campo, 9, 15, 250, true);
        if (cod <> ESC) and (campo <> poslista^.textoComprom) then
            begin
                writeln;
                mensagem ('AGQUERAL', 1);
                sintLeTecla (c, c2);
                writeln (c);
                if (c = ESC) or (upcase(c) = 'N') then
                    mensagem ('AGNAOALT', 1)
                else
                    begin
                        poslista^.textoComprom := campo;
                        mensagem ('AGALT', 1);
                    end;
            end;

        case cod of

            BAIX,
            PGDN: begin
                      if (poslista=NIL) or
                         (poslista^.prox^.prox = NIL) then
                          begin
                              write ($0d);
                              mensagem ('AGNAOACH', 1);
                          end
                      else
                          poslista := poslista^.prox;
                  end;

            CIMA,
            PGUP: begin
                      if poslista^.ant = NIL then
                          begin
                              write ($0d);
                              mensagem ('AGNAOACH', 1);
                          end
                      else
                          poslista := poslista^.ant;
                  end;

        end;

        with poslista^ do
            begin
                 coddia := copy (codifica (diaComprom, mesComprom, anoComprom,
                             horaComprom, minComprom), 1, 8);
                 if codorig <> coddia then
                     begin
                         dia := diaComprom;
                         mes := mesComprom;
                         ano := anoComprom;
                         falaDiaQualquer (dia, mes, ano);
                     end;
            end;

    until cod = ESC;
end;

{--------------------------------------------------------}
{                   procura um compromisso
{--------------------------------------------------------}

procedure procuraComprom;
var poslista: PLISTA;
    texto: string;
    c: char;

begin
    limpaBaixo;
    gotoxy (1, 13);
    mensagem ('AGINFPRO', 1);

    texto := '';
    c := sintEdita (texto, 1, 14, 250, true);
    if (c = #$1b) or (texto = '') then
        begin
            writeln;
            mensagem ('AGPROCAN', 1);
            exit;
        end;

    { a partir da ultima busca... }

    if not (buscaEstrDados (dia, mes, ano, 0, 0, poslista)) then ;

    if (poslista^.prox = NIL) then
            begin
               writeln; clreol;
               mensagem ('AGNAOACH', 1);
               exit;
            end;

    if buscaTextoEstrDados (texto, poslista) then
        begin
            writeln; clreol;
            mensagem ('AGACHEI', 1);
            writeln;

            with poslista^ do
                falaDiaQualquer (diaComprom, mesComprom, anoComprom);
            folheiaComprom (poslista);
        end
    else
        begin
            gotoxy (1, 18);
            mensagem ('AGNAOACH', 1);
            exit;
        end;
end;


{--------------------------------------------------------}
{                 edita os compromissos
{--------------------------------------------------------}

procedure editaComprom;
var poslista: PLISTA;
begin
    if not buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        begin
            poslista := poslista^.ant;
            if (poslista = NIL) then
                begin
                    mensagem ('AGVAZIA', 1);
                    exit;
                end;
        end;

    folheiaComprom (poslista);
end;

{--------------------------------------------------------}
{                insere uma marca especial
{--------------------------------------------------------}

procedure marcaEspecial;
var poslista: PLISTA;
    s: string;
begin
    selecHora;

    if buscaEstrDados (dia, mes, ano, hora, minuto, poslista) then
        begin
            with poslista^ do
                begin
                    if marcaComprom = ' ' then
                        marcaComprom := '*'
                    else
                        marcaComprom := ' ';

                    s := copy (textoComprom, 1, 72);
                    sintWriteln (s);

                    gotoxy (1, 16);
                    if poslista^.marcaComprom <> ' ' then
                        mensagem ('AGREGMAR', 1)
                    else
                        mensagem ('AGREGDSM', 1);
                end;

        end
    else
        begin
	    writeln;
	    mensagem ('AGLIVRE', 1);
        end;
end;

{--------------------------------------------------------}
{            mostra varios compromissos na tela
{--------------------------------------------------------}

procedure mostraDia;
var p1, p2: PLISTA;

    {--------------------------------------------------------}

    procedure falaCompromisso (p: PLISTA);
    begin
        hora   := p^.horaComprom;
        minuto := p^.minComprom;
        falaHoraQualquer (hora, minuto);
        sintetiza (p^.textoComprom);
    end;

    {--------------------------------------------------------}

    procedure mostraOsCompromissos;
    var p, ptela: PLISTA;
        c, c2: char;
        h, m: string;
        l: integer;
    begin
        limpaBaixo;
        mensagem ('AGSETAS', 1);

        p := NIL;
        ptela := p1;

        repeat
            l := 13;
            while ptela <> p2 do
                begin
                    str (ptela^.horaComprom, h);
                    str (ptela^.minComprom, m);
                    if length (h) = 1 then h := '0' + h;
                    if length (m) = 1 then m := '0' + m;

                    if l < 25 then
                        begin
                            gotoxy (1, l);
                            write (h, ':', m, ' - ');
                            write (ptela^.textoComprom);
                            clreol;
                        end;

                    ptela := ptela^.prox;
                    l := l + 1;
                end;

            for l := l to 25 do
                begin
                    gotoxy (1, l);
                    clreol;
                end;

            gotoxy (1, 13);
            sintLeTecla (c, c2);

            gotoxy (1, 12);  clreol;
            gotoxy (1, 13);

            if c = ESC then exit;

            if (p = NIL) then
               begin
                   p  := p1;
                   c := #0;
                   c2 := DIR;
               end;

            if c = ESC then exit;
            if c <> #0 then
                 sintBip
            else
                 case c2 of
                     F1:   begin
                               gotoxy (1, 12);
                               mensagem ('AGSETAS', 1);
                           end;

                     ESQ, DIR: falaCompromisso (p);

                     BAIX,
                     PGDN: if p^.prox = p2 then
                               begin
                                   gotoxy (1, 12);
                                   mensagem ('AGNAOACH', 1);
                               end
                           else
                               begin
                                   p := p^.prox;
                                   falaCompromisso (p);
                               end;

                     CIMA,
                     PGUP: if p = p1 then
                               begin
                                   gotoxy (1, 12);
                                   mensagem ('AGNAOACH', 1);
                               end
                           else
                               begin
                                   p := p^.ant;
                                   falaCompromisso (p);
                               end;
                 end;

            ptela := p;

        until false;
    end;

    {--------------------------------------------------------}

begin
    writeln;
    if buscaEstrDados (dia, mes, ano, 0, -1, p1) then;
    if (dia = p1^.diaComprom) and
       (mes = p1^.mesComprom) and
       (ano = p1^.anoComprom) then

        begin
            if buscaEstrDados (dia+1, mes, ano, 0, -1, p2) then;

            mostraOsCompromissos;
        end
    else
        mensagem ('AGVAZIA', 1);
end;

{-------------------------------------------------------------}
{                          ajuda
{-------------------------------------------------------------}

procedure ajuda;
    procedure msg (s: string; n: integer);
    var i: integer;
    begin
        write (pegaTextoMensagem (s));
        for i := 1 to n do writeln;
    end;

begin
    limpaBaixo;
    gotoxy (1, 13);
    msg ('AGAJUDA0', 2);    {'As opções da agenda são'}
    msg ('AGAJUDA1', 1);    {'   D - selecionar dia'}
    msg ('AGAJUDA2', 1);    {'   H - selecionar hora'}
    msg ('AGAJUDA3', 1);    {'   I - incluir um compromisso'}
    msg ('AGAJUDA4', 1);    {'   E - editar compromissos existentes'}
    msg ('AGAJUDA5', 1);    {'   P - procurar um compromisso'}
    msg ('AGAJUDA6', 1);    {'   R - remover um compromisso'}
    msg ('AGAJUDA7', 1);    {'   * - por uma marca especial num compromisso'}
    msg ('AGAJUDA9', 1);    {'   ESC - terminar a agenda'}
    sintsom ('AGAJUDA');

    while keypressed do readkey;
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas
{--------------------------------------------------------}

function selSetasOpcao: char;

    procedure MenuAdiciona (msg: string);
    begin
         popupMenuAdiciona (msg, pegaTextoMensagem (msg));
    end;

var n: integer;
const
    tabLetrasOpcoes: string [8] = 'dhiepr*f';

begin
    popupMenuCria (wherex, wherey, 50,    7   {8}, MAGENTA);
    MenuAdiciona ('AGAJUDA1');    {'   D - selecionar dia'}
    MenuAdiciona ('AGAJUDA2');    {'   H - selecionar hora'}
    MenuAdiciona ('AGAJUDA3');    {'   I - incluir um compromisso'}
    MenuAdiciona ('AGAJUDA4');    {'   E - editar compromissos existentes'}
    MenuAdiciona ('AGAJUDA5');    {'   P - procurar um compromisso'}
    MenuAdiciona ('AGAJUDA6');    {'   R - remover um compromisso'}
    MenuAdiciona ('AGAJUDA7');    {'   * - por uma marca especial num compromisso'}

    n := popupMenuSeleciona;
    if n > 0 then
        selSetasOpcao := tabLetrasOpcoes[n]
    else
        selSetasOpcao := ENTER;
end;

{--------------------------------------------------------}
{                    trata controles
{--------------------------------------------------------}

function trataControles (c2: char): char;
begin
    trataControles := #0;
    case c2 of
        CIMA, BAIX: trataControles := selSetasOpcao;

        F1:  ajuda;

        F2:  gravaAgenda;

        F3:  begin
                gravaAgenda;
                leAgenda;
             end;
    end;
end;

{--------------------------------------------------------}
{                    executa um comando
{--------------------------------------------------------}

procedure executaComando;
var c, c2: char;
label executa;
begin
    while keypressed do
        c := readkey;

    gotoxy (1, 11);
    clreol;
    textBackground (blue);
    mensagem ('AGOPCAO', 0);
    textBackground (black);
    clreol;

    sintLeTecla (c, c2);

    limpaBaixo;
    gotoxy (1, 13);
executa:
    case upcase(c) of
        #0 : begin
                c := trataControles (c2);
                if c <> #0 then goto executa;
             end;
        'D': begin
                 selecDia;
                 mostraDia;
             end;

        'H': begin
                 selecHora;
                 mostraComprom;
             end;

        'E': editaComprom;
        'P': procuraComprom;
        'I': insereComprom;
        'R': removeComprom;
        '*': marcaEspecial;

        'S': gravaAgenda;

       'F', #$1b: fim := true;
    else
        ajuda;
    end;
end;

{--------------------------------------------------------}
{                    programa principal
{--------------------------------------------------------}

begin
    inicializa;

    falaDiaQualquer (dia, mes, ano);
    delay (1000);
    mostraDia;

    fim:= false;
    repeat
        executaComando;
    until fim;

    gravaAgenda;
    finaliza;
end.
