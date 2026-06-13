unit dvHora;
interface

function diaDaSemana (dia, mes, ano: word): word;
function diaPorExtenso(dia, mes, ano: word): string;
procedure falaDiaQualquer (dia, mes, ano: word);
procedure falaDia;

procedure falahoraQualquer (hora, minuto: word);
procedure falaHora;

implementation

uses dvWin, dvCrt, sysUtils, dvlenum;

const
    nomeDia: array [0..6] of string[10] =
       ('Domingo', 'Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado');

    nomeMes: array [1..12] of string[10] =
       ('Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');


{--------------------------------------------------------}
{                descobre dia da semana
{--------------------------------------------------------}

function diaDaSemana (dia, mes, ano: word): word;
begin
    diaDaSemana := dayOfWeek (encodeDate (ano, mes, dia)) - 1;
end;

{--------------------------------------------------------}
{                  poe dia por extenso
{--------------------------------------------------------}

function diaPorExtenso (dia, mes, ano: word): string;
begin
    diaPorExtenso := nomeDia[diaDaSemana (dia, mes, ano)] +
        ', ' + numeroParaString (dia) +
        ' de ' + nomeMes[mes] + ' de ' + numeroParaString (ano);
end;

{--------------------------------------------------------}
{                    fala o dia
{--------------------------------------------------------}

procedure falaDiaQualquer (dia, mes, ano: word);
var diaSemana: word;

begin
    diaSemana := diaDaSemana (dia, mes, ano);
    sintSom ('_' + nomedia [diaSemana]);

    if dia = 1 then  sintSom ('_primeir')
               else  falaNumeroConv (numeroParaString (dia), MASCULINO);

    sintSom ('_de');
    sintSom ('_' + copy (nomeMes[mes], 1, 7));

    sintSom ('_de');

    falaNumeroConv (numeroParaString (ano ), MASCULINO);
end;

{--------------------------------------------------------}
{                 fala uma hora qualquer
{--------------------------------------------------------}

procedure falaHoraQualquer (hora, minuto: word);
begin
    falaNumeroConv (numeroParaString (hora), FEMININO);
    if sintFalarTudo or (minuto = 0) then
        begin
            if hora > 1 then
                sintSom ('_horas')
            else
                sintSom ('_hora');
        end
    else
        sintSom('_EHORA'); {'e'}
//        sintSom('_58'); {':'}

    if minuto <> 0 then
        begin
            falaNumeroConv (numeroParaString (minuto), MASCULINO);
            if sintFalarTudo then
                if minuto > 1 then
                    sintSom ('_minutos')
                else
                    sintSom ('_minuto');
        end;
end;

{--------------------------------------------------------}
{                 fala uma hora atual
{--------------------------------------------------------}

procedure falaHora;
var
    hora, minuto, segundo, cent: word;
begin
    dvcrt.gettime (hora, minuto, segundo, cent);
    falaHoraQualquer (hora, minuto);
end;

{--------------------------------------------------------}
{                 fala o dia de hoje
{--------------------------------------------------------}

procedure falaDia;
var
    diaSemana, dia, mes, ano: word;
begin
    getDate (ano, mes, dia, diaSemana);
    falaDiaQualquer (dia, mes, ano);
end;

end.
