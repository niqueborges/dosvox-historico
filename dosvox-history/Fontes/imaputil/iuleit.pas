{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Módulo de folheamento de mensagens                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em abril/2013                                       }
{                                                        }
{--------------------------------------------------------}

unit iuleit;

interface

uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes,
    dvinet,
    dvssl,
    dvform,
    dvarq,
    dvexec,
    iurede,
    iuenvel,
    iuvars,
    iumsg,
    iutela,
    iuLeitin;

procedure processarCarta (numCarta: integer);

implementation

type
    TItemEstrut = record
        cod: string [20];
        tipo, subtipo,
        formato, charmap, codif,
        nome: shortString;
        tamanho, numLinhas: integer;
    end;

var
    estrut: array of TItemEstrut;
    boundary: string;

{--------------------------------------------------------}
{ extrair a estrutura de um trecho da carta              }
{--------------------------------------------------------}

function extraiEstrutura (numCarta: integer): boolean;
var lido: string;
    nivel: integer;
    numero: array[1..20] of integer;
    s, x: string;
    i: integer;

    function u_pegaCadeia(var s: string): string;
    begin
        result := upperCase (pegaCadeia(s));
    end;

begin
    result := false;
    setLength (estrut, 0);

    if not execComando('FETCH ' + intToStr(numCarta) + ' BODY') then
        begin
            mensagem ('IUERREST', 1);  {'Erro ao buscar a estrutura da carta'}
            exit;
        end;

    s := respserv[0];
    fillchar (numero, 0, sizeof (numero));
    ignora_ate ('BODY',  s);
    nivel := -1;
    repeat
        if s = '' then break;
        if s = ' ' then
            delete (s, 1, 1)
        else
        if s[1] = '(' then
            begin
                nivel := nivel + 1;
                if nivel > 0 then
                    inc(numero[nivel]);
                delete (s, 1, 1);
            end
        else
        if s[1] = ')' then
            begin
                numero[nivel+1] := 0;
                nivel := nivel - 1;
                delete (s, 1, 1);
            end
        else
            begin
                lido := u_pegaCadeia (s);
                if lido = '' then
                    continue
                else
                if lido = 'BOUNDARY' then
                    begin
                        boundary := pegaCadeia (s);
                        continue;
                    end
                else
                if (lido = 'RELATED') or (lido = 'ALTERNATIVE') or (lido = 'MIXED') then
                    begin
                        s := trimLeft(s);
                    end
                else
                    begin
                        setLength(estrut, length(estrut) + 1);
                        with estrut[length(estrut) - 1] do
                            begin
                                if numero[1] = 0 then numero[1] := 1;
                                cod := intToStr(numero[1]);
                                for i := 2 to nivel do
                                    cod := cod + '.' + intToStr(numero[i]);

                                tipo := lido;
                                subtipo := u_PegaCadeia (s);
                                ignora_ate('(', s);
                                repeat
                                    x := u_PegaCadeia (s);
                                    if x = 'FORMAT'  then formato := u_pegaCadeia(s)
                                    else
                                    if x = 'CHARSET' then charmap := u_pegaCadeia(s)
                                    else
                                    if x = 'NAME'    then nome    := pegaCadeia(s);
                                until (s = '') or (s[1] = ')');
                                delete (s, 1, 1);

                                pegaCadeia(s);
                                pegaCadeia(s);
                                codif := u_pegaCadeia(s);
                                tamanho := pegaNumero (s);
                                if tipo = 'TEXT' then
                                    numLinhas := pegaNumero (s);

                                ignora_ate(')', s);
                                numero[nivel+1] := 0;
                                nivel := nivel - 1;

                            end;
                    end;
            end;
    until nivel = -1;
    result := true;   // assumindo que está tudo OK
end;

{--------------------------------------------------------}
{ rotina para depuração do algoritmo                     }
{--------------------------------------------------------}
(*
procedure testaEstrutura;
const x: string =
'* 2127 FETCH (BODY (' +
    '(' +
      '("text" "plain" ("charset" "ISO-8859-1") NIL NIL "quoted-printable" 579 26)' +
      '("text" "html" ("charset" "ISO-8859-1") NIL NIL "quoted-printable" 1229 21)' +
      ' "alternative" ' +
    ')' +
    '("application" "msword" ("name" "FINEP_FORMULARIO_PATROCINIO_2013 - musibraille.doc") NIL NIL "base64" 170252)' +
       ' "mixed"' +
  ')' +
')';


'* 1 FETCH (BODY (
    ("text" "plain" ("charset" "utf-8")
            NIL NIL
            "quoted-printable" 1456 59 NIL NIL NIL NIL)
    ("text" "html" ("charset" "utf-8")
            NIL NIL "quoted-printable" 2587 59 NIL NIL NIL NIL)
            "alternative"
            ("boundary" "001a11c1334e47f0a4051bfc263d")
            NIL)
    )'


'* 2127 FETCH (BODY (
    (
      ("text" "plain" ("charset" "ISO-8859-1")
              NIL NIL
              "quoted-printable" 579 26)
      ("text" "html" ("charset" "ISO-8859-1")
              NIL NIL
              "quoted-printable" 1229 21)
      "alternative"
    )
      ("application" "msword"
               ("name" "FINEP_FORMULARIO_PATROCINIO_2013 - musibraille.doc")
               NIL NIL
               "base64" 170252)
      "mixed"
       )' +
')';




var y: string;
begin
    respserv := TStringList.Create;
    y := x;
    respserv.add (y);
    extraiEstrutura(1);
end;
*)

{--------------------------------------------------------}
{ limpa a estrutura extraída                             }
{--------------------------------------------------------}

procedure destroiEstrut;
begin
    setLength (estrut, 0);
end;

{--------------------------------------------------------}
{ transforma html em texto plano                         }
{--------------------------------------------------------}

function removeTagsHTML(const strHTML: string): string;
const
  CRLF = #$0d#$0a;
var
  InTag, InPre: Boolean;
  tag: shortstring;
  special: shortString;
  ind, n: integer;
type
  TCodLetra = record
      cod: string[8];
      letra: string[4];
  end;

const
  NUMCODS = 49;
  tabCods: array [1..NUMCODS] of TCodLetra = (
      (cod: 'aACUTE'; letra: 'á'),
      (cod: 'eACUTE'; letra: 'é'),
      (cod: 'iACUTE'; letra: 'í'),
      (cod: 'oACUTE'; letra: 'ó'),
      (cod: 'uACUTE'; letra: 'ú'),
      (cod: 'AACUTE'; letra: 'Á'),
      (cod: 'EACUTE'; letra: 'É'),
      (cod: 'IACUTE'; letra: 'Í'),
      (cod: 'OACUTE'; letra: 'Ó'),
      (cod: 'UACUTE'; letra: 'Ú'),
      (cod: 'aCIRC' ; letra: 'â'),
      (cod: 'eCIRC' ; letra: 'ê'),
      (cod: 'oCIRC' ; letra: 'ô'),
      (cod: 'ACIRC' ; letra: 'Â'),
      (cod: 'ECIRC' ; letra: 'Ê'),
      (cod: 'OCIRC' ; letra: 'Ô'),
      (cod: 'aTILDE'; letra: 'ã'),
      (cod: 'oTILDE'; letra: 'õ'),
      (cod: 'ATILDE'; letra: 'Ã'),
      (cod: 'OTILDE'; letra: 'Õ'),
      (cod: 'aGRAVE'; letra: 'à'),
      (cod: 'AGRAVE'; letra: 'À'),
      (cod: 'uTREMA'; letra: 'ü'),
      (cod: 'UTREMA'; letra: 'Ü'),
      (cod: 'uUML'  ; letra: 'ü'),
      (cod: 'UUML'  ; letra: 'Ü'),
      (cod: 'cCEDIL'; letra: 'ç'),
      (cod: 'CCEDIL'; letra: 'Ç'),
      (cod: 'nTILDE'; letra: 'ñ'),
      (cod: 'NTILDE'; letra: 'Ñ'),
      (cod: 'QUOT'  ; letra: '"'),
      (cod: 'APOS'  ; letra: ''''),
      (cod: 'GT'    ; letra:   '>'),
      (cod: 'LT'    ; letra:   '<'),
      (cod: 'AMP'   ; letra:  '&'),
      (cod: 'NBSP'  ; letra: ' '),
      (cod: 'ORDF'  ; letra: 'a'),
      (cod: 'ORDM'  ; letra: 'o'),
      (cod: 'COPY'  ; letra: '©'),
      (cod: 'LAQUO' ; letra: '"'),
      (cod: 'RAQUO' ; letra: '"'),
      (cod: 'MIDDOT'; letra: '*'),
      (cod: 'LDQUO' ; letra: '"'),
      (cod: 'RDQUO' ; letra: '"'),
      (cod: 'MDASH' ; letra: '-'),
      (cod: 'NDASH' ; letra: '-'),
      (cod: 'RSQUO' ; letra: ''''),
      (cod: 'SHY'   ; letra: ' '),
      (cod: 'HELLIP'; letra: '...')
  );

begin
  ind := 1;
  Result := '';
  InPre := false;
  InTag := False;

  while ind <= length(strHTML) do
  begin
    case strHTML[ind] of
      '<': begin
               InTag := True;
               tag := '';
           end;
      '>': begin
               InTag := False;
               if tag = 'HR' then result := result + CRLF + '- - - - -'
               else
               if tag = 'PRE' then InPre := true
               else
               if tag = '/PRE' then InPre := false
               else
               if tag = 'LI' then result := result + CRLF + '. '
               else
               if tag = 'BR' then result := result + CRLF
               else
               if tag = 'P' then result := result + CRLF + CRLF
               else
               if (tag = 'H1') or (tag = 'H2') or (tag = 'H3') or (tag = 'H4') or (tag = 'H6') or
                  (tag = '/H1') or (tag = '/H2') or (tag = '/H3') or (tag = '/H4') or (tag = 'H5') or
                  (tag = 'TABLE') or (tag = '/TABLE') or (tag = 'TR') or
                  (tag = 'BR') then
                  result := result + CRLF
               else
               if tag = 'IMG' then result := result + ' (imagem) ';
           end;
      '&': if not inTag then
               begin
                    inc(ind);
                    special := strHTML[ind];
                    inc(ind);
                    repeat
                        special := special + upcase(strHTML[ind]);
                        inc(ind);
                    until (ind > length(strHTML)) or (strHTML[ind] = ';');

                    for n := 1 to NUMCODS do
                        if special = tabCods[n].cod then
                            begin
                                result := result + tabCods[n].letra;
                                break;
                            end;
               end;

      #13: ;  {do nothing}
      #10: if not inTag then
              begin
                  if InPre then
                      result := result + CRLF
                  else
                      result := result + ' ';
                  repeat
                      inc(ind);
                  until (ind > length(strHTML)) or (strHTML[ind] <> ' ');
                  dec(ind);
               end;

      else
      if InTag then
          tag := tag + upcase(strHTML[ind])
      else
          result := result + strHTML[ind];
    end;
    Inc(ind);
  end;
end;

{--------------------------------------------------------}
{ informações sobre um trecho da carta                   }
{--------------------------------------------------------}

procedure informacoes (parte: integer);
begin
    limpaBaixo (22);
    with estrut[parte] do
        begin
            if nome <> '' then
                begin
                    sintWriteln (nome);
                    sintClek;
                end;
            sintWrite (formato +' - ' + charmap + ', ' + codif);
        end;
end;

{--------------------------------------------------------}
{ ler rápida de um trecho da carta                       }
{--------------------------------------------------------}

function pegaTamanhoParte (resp0: string): integer;
var s: string;
    p: integer;
begin
    s := resp0;
    p := lastDelimiter ('{', s);
    delete (s, 1, p);
    delete (s, length(s), 1);
    try
        result := strToInt (s);
    except
        result := 0;
    end;
end;

{--------------------------------------------------------}
{ Decodifica a parte textual da carta                    }
{--------------------------------------------------------}

function decodParteTextualCarta (numCarta, parte: integer): boolean;
// nota: destroi a variável respServ
var
    tam, ult: integer;
    i, acum: integer;
    cod_m, cod_q, cod_u: boolean;
    s: string;
begin
    result := true;
    if not execComando('FETCH ' + intToStr(numCarta) + ' body[' + estrut[parte].cod + ']') then
        begin
            mensagem ('IUERRTRZ', 1);   {'Erro ao trazer a carta'}
            result := false;
            exit;
        end;

    // calcula quantas linhas recebidas tem que transferir
    tam := pegaTamanhoParte (respServ[0]);
    acum := 0;
    ult := respServ.count - 2;
    for i := 1 to respServ.Count-2 do
        begin
            acum := acum + length(respserv[i]) + 2;
            if acum >= tam then
                begin
                    ult := i;
                    break;
                end;
        end;

    cod_m := upperCase(estrut[parte].codif) = 'MIME64';
    cod_q := upperCase(estrut[parte].codif) = 'QUOTED-PRINTABLE';
    cod_u := upperCase(estrut[parte].charmap) = 'UTF-8';

    for i := 1 to ult do
        begin
            if cod_m then
                respServ[i] := decodFraseMime64 (respServ[i])
            else
            if cod_q then
                respServ[i] := convQuotedPrintable (respServ[i]);

            if cod_u then
                respServ[i] := Utf8ToAnsi(respServ[i]);
        end;

    for i := respServ.count-1 downto ult+1 do
        respServ.Delete(ult+1);
    respServ.Delete(0);

    if cod_q then
        for i := respServ.count-2 downto 0 do
            begin
                s := respServ[i];
                if (s <> '') and (s[length(s)] = '=') then
                    begin
                         delete (s, length(s), 1);
                         respServ[i] := s + respServ[i+1];
                         respServ.delete(i+1);
                    end;
            end;
end;

{--------------------------------------------------------}
{  Grava parte binária
{--------------------------------------------------------}

procedure gravaBinario (nomeArq: string; numCarta, parte, tamanho: integer);
var
    arq: file;
    i, nc: integer;
    buf: vetBytes;

begin
    if not execComando('FETCH ' + intToStr(numCarta) + ' body[' + estrut[parte].cod + ']') then
        begin
            mensagem ('IUERRTRZ', 1);   {'Erro ao trazer a carta'}
            exit;
        end;

    assign (arq, nomeArq);
    {$I-} rewrite (arq, 1);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('IUERRGRV', 1);  {'Erro de gravação'}
            exit;
        end;

    for i := 1 to respServ.Count-2 do
        begin
            try
                 if (respServ[i] = '') or (respServ[i][1] = ')') then
                     break;
                 nc := decodBinMime64 (respServ[i], buf);
                 blockWrite (arq, buf, nc)
            except
                mensagem ('IUERRGRV', 1);  {'Erro de gravação'}
                break;
            end;
        end;

    closefile (arq);
    mensagem ('IUOK', 0);   {'OK'}
end;

{--------------------------------------------------------}
{  Grava parte textual
{--------------------------------------------------------}

procedure gravaTextual (nomeArq: string; numCarta, parte: integer);
var
    arq: textfile;
    i: integer;
begin
    if not decodParteTextualCarta (numCarta, parte) then
       exit;

    assign (arq, nomeArq);
    {$I-} rewrite (arq);  {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('IUERRGRV', 1);  {'Erro de gravação'}
            exit;
        end;

    if estrut[parte].subtipo = 'HTML' then
        respServ.text := removeTagsHTML(respServ.text);

    for i := 0 to respServ.Count-1 do
        try
            writeln (arq, respServ[i]);
        except
            mensagem ('IUERRGRV', 1);  {'Erro de gravação'}
            closeFile (arq);
            break;
        end;

    closefile (arq);
    mensagem ('IUOK', 0);   {'OK'}
end;

{--------------------------------------------------------}
{ grava a parte em um arquivo                            }
{--------------------------------------------------------}

procedure gravar (numCarta, parte: integer);
var
    c: char;
    nomeArq: string;
begin
    mensagem ('IMARQGRV', 1);    {'Editore o nome do arquivo a gravar:'}
    nomeArq := estrut[parte].nome;
    c := sintEdita (nomearq, wherex, wherey, 80, true);
    if c = ESC then
         mensagem ('IUDESIST', 1)   {'Desistiu...'}
    else
        begin
             writeln (nomeArq);
             mensagem ('IUMOMENT', 0);     {'Um momento...'}
             write ('  ');

             with estrut[parte] do
                 if (tipo <> 'TEXT') or ((subtipo <> 'PLAIN') and (subtipo <> 'HTML')) then
                     gravaBinario (nomeArq, numCarta, parte, tamanho)
                 else
                     gravaTextual (nomeArq, numCarta, parte);
        end;
end;

{--------------------------------------------------------}
{ leitura rápida de um trecho da carta                   }
{--------------------------------------------------------}

procedure leituraRapida (numCarta, parte: integer);
begin
    with estrut[parte] do
      if (tipo <> 'TEXT') or ((subtipo <> 'PLAIN') and (subtipo <> 'HTML')) then
        begin
            mensagem ('IULEINAO', 1);  {'Não ser fazer uma leitura rápida disso'}
            exit;
        end;

    clrscr;
    if decodParteTextualCarta (numCarta, parte) then
        begin
            if estrut[parte].subtipo = 'HTML' then
                respServ.text := removeTagsHTML(respServ.text);

            leituraInterativa (respServ);
        end;

    limpaBufTec;
//    mensagem ('IUAPTENT', 0);  {'Aperte enter para continuar...'}
//Neno    readln;
end;

{--------------------------------------------------------}
{ ler um trecho da carta via Edivox                      }
{--------------------------------------------------------}

procedure chamaEdivox (numCarta, parte: integer);
var nomeProg, nomeArq: string;
    tempPath, tempFileName: array [0..144] of char;
begin
    with estrut[parte] do
      if (tipo <> 'TEXT') or ((subtipo <> 'PLAIN') and (subtipo <> 'HTML')) then
        begin
            mensagem ('IUSOTEXT', 1);  {'Não posso: só envio textos planos ou html'}
            exit;
        end;

    if not decodParteTextualCarta (numCarta, parte) then
        begin
            mensagem ('IUERRDEC', 1);  {'Erro na decodificação - não posso ler'}
            exit;
        end;

    if estrut[parte].subtipo = 'PLAIN' then
        begin
            nomeProg := sintAmbiente ('IMAPUTIL', 'EDITOR');
            if nomeProg = '' then
                nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\edivox.exe';
        end
    else
        begin
            nomeProg := sintAmbiente ('IMAPUTIL', 'NAVEGADOR');
            if nomeProg = '' then
                nomeProg := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\webvox.exe';
        end;

    if pos ('EDIVOX.EXE', uppercase(nomeProg)) <> 0 then
        nomeProg := '"'+ nomeProg+ '"' + ' /L';


    getTempPath (144, tempPath);
    getTempFileName(tempPath, 'imap', 0, tempFileName);
    nomeArq := strPas (tempFileName);
    respserv.SaveToFile(nomeArq);

    if executaProg (nomeProg, '', '"'+nomeArq+'"') >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
        end
    else
        mensagem ('IUERRCHM', 1);  {'Erro ao chamar o leitor'}

    DeleteFile(tempPath+nomeArq);
end;

{--------------------------------------------------------}
{ escolhe com as setas uma parte                         }
{--------------------------------------------------------}

function escolheParte: integer;
var i, n: integer;
    yi: integer;
begin
    mensagem ('IMPARSET', 0);    {'Escolha a parte com as setas: '}
    yi := wherey - length(estrut) + 1;
    if yi < 1 then yi := 1;
    popupMenuCria(wherex, yi, 81-wherex, length(estrut), MAGENTA);

    for i := 0 to length (estrut)-1 do
        with estrut[i] do
            if tipo = 'TEXT' then
                popUpMenuAdiciona('', tipo + ' ' + subtipo + ', ' + intToStr(numLinhas) + ' linhas')
            else
                popUpMenuAdiciona('', tipo + ' ' + subtipo + ' ' + nome + ', ' + intToStr((tamanho+1023) div 1024) + 'K');

    n := popupMenuSeleciona;

    write (#$0d);   // volta ao início da linha
    clreol;
    if n > 0 then
        writeln (opcoesItemSelecionado);

    result := n;
end;

{--------------------------------------------------------}
{ informa as opções disponíveis                          }
{--------------------------------------------------------}

procedure ajuda;
begin
    limpaBaixo (15);
    writeln ('------------------------------------------------------------');
    mensagem ('IUOPCAO',  1);   {'As opções são:'}
    mensagem ('IUINFPAR', 1);   {'I - informações sobre a parte'}
    mensagem ('IULEIRAP', 1);   {'L - leitura rápida'}
    mensagem ('IUEDIVOX', 1);   {'E - leitura com edivox'}
    mensagem ('IUGRAVAR', 1);   {'G - gravar'}
    mensagem ('IUOP_ESC', 1);   {'ESC - Cancelar'}
    readkey;
    limpaBufTec;
end;

{--------------------------------------------------------}
{ seleciona interativamente a opção
{--------------------------------------------------------}

procedure menuAdiciona (cod: string);
begin
    popupMenuAdiciona (cod, pegaTextoMensagem(cod));
end;

function selSetasOpcao: char;
var n: integer;
const
    opmenu: string = 'ileg' + ESC;
begin
    popupMenuCria(40, wherey, 50, 5, RED);
    MenuAdiciona ('IUINFPAR');   {'I - informações sobre a parte'}
    MenuAdiciona ('IULEIRAP');   {'L - leitura rápida'}
    MenuAdiciona ('IUEDIVOX');   {'E - leitura com edivox'}
    MenuAdiciona ('IUGRAVAR');   {'G - gravar'}
    MenuAdiciona ('IUOP_ESC');   {'ESC - Cancelar'}

    n := popupMenuSeleciona;
    if (n < 1) then
        result := ESC
    else
        result := opmenu[n];
end;

{--------------------------------------------------------}
{ executa processamento sobre as partes da carta         }
{--------------------------------------------------------}

procedure processarCarta (numCarta: integer);
var parte: integer;
    terminouPartes: boolean;
    c, c2: char;
label processa, fim;
begin
    if not extraiEstrutura (numCarta) then
        begin
            mensagem ('IUERRSTR', 1);  {'Erro ao obter a estrutura da carta'}
            exit;
        end;

    if length(estrut) = 1 then
        begin
          with estrut[0] do
            if (tipo <> 'TEXT') or ((subtipo <> 'PLAIN') and (subtipo <> 'HTML')) then
                gravar (numCarta, 0)
            else
            if upcase(sintAmbiente('IMAPUTIL', 'LEITURACOMEDIVOX', 'SIM')[1]) = 'S' then
                chamaEdivox (numCarta, 0)
            else
                leituraRapida (numCarta, 0);
            goto fim;
        end;

    gotoxy (40, 21);
    textBackground (BLUE);
    mensagem ('IUNUMPAR', 0);    {'Número de partes desta carta: '}
    sintWrite (intToStr(length(estrut)));
    textBackground (BLACK);

    terminouPartes := false;
    repeat
        salvaTela;

        limpaBaixo (22);
    parte := escolheParte - 1;
        limpaBufTec;
        if parte < 0 then
            begin
                c := ESC;
                goto processa;
            end;

        mensagem ('IUQUEFAZ', 0);    {'Que fazer com esta parte? '}
        sintLeTecla (c, c2);
        writeln;
processa:
        case upcase(c) of
            'I': informacoes (parte);
            'L', ENTER: leituraRapida (numCarta, parte);
            'E': chamaEdivox (numCarta, parte);
            'G': gravar (numCarta, parte);
            ESC: terminouPartes := true;

            #0: case c2 of
                    F1: ajuda;
                    BAIX,
                    F9:   begin
                             c := selSetasOpcao;
                             goto processa;   // como se tivesse teclado a letra
                          end;

                else
                    sintbip;
                end;
        else
            mensagem ('IUNAOSEI', 0);   {Não sei fazer isso não...}
        end;

        recupTela;

    until terminouPartes;

fim:

    destroiEstrut;
    limpaBaixo (21);
    writeln ('------------------------------------------------------------');
    if sintFalarTudo then
        mensagem ('IUCNTFOL', 1)   {'Continue folheando...'}
    else
        begin
            writeln (pegaTextoMensagem('IUCNTFOL'));   {'Continue folheando...'}
            sintclek;
        end;
end;

{--------------------------------------------------------}

begin
end.
