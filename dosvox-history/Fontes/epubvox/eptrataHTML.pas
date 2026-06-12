unit eptrataHTML;
interface
uses
  dvcrt,
  SysUtils,
  classes,
  epvars,
  windows;

function removeTagsHTML(const strHTML: string; buscaSumario: boolean): string;
procedure criaTXT(nomeArq: String);
    
implementation

{--------------------------------------------------------}
{            Descobre diretório de trabalho
{--------------------------------------------------------}

function GetTempDir: string;
var
  Buffer: array[0..512] of Char;
  saida: string;

begin
    GetTempPath(512,Buffer);
    saida := StrPas(Buffer);
    if saida[length(saida)] <>'\' then saida := saida+'\';
    Result := saida;
end;

{--------------------------------------------------------}
{                 trata parametro da tag                 }
{--------------------------------------------------------}

function trataParametro(parametro: string): string;
var
    i: integer;
    id: string;
begin
    if pos('id=',parametro)>0 then
        begin
            i := pos('id=',parametro);
            id := Copy(parametro,i,pos('"',parametro));
        end;
end;

{--------------------------------------------------------}
{       Cria rodapé com o nome das imagens
{--------------------------------------------------------}

procedure criaRodape(Acumulado: TStringlist);
var
    i: integer;
    
const
    CRLF = #$0d#$0a;

begin
    for i:=0 to length(rodapeIMG)-1 do
        Acumulado.text:= Acumulado.text+ CRLF+ trim(rodapeIMG[i].nome)+ ': '+ trim(rodapeIMG[i].src);
end;

{--------------------------------------------------------}
{       Checa se uma string está no array                }
{--------------------------------------------------------}

function checaArray(s: String): integer;
var
    i: integer;
begin
    result := -1;
    for i:=0 to length(ListaIds)-1 do
        if pos(ListaIds[i].id,s)>0 then   result := i;
end;
{--------------------------------------------------------}
{        transforma html em texto plano                  }
{--------------------------------------------------------}

function removeTagsHTML(const strHTML: string; buscaSumario: boolean): string;
const
  CRLF = #$0d#$0a;
var
  InTag, InPre, InStyle, InIf: Boolean;
  tag: shortstring;
  special: shortString;
  ind, p, n, i: integer;
  param, a, b: string;

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
  InStyle := False;
  InIf := False;

  while ind <= length(strHTML) do
  begin
    case strHTML[ind] of
      '<': begin
               InTag := True;
               tag := '';
           end;
      '>': begin
               InTag := False;
               param := '';
               p := pos (' ', tag);
               if p <> 0 then
                   begin
                       param := copy (tag, p+1, 999);
                       delete (tag, p, 999);
                   end;
               if tag = 'HR' then result := result + CRLF + '- - - - -'
               else
               if tag = 'PRE' then InPre := true
               else
               if tag = '/PRE' then InPre := false
               else
               if tag = 'STYLE' then InStyle := true
               else
               if tag = '/STYLE' then InStyle := false
               else
               if tag = '!--[IF' then InIf := true
               else
               if tag = '![ENDIF]--' then
                   InIf := false
               else
               if tag = 'LI' then result := result + CRLF + '. '
               else
               if tag = 'BR' then result := result + CRLF + CRLF
               else
               if tag = 'TITLE' then result := result + '#$#'
               else
               if tag = '/TITLE' then result := copy(result,1, pos('#$#',result)-1)
               else
               if tag = 'I' then result := result + CRLF + '  <II> '
               else
               if tag = 'B' then result := result + CRLF + '  <IN> '
               else
               if tag = '/I' then result := result + CRLF + ' <FI>  '
               else
               if tag = '/B' then result := result + CRLF + ' <FN>  '
               else
               if (tag = 'A') and (checaArray(param)<> -1) then
                   begin
                       for i:=0 to length(ListaIds)-1 do
                       begin
                           b := copy(param, pos(listaids[checaArray(param)].id,param), 999);
                           b := copy(b,0,pos('"',b)-1);
                           if trim(uppercase(b)) = ListaIds[i].id then
                               result := result+  CRLF+ '~ Local ' +ListaIds[i].nome+CRLF;
                       end;
                   end
               else
               if (tag = 'P') or (tag = 'A') then
                   begin
                       if pos('#', param) > 0 then
                           begin
                               if buscaSumario then
                                   begin
                                       if param[length(param)] = '"' then
                                           param := copy(param,1, length(param )-1);
                                       a := copy(param, pos('#', param)+1,999);
                                       SetLength(ListaIds,k);
                                       PLocal.nome := inttostr(k);
                                       PLocal.id := trim(uppercase(a));
                                       ListaIds[k-1] := Plocal;
                                       k := k+1;
                                   end;
                           end
                       else
                           result := result + CRLF
                   end
               else
               if (tag = 'H1') or (tag = 'H2') or (tag = 'H3') or (tag = 'H4') or (tag = 'H6') or
                  (tag = '/H1') or (tag = '/H2') or (tag = '/H3') or (tag = '/H4') or (tag = 'H5') or
                  (tag = 'TABLE') or (tag = '/TABLE') or (tag = 'TR') or
                  (tag = 'BR') then
                  result := result + CRLF

               else
               if (tag = 'IMG') and (pos('SRC', param)>0) then
                   begin
                       if processaImagem then
                           begin
                               b := copy(param, pos('SRC="',param)+5, 999);
                               b := copy(b, 0, pos('"',b)-1);
                               b := StringReplace(b, '/', '\', [rfReplaceAll, rfIgnoreCase]);
                               if pos('..',b)>0 then
                                   b:= copy(b,3,length(b));

                               if b[1] = '\' then b :=  copy(b,2,length(b));

                               b:= ExtractFilePath(localSaida)+'IMAGEM_'+novoNomeLivro+'\'+ExtractFileName(b);

                               SetLength(rodapeIMG,j);

                               PImagem.nome:= '~ Imagem ' + inttostr(length(rodapeIMG))+' ';
                               PImagem.src := b;
                               rodapeIMG[j-1] := PImagem;
                               result := result+ CRLF+ rodapeIMG[j-1].nome + CRLF;
                               j := j+1;
                           end
                       else
                           begin
                               b := copy(param, pos('ALT="',param)+5, 999);
                               b := copy(b, 0, pos('"',b)-1);
                               result := result + CRLF+ ' ~ Imagem ' + b;
                           end;
                   end;
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
                  if InStyle or InIf then
                      {}
                  else
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
          begin
              if InTag then
                  tag := tag + upcase(strHTML[ind])
              else
                  if not (inStyle or inIf) then
                      result := result + strHTML[ind];
          end;
    end;
    Inc(ind);
  end;
end;

{--------------------------------------------------------}
{            tira linhas em excesso
{--------------------------------------------------------}

function tiraLinhaExtra(texto: TStringlist): TStringlist;
var
    i: integer;

begin
    i := texto.count-1;
    repeat
        if (trim(texto[i]) = '') and (trim(texto[i-1]) = '') then
            texto.Delete(i);
        i := i-1;
    until i = 0;

    result := texto;
end;


{--------------------------------------------------------}
{               Checa se o arquivo é a capa
{--------------------------------------------------------}

function excluiCover(href: String): boolean;
var i: integer;
begin
    result := false;
    for i:=0 to length(guide)-1 do
        if guide[i].type_ = 'cover' then
            if href = guide[i].href then
                result := true;
end;

{--------------------------------------------------------}
{               Cria arquivão txt
{--------------------------------------------------------}

procedure criaTXT(nomeArq: String);
var
    Acumulado, texto: TStringList;
    i,j: integer;
begin
    Acumulado := TStringList.create;
    texto := TStringList.create;

    for i:=0 to length(spine)-1 do
        begin
            for j:=0 to length(manifest)-1 do
                begin
                    if ansiuppercase(spine[i].idref) = ansiuppercase(manifest[j].id) then
                    begin
                        if excluiCover(manifest[j].href) then
                            continue
                        else
                        begin
                            texto.LoadFromFile(dirConteiner+manifest[j].href);
                            texto.Text := Utf8ToAnsi(texto.Text);
                            if manifest[j].href = hrefToc then
                                texto.Text := removeTagsHtml(texto.Text, true)
                            else
                                texto.Text := removeTagsHtml(texto.Text, false);
                            Acumulado.text:= Acumulado.text+texto.Text;
                        end;
                    end;
                end;
        end;
    acumulado := tiraLinhaExtra(acumulado);
    if processaImagem then
        criaRodape(acumulado);
    Acumulado.SaveToFile(LocalSaida);
    texto.Destroy;
    Acumulado.Destroy;

end;

end.

