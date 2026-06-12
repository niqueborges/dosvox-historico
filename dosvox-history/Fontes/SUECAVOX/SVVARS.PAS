{--------------------------------------------------------}
{    Programa SuecaVox
{    Variáveis globais
{--------------------------------------------------------}

unit svVars;
interface

(* estruturas *)
type
   naipe = (NULL, paus, ouros, copas, espadas);
   letra = (NULO, dois, tres, quatro, cinco, seis, dama, valete, rei, sete, ace);

   carta = record
            vnaipe: naipe;
            vletra: letra;
            vvalor: 0..11;
            bmp: integer;
            usada: boolean;
         end;

   situacao = record
               corte:array [0..3] of naipe;
               ttrunfo: boolean;
            end;

   jogadores = record
               nomeJogadores: string[15];
               escolhido    : boolean;
               som          : string[12];
             end;

   pessoa = record
            nome  : jogadores;
            cartas: array [0..9] of carta;
         end;

   mesa = record
          cartasJogada: array[0..3] of carta;
        end;

    (*********** controle de tela **************)

    coordenadas = record
                  X: real;
                  Y: real;
               end;

    (******************************************)

const
    MAXJOGADORES = 16;

var  jogador         : array [0..3]  of pessoa;
     vbaralho        : array [0..39] of carta;
     mesa_de_cartas  : array [0..9]  of mesa;
     participante    : array [0..3]  of situacao;
     nomeparticipante: array [0..MAXJOGADORES-1]  of jogadores;
     trunfo: carta;
     pontos1, pontos2, escore1, escore2: integer;
     renuncia: boolean;
     comEfeitos: boolean;

     (********** controle de tela ************)

      Tela: coordenadas;

     (***************************************)

implementation
end.
