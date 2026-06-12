{--------------------------------------------------------}
{
{     Cronovox - cronometro falado
{
{     Autor: Xyko Goncalves
{
{     Em marco/96
{
{--------------------------------------------------------}

program cronovox;
uses
     dvWin, dvCrt, dvleNum;

type
    regevento = record
        numevento, estado : byte;
        dias, hh, mm, ss, ce : word;
    comentario : string [16];
    end;

    regeventos = record
        estado, ultimoevento : byte;
     ano, mes, dia, hh, mm, ss, ce : word;
        evento : array [1..26] of regevento;
    end;

    label repete;

var
    atual : regeventos;
    eventos  : text;

    resposta : string;
    nomearq : string [40];
    opcao : char;
    indeven: integer;
    diacor, mescor, anocor, diasemcor, hhcor, mmcor, sscor, cecor : word;
    diaseven,   hheven, mmeven, sseven, ceeven : word;
    guardado : boolean;

{--------------------------------------------------------}

Procedure titulo;
begin
    clrscr;
    textbackground (BLUE);
    writeln (' ***   ****  *****  **    *   ***   *   *   ***  *   *');
    writeln ('*   *  *   * *   *  **    *  *   *  *   *  *   *  * * ');
    writeln ('*      *   * *   *  * *   *  *   *  *   *  *   *  *** ');
    writeln ('*      ****  *   *  *  *  *  *   *   * *   *   *   *  ');
    writeln ('*      * *   *   *  *   * *  *   *   * *   *   *  *** ');
    writeln ('*   *  *  *  *   *  *    **  *   *    *    *   *  * * ');
    writeln (' ***   *   * *****  *     *   ***     *     ***  *   *');
    textbackground (BLACK); clreol;
    writeln;
end;

{--------------------------------------------------------}

procedure finaliza;
begin
    writeln ('Fim do programa');
    sintsom ('crfim');
    sintfim;
    doneWinCrt;
end;

{--------------------------------------------------------}

function letecla (npula: integer): char;
var
    i: integer;
    c: char;
begin
    c := readkey;
    write(c);
    if c <> #13 then   {enter}
        sintcarac (c);
    for i := 1 to npula do writeln;
    letecla := upcase(c);
end;

{--------------------------------------------------------}
function digite : char;
begin
    textbackground (RED);
    digite := letecla (1);
    textbackground (BLACK);
end;

{--------------------------------------------------------}

Procedure fala (frase: string);
begin
   sintWriteln (frase);
end;

{---------------------------------------------------------------------}

{ *** rotina de leitura de eventos *** }

procedure LeEvento;
var i: integer;
    begin
    {$i-} reset (eventos);    {$I+}
    if ioresult <> 0 then
        begin
        atual.ultimoevento := 0;
        atual.estado := 0;
        for i := 1 to 26 do
            with atual.evento[i] do
                begin
                    estado := 0;
                    numevento := 0;
                    dias := 0;
                    hh := 0;    mm := 0;   ss := 0;  ce := 0;
                    comentario := '';
                end;
        indeven := 1;
        exit;
        end;
    with atual do
        begin
        readln (eventos, estado, ultimoevento,
                         ano, mes, dia, hh, mm, ss, ce);
        end;
    for i := 1 to 26 do
        begin
        with atual.evento [i] do
            begin
            readln (eventos, estado, numevento,
                             dias, hh, mm, ss, ce);
            readln (eventos, comentario);
            end;
        end;
    indeven := 1;
    close (eventos);
    writeln ('Eventos recuperados');
    sintsom ('crevecar');
    if atual.estado = 1 then
        begin
        writeln ('Evento aberto');
        sintsom ('creabert');
        end;
    end;

{---------------------------------------------------------------------}

{ *** rotina de gravacao de eventos *** }

procedure GravaEvento;
var i: integer;
    begin
    {$i-} rewrite (eventos);    {$I+}
    if ioresult <> 0 then
        begin
        writeln ('Erro de gravação no ' + nomearq);
        finaliza;
        end;
    with atual do
        begin
        writeln (eventos, estado, ' ', ultimoevento, ' ',
            ano, ' ', mes, ' ', dia, ' ',
        hh, ' ', mm, ' ', ss, ' ', ce);
        end;
    for i := 1 to 26 do
        begin
        with atual.evento [i] do
            begin
            writeln (eventos, estado, ' ', numevento, ' ',
                dias, ' ', hh, ' ', mm, ' ', ss, ' ', ce, ' ');
            writeln (eventos, comentario);
            end;
        end;
    indeven := 1;
    close (eventos);
    end;

{---------------------------------------------------------------------}

{ *** nas vezes impares do "f7", marca inicio do evento(estado 1) ***}

procedure MarcaInicio;
    begin
    with atual do
        begin
        dia := diacor;
        mes := mescor;
        ano := anocor;
        hh := hhcor;
        mm := mmcor;
        ss := sscor;
        ce := cecor;
        end;
    atual.estado := 1;
    gravaevento;
    end;

{---------------------------------------------------------------------}

{ *** transforma datas em total de dias *** }

procedure somadia (dia, mes, ano :word; var total : longint);
    const
    diasmes : array [1..11] of integer =
        (31, 59, 90,120, 151, 181, 212, 243, 273, 304, 334);

    var
    resto : integer;

    begin
    total := dia;
    if mes > 1 then
        begin
        mes := mes -1;
        total := total + diasmes [mes];
        end;
    resto := ano mod 4;
    if (resto = 0) and (mes > 1) then
        total := total +1;
    total := total + ((ano -1) * 365);
    resto := ano div 4;
    total := total + resto;
    end;


{---------------------------------------------------------------------}

{ *** verifica sequencia de data e hora *** }

procedure verdatahora (valmenor, valmaior : longint);

    begin
    if valmenor < valmaior then
        exit;
    writeln ('erro de sequência de data ou hora');
    writeln ('deseja apagar eventos?');
    writeln ('sim ou nao?');
    sintsom ('crerrodh');
    sintsom ('crdesapa');
    sintsom ('crsimnao');
    opcao := digite;
    if opcao = 'S' then
        begin
        erase (eventos);
        finaliza;
        end
    else finaliza;
    end;


{---------------------------------------------------------------------}

{ *** processa a medicao de dias *** }

procedure SubtraiData;
    var
    datainicio, datafim : longint;

    begin
    with atual do
        SomaDia (dia, mes, ano, datainicio);
    SomaDia (diacor, mescor, anocor, datafim);
    verdatahora (datainicio, datafim);
    diaseven := datafim -datainicio;
    if hhcor < atual.hh then
        begin
        diaseven := diaseven -1;
        hhcor := hhcor + 24;
        end;
    end;


{---------------------------------------------------------------------}

{ *** monta hora em texto *** }

procedure montahora (hheven, mmeven, sseven, ceeven : word);
    begin
    if hheven > 0 then
        begin
        if hheven = 1 then
            begin
            falanumeroconv (numeroparastring (hheven),1);
            sintsom ('crhora');
            end;
        if (hheven = 2) or (hheven =21) or (hheven = 22) then
            falanumeroconv (numeroparastring (hheven),1)
        else falanumeroconv (numeroparastring (hheven),0);
        sintsom ('crhoras');
        end;

    if mmeven > 0 then
        begin
        falanumeroconv (numeroparastring (mmeven),0);
        if mmeven > 1 then
            sintsom ('crminus')
        else sintsom ('crminu');
        end;
    if sseven > 0 then
        begin
        falanumeroconv (numeroparastring (sseven),0);
        if sseven > 1 then
            sintsom ('crsegus')
        else sintsom ('crsegu');
        end;

    if ceeven > 0 then
        begin
        falanumeroconv (numeroparastring (ceeven),0);
        if ceeven > 1 then
            sintsom ('crcents')
        else sintsom ('crcent');
        end;
    end;


{---------------------------------------------------------------------}

{ *** monta dias em texto *** }

procedure montadata (diaseven : word);

    begin
    if diaseven > 0 then
        begin
        falanumeroconv (numeroparastring (diaseven),0);
        if diaseven = 1 then
            sintsom ('crdia')
        else sintsom ('crdias');
        end;
    end;


{---------------------------------------------------------------------}

{ *** nas vezes pares do "f7", faz a medicao da duracao do evento (true) *** }

procedure MedeEvento;
    var
    somaant, somaatual, hora, minuto : longint;

    begin
    with atual do
        begin
        if ((anocor = ano) and (mescor = mes) and (diacor = dia)) then
            diaseven := 0
        else SubtraiData;
        hora := hh;
        minuto := mm;
        somaant := (hora *360000) + (minuto * 6000) + (ss * 100) + ce;
        end;
        hora := hhcor;
        minuto := mmcor;
    somaatual := (hora * 360000) + (minuto * 6000) + (sscor * 100) + cecor;
    verdatahora (somaant, somaatual);
        somaatual := somaatual -somaant;
    hheven := somaatual div 360000;
    somaatual := somaatual mod 360000;
    mmeven := somaatual div 6000;
    somaatual := somaatual mod 6000;
    sseven := somaatual div 100;
    somaatual := somaatual mod 100;
    ceeven := somaatual;

    MontaData (diaseven);
    montahora (hheven, mmeven, sseven, ceeven);
    atual.estado := 0;
    Gravaevento;
    end;

{------------------------------------------------K--------------------}

{ *** verifica se tem eventos para apagar *** }

procedure versaida;
    begin
    if atual.ultimoevento > 0 then
        begin
        writeln ('confirma apagamento de eventos?');
        writeln ('sim ou não');
        sintsom ('crapaeve');
        sintsom ('crsimnao');
        opcao := digite;
        if opcao = 'S' then
            begin
            erase (eventos);
            finaliza;
            end;
        end;
    finaliza;
    end;

{------------------------------------------------K--------------------}

{ *** armazenacontrola estado (0: fechado; 1: (aberto) *** }

procedure TrataEvento;
    label EsperaFim;

    begin
    gettime (hhcor, mmcor, sscor, cecor);
    getdate (anocor, mescor, diacor, diasemcor);
    anocor := anocor -1900;
    if atual.estado = 0 then
        begin
        write ('já... ');
        sintsom ('crja');
        MarcaInicio;
        end
    else begin
        writeln ('Tempo');
        sintsom ('crtempo');
        exit;
        end;

EsperaFim:
    opcao := digite;
    if ord (opcao) = 0 then
        begin
        opcao := readkey;
        case opcao of
            F7: begin
            gettime (hhcor, mmcor, sscor,cecor);
            getdate (anocor, mescor, diacor, diasemcor);
            anocor := anocor - 1900;
            writeln ('Tempo');
            sintsom ('crtempo');
            end;
            F1 : begin
            writeln ('F7 assinala inicio e fim do evento');
            writeln ('F2 salva eventos e encerra');
            sintsom ('craju1');
            sintsom ('craju3');
            goto EsperaFim;
            end;
            F2 : begin
            writeln ('Evento aberto');
            writeln ('eventos guardados');
            sintsom ('creabert');
            sintsom ('creguard');
            finaliza;
            end;
        else begin
            writeln ('Função inválida');
            sintsom ('crfuninv');
            goto EsperaFim;
            end;
        end;
        end
    else begin
        if opcao = esc then
            versaida;
        writeln ('tecla invalida');
        sintsom ('crtecinv');
        goto EsperaFim;
        end;
    end;


{------------------------------------------------K--------------------}

{ *** elimina evento (opcao 0) *** }

procedure EliminaEvento;
    var
    i: integer;
    eliminado : byte;

    begin
    eliminado := atual.evento [indeven] .numevento;
    atual.evento [indeven] .estado := 0;
    for i := 1 to 26 do
        begin
        if eliminado < atual.evento [i] .numevento then
            atual.evento [i] .numevento := atual.evento [i] .numevento -1;
        end;
    indEven := 1;
    atual.ultimoevento := atual.ultimoevento -1;
    end;

{------------------------------------------------K--------------------}

{ *** pega comentario do evento ***}

procedure PoeComentario;

    begin
    writeln ('comente:');
    sintsom ('crcoment');
    sintReadln (resposta);
    atual.evento [indeven] .comentario := resposta;
    end;

{------------------------------------------------K--------------------}

{ *** processa a guarda de eventos *** }

procedure GuardaEvento;
    begin
    if guardado then
        begin
        writeln ('nada');
        sintsom ('crnada');
        exit;
        end;
    atual.ultimoevento := atual.ultimoevento +1;
    with atual.evento [indeven] do
        begin
        dias := diaseven;
        numevento:= atual.ultimoevento;
        hh :=hheven;
        mm :=mmeven;
        ss := sseven;
        ce :=ceeven;
        estado := 1;
        guardado := true;
        PoeComentario;
        GravaEvento;
        writeln ('guardado');
        sintsom ('crguarda');
        end;
    end;

{------------------------------------------------K--------------------}

{ *** fala comentario do evento *** }

procedure FalaComentario;
    begin
    if atual.evento [indeven] .estado = 0 then
        begin
        writeln ('nada');
        sintsom ('crnada');
        exit;
        end;
    if atual.evento [indeven] .comentario = '' then
        begin
        writeln ('nada');
        sintsom ('crnada');
        exit;{------------------------------------------------K--------------------}
        end;
    fala (atual.evento [indeven] .comentario);
    end;


{------------------------------------------------K--------------------}

{ *** trata opcao *** }

procedure testaopcao;
    var i: integer;
    label novaopcao;

    begin
novaopcao:
    textBackground (BLUE);
    write ('Sua opcao');
    textBackground (BLACK);
    sintsom ('crsuaopc');

    opcao := digite;
    if ord (opcao) = 0 then
        begin
        opcao := readkey;
        case opcao of
        F7 : begin
            TrataEvento;
            medeevento;
            guardado := false;
            goto novaopcao;
            end;
        F1 : begin
            writeln ('F7 assinala inicio e fim do evento');
            writeln ('F4 (fala comentario)');
            writeln ('Letra (aciona memoria)');
            writeln ('0 (apaga memoria), * (apaga todas as memorias)');
            writeln ('F2 (salva eventos e encerra)');
            writeln ('Esc (termina)');
            sintsom ('craju1');
            sintsom ('craju4');
            sintsom ('craju2');
            sintsom ('craju3');
            goto novaopcao;
            end;
        F2 : begin
            writeln ('Eventos guardados');
            sintsom ('creguard');
            finaliza;
            end;
        F4 : begin
            FalaComentario;
            goto novaopcao;
            end;
        else begin
            writeln ('Função invalida');
            sintsom ('crfuninv');
            goto novaopcao;
            end;
            end;
        end;
    if opcao = ESC then
        VerSaida;
    if opcao = '*' then
        begin
        writeln ('Deseja zerar eventos? - sim ou nao?');
        sintsom ('crzerato');
        sintsom ('crsimnao');
        opcao := digite;
        if opcao = 'S' then
            begin
            for i := 0 to 26 do
                atual.evento [i] .estado := 0;
            indeven := 1;
            guardado := false;
            atual.ultimoevento := 0;
            goto novaopcao;
            end
        else goto novaopcao ;
        end;
    if opcao = '0' then
        begin
        writeln ('qual a memoria a apagar?');
        sintsom ('crzeraum');
        opcao := digite;
        if opcao = esc then
            goto novaopcao;
        if (ord (opcao) < 65) or (ord (opcao) >90) then
            begin
            writeln ('Tecla invalida');
            sintsom ('crtecinv');
            goto novaopcao;
            end
        else begin
            indeven := ord (opcao) - 64;
            if atual.evento [indeven] .estado = 0 then
                begin
                writeln ('nada');
                sintsom ('crnada');
                goto novaopcao;
                end;
            EliminaEvento;
            goto NovaOpcao;
            end;
        end;
    if (ord (opcao) < 65) or (ord (opcao) > 90) then
        begin
        writeln ('tecla invalida');
        sintsom ('crtecinv');
        goto novaopcao;
        end;
    indeven := ord (opcao) - 64;
    if atual.evento [indeven] .estado = 0 then
        begin
        GuardaEvento;
        goto novaopcao;
        end
    else begin
        with atual.evento [indeven] do
            begin
            sintsom ('crevento');
            falanumeroconv (numeroparastring (numevento),0);
            sintbip;
           { if keypressed then
                goto novaopcao; }
            montadata (dias);
            montahora (hh, mm, ss, ce);
            goto novaopcao;
            end;
        end;
    end;

{--------------------------------------------------------}

{ *** configura ambiente  ***}
procedure inicializa;
var dir: string;
begin
    dir := sintAmbiente ('CRONOVOX', 'DIRCRONOVOX');
    if dir = '' then
        dir := 'c:\winvox\som\cronovox';
    sintinic (0, dir);

    sintsom ('crcronov');
    nomearq := paramstr (1);
    if nomearq = '' then
        nomearq :='eventos.tpo';

    assign (eventos, nomearq);
    leevento;
    end;

{--------------------------------------------------------}

{ *** inicio do programa ***}
begin
    titulo;
    inicializa;
    TestaOpcao;
    end.
