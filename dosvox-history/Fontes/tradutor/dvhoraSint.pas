unit dvHora;
interface

function diaDaSemana (dia, mes, ano: word): word;
function diaPorExtenso(dia, mes, ano: word): string;
procedure falaDiaQualquer (dia, mes, ano: word);
procedure falaDia;

function horaPorExtenso(hora, minuto: word): string;
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
begin
    sintetiza (diaPorExtenso (dia, mes, ano));
end;

{--------------------------------------------------------}
{                  poe hora por extenso
{--------------------------------------------------------}

function horaPorExtenso (hora, minuto: word): string;
var h: string;
begin
    h := numeroParaString (hora);
    if copy (h, length(h)-1, 2) = 'um' then
        h := h + 'a'
    else
    if copy (h, length(h)-3, 4) = 'dois' then
        begin
             delete (h, length(h)-3, 4);
             h := h + 'duas';
        end;

    if (h = 'zero') or (h = 'uma') then
        h := h + ' hora'
    else
        h := h + ' horas';

    if minuto <> 0 then
       h := h + ' e ';

    if minuto = 1 then
       h := h + 'um minuto'
    else
       h := h + numeroParaString (minuto) + ' minutos';

    result := h;
end;

{--------------------------------------------------------}
{                 fala uma hora qualquer
{--------------------------------------------------------}

procedure falaHoraQualquer (hora, minuto: word);
begin
    sintetiza (horaPorExtenso (hora, minuto));
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
