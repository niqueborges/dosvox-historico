unit brantigo;

interface

function brailleAntigo (texto: string): string;

implementation

uses brvars, brutil;
{--------------------------------------------------------}
{             converte uma linha para Braille
{--------------------------------------------------------}

function brailleAntigo (texto: string): string;
const
    brailleEmbaixo: array ['0'..'9'] of char =
        ('}', ',', ';', ':', '.', '?', '!', ')', '{', '*');
var
    s: string;
    posl: integer;
    c: char;

{-------------------------------------------------------------}

    function trataData: boolean;
    var i, p, numBarras: integer;
        lido: string;
    begin
        trataData := false;

        numBarras := 0;
        p := posl;
        lido := '';
        while (p <= length (texto)) and (texto [p] in ['0'..'9', '/']) do
             begin
                 lido := lido + texto [p];
                 p := p + 1;
                 if (p <= length (texto)) and (texto [p] = '/') then
                     numBarras := numBarras + 1;
             end;
        if (numBarras <> 2) or
            not (lido [length (lido)] in ['0'..'9']) then
                exit;   { número comum ou mal formado }

        posl := posl + length (lido);

        for i := 1 to length (lido) do
            if lido [i] = '/' then lido [i] := '-';
        s := s + lido;

        trataData := true;
    end;

{--------------------------------------------------------}

    function trataHora: boolean;
    var p: integer;
        lido: string;
    begin
        trataHora := false;
        p := posl;
        lido := '';
        while (p <= length (texto)) and (texto [p] in ['0'..'9']) do
             begin
                 lido := lido + texto [p];
                 p := p + 1;
             end;
        if (p > length (texto)) or (texto[p] <> ':') then exit;

        while (p <= length (texto)) and (texto [p] in ['0'..'9', ':']) do
             begin
                 lido := lido + texto [p];
                 p := p + 1;
             end;

        s := s + lido;
        posl := posl + length (lido);
        trataHora := true;
    end;

{--------------------------------------------------------}

    function trataOrdinal: boolean;
    var i, p: integer;
        lido: string;
        sufixo: string [3];
    begin
        trataOrdinal := false;

        p := posl;
        lido := '';
        while (p <= length (texto)) and (texto [p] in ['0'..'9']) do
            begin
                lido := lido + texto [p];
                p := p + 1;
            end;

        if p > length (texto) then exit;    { não é um numeral }

        if texto[p] = 'ª' then
            begin
                sufixo := 'a';
                p := p + 1;
            end
        else
        if (texto[p] = '°') or (texto[p] = 'º') then
            {nota: os dois ozinhos são diferentes: em Delphi não aparece no editor ! }
            begin
                sufixo := 'o';
                p := p + 1;
            end
        else
        if (p+1 <= length (texto)) and
           (   (copy (texto, p, 2) = 'a.') or  (copy (texto, p, 2) = 'o.') ) then
               begin
                   sufixo := texto[p];
                   p := p + 2;
               end
        else
        if (p+2 <= length (texto)) and
           (   (copy (texto, p, 3) = 'as.') or  (copy (texto, p, 3) = 'os.') ) then
               begin
                   sufixo := copy (texto, p, 2);
                   p := p + 3;
               end
        else
            exit;    { não é um numeral }

        for i := 1 to length (lido) do
            s := s + brailleEmbaixo [lido[i]];
        s := s + sufixo;

        posl := p;
        trataOrdinal := true;
    end;

{-------------------------------------------------------------}

    procedure convNumero;
    begin
        s := s + SINALNUMERO;

        if not trataData then
          if not trataHora then
           if not trataOrdinal then
              begin
                while (posl <= length(texto)) and
                      (texto[posl] in ['0'..'9', '.', ',']) do
                     begin
                         case texto[posl] of
                            ',': s := s + VIRGDECBRL;

                            '.': if (posl <> length(texto)) and
                                    (texto[posl+1] in ['0'..'9']) then
                                        s := s + PONTODECBRL
                                 else
                                        s := s + PONTOBRL;
                         else
                             s := s + texto[posl];
                         end;
                         posl := posl + 1;
                    end;
                end;
    end;

{--------------------------------------------------------}

    procedure trataFracao;
    begin   { fração }
        s := s + SINALNUMERO;
        posl := posl + 1;
        while (posl <= length(texto)) and (texto[posl] in ['0'..'9']) do
            begin
                s := s + brailleEmbaixo [texto [posl]];
                posl := posl + 1;
            end;

        if posl > length (texto) then exit;

        if texto [posl] = '/' then
            begin
                posl := posl + 1;
                while (posl <= length(texto)) and (texto[posl] in ['0'..'9']) do
                    begin
                        s := s + texto [posl];
                        posl := posl + 1;
                    end;
            end;
    end;

{--------------------------------------------------------}

    procedure convPalavra;
    begin
        repeat
            s := s + texto[posl];
            posl := posl + 1;
        until (posl > length(texto)) or
              (not (texto[posl] in MINUSCULAS+['-']));
    end;

{--------------------------------------------------------}

    procedure convPalavraMaiusc;    { nao trata o caso MMmM }
    begin
        if (posl >= length(texto)) or
                   not (texto [posl+1] in MAIUSCULAS) then
            begin
                c := convMinusc (texto[posl]);
                if txtIngles then
                    s := s + MAIUSCINGLES + c
                else
                    s := s + MAIUSCBRL + c;
                posl := posl + 1;
            end
        else
            begin
                if txtIngles then
                    s := s + MAIUSCINGLES + MAIUSCINGLES
                else
                    s := s + MAIUSCBRL + MAIUSCBRL;
                repeat
                    c := convMinusc (texto[posl]);
                    s := s + c;
                    posl := posl + 1;
                until (posl > length(texto)) or
                              not (texto[posl] in MAIUSCULAS);
            end;
    end;

{--------------------------------------------------------}

    procedure convPonto;
    begin
        if (length (texto) >= posl+2) and
           (texto [posl+1] = '.') and
           (texto [posl+2] = '.') then
            begin
                s := s + RETICBRL;
                posl := posl + 3;
            end
        else
            begin
                s := s + PONTOBRL;
                posl := posl + 1;
            end;
    end;

{--------------------------------------------------------}

    procedure convAspas (c: char);
    begin
        if c = #$93 then abre_aspas := true
        else
        if c = #$94 then abre_aspas := false;

        if abre_aspas then
            begin
                s := s + ABREASPASBRL;
                abre_aspas := false;
            end
        else
            begin
                s := s + FECHAASPASBRL;
                abre_aspas := true;
            end;

        posl := posl + 1;
    end;

{--------------------------------------------------------}

    procedure convCarac;
    begin
        case texto [posl] of
            '_': if txtIngles then
                     s := s + GRIFOINGLES
                 else
                     s := s + GRIFOBRL;
            '%': s := s + PERCENTBRL;
            '§': s := s + PARAGRAFO;
        else
            s := s + texto[posl];
        end;

        posl := posl + 1;
    end;

{--------------------------------------------------------}

    procedure convMatematicos;
    begin
        posl := posl + 1;
        case texto [posl] of
            '(':  s := s + 'ê';
            ')':  s := s + 'ã';
            '*':  s := s + '{';
            '[':  s := s + 'á';
            ']':  s := s + 'ú';
            '{':  s := s + '~l';
            '}':  s := s + '_,';
        end;
        posl := posl + 1;
    end;

{--------------------------------------------------------}
begin
   s := '';

   if (texto <> '') and (texto <> ' ') then
      if (texto[1] = ' ') and (texto[2] <> ' ') then
         delete (texto, 1, 1);

    posl := 1;
    while posl <= length (texto) do
        begin
            if texto [posl] in MINUSCULAS then
                convPalavra
            else

            if texto[posl] in MAIUSCULAS then
                convPalavraMaiusc
            else

            if (texto[posl] in ['0'..'9']) then
                convNumero
            else

            if (posl < length(texto)) and
               (texto[posl] = '`') and (texto[posl+1] in ['0'..'9']) then
                    trataFracao
            else

            if (posl < length(texto)) and
               (texto[posl] = '`') and (texto[posl+1] in ['(', ')', '*', '[', ']', '{', '}']) then
                    convMatematicos
            else

            if texto[posl] = '.' then
                convPonto
            else

            if texto[posl] in ['"', #$93, #$94] then
                convAspas (texto[posl])
            else

                convCarac;
        end;

    brailleAntigo := s;
end;

end.
 