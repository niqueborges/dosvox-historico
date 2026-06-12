{--------------------------------------------------------}
{
{    NIMVOX - Jogo dos Palitinhos
{
{    Módulo de mensagens
{
{    Por Patrick Barboza
{
{    Em agosto/2021
{
{--------------------------------------------------------}

unit nimMsg;

interface

uses dvCrt, dvWin;

procedure msg (m : string);

implementation

procedure msg (m : string);
begin
    if m = 'nim_quem' then      write ('Deseja começar? (s/n): ')
    else
    if m = 'nim_mal' then       writeln ('Está ficando difícil...')
    else
    if m = 'nim_inv' then       writeln ('Resposta inválida')
    else
    if m = 'nim_vici' then      writeln ('Uau! Venci novamente...')
    else
    if m = 'nim_apla' then      begin end
    else
    if m = 'nim_mifu' then      writeln ('Não é possível! Eu perdi!??!')
    else
    if m = 'nim_situ' then      writeln ('Situação atual:')
    else
    if m = 'nim_lin1' then      write ('1: ')          { linha 1 }
    else
    if m = 'nim_lin2' then      write ('2: ')          { linha 2 }
    else
    if m = 'nim_lin3' then      write ('3: ')          { linha 3 }
    else
    if m = 'nim_lin4' then      write ('4: ')          { linha 4 }
    else
    if m = 'nim_lin5' then      write ('5: ')          { linha 5 }
    else
    if m = 'nim_lin6' then      write ('6: ')          { linha 6 }
    else
    if m = 'nim_lin7' then      write ('7: ')          { linha 7 }
    else
    if m = 'nim_lin8' then      write ('8: ')          { linha 8 }
    else
    if m = 'nim_lin9' then      write ('9: ')          { linha 9 }
    else
    if m = 'nim_qtd0' then      writeln ('')           { nada }
    else
    if m = 'nim_qtd1' then      writeln ('I')          { 1 }
    else
    if m = 'nim_qtd2' then      writeln ('I I')        { 2 }
    else
    if m = 'nim_qtd3' then      writeln ('I I I')      { 3 }
    else
    if m = 'nim_qtd4' then      writeln ('I I I I')    { 4 }
    else
    if m = 'nim_qtd5' then      writeln ('I I I I I')   { 5 }
    else
    if m = 'nim_qtd6' then      writeln ('I I I I I I')   { 6 }
    else
    if m = 'nim_qtd7' then      writeln ('I I I I I I I')   { 7 }
    else
    if m = 'nim_qtd8' then      writeln ('I I I I I I I I')   { 8 }
    else
    if m = 'nim_qtd9' then      writeln ('I I I I I I I I I')   { 9 }
    else
    if m = 'nim_dnov' then      write ('Deseja jogar de novo? (s/n): ')
    else
    if m = 'nim_aprs' then
        begin
            textBackground (BLUE);
            write ('NIMVOX II - O jogo dos palitinhos');
            textBackground (BLACK);
            writeln;
            writeln;
        end
    else
    if m = 'nim_mlin' then      write ('Quantas linhas (de 3 a 9): ')
    else
    if m = 'nim_qpln' then      write ('Quantos por linha (de 3 a 9): ')
    else
    if m = 'nim_mvez' then      write ('Minha jogada -> linha ')
    else
    if m = 'nim_qlin' then      write ('Qual a linha? ')
    else
    if m = 'nim_qqtd' then      write ('Quantos? ')
    else
    if m = 'nim_linv' then      writeln ('Linha inválida ou inexistente. Tente novamente !')
    else
    if m = 'nim_lvaz' then      writeln ('Esta linha está vazia!')
    else
    if m = 'nim_qbig' then      write ('Esta linha tem somente ')
    else
    if m = 'nim_qpeq' then      write ('Puxa vida, blefar não vale !')
    else
    if m = 'nim_svez' then      write ('Sua jogada -> linha ')
    else
    if m = 'nim_retr' then      write (' retirando ')
    else
    if m = 'nim_inst' then      write ('Deseja instruções (s/n) ? ')
    else
    if m = 'nim_bye' then       writeln ('Bye bye !')
    else
    if m = 'nim_nstr' then
        begin
        writeln;
        writeln ('Eu apresento para você várias linhas contendo palitinhos.');
        writeln ('Eu e você podemos tirar de uma linha quantos palitinhos quisermos.');
        writeln ('Quem tirar o último palitinho perde...');
        writeln;
        end
    else
        writeln (chr(7)+chr(7)+chr(7)+'Erro: '+m);

    sintSom (m);
end;

end.
