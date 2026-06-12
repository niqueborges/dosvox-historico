{--------------------------------------------------------}
{                                                        }
{    Programa acesso simplificado ao Google              }
{                                                        }
{    Módulo de processamento HTML                        }
{                                                        }
{    Autores: Antonio Borges e Fabiano Ferreira          }
{       Em maio/2013                                     }
{                                                        }
{    Atualizado por Antonio Borges e Patrick Barboza     }
{       Em fevereiro/2025                                }
{                                                        }
{--------------------------------------------------------}

unit gvhtml;

interface
uses SysUtils, classes;

function traduzLetrasHTML(const strHTML: string): string;
function HTMLparaStringList(const strHTML: string): TStringList;
function hexDecode(s: string): string;

implementation

var
    slHTML: TStringList;

const
    CRLF = ^m^j;

{--------------------------------------------------------}
{             transforma html em texto plano             }
{--------------------------------------------------------}

function traduzLetrasHTML(const strHTML: string): string;
var
  saida: string;
  n, ind: integer;
  special: string;

type
  TCodLetra = record
      cod: string[8];
      letra: string[4];
  end;

const
  NUMCODS = 65;
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
      (cod: 'GT'    ; letra: '>'),
      (cod: 'LT'    ; letra: '<'),
      (cod: 'AMP'   ; letra: '&'),
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
      (cod: 'HELLIP'; letra: '...'),
      (cod: '#8211';  letra: '–'),
      (cod: '#8212';  letra: '—'),
      (cod: '#8216';  letra: '‘'),
      (cod: '#8217';  letra: '’'),
      (cod: '#8218';  letra: '‚'),
      (cod: '#8220';  letra: '“'),
      (cod: '#8221';  letra: '”'),
      (cod: '#8222';  letra: '„'),
      (cod: '#8224';  letra: '†'),
      (cod: '#8225';  letra: '‡'),
      (cod: '#8226';  letra: '•'),
      (cod: '#8230';  letra: '…'),
      (cod: '#8240';  letra: '‰'),
      (cod: '#8250';  letra: '/'),
      (cod: '#8364';  letra: '€'),
      (cod: '#8482';  letra: '™')
  );

begin
    ind := 1;
    saida := '';

    while ind <= length(strHTML) do
        begin
            if strHTML[ind] <> '&' then
                saida := saida + strHTML[ind]
            else
                begin
                    special := '';
                    inc(ind);
                    repeat
                        special := special + upcase(strHTML[ind]);
                        inc(ind);
                    until (ind > length(strHTML)) or (strHTML[ind] = ';');

                    if copy (special, 1, 5) = '#8250' then
                        begin
                            inc (ind);
                            delete (saida, length(saida), 1);
                        end;

                    for n := 1 to NUMCODS do
                        if special = tabCods[n].cod then
                             begin
                                  saida := saida + tabCods[n].letra;
                                  break;
                           end;
                end;

            Inc(ind);
        end;

    result := saida;
end;

{--------------------------------------------------------}
{             transforma html em stringList              }
{--------------------------------------------------------}

function HTMLparaStringList(const strHTML: string): TStringList;
var i: integer;
    s: string;
begin
    s := '';
    for i := 1 to length(strHTML) do
        begin
            if strHTML[i] = '<' then
                s := s + CRLF + strHTML[i]
            else
            if strHTML[i] = '>' then
                s := s + strHTML[i] + CRLF
            else
                s := s + strHTML[i];
        end;

    if slHTML <> NIL then
         slHTML.Free;

    slHTML := TStringList.Create;
    slHTML.text := s;
    result :=  slHTML;
end;

{--------------------------------------------------------}
{       converte de dois bytes em hexa para char         }
{--------------------------------------------------------}

function HexToChar(s: String): char;
var
    b1, b2: byte;
begin
    b1 := (byte(upcase(s[1])) - ord('0'));
    if b1 >= 10 then b1 := b1 - 7;
    b2 := (byte(upcase(s[2])) - ord('0'));
    if b2 >= 10 then b2 := b2 - 7;
    result := chr (b1*16 + b2);
end;

{--------------------------------------------------------}
{              remove os códigos em hexa                 }
{--------------------------------------------------------}

function hexDecode (s: string): string;
var
    saida: string;
    i: integer;
    c: char;

begin
    i := 1;
    saida := '';
    while i <= length(s) do
        begin
            c := s[i];
            if c = '%' then
                begin
                    c := hexToChar (copy (s, i+1, 2));
                    i := i + 3;
                end
            else
                i := i + 1;
            saida := saida + c;
        end;
    result := saida;
end;
end.

