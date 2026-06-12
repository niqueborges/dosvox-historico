{---------------------------------------------------------------}
{                                                               }
{   Jogo do Barão                                               }
{                                                               }
{   Autor: Antonio Borges                                       }
{                                                               }
{   Em outubro/2005                                             }
{                                                               }
{   Inspirado no jogo BARON,                                    }
{       original escrito na linguagem FOCAL para DEC-PDP-8      }
{       autor desconhecido                                      }
{       modificado por Tom Kloss em 1971                        }
{                                                               }
{---------------------------------------------------------------}

program baronvox;
uses
  dvcrt,
  dvwin,
  videovox,
  sysUtils;

var
    chegados, mortos, populacao,
    alqueires, valorDoAlqueire, colheitaPorAlqueire,
    estocados, colheita, ratosComeram,
    alqueiresVendidos, alqueiresComprados, alimento, alqueiresSemeados: integer;
    idade: integer;
    ocorreuPraga: boolean;
    arqlog: textFile;

{---------------------------------------------------------------}

procedure ajuda;
var c: char;
begin
    repeat
        clrscr;
        textBackground (BLUE);
        sintWriteln ('DESAFIO DO BARÃO');
        textBackground (BLACK);
        Writeln;

        textColor (YELLOW);
        Writeln;
        sintWriteln ('Este programa permite que você seja o barão de uma pequena cidade');
        sintWriteln ('onde todas as pessoas são dependentes de você.');
        sintWriteln ('A forma de gerenciar sua terra, o destino das pessoas e o seu próprio');
        sintWriteln ('vão ser definidos pelas respostas que der.');
        Writeln;
        sintWriteln ('Cada pessoa pode plantar apenas 10 alqueires.');
        sintWriteln ('Um almude de sementes é suficiente para semear 2 alqueires.');
        sintWriteln ('Para não morrer, cada pessoa precisa de 20 almudes de sementes.');
        sintWriteln ('Você deve reservar pelo menos um almude para alimentação.');
        sintWriteln ('Seu objetivo é se tornar ministro ao conseguir uma população de 250 pessoas.');
        Writeln;
        sintWriteln ('Sempre que precisar aperte Interrogação para dicas ou Enter para status.');
        Writeln;
        textColor (WHITE);
        sintWriteln ('Aperte Enter.');
        while keypressed do readkey;
        c := readkey;
        if (c = #$0) and (readkey = CTLF9) then
            leitorDeTela;
    until c = #$0d;
    sintClek;

    while sintFalando do;
    delay (1000);
end;

{---------------------------------------------------------------}

procedure dicas (detalhe: boolean);
begin
    textColor (GREEN);
    if detalhe then
        begin
            sintWriteln ('Cada pessoa planta 10 alqueires.');
            sintWriteln ('Um almude semeia 2 alqueires.');
            sintWriteln ('Cada pessoa come 20 almudes.');
        end;

    sintWriteln ('Agora: ' +
                 intToStr (populacao) + ' de população, ' +
                 intToStr (alqueires) + ' alqueires, ' +
                 intToStr (estocados) + ' almudes.');
    textColor (WHITE);
end;

{---------------------------------------------------------------}

function pergunta (s: string): integer;
var resp: string;
    valor, erro: integer;
begin
    valor := 0;
    repeat
        sintWrite (s);
        sintReadln (resp);
        resp := trim (resp);
        erro := 1;

        if resp = '' then
            dicas (false)
        else
        if resp = '?' then
            dicas (true)
        else
            val (resp, valor, erro);

        if erro <> 0 then sintBip;
    until erro = 0;

    pergunta := valor;
end;

{---------------------------------------------------------------}

procedure inicializa;
var c: char;
begin
    sintInic (0, '');
    if paramCount <> 0 then
        if (paramStr(1) = 'R') or (paramStr(1) = 'r') then randomize;

    textBackground (BLUE);
    sintWriteln ('DESAFIO DO BARÃO');
    textBackground (BLACK);
    Writeln;
    sintWrite ('Você precisa de instruções? ');
    c := sintReadkey;
    writeln (c);
    if upcase (c) = 'S' then
        ajuda;

    populacao := 95;
    chegados := 5;
    mortos := 0;

    estocados := 2800;
    alqueires := 1000;

    colheita := 3000;
    ratosComeram := 200;
    colheitaPorAlqueire := 3;

    ocorreuPraga := false;

    populacao := populacao + chegados - mortos;
    idade := 21;

    assign (arqlog, 'baronvox.log');
    {$I-} erase (arqlog); {$I+}
    if ioresult <> 0 then;
end;

{---------------------------------------------------------------}

procedure registraRelatorio;
begin
    {$I-} append (arqlog); {$I+}
    if ioresult <> 0 then
        begin
            {$I-}  rewrite (arqlog);  {$I+}
            if ioresult <> 0 then exit;
        end;

    writeln (arqlog, 'Idade:                 ', idade);
    writeln (arqlog, 'Valor do alqueire:     ', valorDoAlqueire);
    writeln (arqlog, 'Alqueires vendidos:    ', alqueiresVendidos);
    writeln (arqlog, 'Alqueires comprados:   ', alqueiresComprados);
    writeln (arqlog, 'Alqueires semeados:    ', alqueiresSemeados);
    writeln (arqlog, 'Colheita:              ', colheita);
    writeln (arqlog, 'Colheita por alqueire: ', colheitaPorAlqueire);
    writeln (arqlog, 'Ratos comeram:         ', ratosComeram);
    writeln (arqlog, 'Alimento fornecido:    ', alimento);
    writeln (arqlog, 'Ocorreu praga:         ', ocorreuPraga);
    writeln (arqlog, 'Chegados:              ', chegados);
    writeln (arqlog, 'Mortos:                ', mortos);
    writeln (arqlog, 'População:             ', populacao);
    writeln (arqlog, 'Alqueires:             ', alqueires);
    writeln (arqlog, 'Estocados:             ', estocados);
    writeln (arqlog, '-----------------------------------');

    close (arqlog);
end;

{---------------------------------------------------------------}

procedure relatorio;
begin
    registraRelatorio;

    clrscr;
    textBackground (BLUE);
    Writeln ('DESAFIO DO BARÃO');
    textBackground (BLACK);
    Writeln;
    textColor (YELLOW);
    sintWriteln ('Senhor Barão:');
    sintWriteln ('Vossa mercê está agora com ' + intToStr(idade) + ' anos.');
    sintWrite ('No último ano ');

    if mortos = 0 then
        sintWrite ('ninguém morreu de fome, ')
    else
        sintWrite (intToStr(mortos) + ' morreram de fome, ');
    sintWriteln (intToStr(chegados) + ' chegaram.');
    sintWriteln ('A população é de ' + intToStr(populacao) + '.');

    if (populacao > 250) then exit;  { vitória }

    if ocorreuPraga then sintWriteln ('Infelizmente, a peste negra dizimou metade de nosso povo.');

    if (colheita >= 1) then
        sintWriteln ('A colheita foi de ' + intToStr(colheitaPorAlqueire) + ' almudes por alqueire.');

    sintWriteln ('Os ratos comeram ' + intToStr(ratosComeram) + ' almudes.');
    sintWriteln ('Há ' + intToStr(estocados) + ' almudes no estoque.');

    sintWriteln ('A cidade tem agora ' + intToStr(alqueires) + ' alqueires.');
    textColor (WHITE);
end;

{---------------------------------------------------------------}

procedure compraEVendeTerras;
begin
    Writeln;
    sintWriteln ('Senhor Barão:');
    valorDoAlqueire := 9 + random(17);
    sintWriteln ('A terra está sendo comercializada a ' + intToStr(valorDoAlqueire) + ' almudes por alqueire.');

    repeat
        alqueiresComprados := pergunta ('Quantos alqueires vossa mercê quer comprar? ');
        if alqueiresComprados = 0 then break;

        if alqueiresComprados < 0 then
            sintWriteln ('Por favor, Senhor Barão! Não estou aqui para escutar blefes.')
        else
            if (valorDoAlqueire*alqueiresComprados) > estocados then
                begin
                    sintWriteln ('Vossa mercê pode comprar no máximo ' +  intToStr(estocados div valorDoAlqueire) + ' alqueires.');
                    alqueiresComprados := -1;
                end
    until alqueiresComprados > 0;

    alqueiresVendidos := 0;

    if alqueiresComprados = 0 then
    repeat
        alqueiresVendidos := pergunta ('Quantos alqueires vossa mercê quer vender? ');
        if alqueiresVendidos = 0 then break;

        if alqueiresVendidos < 0 then
            sintWriteln ('Por favor, Senhor Barão! Não estou aqui para ouvir blefes.')
        else
        if alqueiresVendidos > alqueires then
            begin
                sintWriteln ('Senhor Barão, mas vossa mercê tem apenas ' + intToStr(alqueires) +  ' alqueires.');
                alqueiresVendidos := 0;
            end;

    until alqueiresVendidos > 0;

    alqueires := alqueires + alqueiresComprados - alqueiresVendidos;
    estocados := estocados - (alqueiresComprados - alqueiresVendidos) *  valorDoAlqueire;
end;

{---------------------------------------------------------------}

function alimentaPovo: boolean;
begin
    repeat
        alimento  := pergunta ('Quantos almudes reservo para alimentar o povo: ');
        if alimento < 0 then
            sintWriteln ('Por favor, Senhor Barão! Não estou aqui para ouvir blefes.')
        else
        if alimento = 0 then
             begin
                alimentaPovo := false;
                exit;
             end;

        if alimento > estocados then
            begin
                sintWriteln ('Senhor Barão, mas vossa mercê tem apenas ' + intToStr(estocados) + ' almudes estocadas.');
                alimento := -1;
            end;

    until alimento > 0;

    estocados := estocados - alimento;
    alimentaPovo := true;
end;

{---------------------------------------------------------------}

procedure semeia;
var ok: boolean;
begin
    if estocados <= 1 then
         begin
             alqueiresSemeados := 0;
             sintWrite ('Senhor Barão, vossa mercê não tem mais grãos para semear!!!');
             exit;
         end;

    repeat
        ok := false;
        alqueiresSemeados := pergunta ('Quantos alqueires vossa mercê deseja semear? ');
        if alqueiresSemeados < 0 then
            sintWriteln ('Por favor, Senhor Barão! Não estou aqui para ouvir blefes.')
        else
        if alqueiresSemeados > alqueires then
            sintWriteln ('Senhor Barão, mas vossa mercê tem apenas ' + intToStr(alqueires) + ' alqueires.')
        else
        if alqueiresSemeados > (10 * populacao)  then
            sintWriteln ('Senhor Barão, mas vossa mercê tem apenas ' + intToStr(populacao) + ' pessoas.')
        else
        if alqueiresSemeados > (estocados-1)*2 then
            begin
                sintWriteln ('Senhor Barão, mas vossa mercê tem apenas ' + intToStr(estocados) + ' almudes estocadas.');
                sintWriteln ('Vossa mercê pode semear apenas ' + intToStr((estocados-1) * 2) + ' alqueires.');
            end
        else
            ok := true;

    until ok;

    estocados := estocados - alqueiresSemeados div 2;
end;

{---------------------------------------------------------------}

procedure natureza;
var
    R: integer;
    pessoasAlimentadas: integer;
begin
    idade := idade + 1;

    R := random(5) + 1;
    colheitaPorAlqueire := R;    { entre 1 e 5 almudes por alqueire }
    colheita := alqueiresSemeados * colheitaPorAlqueire;

    R := random(5) + 1;
    if R < 4 then
        ratosComeram := 0
    else
        ratosComeram := trunc(estocados / R);   { max 25% }

    estocados := estocados + colheita - ratosComeram;

    R := random(5) + 1;
    chegados := trunc (R * (20*alqueires+estocados) div populacao div 100 + 1);
    populacao := populacao + chegados;

    ocorreuPraga := random(10) < 1;            { 10% }
    if ocorreuPraga then
        populacao := populacao div 2;

    pessoasAlimentadas := alimento div 20;
    if populacao <= pessoasAlimentadas then
        mortos := 0
    else
        begin
           mortos := populacao - pessoasAlimentadas;
           populacao := pessoasAlimentadas;
        end;
end;

{---------------------------------------------------------------}

procedure finaliza;
begin
    while sintFalando do;
    delay (1000);
    sintWriteln ('Fim do Jogo');
    readln;
    doneWinCrt;
end;

{---------------------------------------------------------------}

var
    objetivoAlcancado: boolean;

begin
    inicializa;

    objetivoAlcancado := false;
    repeat
        relatorio;
        if idade > 90 then
            begin
                Writeln ('---------------------------------');
                sintWriteln ('Senhor Barão: a Mãe Natureza é inflexível e soberana.');
                sintWriteln ('Neste seu funeral aceite nossas humildes homenagens.');
                break;
            end;

        if populacao > 250 then
            objetivoAlcancado := true
        else
            begin
                if populacao = 0 then
                    begin
                        Writeln ('---------------------------------');
                        sintWriteln ('Todo seu povo morreu.');
                        sintWriteln ('Sem ninguém para servi-lo, vossa mercê definha até a morte.');
                        break;
                    end;
                    
                compraEVendeTerras;
                if not alimentaPovo then
                    begin
                        Writeln ('---------------------------------');
                        sintWriteln ('Revolução! O povo faminto invade seu castelo.');
                        sintWriteln ('A morte será o seu destino!');
                        break;
                    end
                else
                    begin
                        semeia;
                        natureza;
                    end;
            end;
    until objetivoAlcancado;   { ou break }

    if objetivoAlcancado then
        begin
            Writeln ('---------------------------------');
            sintWriteln ('Senhor Barão, nossas efusivas congratulações.');
            sintWriteln ('Vossa mercê foi promovido a primeiro ministro do controle da natalidade!');
        end;

    finaliza;
end.

