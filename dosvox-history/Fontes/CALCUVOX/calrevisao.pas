{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 3.0
{
{    Módulo de revisão 
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calrevisao;

interface
uses dvcrt, dvwin, caltecla, calvars, calfala, calmsg;

procedure revisaFita;
procedure revisaContaEMemorias;

implementation

{--------------------------------------------------------}

procedure revisaFita;
var c: char;

begin
    leTeclado (c);
    case c of
        CIMA:  if nrfita <= 1 then
                   sintBip
               else
                   begin
                       nrfita := nrfita - 1;
                       if (opFita[nrfita] <> ' ') and (opFita[nrfita] <> '(') then
                           falaNumeroReal (valorFita [nrfita]);

                       if opFita [nrfita] = '#' then
                           sintSom ('CA_RESULT')        { 'Resultado' }
                       else
                           sintSoletra (opFita [nrfita]);
                   end;

        BAIX:  if nrfita >= posFita then
                   sintBip
               else
                   begin
                       nrfita := nrfita + 1;
                       if (opFita[nrfita] <> ' ') and (opFita[nrfita] <> '(') then
                           falaNumeroReal (valorFita [nrfita]);

                       if opFita [nrfita] = '#' then
                           sintSom ('CA_RESULT')        { 'Resultado' }
                       else
                           sintSoletra (opFita [nrfita]);
                   end;

        PGUP:  begin
                   while (nrfita > 0) and
                            ((opFita[nrfita] = ' ') or (opFita[nrfita] = ' ')) do
                       begin
                           nrfita := nrfita - 1;
                           sintClek;
                       end;

                   while (nrfita > 0) and (opFita[nrfita] <> ' ') and (opFita[nrfita] <> '(') do
                       begin
                           nrfita := nrfita - 1;
                           sintClek;
                       end;

                   if nrfita <= 0 then
                       begin
                           sintBip;
                           nrfita := 0;
                       end;
               end;

        PGDN:  begin
                   if (opFita[nrfita] <> ' ') and (opFita[nrfita] <> '(') then
                       while (nrfita <= posFita) and
                             (opFita[nrfita] <> ' ') and (opFita[nrfita] <> '(') do
                           begin
                               nrfita := nrfita + 1;
                               sintClek;
                           end;

                   while (nrfita <= posFita) and
                         ((opFita[nrfita] = ' ') or (opFita[nrfita] = ' ')) do
                       begin
                           nrfita := nrfita + 1;
                           sintClek;
                       end;

                   if nrfita > posFita then
                       begin
                           sintBip;
                           nrfita := posFita + 1;
                       end;
               end;

        HOME:  begin
                   nrfita := 0;
                   sintClek;
               end;

        TEND:  begin
                   nrfita := posFita+1;
                   sintClek;
               end;
    end;
end;

{--------------------------------------------------------}

procedure revisaContaEMemorias;
var c: char;

begin
    gotoxy (45, 23);
    mensagem ('CA_LREVE', 1);  { 'Use as setas ou a letra da memória' }
    gotoxy (45, 24);
    mensagem ('CA_ESCT', 1);  { 'ESC termina' }

    nrFita := posFita;

    repeat
        leTeclado (c);
        c := upcase(c);
        case c of
            '0'..'9':  begin
                           sintSom ('CA_MEMO');     { 'Memória...'}
                           sintCarac (c);
                           falaNumeroReal (memoria [ord(c) - ord ('0')]);
                       end;
            'A'..'Z':  begin
                           sintSom ('CA_MEMO');     { 'Memória...'}
                           sintCarac (c);
                           falaNumeroReal (memoria [ord(c) - ord ('A') + 10]);
                       end;

            #0: revisaFita;
        end;

    until c = #$1b;

    gotoxy (45, 23);
    write ('                            ');
    gotoxy (45, 24);
    write ('                            ');

    sintSom ('CA_FIMREV');      { 'Revisão terminada' }
end;

end.
