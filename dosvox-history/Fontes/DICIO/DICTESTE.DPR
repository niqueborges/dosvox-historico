{----------------------------------------------------------------}
{
{    Dicteste
{    Autor: Antonio Borges
{    Em 2/3/2002
{
{----------------------------------------------------------------}

program dicteste;
uses
  dvcrt,
  dvWin,
  dvArq,
  dvdic;

var arq, arqSai: text;
    nomeArq, nomeSai: string;
    caracErro: char;

{----------------------------------------------------------------}
{                            finaliza
{----------------------------------------------------------------}

procedure finaliza;
begin
    sintWriteln ('Programa terminado');
    sintFim;
    readln;
    doneWinCrt;
end;

{----------------------------------------------------------------}
{                            inicializa
{----------------------------------------------------------------}

procedure inicializa;
begin
    sintInic (0, '');
    sintFalaPont := false;
    sintWriteln ('Verificador gramatical - v0.9');
    writeln;

    sintWrite ('Nome do arquivo a verificar: ');
    nomeArq := obtemNomeArq (20);
    writeln (nomeArq);
    if nomearq = '' then finaliza;
    assign (arq, nomeArq);
    {$I-} reset (arq);
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo não existe');
            finaliza;
        end;

    sintWrite ('Nome do arquivo com marcações de erro: ');
    sintReadln (nomeSai);
    if nomeSai = '' then nomeSai := nomeArq + '.ERR';

    assign (arqSai, nomeSai);
    {$I-} rewrite (arqSai, nomeSai);
    if ioresult <> 0 then
        begin
            sintWriteln ('Arquivo não pode ser criado');
            close (arq);
            finaliza;
        end;

    sintWrite ('Que caractere você quer usar para marcar os erros? ');
    caracErro := sintReadkey;
    writeln (caracErro);
    if caracErro = #13 then caracErro := '#';

    while keypressed do readkey;
    sintWriteln ('Aperte enter para começar');
    readln;
end;

{----------------------------------------------------------------}
{                           processa
{----------------------------------------------------------------}

procedure processa;
var s, saida, palavra: string;
    i: integer;
    ok: boolean;
label fim, continuaPalavra;

begin
    while not eof (arq) do
        begin
            readln (arq, s);
            saida := '';
            i := 1;

            while i <= length (s) do
                begin
                    while (i <= length (s)) and not (s[i] in dicAlfabeto) do
                        begin
                            saida := saida + s[i];
                            i := i + 1;
                        end;

                    if i > length (s) then break;

                continuaPalavra:
                    while (i <= length (s)) and (s[i] in dicAlfabeto) do
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                        end;

                    if (i < length (s)-1) and (s[i] = '-') and (s[i+1] in dicAlfabeto) then
                        begin
                            palavra := palavra + s[i];
                            i := i + 1;
                            goto continuaPalavra;
                        end;

                     ok := procuraDic (palavra);
                     if ok then
                         saida := saida + palavra
                     else
                         saida := saida + caracErro + palavra;
                     palavra := '';
                end;

            writeln (saida);
            writeln (arqSai, saida);
        end;

fim:
    {$I-} close (arq); {$I+}
    if ioresult <> 0 then;
    {$I-} close (arqSai); {$I+}
    if ioresult <> 0 then;
end;

{----------------------------------------------------------------}
{                      programa principal
{----------------------------------------------------------------}

var erro: integer;
begin
    inicializa;

    erro := carregaDic ('diciona.dic', 'diciona.suf', 'diciona.exc', 'diciona.nom');
    if erro = 0 then
       processa
    else
        case erro of
            1: sintWriteln ('Arquivo de dicionário não foi achado');
            2: sintWriteln ('Arquivo de sufixos do dicionário não foi achado');
            3: sintWriteln ('Arquivo de excessões do dicionário não foi achado');
            4: sintWriteln ('Arquivo de nomes e abreviaturas do dicionário não foi achado');
        end;

    fechaDic;
    finaliza;
end.
