unit ckfolhei;

interface

uses dvcrt, dvwin,
ckarq, ckutil, ckjan, ckvars;

    procedure ajudaFolheia;
    procedure apagaEvento;
    procedure totalEventos;
    procedure informaDataHoraEvento;
    procedure detalhesEventos;
    procedure folheiaEventos;

implementation

procedure ajudaFolheia;
begin

        gotoxy (10, 5);
        write ('Opções nas teclas : ');
        gotoxy (10, 6);
        write ('Setas ..... Lista eventos existentes');
        gotoxy (10, 7);
        write ('A     ..... Apaga evento existente');
        gotoxy (10, 8);
        write ('I     ..... Informações detalhadas sobre evento existente');
        gotoxy (10, 9);
        write ('T     ..... Informa total de eventos existentes');

end; {Procedure}

procedure apagaEvento;
    var convString: string; opcao: char;
begin

    str (numEvento, convString);
    write ('Confirma a exclusão do evento ? ');
    sintsom ('ckconfe');
    sintwrite (convString);
    write (' (S/N) : ');

    opcao:= sintreadkey;
    writeln (opcao);
    if upcase(opcao) <> 'S' then
    begin
        writeln ('Ok, exclusão cancelada');
        sintsom ('ckexcan');
        exit;
    end;

    numeroRegistros:= filesize(arq);
    seek (arq, numeroRegistros - numeroRegistros);

    assign (arq_tmp, nomeTemp);
    rewrite (arq_tmp);

    while not eof (arq) do
    begin
        read (arq, x);
        if filepos(arq) <> numEvento then
        write (arq_tmp, x);
    end;

    close (arq);
    erase (arq);
    close (arq_tmp);
    rename (arq_tmp, nomeDat);
    reset (arq);
    carregaEventos;

    sintsom ('ckdel');
    writeln ('Ok, o evento foi excluído');
    sintsom ('ckexok');

end; {Procedure}

procedure totalEventos;
var convString: string;
begin
    str (numeroRegistros, convString);
    write ('Número total de eventos : ');
    sintsom ('ckntotal');
    sintwriteln (convString);

end; {Procedure}

procedure informaDataHoraEvento;
var convString: string;
label hora;
begin

    if execDia_m[numEvento] = 'AMANHA' then
    begin
        sintwrite ('Amanhã');
        goto hora;
    end;

    if execDia_m[numEvento] = 'HOJE' then
    begin
        sintwrite ('Hoje');
        goto hora;
    end;

    if execDia_m[numEvento] = 'CERTODIA' then
    begin
        sintwrite ('Dia : ');
        str (dia_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (mes_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (ano_m[numEvento], convstring);
        sintwrite (convstring);
        goto hora;
    end;

    if execDia_m[numEvento] = 'TODOSDIAS' then
    begin
        sintwrite ('Todos os dias');
        goto hora;
    end;

    if execDia_m[numEvento] = 'CERTOSDIASEMANA' then
    begin
        if diaSemana_m[numEvento] = 0 then sintwrite ('todo domingo');
        if diaSemana_m[numEvento] = 1 then sintwrite ('toda segunda feira');
        if diaSemana_m[numEvento] = 2 then sintwrite ('toda terça feira');
        if diaSemana_m[numEvento] = 3 then sintwrite ('toda quarta feira');
        if diaSemana_m[numEvento] = 4 then sintwrite ('toda quinta feira');
        if diaSemana_m[numEvento] = 5 then sintwrite ('toda sexta feira');
        if diaSemana_m[numEvento] = 6 then sintwrite ('todo sábado');
        goto hora;
    end;

    if execDia_m[numEvento] = 'DIASUTEIS' then
    begin
        sintwrite ('Todos os dias úteis');
        goto hora;
    end;

    if execDia_m[numEvento] = 'INICIO' then
    begin
        sintwrite ('Sempre que iniciar');
        exit;
    end;

hora:
    sintbip;
    write ('     ');

    sintwrite ('Hora:');
    str (hora_m[numEvento], convstring);
    sintwrite (convstring);
    sintwrite (':');
    str (minuto_m[numEvento], convstring);
    sintwrite (convstring);
    writeln;
end; {Procedure}

procedure DetalhesEventos;
var convString: string;
begin

    if execDia_m[numEvento] = 'AMANHA' then
    begin
        writeln ('Marcado para amanhã');
        sintsom ('ckmarc'); sintetiza ('amanhã');
        sintwrite ('Dia : ');
        str (dia_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (mes_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (ano_m[numEvento], convstring);
        sintwrite (convstring);
    end;

    if execDia_m[numEvento] = 'HOJE' then
    begin
        writeln ('Marcado para hoje');
        sintsom ('ckmarc'); sintetiza ('hoje');
        sintwrite ('Dia : ');
        str (dia_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (mes_m[numEvento], convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (ano_m[numEvento], convstring);
        sintwriteln (convstring);
    end;

    if execDia_m[numEvento] = 'TODOSDIAS' then
    begin
        writeln ('Marcado para todos os dias');
        sintsom ('ckmarc'); sintetiza ('todos os dias');
    end;

    if execDia_m[numEvento] = 'CERTODIA' then
    begin
        write ('Marcado para o dia : ');
        sintsom ('ckmarc'); sintetiza ('o dia');
        str (x.dia_b, convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (x.mes_b, convstring);
        sintwrite (convstring);
        sintwrite ('/');
        str (x.ano_b, convstring);
        sintwriteln (convstring);
    end;

    if execDia_m[numEvento] = 'CERTOSDIASEMANA' then
    begin
        write ('Marcado para ');
        sintsom ('ckmarc');
        if diaSemana_m[numEvento] = 0 then sintwriteln ('todo domingo');
        if diaSemana_m[numEvento] = 1 then sintwriteln ('toda segunda');
        if diaSemana_m[numEvento] = 2 then sintwriteln ('toda terça');
        if diaSemana_m[numEvento] = 3 then sintwriteln ('toda quarta');
        if diaSemana_m[numEvento] = 4 then sintwriteln ('toda quinta');
        if diaSemana_m[numEvento] = 5 then sintwriteln ('toda sexta');
        if diaSemana_m[numEvento] = 6 then sintwriteln ('todo sábado');
    end;

    if execDia_m[numEvento] = 'DIASUTEIS' then
    begin
        writeln ('Marcado para todos os dias úteis');
        sintsom ('ckmarc'); sintetiza ('todos os dias úteis');
    end;

    if execDia_m[numEvento] = 'INICIO' then
    begin
        writeln ('Marcado para sempre que iniciar');
        sintsom ('ckmarc'); sintetiza ('sempre que iniciar');
        if ano_m[numEvento] = 2099 then
        sintwriteln ('Todos os dias')
        else
        begin
            sintwrite ('Dia : ');
            str (dia_m[numEvento], convstring);
            sintwrite (convstring);
            sintwrite ('/');
            str (mes_m[numEvento], convstring);
            sintwrite (convstring);
            sintwrite ('/');
            str (ano_m[numEvento], convstring);
            sintwriteln (convstring);
        end;
    end;

    if frase_m[numEvento] <> '' then
    begin
        write ('Informará o texto : ');
        sintsom ('ckinftxt');
        sintwriteln (frase_m[numEvento]);
    end;

    if programa_m[numEvento] <> '.EXE' then
    begin
        write ('Executara o programa : ');
        sintsom ('ckinfexe');
        sintwriteln (programa_m[numEvento]);
    end;

end; {Procedure}

procedure folheiaEventos;
var c: char; maxEventos: integer; s: string;
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

    if numeroRegistros = 0 then
    begin
        jan_fim;
        writeln ('Não existe nenhum evento a folhear, o arquivo está vazio');
        sintsom ('cknexist');
        exit;
    end;

    numEvento:= 0;
    {maxEventos será dinâmico}

    jan_mei;
    ajudaFolheia;
    sintsom ('cktec');
    jan_fim;
    writeln ('Folheando eventos, use as setas e tecle sua opção, F1 ajuda');
    sintsom ('ckfevent');

repeat

    maxEventos:= numeroRegistros;

    c := readkey;
    if c in ['a'..'z', 'A'..'Z'] then
    sintcarac (c);

    if c = #0 then
    begin
        c:= readkey;
        case c of

            F1: begin
                sintsom ('ckoptec');
                sintsom ('cksevent');
                sintsom ('ckaevent');
                sintsom ('ckievent');
                sintsom ('cktevent');
                sintsom ('cktec2');
            end;


            BAIXo:   begin
            sintsom ('ckbip');
            numEvento:= numEvento + 1;
            if numEvento > maxEventos then
            begin
                numEvento:= maxEventos + 1;
                sintSom ('ckult');
            end
            else
                informaDataHoraEvento;
            end;

            CIMA:   begin
            sintsom ('ckbip');
            numEvento:= numEvento - 1;
            if numEvento < 1 then
            begin
                numEvento:= 0;
                sintsom ('ckpri');
            end
            else
                informaDataHoraEvento;
            end;

        end;
        end
        else
        begin
            if (numEvento > 0) and (numEvento <= maxEventos) then
            case upcase(c) of

            ENTER: detalhesEventos;

            'I': detalhesEventos;
            'T': totalEventos;
            'A': apagaEvento;

            else if c <> ESC then
            begin
                writeln;
                writeln ('Opção inválida, use as setas, F1 ajuda');
                sintsom ('ckinvset');
                sintsom ('ckf1');
            end;
            end;

            if (c <> ESC) and (numeroRegistros > 0) then
            begin
                writeln;
                writeln ('Continue selecionando ou tecle ESC');
                sintsom ('ckcontf');
            end;

        end;

until (c = ESC) or (numeroRegistros = 0);

end; {Procedure}

end.
