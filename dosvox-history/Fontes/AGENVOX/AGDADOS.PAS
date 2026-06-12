{--------------------------------------------------------}
{                    variaveis globais
{--------------------------------------------------------}

unit agdados;
interface

type
    PLISTA = ^LISTA;

    LISTA = record
        diaComprom, mesComprom, anoComprom,
        horaComprom, minComprom: integer;
        textoComprom: string;
        marcaComprom: char;
        prox, ant: PLISTA;
    end;

var
    dia, mes, ano, diaSemana: word;
    hora, minuto: word;
    fim: boolean;

    primeiro: PLISTA;
    ultimo: LISTA;
    arqAgenda: text;

implementation
end.