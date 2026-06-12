{--------------------------------------------------------}
{
{    Calculadora Vocal - versao 3.0
{
{    Módulo de manipulação da fita
{
{    Autor: Jose' Antonio Borges
{           Mara Lucia Caldeira
{           Julio Tadeu Carvalho da Silveira
{
{    Versão 4.0 em maio/2019
{
{--------------------------------------------------------}

unit calfita;

interface
uses
    calvars, caltecla, calfala, caltela,
    dvcrt, dvwin;

procedure mostraValorFita (valor: Numerico; oper: string);

procedure limpaFita;
procedure insFita (op: string; valor: Numerico);
procedure leFita;

implementation

{--------------------------------------------------------}

procedure mostraValorFita (valor: Numerico; oper: string);
begin
    mostraValor (xVisor, yFimFita, numVisor, tamVisor, nDecimais);
    write (' ', oper);
end;

{--------------------------------------------------------}

procedure limpaFita;
begin
    posFita := 0;
end;

{--------------------------------------------------------}

procedure insFita (op: string; valor: Numerico);
begin
    posFita := posFita + 1;
    valorFita [posFita] := valor;
    opFita [posFita] := op;
end;

{--------------------------------------------------------}

procedure leFita;
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
                           sintSom ('CA_RESULT')    { 'Resultado' }
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
                           sintSom ('CA_RESULT')    { 'Resultado' }
                       else
                           sintSoletra (opFita [nrfita]);
                   end;

        PGUP:  begin
                   while (nrfita > 0) and (opFita[nrfita] <> ' ')
                                      and (opFita[nrfita] <> '(') do
                       begin
                           nrfita := nrfita - 1;
                           sintClek;
                       end;

                   while (nrfita > 0) and (opFita[nrfita] <> ' ')
                                      and (opFita[nrfita] <> '(') do
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
                         ((opFita[nrfita] = ' ') or (opFita[nrfita] = '(')) do
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

end.
