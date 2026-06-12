{-----------------------------------------------------------------}
{ Converte número para extenso                                    }
{ Opcionalmente para  Reais, Dólares e Euros                      }
{ Baseada na rotina produzida pela InfusTec                       }
{ https://showdelphi.com.br                                       }
{ Em maio/2020                                                    }
{-----------------------------------------------------------------}

unit numExtenso;

interface
uses sysUtils;

function Extenso(Valor: Extended; Moeda: Boolean; Tipo: Integer): String;

implementation

function Extenso(Valor: Extended; Moeda: Boolean; Tipo: Integer): String;
var
  Centavos, Centena, Milhar, Milhao, Bilhao, Texto : string;
const
    Unidades: array [1..9] of string =
      ('um', 'dois', 'três','quatro', 'cinco', 'seis', 'sete', 'oito', 'nove');
    Dez     : array [1..9] of string =
      ('onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete',
       'dezoito', 'dezenove');
    Dezenas : array [1..9] of string =
      ('dez', 'vinte', 'trinta', 'quarenta', 'cinqüenta', 'sessenta', 'setenta',
       'oitenta', 'noventa');
    Centenas: array [1..9] of string =
      ('cento', 'duzentos', 'trezentos', 'quatrocentos', 'quinhentos',
      'seiscentos', 'setecentos', 'oitocentos', 'novecentos');

const
    nomeMoeda: array [0..2, 0..4] of string[11] = (
        (' de reais', ' real', ' reais', ' centavo', ' centavos'),
        (' de dólares', ' dólar', ' dólares', ' cent', ' cents'),
        (' de euros', ' euro', ' euros', ' centavo', ' centavos'));


    function ifs( Expressao: Boolean; CasoVerdadeiro, CasoFalso:String): String;
    begin
        if Expressao then
            Result := CasoVerdadeiro
        else
            Result :=CasoFalso;
    end;

  function MiniExtenso( Valor: ShortString ): string;
  var
      Unidade, Dezena, Centena: String;
  begin
        if (Valor[2] = '1') and (Valor[3] <> '0') then
            begin
                Unidade := Dez[StrToInt(Valor[3])];
                Dezena := '';
            end
        else
            begin
                if Valor[2] <> '0' then
                    Dezena := Dezenas[StrToInt(Valor[2])];
                if Valor[3] <> '0' then
                   unidade := Unidades[StrToInt(Valor[3])];
            end;

        if (Valor[1] = '1') and (Unidade = '') and (Dezena = '') then
            centena := 'cem'
        else
            if Valor[1] <> '0' then
                Centena := Centenas[StrToInt(Valor[1])]
            else
                Centena := '';

        Result := Centena + ifs( (Centena <> '') and ((Dezena <> '') or
            (Unidade <> '')),' e ', '') + Dezena + ifs( (Dezena <> '') and
            (Unidade <> ''), ' e ','') + Unidade;
  end;

begin
    if Valor = 0 then
        begin
            if Moeda then
                Result := ''
            else
                Result := 'zero';
            Exit;
        end;

    Texto := FormatFloat( '000000000000.00', Valor );
    Centavos := MiniExtenso( '0' + Copy( Texto, 14, 2 ) );
    Centena  := MiniExtenso( Copy( Texto, 10, 3 ) );
    Milhar   := MiniExtenso( Copy( Texto,  7, 3 ) );

    if Milhar <> '' then
        Milhar := Milhar + ' mil';

    Milhao   := MiniExtenso( Copy( Texto,  4, 3 ) );

    if Milhao <> '' then
        begin
            Milhao := Milhao
               + ifs( Copy( Texto, 4, 3 ) = '001', ' milhão', ' milhões');
        end;

    Bilhao   := MiniExtenso( Copy( Texto,  1, 3 ) );

    if Bilhao <> '' then
        begin
            Bilhao := Bilhao + ifs( Copy( Texto, 1, 3 ) = '001', ' bilhão',
            ' bilhões');
        end;

  Result := Bilhao +
      ifs( (Bilhao <> '') and (Milhao + Milhar + Centena <> ''),
      ifs((Pos(' e ', Bilhao) > 0) or
         (Pos( ' e ', Milhao + Milhar + Centena ) > 0), ', ', ' e '), '') +
         Milhao + ifs( (Milhao <> '') and (Milhar + Centena <> ''),
      ifs((Pos(' e ', Milhao) > 0) or
         (Pos( ' e ', Milhar + Centena ) > 0 ),', ',    ' e '), '') +
         Milhar + ifs( (Milhar <> '') and
        (Centena <> ''), ifs(Pos( ' e ', Centena ) > 0, ', ', ' e '),'') +
        Centena;

    if Moeda then
      begin
        if (Bilhao <> '') and (Milhao + Milhar + Centena = '') then
            Result := Bilhao + nomeMoeda[tipo, 0]
        else

        if (Milhao <> '') and (Milhar + Centena = '') then
            Result := Milhao + nomeMoeda[tipo, 0]
        else
            Result := Bilhao + ifs( (Bilhao <> '') and (Milhao + Milhar +
                Centena <> ''), ifs((Pos(' e ', Bilhao) > 0) or (Pos( ' e ',
                Milhao +Milhar + Centena ) > 0), ', ', ' e '), '') + Milhao +
                ifs((Milhao <> '') and (Milhar + Centena <> ''), ifs((Pos(' e ',
                Milhao) > 0) or (Pos( ' e ', Milhar + Centena ) > 0 ),', ',
                ' e '), '') + Milhar + ifs( (Milhar <> '') and (Centena <> ''),
                ifs(Pos( ' e ', Centena ) > 0, ', ', ' e '),'') + Centena +
                ifs( Int(Valor) = 1, nomeMoeda[tipo, 1], nomeMoeda[tipo, 2]);

        if Centavos <> '' then
            begin
                if Valor > 1 then
                      Result := Result + ' e ' + Centavos +
                          ifs( Copy(Texto, 14, 2 )= '01',
                               nomeMoeda[tipo, 3], nomeMoeda[tipo, 4] )
                else
                      Result := Centavos +
                          ifs( Copy( Texto, 14, 2 )= '01',
                               nomeMoeda[tipo, 3], nomeMoeda[tipo, 4] );
            end;
      end;

    if (pos ('um mil', Result) = 1) and (pos ('um milh', Result) <> 1) then
        delete (Result, 1, 3);
end;

end.
