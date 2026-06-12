unit webtela;

interface

type
   STela = record
      x,
      y: integer;
   end;

   PTela = ^STela;
   VTela = array [0..5000] of PTela;

(*
   TTela = class
   private
      Tela:         VTela;    {Vetor que quarda todas as posicoes}
      Vtopo:        integer;
      Vfundo:       integer;
      Vquant:       integer;
      VposAtual:    integer;
      VposAnterior: integer;
   public
      property topo: integer read VTopo;
      property fundo: integer read VFundo;
      property posAtual: integer read VPosAtual;
      property posAnterior: integer read VPosAnterior;
      constructor create (t,f: integer);
      procedure adicionarPos (x,y: integer);
      procedure atualizaTela (i: integer);
      destructor destroy;
   end;
*)
implementation

end.
