{-------------------------------------------------------------------}
{
{    CHESSVOX - Programa de Xadrez Vox
{
{    Módulo de definições globais
{
{    Autor: José Antonio Borges
{
{    Adaptação para o DOSVOX do TSCP
{         Tom Kerrigan's Simple Chess Program (TSCP)
{         Copyright 1997 Tom Kerrigan
{
{    Em setembro/2007
{
{-------------------------------------------------------------------}

unit defs;

interface

const
    version = 'v1.0';

    GEN_STACK  = 1120;
    MAX_PLY    = 32;
    HIST_STACK = 400;

    LIGHT  = 0;
    DARK   = 1;

    PAWN   = 0;
    KNIGHT = 1;
    BISHOP = 2;
    ROOK   = 3;
    QUEEN  = 4;
    KING   = 5;

    EMPTY  = 6;

{ useful squares }

    A1 = 56;
    B1 = 57;
    C1 = 58;
    D1 = 59;
    E1 = 60;
    F1 = 61;
    G1 = 62;
    H1 = 63;

    A8 = 0;
    B8 = 1;
    C8 = 2;
    D8 = 3;
    E8 = 4;
    F8 = 5;
    G8 = 6;
    H8 = 7;

(* This is the basic description of a move. promote is what
   piece to promote the pawn to, if the move is a pawn
   promotion. bits is a bitfield that describes the move,
   with the following bits:

   1	capture
   2	castle
   4	en passant capture
   8	pushing a pawn 2 squares
   16	pawn move
   32	promote

   It's union'ed with an integer so two moves can easily
   be compared with each other. *)

type
    move_bytes = record
	from: byte;
	to_: byte;
	promote: byte;
	bits: byte;
    end;

type
    move = record
        case boolean of
            false: (b: move_bytes);
            true:  (u: integer);
    end;

(* an element of the move stack. it's just a move with a
   score, so it can be sorted by the search functions. *)

type
    gen_t = record
        m: move;
        score: integer;
    end;

(* an element of the history stack, with the information
   necessary to take a move back. *)

type
    hist_t = record
	m: move;
	capture: integer;
        castle: integer;
	ep: integer;
	fifty: integer;
	hash: integer;
    end;

function ROW(x: integer): integer;
function COL(x: integer): integer;

implementation

function ROW(x: integer): integer;
begin
    ROW := x shr 3;
end;

function COL(x: integer): integer;
begin
    COL := x and 7;
end;

end.
