program ligavox;

uses dvCrt, dvWin, dvComm, dvArq, videoVox,
    windows, sysUtils,
    ligUtil, ligMsg;
var
    ler, gravar: text;
    cadNomes, cadPulso: string;
    portaModem: word;
    nomes: array [0..199] of string;
    i, j: integer;
    s: string;
    existeNomes: boolean;
    tec: char;
    cont: integer;
    tel, tipoPul: string;
    puls: integer;
    valPuls, calcPulsos: double;
    erro: integer;
    dia, mes, ano, sem: word;
    d, m: string;

    dir: string;
    label novoNum, mesmoNum, erro_modem, terminar_programa;

{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (pitch);
    delay (10);
    SpeakerNoSound;
end;

{--------------------------------------------------------}

procedure incrementaVariaveis;
begin

    cont:= 0;
    puls:= puls + 1;

    sintSom ('CUCO');

    write ('/ ');
    sintWrite (intToStr(puls));

end;

{--------------------------------------------------------}

begin
    dir := sintAmbiente('LIGAVOX', 'DIRLIGAVOX');
    if dir = '' then
        dir := 'c:\winvox\som\ligavox';
    SintInic (0, dir);

    cadNomes:= sintAmbiente('LIGAVOX', 'CADASTRONOMES');
    if cadNomes= '' then
        cadNomes:= 'c:\winvox\lignomes.txt';
    cadPulso:= sintAmbiente('LIGAVOX', 'CADASTROPULSOS');
    if cadPulso = '' then
        cadPulso:= 'c:\winvox\ligpulso.txt';
    s:= sintAmbiente('LIGAVOX', 'PORTAMODEM');
    if s = '' then
        s:= '2';
    val (s, portaModem, erro);
    if erro <> 0 then
    begin
        writeln;
        sintWriteln ('Porta inválida');
        goto terminar_programa;
    end;

    getdate (ano, mes, dia, sem);
    s:= '';
    existeNomes:= false;
    puls:= 1;
    cont:= 0;
    tec := ' ';
    valPuls := 0;

// Verifica nomes cadastrados

    assign (ler, cadNomes);
    {$i-} reset(ler); {$i+}
    if IoResult <> 0 then
    rewrite (ler)
    else
    begin
        while not eof (ler) do
        begin
            readln (ler, s);
            if s <> '' then
                if s[1] in ['a'..'z', 'A'..'Z'] then
                begin
                    existeNomes:= true;
                    cont:= cont + 1;
                    nomes[cont]:= s;
                end;
        end;

    close (ler);
    s:= '';

// Ordena nomes cadastrados

    if (existeNomes) and (cont > 2) then
        begin
                for i:= 1 to cont - 1 do
                for j:= i + 1 to cont do
                    if nomes[i] > nomes[j] then
                        begin
                            s:= nomes[i];
                            nomes[i]:= nomes[j];
                            nomes[j]:= s;
                        end;
        end;
    cont:= 0;
    end;

// Inicia as mensagens na tela

    clrscr;
    mensagem ('LGINIC', 1); {'Contador de pulsos telefônicos'}
    writeln ('PROJETO DOSVOX - NCE/UFRJ');
    writeln;
    sintSom ('INICIAR');
    delay (500);

// Escolhe por nomes cadastrados

    if existeNomes then
    begin
        mensagem ('LGCADATI', 1); {'Cadastro ativo, use as SETAS e pressione ENTER'}
        cont:= 1;
        repeat
            bipSpeaker (5000);
            sintWriteln (copy (nomes[cont], 1, pos ('/', nomes[cont]) -1));
            tec:= readkey;
            if tec = #0 then
                tec:= readkey;
            if (tec = CIMA) and (cont > 0) then
            begin
                cont:= cont -1;
                if nomes[cont] = '' then
                    cont:= cont + 1;
            end;
            if (tec = baix) and (cont < 200) then
            begin
                cont:= cont +1;
                if nomes[cont] = '' then
                    cont:= cont -1;
            end;
            //if (tec = CIMA) or (tec = BAIX) then
        until (tec = ENTER) or (tec = ESC);

        if tec = ESC then
            goto terminar_programa;

        delete (nomes[cont], 1, pos ('/', nomes[cont]));
        tipoPul:= copy(nomes[cont], 1, pos('=', nomes[cont]) -1);
        delete (nomes[cont], 1, pos ('=', nomes[cont]));
        tel:= nomes[cont];
    end
    else
    begin
        novoNum:
        tipoPul:= 'Não informado pelo cadastro';
        writeln;
        mensagem ('LGTEL', 0); {'Informe o telefone desejado : '}
        sintReadln (tel);
        if tel = ESC then
            goto terminar_programa;
    end;

// Pede valor do pulso

    s:= '0';
    if upcase(tipoPul[1]) <> 'G' then
    begin
        writeln;
        mensagem ('LGPUL', 0); {'Informe o valor do pulso neste horário : '}
        sintReadln (s);
        if s = '' then
            s:= '0';
            val (s, valPuls, erro);
            if erro <> 0 then
            begin
                    writeln;
                    sintWriteln ('Valor inválido');
                    goto terminar_programa;
            end;
    end;

// Informa tipo de ligação e número do telefone

    if tel <> '' then
    begin
        mensagem ('LGTIP', 0); {'Ligação tipo'}
        write (' - ');
        sintWrite (tipoPul);
        write (' - ');
        mensagem ('LGNUM', 0); {'para o número '}
        sintWriteln (tel);
        writeln;
        writeln ('Informações do modem');
        writeln;

        mesmoNum:
        if InicLink (portaModem, 14400, 8, 1, 0) <> 0 then
            goto erro_modem;
        delay (500);
        if not discaModem (tel) then
            goto erro_modem;
        delay (5000);
        sintSom ('TELEFONE');
        if tec = '*' then
            repeat until keyPressed;
        writeln;
        writeln;
        mensagem ('LGRETIR', 1); {'Retire o telefone do gancho agora'}
        sintSom ('TELEFONE');
        delay (500);
        desligaModem;
        finalLink;
    end
    else
        tel:= 'Tel não informado';

// Verifica se ligação é gratuíta

    if upcase(tipoPul[1]) = 'G' then
    begin
        writeln;
        mensagem ('LGLIGGRA', 1); {'Ligação gratuíta, não irei contabilizar os pulsos'}
        goto terminar_programa;
    end;

// Aguarda tecla pressionada para iniciar a contagem

    writeln;
    mensagem ('LGBARRA', 1); {'Para a contagem, ao ser atendido pressione BARRA DE ESPAÇOS'}
    writeln;
    writeln ('Comandos especiais:');
    writeln ('* --- Repetir o mesmo número não desligando o MODEM');
    writeln ('R --- Repetir o mesmo número desligando o MODEM');
    writeln ('N --- Informar novo número');
    writeln ('S --- Sair sem a contagem de pulsos');
    writeln;
    tec:= readKey;
    if (upcase(tec) = 'R') or (tec = '*') then
        goto mesmoNum;
    if upcase(tec) = 'N' then
        goto novoNum;
    if (upcase(tec) = 'S') or (tec = ESC) then
        goto terminar_programa;
    if tec = #0 then
        leitorDeTela;

// Informa total de pulso(s)

    tec:= ENTER;
    sintSom ('CUCO');
    write ('Total de pulso(s) neste momento --- ');
    sintWrite (intToStr(puls));

    repeat
        delay (1000);
        cont:= cont+ 1;
        bipSpeaker (50);
        if upcase(tipoPul[1]) = 'L' then
            if cont = 230 then
                sintSom ('BIPA');
        if (upcase(tipoPul[1]) = 'I') or (upcase(tipoPul[1]) = 'C') or (upcase(tipoPul[1]) = 'M') then
            if cont = 50 then
                sintSom ('BIPA');
        if upcase(tipoPul[1]) = 'L' then
            if cont = 240 then
                incrementaVariaveis;
        if (upcase(tipoPul[1]) = 'I') or (upcase(tipoPul[1]) = 'C') or (upcase(tipoPul[1]) = 'M') then
            if cont = 60 then
                incrementaVariaveis;
        if keyPressed then
        begin
            tec:= readkey;
            if tec = ENTER then
            begin
                calcPulsos:= valPuls * puls;
                str (calcPulsos:2:2, s);
                sintetiza (s);
            end;
        end;
    until tec <> ENTER;

// Realiza cálculo e escreve na tela

    calcPulsos:= valPuls * puls;

    writeln;
    write ('Valor aproximado de pulsos gastos --- ');
    writeln (calcPulsos:2:2);

    writeln;
    mensagem ('LGLEIA', 1); {'Leia com as setas ou pressione ESC para terminar'}
    leitorDeTela;

// Grava dados em arquivo

    assign (gravar, cadPulso);
    {$i-} append (gravar); {$i+}
    if IoResult <> 0 then
    begin
        rewrite (gravar);
        writeln (gravar, 'Consulte obedecendo a tabela:');
        writeln (gravar, 'data - telefone/ val pulso/ num pulso(s)/ cálculo aproximado');
        writeln (gravar);
    end;

    str (dia, d);
    str (mes, m);
    write (gravar, d +'/' + m + ' - ' + tipoPul + '/ ' + tel + '/ ' + s+ '/ ');
    write (gravar, puls);
    write (gravar, '/ Val aprox: ');
    write (gravar, calcPulsos:2:2);
    writeln (gravar, '+');
    close (gravar);

    sintSom ('GRAVADO');
    writeln;
    mensagem ('LGDADGRA', 1); {'OK, dados gravados em arquivo'}
    goto terminar_programa;

    erro_modem:
    writeln;
    sintWriteln ('Erro ao acessar o MODEM');

    terminar_programa:
    sintSom ('SAIR');
    writeln;
    mensagem ('LGFIM', 1); {'Fim do programa'}
    sintFim;
    doneWinCrt;
end.
