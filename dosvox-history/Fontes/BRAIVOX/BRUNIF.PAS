unit brunif;

interface

function brailleUnificado (texto: string): string;

implementation
uses brvars, brutil;

{--------------------------------------------------------}
{             converte uma linha para Braille
{--------------------------------------------------------}

function brailleUnificado (texto: string): string;
const
    brailleEmbaixo: array ['0'..'9'] of char =
        ('}', ',', ';', ':', '/', '?', '!', '=', '"', '*');
var
    s: string;
    posl: integer;
    c: char;

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
        if (texto[p] = 'º') then
            {os dois ozinhos são diferentes: em Delphi não aparece no editor ! mas um é o grau}
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

    procedure trataPontoDec;
    var numerosAntes, numerosDepois, i: integer;
    begin
        if (posl = length(texto)) or           // se não é sucedido por número
           (not (texto[posl+1] in ['0'..'9'])) then
            begin
                s := s + PONTOBRL;                  //     gera ponto
                exit;
            end;

        numerosAntes := 0;
        for i := posl-1 downto 1 do
            if texto[i] in ['0'..'9'] then
                numerosAntes := numerosAntes + 1
            else
                break;

        numerosDepois := 0;
        for i := posl+1 to length (texto) do
            if texto[i] in ['0'..'9'] then
                numerosDepois := numerosDepois + 1
            else
                break;

        if (numerosAntes < 3) and (numerosDepois < 3) then
            s := s + PONTOBRL + '#'
        else
            s := s + PONTOBRL;
    end;

{-------------------------------------------------------------}

    procedure convNumero;
    begin
        s := s + SINALNUMERO;
        if not trataOrdinal then
            begin
                while (posl <= length(texto)) and
                      (texto[posl] in ['0'..'9', '.', ',' ,'$' ,'a'..'e']) do
                     begin
                         case texto[posl] of
                            'a'..'e': begin
                                         s := s + '~';
                                         exit;
                                      end;
                            ',': s := s + VIRGDECBRL;
                            '$': s := s + '$';
                            '.': trataPontoDec;
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
                    s := s + MAIUSCINGLESU + c
                else
                    s := s + MAIUSCBRLU + c;
                posl := posl + 1;
            end
        else
            begin
                if txtIngles then
                    s := s + MAIUSCINGLESU + MAIUSCINGLESU
                else
                    s := s + MAIUSCBRLU + MAIUSCBRLU;
                repeat
                    c := convMinusc (texto[posl]);
                    s := s + c;
                    posl := posl + 1;
                until (posl > length(texto)) or
                              not (texto[posl] in MAIUSCULAS);

                if (not (posl > length(texto))) and
                              (texto[posl] in MINUSCULAS) then
                   s := s + '~';
            end;
    end;

{--------------------------------------------------------}

    procedure convPonto;
    begin
       if txtIngles then
          s := s + PONTOINU
       else
          s := s + PONTOBRL;
       posl := posl + 1;
    end;

{--------------------------------------------------------}

    procedure convAspas (c: char);
    begin
       if txtIngles then
          begin
             if c = #$93 then abre_aspas_inu := true
             else
             if c = #$94 then abre_aspas_inu := false;

             if abre_aspas_inu then
                begin
                   s := s + ABREASPASINU;
                   abre_aspas_inu := false;
                end
             else
                begin
                   s := s + FECHAASPASINU;
                   abre_aspas_inu := true;
                end;
          end
       else
          s := s + ABREASPASBRLU;

       posl := posl + 1;
    end;

{--------------------------------------------------------}

    procedure convCarac;
    begin
        case texto [posl] of
            '_': if txtIngles then
                     s := s + GRIFOINGLES
                 else
                     s := s + GRIFOBRU;

            '?': if txtIngles then
                    s := s + '"'
                 else
                    s := s + '?';

            '*': if txtIngles then
                    s := s + '{'
                 else
                    s := s + '*';

            '²':  s := s + ELEV_2_U;
            '³':  s := s + ELEV_3_U;
            '¹':  s := s + ELEV_1_U;
            '%': s := s + PERCENTBRL;
            '‰': s := s + PERCENROMILBRU;
            '§': s := s + PARAGRAFO;
            '•': S := S + BOLABRU;
            '»','«': s := s + ASPASANGBRU;
//            '~': s := s + '\';
            '/': if txtIngles then
                    s := s + 'ì'
                 else
                    s := s + BARRABRU;
            '€': s := s + EUROBRU;
            '(': begin
                     abriuParentLiterario := true;
                     if txtIngles then
                         s := s + '='
                     else
                         s := s + ABREPARENTU;
                end;
            ')': begin
                     abriuParentLiterario := false;
                     if txtIngles then
                        s := s + '='
                     else
                        s := s + FECHAPARENTU;
                 end;

            '[': s := s + ABRECOLCHU;
            ']': s := s + FECHACOLCHU;
            '—': s := s + TRAVESSAOU;
            '‘','’': s := s + ASPASVARIADASU;
            '…': s := s + RETICENCIASU;
            '#': s := s + SINALNUMERO;
            '\': s := s + RAIZU;
            '­','–': s := s + TRAVESSAOU;
            'œ': s := s + 'oe';
            'æ': s := s + 'ae';
            '¼': s := s + UMQUARTOU;
            '½': s := s + UMMEIOU;
            '¾': s := s + TRESQUARTOSU;
            'ß': s := s + BETAU;
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

            '^':  s := s + 'å';
            '(':  s := s + 'ê';
            ')':  s := s + 'ã';
            '[':  s := s + 'á';
            ']':  s := s + 'ú';
            '{':  s := s + '~l';
            '}':  s := s + '_,';
            '-':  s := s + '-';
            '_':  s := s + '~÷';
            '/',
            ':':  s := s + '÷';
            '÷':  s := s + '~÷';
            'e',
            'E':  s := s + EUROBRU;
            '%':  s := s + PERCENROMILBRU;
            '*',
            'X',
            'x':  s := s + '×';
            '=':  s := s + '=';
            '+':  s := s + '+';
            '''': s := s + 'ü';
            '"':  s := s + 'üü';
            '.':  s := s + '.';
            'o',
            'O': s := s + '°';
        end;
        posl := posl + 1;
    end;

{--------------------------------------------------------}

procedure abreParentMatem;
var term: char;
    n: integer;
    restoCadeia: string;
begin
    abriuParentLiterario := false;   // por garantia
    term := ')';
    if texto [posl] = '[' then term := ']';

    restoCadeia := copy (texto, posl+1, 999);
    n := pos (term, restoCadeia);
    if (n > 1) and (restoCadeia[n-1] in ['0'..'9']) then   // codifica como matemático
        begin
            if texto [posl] = '(' then s := s + 'ê'
            else
            if texto [posl] = '[' then s := s + 'á';

            posl := posl + 1;
        end
    else
        begin
            abriuParentLiterario := true;   // por garantia
            convCarac;    // senão codifica como literário
        end;
end;

{--------------------------------------------------------}

procedure fechaParentMatem;
begin
    case texto [posl] of
        ')':  s := s + 'ã';
        ']':  s := s + 'ú';
    end;
    posl := posl + 1;
    abriuParentLiterario := false;   // por garantia
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

            if (texto[posl] in MAIUSCULAS) and
               (texto[posl] <> '×') and (texto[posl] <> 'ß') then
                convPalavraMaiusc
            else

            if (texto[posl] in ['0'..'9']) then
                convNumero
            else

            if (posl < length(texto)) and
               (texto[posl] in ['(', '[']) and (texto[posl+1] in ['0'..'9']) then
                    abreParentMatem
            else

            if (not abriuParentLiterario) and (posl > 1) and
               (texto[posl] in [')', ']']) and (texto[posl-1] in ['0'..'9']) then
                    fechaParentMatem
            else

            if (posl < length(texto)) and
               (texto[posl] = '`') and (texto[posl+1] in ['0'..'9']) then
                    trataFracao
            else

            if (posl < length(texto)) and
               (texto[posl] = '`') and
               (texto[posl+1] in ['.','-','+','o','O','*',
                                  '(', ')', '[', ']', '{', '}',
                                  '/', '÷', 'e','E', '%','X','x',':',
                                  '_', '''','"', '`','=', '^']) then
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

    brailleUnificado := s;
end;

end.

