{--------------------------------------------------------}
{
{    NIMVOX - Jogo dos Palitinhos
{
{    Autores: Fabio David e Andrea Rodrigues
{
{    Em junho de 1994
{
{    Revisto por Patrick Barboza
{
{    Em agosto/2021
{
{--------------------------------------------------------}

program NIMVOX;
uses
    dvCrt, dvWin, dvForm, nimMsg, nimVars;

procedure finaliza; forward;

{--------------------------------------------------------}

procedure le (var r: char);
begin
   r := readkey;
   writeln (r);
   sintCarac (r);
   r := upcase (r);

   if r = #$1b then finaliza;
end;

{--------------------------------------------------------}

procedure instrucoes;
begin
    msg ('nim_nstr');
end;

{--------------------------------------------------------}

function sim_ou_nao (m : string) : char;
var c : char;
begin
   repeat
       msg (m);
       c := popupMenuPorLetra('SN');
       if not (c in [#$1b, 'S','N']) then msg ('nim_inv');
   until (c in ['S','N', #$1b]);
   sim_ou_nao := c;
end;

{--------------------------------------------------------}

procedure finaliza;
begin
    msg ('nim_bye');
    delay (1000);
    sintFim;
    doneWinCrt;
end;

{--------------------------------------------------------}

procedure inicializa;
var
    dir: string;
begin
    dir := sintAmbiente ('NIMVOX', 'DIRNIMVOX');
    if dir = '' then
        dir := 'c:\winvox\som\nimvox';
    sintinic (0, dir);

    randomize;
    partidas := 0;
    vitorias := 0;
    derrotas := 0;

    sintSom ('chaaaaan');
    clrscr;
    msg ('nim_aprs');
    case upcase (sim_ou_nao ('nim_inst')) of
       'S': instrucoes;
      #$1b: finaliza;
    end;

    while keypressed do readkey;
end;

{--------------------------------------------------------}

procedure reordena;
var i, j, x, temp: byte;
begin
    for i:=1 to totlinhas do
        ordem[i] := 0;

    for i:=1 to totlinhas do
       begin
       repeat
          x := random(totlinhas) + 1;
       until ordem[x] = 0;
       ordem [x] := i;
       end;

    for i:=1 to totlinhas-1 do
      for j := i to totlinhas do
       if linha [i] < linha [j] then
           begin
               temp := linha [i];
               linha [i] := linha [j];
               linha [j] := temp;
           end;
end;

{--------------------------------------------------------}

procedure mostra_situacao;
var
    i: integer;
begin
   writeln;
   msg ('nim_situ');
   for i := 1 to totlinhas do
      begin
          msg ('nim_lin'+chr(i+$30));
          msg ('nim_qtd'+chr(linha[i]+$30));
          if keypressed then
              begin
                  readkey;
                  exit;
              end;
      end;
end;

{--------------------------------------------------------}

procedure jogo_novo;
var c: char;
    maxporlin, aux : integer;
    i: integer;
begin
    inc (partidas);
    pauzinhos := 0;
    repeat
        msg ('nim_mlin');
        c := popupMenuPorLetra('3456789');
        totlinhas := ord (c) - ord ('0');
    until totlinhas in [3..9];

    repeat
        msg ('nim_qpln');
        c := popupMenuPorLetra('3456789');
        maxporlin := ord (c) - ord ('0');
        writeln;
    until maxporlin in [3..9];

    for i := 1 to totlinhas do
       begin
       aux := random(maxporlin)+ 1;
       linha [i] := aux;
       inc (pauzinhos, aux);
       end;

    reordena;
    mostra_situacao;

    vez := 0;
    while (vez = 0) do
       if sim_ou_nao ('nim_quem') = 'S' then
           vez := byte (not (COMPUTADOR))
       else
           vez := COMPUTADOR;
    sintSom ('plin');
end;

{--------------------------------------------------------}

procedure ta_mal;
var i: integer;
begin
    reordena;
    for i:=1 to totlinhas do
        if linha[ordem[i]] > 0 then
            begin
            lin := ordem[i];
            quantos := random(linha[lin]) + 1;
            end;
    msg ('nim_mal');
end;

{--------------------------------------------------------}

procedure minha_vez;
var
    linhas_com_um, linhas_com_mais_de_um, mask, n, l : byte;
    achei_jogada : boolean;
    i: integer;
begin
    linhas_com_um := 0;
    linhas_com_mais_de_um := 0;
    mask := 0;
    l := 1;
    for i:=1 to totlinhas do
        begin
        mask := mask XOR linha[i];
        if linha[i] = 1 then
            inc (linhas_com_um)
        else
        if linha[i] > 1 then
            begin
            inc (linhas_com_mais_de_um);
            l := i;
            end;
        end;

    if (linhas_com_mais_de_um = 1) then
        begin
        lin := l;
        quantos := linha[lin] - ((linhas_com_um AND 1) XOR 1);
        end
    else
        if (mask = 0)  then
            ta_mal
        else
            begin
            achei_jogada := false;
            i := 0;
            while not (achei_jogada) do
                begin
                inc (i);
                n := linha[ordem[i]];
                l := ((n and not mask) or (not n and mask));
                achei_jogada := l <= n;
                end;
            lin := ordem[i];
            quantos := linha[lin] - l;
            end;
end;

{--------------------------------------------------------}

procedure jogada_humana;
var jogada_valida : boolean;
begin
    jogada_valida := false;
    while not jogada_valida do
        begin

        repeat
            sintSom ('tingting');
            msg ('nim_qlin');
            le (st);
            if st = #$1b then
                finaliza;

            if not (st in ['1'..'9']) then
                 mostra_situacao;
        until st in ['1'..'9'];

        lin := ord (st) - $30;
        if (lin < 1) or (lin > totlinhas) then
           msg ('nim_linv')
        else
        if (linha[lin] = 0) then
           msg ('nim_lvaz')
        else
           begin
           msg ('nim_qqtd');
           le (st);
           quantos := ord (st) - $30;
           if (quantos < 1) then
               msg ('nim_qpeq')
           else
           if (quantos > linha[lin]) then
               begin
               msg ('nim_qbig');
               msg ('nim_qtd'+chr(linha[lin]+$30));
               end
           else
               jogada_valida := true;
           end;
        end;
end;

{--------------------------------------------------------}

procedure vitoria;
begin
    inc (vitorias);
    sintSom ('tingting');
    msg ('nim_vici');
end;

{--------------------------------------------------------}

procedure derrota;
begin
    inc (derrotas);
    msg ('nim_apla');
    msg ('nim_mifu');
    sintSom ('chaaaaan');
end;

{--------------------------------------------------------}

begin
    inicializa;
    repeat
        begin
        jogo_novo;
        writeln;

        while (pauzinhos > 1) do
           begin
           delay (500);
           if (vez = COMPUTADOR) then
               begin
               minha_vez;
               textBackground (BLUE);
               msg ('nim_mvez');
               end
           else
               begin
               jogada_humana;
               textBackground (BLUE);
               msg ('nim_svez');
               end;

           msg ('nim_lin'+chr(lin+$30));
           textBackground (BLACK);
           msg ('nim_retr');
           msg ('nim_qtd'+chr(quantos+$30));

           dec (linha[lin], quantos);
           dec (pauzinhos, quantos);
           vez := not(vez);
           end;

       if (vez = COMPUTADOR) then
           derrota
       else
           vitoria;
       end
   until (sim_ou_nao ('nim_dnov') = 'N');

   finaliza;
end.
