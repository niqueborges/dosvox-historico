unit pptvars;

interface
uses pptObject, graphics, classes, MPlayer;
{
     cima = 38;
      baixo = 40;
      direita = 39;
      esquerda = 37;
      Tend = 35;
      home = 36;
      pageup = 33;
      pageDown = 34;
      insert = 45;
      delete = 46;
      space = 32;
 }
type
   config = record
      debug: boolean;
      titulo: TFonte;
      tituloCorFundo: PChar;
      tituloFundo: TFundo;
      topico: TFonte;
      topicoFundo: TFundo;
      topicoMargem: TMargem;
      subTopico: TFonte;
      marcador: string [1];
      subtopicoFundo: TFundo;
      subtopicoMargem: TMargem;
   end;

   contadores = record
      count: integer;
      indice: integer;
   end;

var
   BitMap: TBitmap;
   apresent: VTela;
   cont: Contadores;

   arq1: string;
   arq2: string;

   temp: config;
   dirPPTVOX: string;

implementation

end.
