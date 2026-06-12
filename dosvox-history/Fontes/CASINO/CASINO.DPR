{----------------------------------------------------------------}
{
{    Jogo do Alto e Baixo
{    Autor: Antonio Borges
{    Baseado num original de autor desconhecido, em linguagem C++
{    Em 2/3/2002
{
{    Revisado por Wendrill Aksenow Brandão, com a colaboração do Chat GPT
{    Em 04/01/2025
{
{----------------------------------------------------------------}

program casino;
uses dvcrt, dvWin, sysUtils;
var
    initialMoney, oldInitial: longint;
    money: longint;
    oldMoney: longint;
    bet: longint; { Introduzido para limitar apostas }
    asd, dsa: integer;
    turns, oldTurns: integer;
    highLow: char;
    know: char;
    name, oldName: string;
    s: string;
    scorefile: text;
    error: integer;

const
    MAXMONEY = 1000000;
    cardName: array [1..13] of string[10] =
    ('Ás', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Valete', 'Dama', 'Rei');

label reiniciarJogo;

begin
    sintInic (0, '');
    sintFalaPont := false;

    textBackground (BLUE);
    sintWriteln ('Benvindo ao Cassino da Fortuna!');
    textBackground (BLACK);
    writeln;
    randomize;
    sintWriteln ('Olá, com quem tenho o prazer de jogar?');
    sintReadln (name);

reiniciarJogo:

    sintWriteln ('Com quanto dinheiro você começa? (no máximo 30000)');
    sintReadln (s);
    if trim(s) = '' then s := '30000';
    val (s, money, error);
    if error <> 0 then money := 0;

    if (money > 30000) or (money < 1) then
    begin
        money := 30000;
        sintWriteln ('Eu só aceito entre 1 e 30000, são as regras da casa!');
    end;

    initialMoney := money;

    writeln;
    sintWriteln ('OK, vou levá-lo à mesa do jogo de Alto ou Baixo.');
    delay (2000);
    writeln;
    sintWrite ('Você conhece as regras de Alto ou Baixo? ');
    know := readkey;
    sintWriteln (know);
    if upcase (know) <> 'N' then
        sintWriteln ('Muito bem, começaremos o jogo.')
    else
        begin
            sintWriteln ('Certo, eu ensino...');
            writeln;
            textColor (YELLOW);
            sintWriteln ('Você tira uma carta, faz sua aposta, e tenta adivinhar a próxima.');
            sintWriteln ('Você responderá Alto (tecle apenas A) se achar que a próxima carta é maior,');
            sintWriteln ('ou então Baixo (tecle apenas B) se achar que a próxima é menor.');
            sintWriteln ('O valor das cartas com um número é o próprio número.');
            sintWriteln ('Ás vale 1, valete vale 11, dama vale 12 e rei vale 13.');
            sintWriteln ('Se estiver certo ganha, caso contrário perde!');
            sintWriteln ('O objetivo do jogo é atingir um milhão de reais no menor número de jogadas.');
            { Informação sobre as novas regras }
            sintWriteln ('Nota: Quando estiver perto de alcançar 1 milhão de reais,');
            sintWriteln (' o valor máximo da sua aposta será ajustado automaticamente para evitar que você ultrapasse este limite.');
            textColor (LIGHTGRAY);
        end;

    turns := 0;
    while (money < MAXMONEY) and (money > 0) do
    begin
        while keypressed do readkey;
        delay (1000);
        writeln;
        turns := turns + 1;

        textBackground (RED);
        sintWrite ('Rodada ');
        sintWriteInt (turns);
        writeln;
        textBackground (BLACK);
        writeln;

        asd := random(13) + 1;
        dsa := random(13) + 1;
        repeat
            sintWrite ('Você tirou ');
            sintWriteln (cardName[asd]);
            sintWrite ('A próxima carta vai ser mais alta ou baixa? ');
            highLow := upcase (readkey);
            sintWriteln (highLow);
        until (highLow = 'A') or (highLow = 'B');

        repeat
            { Calcula o limite dinâmico da aposta }
            if money + money > MAXMONEY then
                bet := MAXMONEY - money
            else
                bet := money;

            sintWrite ('Quanto dinheiro você aposta? No máximo ');
            sintWriteInt (bet); { Limite atualizado dinâmicamente }
            writeln;
            sintReadln (s);
            if trim (s) = '' then s := intToStr(bet);
            val (s, bet, error);
        until (error = 0) and (bet <= money) and (bet > 0) and (money + bet <= MAXMONEY);

        if ((highLow = 'A') and (asd < dsa)) or
           ((highLow = 'B') and (asd > dsa)) then
        begin
            sintWriteln ('Você ganhou. A outra carta era ' + cardName[dsa]);
            money := money + bet;
        end
        else
        begin
            sintWriteln ('Você perdeu. A outra carta era ' + cardName[dsa]);
            money := money - bet;
        end;

        sintWrite ('Você tem agora ');
        sintWriteInt (money);
        sintWriteln (' reais.');
    end;

    { Lógica de verificação de recorde corrigida }
    if money >= MAXMONEY then
    begin
        assign (scorefile, 'recasino.txt');
        {$I-} reset (scoreFile);  {$I+}
        if ioresult = 0 then
        begin
            readln (scoreFile, oldInitial, oldMoney, oldTurns, oldName);
            close (scoreFile);
        end
        else
        begin
            oldInitial := 30000;
            oldMoney := 1000000; { Corrigido para o valor máximo possível }
            oldTurns := 18; { Corrigido para refletir um número plausível de rodadas }
            oldName := 'Pingüim';
        end;

        writeln;
        sintWrite ('O recorde anterior era de ');
        sintWrite (oldName);
        sintWrite (' que começou com ');
        sintWriteInt (oldInitial);
        sintWrite (' e conseguiu chegar a ');
        sintWriteInt (oldMoney);
        sintWrite (' reais em ');
        sintWriteInt (oldTurns);
        sintWrite (' jogadas.');
        writeln;

        if (money > oldMoney) or
           ((money = oldMoney) and (turns < oldTurns)) then
        begin
            rewrite (scoreFile);
            writeln (scoreFile, initialMoney, ' ', money, ' ', turns, ' ', name);
            close (scoreFile);

            writeln;
            textColor (YELLOW);
            sintWrite ('Novo recorde! ');
            sintWrite (name); { Corrigido para mostrar o nome do jogador em vez do valor acumulado } 
            textColor (LIGHTGRAY);
            writeln;
        end;

        sintWrite ('Você conseguiu atingir o total de ');
        sintWriteInt (money);
        sintWrite (' reais em ');
        sintWriteInt (turns);
        sintWriteln (' jogadas.');
    end
    else
    begin
        writeln;
        sintWriteln ('Você perdeu o jogo.');
    end;

    sintWrite ('Aperte Enter para jogar novamente ou ESC para terminar');
//    readln;
    know := readkey;
    if know <> ESC then goto reiniciarJogo;

    doneWinCrt;
end.
