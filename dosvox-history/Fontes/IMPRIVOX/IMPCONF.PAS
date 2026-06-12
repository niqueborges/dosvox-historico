{--------------------------------------------------------}
{
{    Programa de impressao do DOSVOX
{
{    Modulo de mensagens
{
{    Autor: Jose' Antonio Borges
{
{    Em marco/96
{
{--------------------------------------------------------}

unit impConf;
interface
uses DVcrt, DVWin, windows, sysutils,
     impvars, impmsg;

function pegaParametros: boolean;

implementation

{--------------------------------------------------------}
{       pega um parametro do arquivo de configuracao
{--------------------------------------------------------}

procedure pegaParamDefault;

    {--------------------------------------------------------}

    function pegaParamBool (param: string; default: boolean): boolean;
    var
        s: string;
        pcParam: array [0..20] of char;
    begin
        pegaParamBool := default;
        s := sintAmbiente ('IMPRIVOX', param);
        if s <> '' then
            begin
                if s[1] = 'N' then pegaParamBool := false
                else
                if s[1] = 'S' then pegaParamBool := true;
            end
        else
            begin
                strPCopy (pcParam, param);
                if default then
                    writePrivateProfileString ('IMPRIVOX', pcParam, 'SIM', 'DOSVOX.INI')
                else
                    writePrivateProfileString ('IMPRIVOX', pcParam, 'NAO', 'DOSVOX.INI');
            end;
    end;

    {--------------------------------------------------------}

    function pegaParam (param: string; default: integer): integer;
    var erro, i: integer;
        s: string;
        pcParam, pcValor: array [0..20] of char;
    begin
        pegaParam := default;
        s := sintAmbiente ('IMPRIVOX', param);
        if s <> '' then
            begin
                val (s, i, erro);
                if erro = 0 then pegaParam := i;
            end
        else
            begin
                strPCopy (pcParam, param);
                str (default, s);
                strPCopy (pcValor, s);
                writePrivateProfileString ('IMPRIVOX', pcParam, pcValor, 'DOSVOX.INI');
            end;
    end;

    {--------------------------------------------------------}

begin
    ncopias := 1;
    pagInicial := 1;
    pagFinal := 9999;
    numInicial := 1;

    tamFonte := pegaParam ('TamFonte', 12);
    tamFonteRod := pegaParam ('TamFonteRodape', 10);
    primLinha :=  pegaParam ('PrimeiraLinha', 2);
    ultLinha := pegaParam ('UltimaLinha', 56);
    primColCabec := pegaParam ('PrimeiraColuna', 9);
    ultColCabec := pegaParam ('UltimaColuna', 78);
    espacejamento := pegaParam ('Espacejamento', 1);
    autoFormata := pegaParamBool ('AutoFormata', true);
    alinhaDireita := pegaParamBool ('Alinhamento', true);
    separaSilabas := pegaParamBool ('SeparaSilabas', true);
end;

{--------------------------------------------------------}
{          altera configuração física da página
{--------------------------------------------------------}

procedure sugiro (n: integer);
begin
    mensagem ('IMSUGIRO', 0);   {' (sugiro '}
    sintWriteint (n);
    write ('): ');
end;

{--------------------------------------------------------}
{          altera configuração física da página
{--------------------------------------------------------}

procedure configFisica;
var c: char;

        procedure guardaParam (param: string; valor: integer);
        var s: string;
            sz, szparam: array [0..40] of char;
        begin
            strPCopy (szparam, param);
            str (valor, s);
            strPCopy (sz, s);
            writePrivateProfileString('IMPRIVOX', szparam, sz, 'DOSVOX.INI');
        end;

        procedure guardaParamBool (param: string; valor: boolean);
        var s: string;
            sz, szparam: array [0..40] of char;
        begin
            strPCopy (szparam, param);
            if valor then s := 'SIM'
                     else s := 'NAO';
            strPCopy (sz, s);
            writePrivateProfileString('IMPRIVOX', szparam, sz, 'DOSVOX.INI');
        end;

begin
    mensagem ('IMTAMFON', 0);        {'Tamanho da fonte a usar'}
    sugiro (12);
    sintreadInt (tamFonte);

    mensagem ('IMFONROD', 0);        {'Tamanho da fonte do rodapé'}
    sugiro (10);
    sintreadInt (tamFonteRod);

    mensagem ('IMESPAC', 0);         {'Qual o espacejamento (1, 2 ou 3)'}
    sugiro (2);
    sintreadInt (espacejamento);
    if (espacejamento < 1) or (espacejamento > 3) then
        espacejamento := 1;

    mensagem ('IMPRILIN', 0);        {'Primeira linha a imprimir'}
    if espacejamento = 1 then sugiro (3)
                         else sugiro (2);
    sintreadInt (primLinha);

    mensagem ('IMULTLIN', 0);        {'Última linha a imprimir'}
    sugiro (trunc (54 * (12/tamFonte) / ((espacejamento+1)/2)));   {56 = carta fonte 12}
    sintreadInt (ultLinha);

    mensagem ('IMPRICOL', 0);        {'Primeira coluna a imprimir'}
    sugiro (trunc (9 * (12/tamFonte)));
    sintreadInt (primColCabec);

    mensagem ('IMULTCOL', 0);        {'Última coluna a imprimir'}
    sugiro (trunc (78 * (12/tamFonte)));
    sintreadInt (ultColCabec);

    mensagem ('IMAUTFOR', 0);         {'Posso ajustar automaticamente os parágrafos ? '}
    c := sintReadKey;
    writeln (c);
    if c <> ENTER then
        autoFormata := upcase(c) <> 'N';

    mensagem ('IMSEPSIL', 0);         {'Separo sílabas no final da linha ? '}
    c := sintReadKey;
    writeln (c);
    if c <> ENTER then
        separaSilabas := upcase(c) <> 'N';

    mensagem ('IMALIDIR', 0);         {'Alinho o texto à direita ? '}
    c := sintReadKey;
    writeln (c);
    if c <> ENTER then
        alinhaDireita := upcase(c) <> 'N';

    mensagem ('IMGUARDA', 0);         {'Guardo esses valores como novos padrões ? '}
    c := sintReadKey;
    writeln (c);
    if upcase(c) = 'S' then
        begin
            guardaParam ('TamFonte', tamFonte);
            guardaParam ('TamFonteRodape', tamFonteRod);
            guardaParam ('PrimeiraLinha', primLinha);
            guardaParam ('UltimaLinha', ultLinha);
            guardaParam ('PrimeiraColuna', primColCabec);
            guardaParam ('UltimaColuna', ultColCabec);
            guardaParam ('Espacejamento', espacejamento);
            guardaParamBool ('AutoFormata', autoFormata);
            guardaParamBool ('Alinhamento', alinhaDireita);
            guardaParamBool ('SeparaSilabas', separaSilabas);
        end;
end;

{--------------------------------------------------------------}
{    substitui a impressora padrão por outra existente
{--------------------------------------------------------------}

function modifImpressoraPadrao: boolean;

var
   imp: array [1..30] of pchar;
   nImp: integer;
   returnString: array [0..2000] of char;
   paramImp, padrao: array [0..200] of char;
   i, n, l: integer;
   s :string;

begin
  modifImpressoraPadrao := false;

  GetProfileString('Devices', nil, '', returnString, 2000);

  nImp := 0;
  i := 0;
  while returnString[i] <> #0 do
      begin
          nImp := nImp + 1;
          imp[nimp] := @returnString[i];
          while returnString[i] <> #0 do
              i := i + 1;
          i := i + 1;
      end;

  if nImp = 0 then
      begin
          mensagem ('IMSEMIMP', 1);    {'Não existe impressora instalada'}
          exit;
      end;

  mensagem ('IMIMEX',1);  {  As impressoras existentes são: }

  for n := 1 to nImp do
      begin
          str (n, s);
          sintWriteln (s + ' ' + strPas (imp[n]));
      end;

  limpaBufTec;
  mensagem ('IMQUDEPA',0);   { Qual impressora você desejá tornar padrão ? }
  l := 0;
  SintReadInt (l);
  if l = 0 then
      mensagem ('IMMAIMAT',1)    { Mantida impressora atual }
  else
      begin
          if (l < 1) or (l > nImp) then l := 1;

          GetProfileString('Devices', imp[l], '', paramImp, 200);
          strcopy (padrao, imp[l]);
          strcat (padrao, ',');
          strcat (padrao, paramImp);
          writeProfileString ('windows', 'device', padrao);

          mensagem ('IMIMPAAL',1);  { impressora padrão alterada }
      end;

  modifImpressoraPadrao := true;
end;


{--------------------------------------------------------}
{            pega parametros para a impressao
{--------------------------------------------------------}

function pegaParametros: boolean;
var c: char;

        procedure guardaParam (param: string; valor: integer);
        var s: string;
            sz, szparam: array [0..40] of char;
        begin
            strPCopy (szparam, param);
            str (valor, s);
            strPCopy (sz, s);
            writePrivateProfileString('IMPRIVOX', szparam, sz, 'DOSVOX.INI');
        end;

begin
    pegaParametros := true;
    pegaParamDefault;

    textBackground (RED);
    mensagem ('IMHABITU', 0);        {'Posso usar a configuração habitual ? '}
    textBackground (BLACK); clreol;
    c := sintReadKey;
    writeln (c);

    if c = #$1b then
        begin
            pegaParametros := false;
            exit;
        end;

    if upcase(c) = 'N' then
        begin
            mensagem ('IMNCOP', 0);           {'Quantas copias ? '}
            sintReadInt (ncopias);

            mensagem ('IMPAGINI', 0);         {'Página inicial a imprimir'}
            sugiro (1);
            sintreadint (pagInicial);
            mensagem ('IMPAGFIN', 0);         {'Página final'}
            sugiro (9999);
            sintreadint (pagFinal);
            mensagem ('IMNUMINI', 0);         {'Número a imprimir na pagina inicial'}
            sugiro (1);
            sintreadint (numInicial);

            writeln;
            mensagem ('IMTRIMPA',0);         {'Deseja trocar impressora padrão do DOSVOX ?}
            c := sintReadKey;
            writeln (c);
            if upcase (c) = 'S' then
                if not modifImpressoraPadrao then
                    begin
                        pegaParametros := false;
                        exit;
                    end;

            writeln;
            mensagem ('IMMUDPAD', 0);         {'Deseja configurar padrões físicos de impressão ? }
            c := sintReadKey;
            writeln (c);
            if upcase (c) = 'S' then
                configFisica;

            writeln;
            mensagem ('IMPOSIMP', 0);         {'Posso imprimir agora ? '}
            c := sintReadKey;
            writeln(c);
            if upcase (c) = 'N' then
                pegaParametros := false;
        end;
end;

end.
