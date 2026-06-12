{-------------------------------------------------------------}
{    Programa CLOCKVOX}
{    Autores: Bernard Condorcet e Antônio Borges}
{    Em 1/12/1999}
{-------------------------------------------------------------}

program clockvox;

uses
   windows, dvcrt, dvwin, dvhora, dvexec,
   ckajusdh, ckcalend, ckfolhei, ckprog, ckarq,
   ckutil, ckjan, ckvars;

    var dir: string;

procedure ajudaClockvox;
begin

        gotoxy (10, 5);
        Write ('Opções nas teclas :');
        gotoxy (10, 6);
        write ('F8 ..... Informa data e hora');
        gotoxy (10, 7);
        write ('A  ..... Ajusta Data e Hora');
        gotoxy (10, 8);
        write ('C  ..... Calendário');
        gotoxy (10, 9);
        write ('F  ..... Folheia Eventos');
        gotoxy (10, 10);
        write ('P  ..... Programa eventos');
        gotoxy (10, 11);
        write ('X  ..... Ativa senha');

end; {Procedure}

procedure finalizaClockvox;
begin

    deletaEventosPassados;
    delay (100);

    sintsom ('cksair');
    delay (100);

    sintFim;
    doneWinCrt;

end; {Procedure}

procedure ativaSenha;
var s: string;
begin

    if senha <> '' then
    exit;

    jan_fim;
    write ('Informe a senha desejada, até 8 letras : ');
    sintsom ('cksenhad');
    sintreadln (s);

    if s = '' then
    exit
    else
    begin
        senha:= s;
        EnableMenuItem(GetSystemMenu(CrtWindow, False), sc_Close, mf_Disabled);
    end;

end; {Procedure}

procedure despertaOk;
var i:integer;

procedure bipSpeaker (pitch: integer);
begin
    speakerSound (pitch);
    delay (10);
    speakerNosound;
end;

begin
    delay (500);
    sintsom ('ckcam');
    delay (500);

    if execDia_m[indice] <> 'INICIO' then
    begin
        repeat
            for i:= 50 to sinal_m[indice] do
                bipspeaker (i);
        until (keypressed) or (sinal_m[indice] = 55);
    end;

    while keypressed do readkey;

    if frase_m[indice] <> '' then
    begin
        delay (1000);
        while sintfalando do;
        sintetiza (frase_m[indice]);
    end;

    if programa_m[indice] <> '.EXE' then
    begin
        getDir (0, dir);
        if executaProg (programa_m[indice], dir, arquivo_m[indice]) >= 32 then
        else
        begin
            delay (1000);
            while sintfalando do;
            sintsom ('cknprog');
        end;
    end;

    falaJanela:= true;
    execAtrib[indice]:= false;

end; {Procedure}

procedure defineFuncaoTecla;
var c, opcao: char; s: string;
begin

    c:= readkey;
    if c in ['a'..'z','A'..'Z'] then
    sintcarac (c);

    if c = #0 then
    begin
        c:= readkey;
        case c of
            F1: begin
                sintsom ('ckoptec');
                sintsom ('ckajusdh');
                sintsom ('ckcalend');
                sintsom ('ckfolhei');
                sintsom ('ckprog');
                sintsom ('ckx');
                sintsom ('cktec2');
            end;

            F8: begin falaDia; falaHora; end;

        end;
    end
    else

        case upcase(c) of
            ESC, 'S':
                begin
                    jan_fim;
                    write ('Confirma o fim do Clockvox ? (S/N) : ');
                    sintsom ('ckfim');
                    opcao:= sintreadkey;
                    if upcase(opcao) <> 'S' then
                    exit
                    else
                    begin
                        if senha <> '' then
                        begin
                            writeln;
                            write ('Informe a senha : ');
                            sintsom ('cksenhap');
                            sintreadln (s);
                            if s <> senha then
        exit;
                        end;
                    sairLoop:= true;
                    end;
                end;

            'A': ajustaDataHora;
            'C': calendario;
            'F': folheiaEventos;
            'P': programaEvento;
            'X': ativaSenha;
            GOTFOCUS: falaJanela:= true;
            NOFOCUS: falaJanela:= false;

        end;

end; {Procedure}

procedure verificaAtributos;
begin

    if (execDia_m[indice] = 'AMANHA') or (execDia_m[indice] = 'HOJE') or (execDia_m[indice] = 'CERTODIA') then
    begin
        if dia = dia_m[indice] then
        if mes = mes_m[indice] then
        if ano = ano_m[indice] then
        if minuto = minuto_m[indice] then
        if hora = hora_m[indice] then
        despertaOk;
        exit;
    end;

    if execDia_m[indice] = 'TODOSDIAS' then
    begin
        if minuto = minuto_m[indice] then
        if hora = hora_m[indice] then
        despertaOk;
        exit;
    end;

    if execDia_m[indice] = 'CERTOSDIASEMANA' then
    begin
        if sem = diaSemana_m[indice] then
        if minuto = minuto_m[indice] then
        if hora = hora_m[indice] then
        despertaOk;
        exit;
    end;

    if execDia_m[indice] = 'DIASUTEIS' then
    begin
        if (sem <> 6) and (sem <> 0) then
        if minuto = minuto_m[indice] then
        if hora = hora_m[indice] then
        despertaOk;
        exit;
    end;

    if start then
    begin
        if execDia_m[indice] = 'INICIO' then
        if ano_m[indice] = 2099 then
        despertaOk
        else
        begin
            if dia = dia_m[indice] then
            if mes = mes_m[indice] then
            if ano = ano_m[indice] then
            despertaOk;
        end;
        exit;
    end;

end; {Procedure}

procedure loopPrincipal;
begin

     repeat

    getdate (ano, mes, dia, sem);
    gettime (hora, minuto, segundo, cents);

    if numeroRegistros > 0 then
    begin
    delay (500);
        indice:= 0;
        repeat
            indice:= indice + 1;
            if execAtrib[indice] then
                verificaAtributos;
        until indice = numeroRegistros;
        start:= false;
    end
    else
    delay (1000);

    if keypressed then
    begin

        defineFuncaoTecla;
        while keypressed do readkey;

        if (falaJanela) and (not sairLoop) then
        begin

            jan_mei;
            ajudaClockvox;

            jan_fim;
            sintsom ('ckmen');
            write ('Clockvox, qual sua opção, F1 ajuda');
            sintsom ('ckckf1');
        end;
    end;

until sairLoop;

end; {Procedure}

procedure inicializaClockvox;
var s1, s2: string;
    j: integer;
begin

    j := findWindowEx(0, 0, 'dvwincrt', 'CLOCKVOX');
    if j <> 0 then halt;

    if (GetVersion and $80000000) = 0 then   // windows NT ou XP
        commandCom := 'cmd'
    else
        commandCom := 'command';

    sintInic (0, sintambiente ('CLOCKVOX', 'DIRCLOCKVOX'));
    nomeDat  := sintambiente ('CLOCKVOX', 'ARQCLOCKVOX');
    if nomeDat = '' then nomeDat := sintDirAmbiente + '\clockvox.dat';

    nomeTemp := sintambiente ('CLOCKVOX', 'ARQTEMP');
    if nomeTemp = '' then nomeTemp := sintDirAmbiente + '\clockvox.$$$';

    s1:= ('Programa CLOCKVOX - Versão 1.2b             Projeto DOSVOX - NCE/UFRJ');
    s2:= ('CLOCKVOX ATIVO, F1 AJUDA');

    jan_ini;
    setWindowText (crtWindow, 'CLOCKVOX');
    GOTOXY((80-LENGTH(s1))DIV 2,2);
    write (s1);
    jan_mei;
    ajudaClockvox;
    jan_fim;
    writeln (s2);

    sintsom ('ckini');
    sintsom ('ckclock');

    abreArquivo;
    if filesize(arq) > 0 then
        carregaEventos
    else
    begin
        writeln ('Não existe nenhum evento relacionado, F1 ajuda');
        sintsom ('cknevent');
        delay (1000);
    end;

    checkBreak := false;
    checkFocus:= true;
    start:= true;
    falaJanela:= true;
    sairLoop:= false;
    senha:= '';

end; {Procedure}

                                {Rotina Principal}

begin

    inicializaClockvox;
    loopPrincipal;
    finalizaClockvox;

end.
