unit ppAuto;

interface

uses dvCrt, dvWin,
    ppMsg, ppVars;

procedure defineTempo;

implementation

{--------------------------------------------------------}

procedure defineTempo;
var opcao: char;
begin

    writeln;
    mensagem ('PPAUTATR', 1); {('Automatizando, atribua funções de tempo, repetição e leitura');}
    delay (100);

    writeln;
    mensagem ('PPTEMTRO', 0); {('Deseja definir um tempo para a troca de cada slide ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if (upcase(opcao) <> 'N') and (opcao <> ESC) then
    begin
        mensagem ('PPINFTEM', 0); {('Informe então o tempo para cada slide (mínimo de 3 segundos) : ');}
        sintReadInt (tempoSlide);
        if tempoSlide < 3 then
        begin
            mensagem ('PPVALINV', 1); {('Valor inválido');}
            tempoSlide:= 0;
        end
        else
        begin
            mensagem ('PPIREAVA', 0); {('OK, irei avançar em ');}
            sintWriteInt (tempoSlide);
            mensagem ('PPSEGUND', 1); {(' segundos');}
        end;
    end
    else
    begin
        tempoSlide:= 0;
        mensagem ('PPTROMAN', 1); {('OK, a troca dos slides será feita manualmente');}
    end;

    if tempoSlide <> 0 then
    begin
        limpaBufTec;

        writeln;
        mensagem ('PPREIULT', 0); {('Deseja reiniciar a apresentação após o último slide ? ');}
        opcao:= sintReadkey;
        writeln (opcao);

        if (upcase(opcao) <> 'N') and (opcao <> ESC) then
        begin
            repeteAuto:= true;
            mensagem ('PPREPATI', 1); {('OK, repetição ativada');}
        end
        else
            mensagem ('PPREPDES', 1); {('OK, repetição desativada');}
    end;

    limpaBufTec;

    writeln;
    mensagem ('PPDEFLIN', 0); {('Deseja definir que todas as linhas sejam sintetizadas automaticamente ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if (upcase(opcao) <> 'N') and (opcao <> ESC) then
    begin
        mensagem ('PPTEMLIN', 0); {('Informe então o tempo entre cada linha (mínimo de 1 segundo) : ');}
        sintReadInt (tempoLinha);
        if tempoLinha < 1 then
        begin
            mensagem ('PPVALINV', 1); {('Valor inválido');}
            tempoLinha:= 0;
            leAuto:= false;
            primeiraVez:= true;
        end
        else
        begin
            leAuto:= true;
            primeiraVez:= true;
            mensagem ('ppiresin', 0); {('OK, irei sintetizar em ');}
            sintWriteInt (tempoLinha);
            if tempoLinha > 1 then
                mensagem ('PPSEGUND', 1) {(' segundos');}
            else
                mensagem ('PPSEGUN', 1); {(' segundo');}
        end;
    end
    else
    begin
        tempoLinha:= 0;
        leAuto:= false;
        primeiraVez:= true;
        mensagem ('PPSINMAN', 1); {('OK, a síntese das linhas será feita manualmente');}
    end;

mensagem ('PPFIMATR', 1); {('Fim das atribuições, irei retornar ao menu principal');}

end;

end.
