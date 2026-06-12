{--------------------------------------------------------}
{
{    Rotinas de controle de soletração Braille
{
{    Autor: Patrick Barboza
{
{    Em 17/05/2023
{
{    Alterações: 19/05/2023, 20/05/2023, 24/05/2023
{       25/05/2023
{
{--------------------------------------------------------}

unit edBraille;

interface

uses dvCrt, dvWin, edVars, edMensag;

procedure trocaModoSoletrar;
procedure soletraPontosBraille(c: char; modo: integer);

const
    SOLETRABRAILLE = 1;         { Soletração braille Unificado }
    SOLETRAAMERICANBRAILLE = 2; { Soletrando american Braille code }
    SOLETRANORMAL = 3;          { Soletração padrão }

var
    modoSoletrar: integer = 0;  { 0 - normal; 1 - Braille unificado; 2 - American Braille Code. }

implementation

{--------------------------------------------------------}

const
    { Patrick. Tabela transcrita do BRAILEX.AMB }
    tabCaracAMBCode : array[#$20..#$7F] of string[6]=(
        { } '0',
        {!} '2346',
        {"} '5',
        {#} '3456',
        {cifrão} '1246',
        {%} '146',
        {&} '12346',
        {'} '3',
        {(} '12356',
        {)} '23456',
        {*} '16',
        {+} '346',
        {,} '6',
        {-} '36',
        {.} '46',
        {/} '34',
        {0} '356',
        {1} '2',
        {2} '23',
        {3} '25',
        {4} '256',
        {5} '26',
        {6} '235',
        {7} '2346',
        {8} '236',
        {9} '35',
        {:} '156',
        {;} '56',
        {<} '126',
        {=} '123456',
        {>} '345',
        {?} '1456',
        {@} '4',
        {A} '1',
        {B} '12',
        {C} '14',
        {D} '145',
        {E} '15',
        {F} '124',
        {G} '1245',
        {H} '125',
        {I} '24',
        {J} '245',
        {K} '13',
        {L} '123',
        {M} '134',
        {N} '1345',
        {O} '135',
        {P} '1234',
        {Q} '12345',
        {R} '1235',
        {S} '234',
        {T} '2345',
        {U} '136',
        {V} '1236',
        {W} '2456',
        {X} '1346',
        {Y} '13456',
        {Z} '1356',
        {[} '246',
        {\} '1256',
        {]} '12456',
        {^} '45',
        {_} '456',
        {`} '4',
        {a} '1',
        {b} '12',
        {c} '14',
        {d} '145',
        {e} '15',
        {f} '124',
        {g} '1245',
        {h} '125',
        {i} '24',
        {j} '245',
        {k} '13',
        {l} '123',
        {m} '134',
        {n} '1345',
        {o} '135',
        {p} '1234',
        {q} '12345',
        {r} '1235',
        {s} '234',
        {t} '2345',
        {u} '136',
        {v} '1236',
        {w} '2456',
        {x} '1346',
        {y} '113456',
        {z} '1356',
        {abre chave} '246',
        {|} '1256',
        {fecha chave} '12456',
        {~} '45',
        {} '123456'
    );

    { Patrick. Tabela Braille Unificado }
    tabCaracBrUnif : array[#$20..#$FF] of string[10] = (
        { }  '0',
        {!} '235',
        {"} '236',
        {#} '3456',
      {cif} '56',
        {%} '456 356',
        {&} '12346',
        {'} '3',
        {(} '126 3',
        {)} '6 345',
        {*} '35',
        {+} '235',
        {,} '2',
        {-} '36',
        {.} '3',
        {/} '6 5',
        {0} '3456 245',
        {1} '3456 1',
        {2} '3456 12',
        {3} '3456 14',
        {4} '3456 145',
        {5} '3456 15',
        {6} '3456 124',
        {7} '3456 1245',
        {8} '3456 125',
        {9} '3456 24',
        {:} '25',
        {;} '23',
        {<} '246',
        {=} '2356',
        {>} '135',
        {?} '26',
        {@} '156',
        {A} '1',
        {B} '12',
        {C} '14',
        {D} '145',
        {E} '15',
        {F} '124',
        {G} '1245',
        {H} '125',
        {I} '24',
        {J} '245',
        {K} '13',
        {L} '123',
        {M} '134',
        {N} '1345',
        {O} '135',
        {P} '1234',
        {Q} '12345',
        {R} '1235',
        {S} '234',
        {T} '2345',
        {U} '136',
        {V} '1236',
        {W} '2456',
        {X} '1346',
        {Y} '13456',
        {Z} '1356',
        {[} '12356 3',
        {\} '5 3',
        {]} '6 23456',
        {^} '4',
        {_} '456',
        {`} '6',
        {a} '1',
        {b} '12',
        {c} '14',
        {d} '145',
        {e} '15',
        {f} '124',
        {g} '1245',
        {h} '125',
        {i} '24',
        {j} '245',
        {k} '13',
        {l} '123',
        {m} '134',
        {n} '1345',
        {o} '135',
        {p} '1234',
        {q} '12345',
        {r} '1235',
        {s} '234',
        {t} '2345',
        {u} '136',
        {v} '1236',
        {w} '2456',
        {x} '1346',
        {y} '13456',
        {z} '1356',
      {chv} '5 123',
        {|} '456',
      {fcv} '456 2',
        {~} '5',
        {} '123456',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {não usamos} '0',
        {parágrafo} '234 234',
        {trema} '0',
        {copyright} '0',
        {ordinal feminino} '1',
        {abre-aspas literário} '6 236',
        {negação lógica} '0',
        {soft hyphen} '0',
        {registrado} '0',
        {overscore} '0',
        {grau} '356',
        {mais ou menos} '0',
        {superscrito 2} '16 # 12',
        {superscrito 3} '16 #14',
        {acento agudo} '35',
        {micro} '134', //M maiúscula
        {parágrafo} '5 346', //Outro código para parágrafo
        {middle dot} '0',
        {cedilha} '0',
        {superscrito 1} '16 #1',
        {ordinal masculino} '135',
        {fecha-aspas  literário} '6 236',
        {1 quarto} '# 2 145',
        {1 meio} '# 2 12',
        {3 quartos} '# 25 145',
        {interrogação invertida} '26', //Igual a interrogação convencional
        {À} '1246',
        {Á} '12356',
        {Â} '16',
        {Ã} '345',
        {Ä} '345',
        {Å} '16',
        {não usamos} '0',
        {Ç} '12346',
        {È} '2346',
        {É} '123456',
        {Ê} '126',
        {Ë} '0',
        {Ì} '146',
        {Í} '34',
        {Î} '0',
        {Ï} '0',
        {não usamos} '0',
        {Ñ não usamos} '12456',
        {Ò} '2456',
        {Ó} '346',
        {Ô} '1456',
        {Õ} '246',
        {Ö} '246',
        {× multiplicação} '236',
        {Ø vazio} '0',
        {Ù} '0',
        {Ú} '23456',
        {Û} '0',
        {Ü} '1246',
        {Ý} '0',
        {Þ não usamos} '0',
        {ß não usamos} '0',
        {à} '1246',
        {á} '12356',
        {â} '16',
        {ã} '345',
        {ä} '345',
        {å} '16',
        {æ não usamos} '0',
        {ç} '12346',
        {è} '2346',
        {é} '123456',
        {ê} '126',
        {ë} '0',
        {ì} '146',
        {í} '34',
        {î} '0',
        {ï não usamos} '0',
        {ð não usamos} '0',
        {ñ não usamos} '12456',
        {ò} '2456',
        {ó} '346',
        {ô} '1456',
        {õ} '246',
        {ö} '246',
        {÷ divisão} '256',
        {ø não usamos} '0',
        {ù} '0',
        {ú} '23456',
        {û} '0',
        {ü} '1256',
        {ý não usamos} '0',
        {þ não usamos} '0',
        {ÿ não usamos} '0'
    );

var
    soletrarMaiusculaBraille: boolean;
    pausaEntreCelBraille: integer;

{--------------------------------------------------------}

procedure soletraPontosBraille(c: char; modo: integer);

    procedure soletraPontosBraille (s: string);
    begin
        while pos(' ', s) <> 0 do
            begin
                sintSoletra (copy(s, 1, pos(' ', s)-1));
                delete (s, 1, pos(' ', s));
                if length(s) > 0 then delay (pausaEntreCelBraille);
            end;
        sintSoletra (s);
    end;

    function estaEmMaiusculo (c: char): boolean;
    begin
        result := (c = upcase(c)) and
                (not(c in ['0' .. '9', 'á'.. 'ú', 'à' .. 'ù', 'ã' .. 'õ', 'â' .. 'û', 'ç',
                        '.', ',', ':', ';', '?', '!', '/','\', '|', '''', '"','@', '#', '$',
                        '%', '&', '*', '(', ')', '_', '-', '+', '=', '[', ']', '{', '}']));
    end;

begin
    if c = ' ' then sintCarac(' ')
    else
        begin
            if soletrarMaiusculaBraille and  estaEmMaiusculo(c) then
                begin
                    sintSoletra ('46');
                    delay (pausaEntreCelBraille);
                end;

            if modo = 1 then
                soletraPontosBraille (tabCaracBrUnif[c])
            else { modo = 2}
                begin
                    if (c < #$20) or (c > #$7F) then
                        begin
                        sintClek;
                        sintClek;
                    end
                    else
                        soletraPontosBraille (tabCaracAMBCode[c]);
                end;
        end;
end;

{--------------------------------------------------------}

procedure trocaModoSoletrar;
begin
    modoSoletrar := (modoSoletrar + 1) mod 3;
    case modoSoletrar of
        0: fala ('EDSOLNOR');  {'Soletração normal'}
        1: fala ('EDSOLBRL');  {'Soletração braille'}
        2: fala ('EDSOLAMB');  {'Soletração American Braille Code'}
    end;
end;

{--------------------------------------------------------}

var erro: integer;
begin
    soletrarMaiusculaBraille := upcase(sintAmbiente ('EDIVOX', 'SOLETRARMAIUSCULABRAILLE', 'NAO')[1]) = 'S';
    val (sintAmbiente ('EDIVOX', 'PAUSAENTRECELBRAILLE', '200'), pausaEntreCelBraille, erro);
    if erro <> 0 then pausaEntreCelBraille := 200;
end.
