{--------------------------------------------------------}
{                                                        }
{    Programa leitor de notícias e RSS                   }
{                                                        }
{    Rotinas acessórias                                  }
{                                                        }
{    Autor: José Antonio Borges e Fabiano Ferreira       }
{                                                        }
{    Em maio/2013                                        }
{                                                        }
{--------------------------------------------------------}

unit neutil;

interface
function removeTagsHTML(const strHTML: string): string;

implementation

{--------------------------------------------------------}
{ transforma html em texto plano                         }
{--------------------------------------------------------}

function removeTagsHTML(const strHTML: string): string;
const
  CRLF = #$0d#$0a;
var
  InTag, InPre: Boolean;
  InScript, InStyle: Boolean;
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
  InScript := False;
  InStyle := False;

  while ind <= length(strHTML) do
  begin
    case strHTML[ind] of
      '<': begin
               InTag := True;
               tag := '';
           end;
      '>': begin
               InTag := False;
               if copy (tag, 1, 6) = 'SCRIPT' then
                    begin
                        result := result + CRLF;
                        inScript := true;
                    end
               else
               if copy (tag, 1, 5) = 'STYLE' then
                   inStyle := true
               else
               if tag = '/SCRIPT' then inScript := false
               else
               if tag = '/STYLE' then inStyle := false
               else
               if (not inScript) and (not inStyle) then
                  begin
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
           end;

      '&': if (not inScript) and (not inStyle) then
               if not inTag then
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
      #10: if (not inScript) and (not inStyle) then
               if not inTag then
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
              if (not inScript) and (not inStyle) then
                  result := result + strHTML[ind];
    end;
    Inc(ind);
  end;
end;

end.
