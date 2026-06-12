{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de tratamento de instruções                  }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crimport;

interface
uses sysUtils, dvwin, dvcrt, dvarq, dvform, crvars, crarq, crmsg, crlegend;

procedure  importaJogo;
procedure  importaTudo;

var arq: textFile;
    l: integer;

implementation

procedure pegaPalavras (direcao: TDirecao);
var s, palavra: string;
    i, p: integer;
    x, y: integer;
begin
    readln (arq, s);
    readln (arq, s);

    while not (eof (arq)) do
        begin
            readln (arq, s);
            l := l + 1;

            if s = '' then break;
            p := pos (':', s);
            palavra := copy (s, 1, p-1);
            delete (s, 1, p);

            s := trim (s);
            p := pos (',', s);
            x := strToInt (copy (s, 1, p-1));
            delete (s, 1, p);

            s := trim (s);
            p := pos (':', s);
            y := strToInt (copy (s, 1, p-1));
            delete (s, 1, p);

            s := trim (s);
            if direcao = HORIZ then
                begin
                    for i := 1 to length(palavra) do
                        begin
                            if x+i-1 > 15 then break;
                            modelo[y, x+i-1] := palavra[i];
                        end;
                end
            else
                begin
                    for i := 1 to length(palavra) do
                        begin
                            if y+i-1 > 15 then break;
                            modelo[y+i-1, x] := palavra[i];
                        end;
                end;

            incluiLegenda (x, y, direcao, s);
        end;
end;

function importaEcw (nomeArq: string): boolean;
var
    erro: boolean;
    s: string;
    x, y: integer;
begin
    importaEcw := false;

    for y := 1 to MAXDIM do
        begin
            modelo [y] := '...............';
            for x := 1 to MAXDIM do
                begin
                    legendasHoriz [x, y] := '';
                    legendasVert  [x, y] := '';
                    nx := MAXDIM;
                    ny := MAXDIM;
                end;
        end;

    removeTodasAsLegendas;

    assignFile (arq, nomeArq);
    {$I-} reset (arq); {$i-}
    if ioresult <> 0 then
        exit;

    erro := false;
    tema := 'Diversão';
    l := 0;
    while not (erro or eof (arq)) do
        begin
            readln (arq, s);
            l := l + 1;
            if s = '' then continue;
            if s[1] = ';' then continue;

            if copy (s, 1, 6) = 'Title:' then
                titulo := trim (copy (s, 7, 999))
            else
            if copy (s, 1, 6) = 'Width:' then
                try
                    nx := strToInt (trim (copy (s, 7, 999)));
                except erro := true; end
            else
            if copy (s, 1, 7) = 'Height:' then
                try
                    ny := strToInt (trim (copy (s, 8, 999)));
                except erro := true; end
            else
            if copy (s, 1, 7) = 'Author:' then
                autor := trim (copy (s, 8, 999))
            else
            if copy (s, 1, 10) = 'Copyright:' then
                dataCriacao := trim (copy (s, 11, 999))
            else
            if copy (s, 1, 9) = 'CodePage:' then
                {}
            else
            if copy (s, 1, 3) = '* A' then
                pegaPalavras (HORIZ)
            else
            if copy (s, 1, 3) = '* D' then
                pegaPalavras (VERT)
            else
                begin
                    mensagem ('CRLINIGN', 1);    {'Linha ignorada: '}
                    sintWriteln (s);
                end;
      end;

    for y := 1 to ny do
        modelo [y] := copy (modelo[y], 1, nx);

    if erro then
          begin
              mensagem ('CRERRECW', 0);   {'Erro na importação: linha '}
              sintWriteInt (l);
              writeln;
              exit;
          end;

    closeFile (arq);
    importaEcw := true;
end;

procedure importaJogo;
var nomeNovo: string;
begin
    if not escolhePastaJogo (dirAtual) then
        exit;

    chdir (dirAtual);
    garanteEspacoTela (10);
    writeln;
    mensagem ('CRESCARQ', 0);    {'Escolha o arquivo com as setas: '}
    nomeArq := obtemNomeArqMasc(24-wherey, '*.ecw');
    writeln (nomeArq);

    if nomeArq = '' then
         mensagem ('CRNAOECW', 1)  {'Arquivo de importação não achado.'}
    else
        if importaEcw (nomeArq) then
            begin
                nomeNovo := trocaExtensao ('crz', nomeArq);
                salvaJogoModelo (nomeNovo);
            end
        else
            mensagem ('CRPROBLE', 1);  {'Problemas na leitura do arquivo.'}

    delay (1000);
end;

procedure importaTudo;
var nomeNovo: string;
    sr: TSearchRec;
    narq: integer;
begin
    if not escolhePastaJogo (dirAtual) then
        exit;

    chdir (dirAtual);
    if FindFirst('*.ecw', faAnyFile, sr) <> 0 then
         mensagem ('CRNAOECW', 1)  {'Arquivo de importação não achado.'}
    else
        begin
            narq := 0;
            repeat
                nomeNovo := trocaExtensao ('crz', sr.Name);
                if importaEcw (sr.Name) then
                    begin
                        salvaJogoModelo (nomeNovo);
                        narq := narq + 1;
                        write ('*');
                    end;
            until FindNext(sr) <> 0;
            writeln;
            sintWriteln (intToStr(narq));
            FindClose(sr);
        end;
end;

end.


