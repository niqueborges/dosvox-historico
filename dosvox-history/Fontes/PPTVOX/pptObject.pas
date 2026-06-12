unit pptObject;

interface

uses Windows, Graphics, SysUtils,classes,mplayer, controls;

type
   TMargem = (MC, ME, MD);
   TFundo = (OPACO, TRANSPARENTE);
   PSubTopico = ^string;
   VSubTopicos = array [1..20] of PSubTopico;

   TPosImagem = record
      Topo,
      Esquerda,
      Direita,
      Fundo: boolean;
   end;

   TAplicativo = record
      aplicativo: string;
      parametro: string;
   end;

   Tfonte = record
      Nome: string;
      tamanho: integer;
      italico: boolean;
      negrito: boolean;
      sublinhado: boolean;
      cor: PChar;
   end;

   TPosicao = record
      x,
      y: integer;
   end;

   TSubTopico = object
   private
      frase: TBitmap;
      tela: TCanvas;
      nome: VsubTopicos;
      quantidade: integer;
      indice: integer;
      font: TFonte;
      deltax,
      deltay: integer;
      TopicoHeight: integer;
      naoCoube: boolean;
      procedure desenhaUmSubTopico (i: integer);
      procedure alteraFonte (f: TFonte);
   public
      pos: TPosicao;
      debug: boolean;
      msg: TStrings;
      margem: TMargem;
      caracMarc: string [1];
      ModoFundo: TFundo;
      constructor create (bitmap: TCanvas; dx, dy: integer);
      property fonte: TFonte read font write alteraFonte;
      property quant: integer read quantidade default 0;
      property posAtual: integer read indice default 0;
      procedure inserirSubTopico (s: string);
      function subTopico (i: integer): string;
      function subTopicoAtual: string;
      procedure avancaUmSubTopico;
      procedure recuaUmSubTopico;
      procedure desenharSubTopicos;
      destructor destroy;
   end;

   TTopico = object
   private
   public
      nome: string;
      subTopico: TSubTopico;
      programa: String;
      constructor create (bitMap: TCanvas; dx, dy: integer);
      destructor destroy;
   end;

   PTopico = ^TTopico;
   VTopico = array [1..15] of PTopico;

   TTitulo = object
   private
      bmap: TBitMap;
      dx,
      dy: integer;
      cor: PChar;
      font: TFonte;
      procedure alteraFonte (f: TFonte);
      procedure alteraCor (c: PChar);
      procedure pintaTitulo;
   public
      nome: string;
      ModoFundo: TFundo;
      property corFundo: PChar read cor write alteracor;
      property fonte: TFonte read font write alteraFonte;
      constructor create (deltax: integer);
      destructor destroy;
   end;

   TTela = object
   private
      frase: TBitmap;
      bitMap: TCanvas;
      deltax,
      deltay: integer;
      quantidade: integer;
      indice: integer;
      font: TFonte;
      BitMapFundo: TBitMap;
      BmpFundo: PChar;
      db: boolean;
      naoCoube: boolean;
      smidia: string;
      procedure insereBitMap (s: PChar);
      procedure alteraFonte (f: TFonte);
      procedure desenhaUmTopico (i: integer);
      procedure dbug (b: boolean);
      procedure alteraMidia (s: string);
      procedure pintarFundo;
      procedure pintaTitulo;
   public
      Titulo: TTitulo;
      pos: TPosicao;
      msg: TStrings;
      Topicos: VTopico;
      margem: TMargem;
      ModoFundo: TFundo;
      posImagem: TPosImagem;
      property debug: boolean read db write dbug;
      property fonte: TFonte read font write alteraFonte;
      property quant: integer read quantidade default 0;
      property fundo: PChar read bmpFundo write insereBitMap;
      property Media: string read smidia write alteraMidia;
      property posAtual: integer read indice default 0;
      constructor create (canvas: TCanvas; dx, dy: integer);
      procedure novoTopico (s: string);
      function Topico (i: integer): string;
      function TopicoAtual: string;
      procedure avancaUmTopico;
      procedure recuaUmTopico;
      procedure desenharTela;
      destructor destroy;
   end;

   PTela = ^TTela;
   VTela = array [1..100] of PTela;

function extraiCor (cor: PChar): TColor;

implementation

{-------------------------------------}
{                TTela                }
{-------------------------------------}
constructor TTela.create (canvas: TCanvas; dx, dy: integer);
begin
   frase := TBitMap.Create;
   frase.Canvas.LineTo (0,0);
   bitMapFundo := TbitMap.Create;
   bitMapFundo.Canvas.LineTo (0,0);
   pos.x := 0;
   pos.y := 0;
   BitMap := canvas;
   deltax := dx;
   deltay := dy;
   quantidade := 0;
   indice := 0;
   db := false;
   font.Nome := frase.Canvas.Font.Name;
   font.tamanho := frase.Canvas.Font.Size;
   msg := TStringList.Create;
   naoCoube:= false;
   margem := ME;
   smidia := '';
   Titulo.create (deltax);
   ModoFundo := TRANSPARENTE;
   posImagem.Topo := false;
   posImagem.Esquerda := false;
   posImagem.Direita := false;
   posImagem.Fundo := false;
   new (bmpFundo);
   bmpFundo := ' ';
end;

procedure TTela.dbug (b: boolean);
var
   i: integer;
begin
   db := b;
   for i := 1 to quantidade do
      Topicos [i]^.subTopico.debug := b;
end;

procedure TTela.insereBitMap (s: PChar);
begin
   if s = '' then
      begin
         bmpFundo := ' ';
         exit;
      end
   else
      begin
         try
{ Antônio Borges
Não esta fazendo esse tratamento de exceção
se a figura s não existir dá erro}
            BitMapFundo.LoadFromFile (s);
         except
            msg.Add ('Imagem inexistente ' + s +'.');
            bmpFundo := ' ';
            exit;
         end;
         bmpFundo := s;
      end;
end;

procedure TTela.alteraFonte;
   {--------------------------------------}
   function ExtraiEstilo: TFontStyles;
   begin
      with font do
         begin
            if (negrito) and (italico) and (sublinhado) then
               result := [fsBold, fsItalic, fsUnderline]
            else if (negrito) and (italico) and not (sublinhado) then
               result := [fsBold, fsItalic]
            else if (negrito) and not (italico) and (sublinhado) then
               result := [fsBold, fsUnderline]
            else if not (negrito) and (italico) and (sublinhado) then
               result := [fsItalic, fsUnderline]
            else if (negrito) and not (italico) and not(sublinhado) then
               result := [fsBold]
            else if not (negrito) and (italico) and not (sublinhado) then
               result := [fsItalic]
            else if not (negrito) and not (italico) and (sublinhado) then
               result := [fsUnderline];
         end;
   end;
   {--------------------------------------}
begin
   font := f;
   frase.Canvas.Font.Name := font.Nome;
   frase.Canvas.Font.Size := font.tamanho;
   frase.Canvas.Font.Color := extraiCor (font.cor);
   frase.Canvas.Font.Style := ExtraiEstilo;
end;

procedure TTela.novoTopico (s: string);
begin
   if quantidade >= 15 then
      begin
         if db then
            msg.Add ('Foi extrapolado o limite de 15 topicos.');
         exit;
      end;

   quantidade := quantidade + 1;
   new (Topicos [quantidade]);
   Topicos [quantidade]^.nome := s;
   Topicos [quantidade]^.create (BitMap,deltax,deltay);
   Topicos [quantidade]^.subTopico.debug := db;
end;

procedure TTela.avancaUmTopico;
begin
   if indice <= quantidade then
      indice := indice + 1;
end;

procedure TTela.recuaUmTopico;
begin
   if indice > 0 then
      indice := indice - 1;
end;

procedure TTela.pintarFundo;
var
   xini, dx, yini, dy: integer;
begin
   if bmpFundo = ' ' then exit;

   with posImagem do
      begin
         if Topo and Esquerda and Direita and Fundo then
            begin
               xini := 0;
               yini := 0;
               dx := deltax;
               dy := deltaY;
            end
         else if not Topo and Esquerda and Direita and Fundo then
            begin
               yini := deltay - BitMapFundo.Height;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := deltax;
            end
         else if Topo and not Esquerda and Direita and Fundo then
            begin
               xini := deltax - BitMapFundo.Width;
               dx := BitMapFundo.Width;
               yini := 0;
               dy := deltay;
            end
         else if Topo and Esquerda and not Direita and Fundo then
            begin
               xini := 0;
               dx := BitMapFundo.Width;
               yini := 0;
               dy := deltay;
            end
         else if Topo and Esquerda and Direita and not Fundo then
            begin
               yini := 0;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := deltax;
            end
         else if not Topo and not Esquerda and Direita and Fundo then
            begin
               yini := deltay - BitMapFundo.Height;
               dy := BitMapFundo.Height;
               xini := deltax - BitMapFundo.Width;
               dx := BitMapFundo.Width;
            end
         else if not Topo and Esquerda and not Direita and Fundo then
            begin
               yini := deltay - BitMapFundo.Height;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := BitMapFundo.Width;
            end
         else if not Topo and Esquerda and Direita and not Fundo then
            begin
               yini := (deltay - BitMapFundo.Height) div 2;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := deltax;
            end
         else if Topo and not Esquerda and not Direita and Fundo then
            begin
               yini := 0;
               dy := deltay;
               xini := (deltax - BitMapFundo.Width) div 2;
               dx := BitMapFundo.Width;
            end
         else if Topo and not Esquerda and Direita and not Fundo then
            begin
               yini := 0;
               dy := BitMapFundo.Height;
               xini := deltax - BitMapFundo.Width;
               dx := BitMapFundo.Width;
            end
         else if Topo and Esquerda and not Direita and not Fundo then
            begin
               yini := 0;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := BitMapFundo.Width;
            end
         else if not Topo and not Esquerda and not Direita and Fundo then
            begin
               yini := deltay - BitMapFundo.Height;
               dy := BitMapFundo.Height;
               xini := (deltax - BitMapFundo.Width) div 2;
               dx := BitMapFundo.Width;
            end
         else if not Topo and not Esquerda and Direita and not Fundo then
            begin
               yini := (deltay - BitMapFundo.Height) div 2;
               dy := BitMapFundo.Height;
               xini := deltax - BitMapFundo.Width;
               dx := BitMapFundo.Width;
            end
         else if not Topo and Esquerda and not Direita and not Fundo then
            begin
               yini := (deltay - BitMapFundo.Height) div 2;
               dy := BitMapFundo.Height;
               xini := 0;
               dx := BitMapFundo.Width;
            end
         else if Topo and not Esquerda and not Direita and not Fundo then
            begin
               yini := 0;
               dy := BitMapFundo.Height;
               xini := (deltax - BitMapFundo.Width) div 2;
               dx := BitMapFundo.Width;
            end
         else
            begin
               xini := (deltax - BitMapFundo.Width) div 2;
               yini := (deltay - BitMapFundo.Height) div 2;
               dx := BitMapFundo.Width;
               dy := BitMapFundo.Height;
            end;
      end;

   stretchBlt (bitMap.Handle,xini,yini,dx,dy,BitMapFundo.Canvas.Handle,0,0,
               BitMapFundo.Width, BitMapFundo.Height,SRCCOPY);
end;

procedure TTela.desenhaUmTopico (i: integer);
   {------------------------------------}
var
   st: TStrings;

   procedure verificaDebug;
   var
      s,s1: string;
   begin
      if st.Count > 1 then
         begin
            str (st.Count, s);
            str (i, s1);
            msg.Add ('O Topico ' + s1 + ' extrapolou a tela, e foi dividido em ' + s + 'linhas.');
         end;
      if pos.y > deltay then
         msg.Add ('Não coube na tela, a ultima frase é: ' + Topicos [i]^.nome + '.');
   end;
   {------------------------------------}
   procedure pintaFrase;
   var
      tam, xquebra, xfrente: integer;
      s, s1,s2: string;
      l: integer;
   begin
      s1 := '';
      s2 := '';
      s := Topicos [i]^.nome;
      s := s + ' ';
      tam := length (s);
      xquebra := 1;
      xfrente := 0;

      frase.Width := 1;
      frase.Height := 1;

      for l := 1 to tam do
         begin
            xfrente := xfrente + 1;
            if s [l] = ' ' then
               begin
                  if (pos.x + frase.Canvas.TextWidth (s1)+ 30) > deltax then
                     begin
                        s2 := copy (s1,1,xquebra-1);
                        delete (s1,1,xquebra);
                        xfrente := xfrente - xquebra;
                        xquebra := 1;
                        st.Add (s2);
                     end
                  else
                     xquebra := xfrente;
               end;
            s1 := s1 + s [l];
         end;

      st.Add (s1);

      if st.count > 1 then
         frase.Width := deltax - pos.x
      else
         frase.width := frase.Canvas.TextWidth (Topicos [i]^.nome);

      tam := frase.Canvas.TextHeight (Topicos [i]^.nome);
      frase.Height :=st.Count*tam;

      xfrente := 0;
      for l := 0 to st.Count-1  do
         begin
            if margem = ME then
               xquebra := 0
            else if margem = MD then
               xquebra := frase.Width - frase.Canvas.TextWidth (st.Strings [l])
            else if margem = MC then
               xquebra := (frase.Width - frase.Canvas.TextWidth (st.Strings [l]) + frase.Canvas.TextWidth (' ')) div 2;

            frase.Canvas.TextOut (xquebra,xfrente, st.Strings [l]);
            xfrente := xfrente + tam;
         end;
   end;

begin
  if i > 1 then
     begin
       if Topicos [i-1]^.subTopico.quantidade = 0 then
          pos.y := pos.y + Topicos [i-1]^.subTopico.TopicoHeight
       else
          pos.y := Topicos [i-1]^.subTopico.pos.y;
     end;

   st := TStringList.Create;
   pintaFrase;

   if i > 1 then
      pos.y := pos.y + frase.Height + 10;

   Topicos [i]^.subTopico.TopicoHeight := frase.Height;

   Topicos [i]^.subTopico.pos.y := pos.y;

   Topicos [i]^.subTopico.desenharSubTopicos;

   if db then
      begin
         verificaDebug;
         if Topicos [i]^.subTopico.msg.Count <> 0 then
            msg.AddStrings (Topicos [i]^.subTopico.msg);
      end;

   st.free;
end;

procedure TTela.desenharTela;
var
   j: integer;
   f: DWORD;
begin
   pintarFundo;
   pintaTitulo;
   pos.y := 0;
   pos.y := Titulo.dy + 15;

   if ModoFundo = OPACO then
      f := SRCCOPY
   else
      f := SRCAND;

   for j := 1 to quantidade do
      begin
         desenhaUmTopico (j);
         if margem = MD then
            pos.x := deltax - frase.Width
         else if margem = MC then
            pos.x := (deltax - frase.Width) div 2;

         BitBlt (bitMap.Handle, pos.x, pos.y, frase.Width, frase.Height,
                 frase.Canvas.Handle,0,0, f);
      end;
end;

function TTela.Topico (i: integer): string;
begin
   if (i <= 0) or (i > quantidade) then
      result := ''
   else
      result := Topicos [i]^.nome;
end;

function TTela.TopicoAtual: string;
begin
   if (indice <= 0) or (indice > quantidade) then
      result := ''
   else
      result := Topicos [indice]^.nome;
end;

procedure TTela.alteraMidia (s: string);
begin
    smidia := s;
end;

procedure TTela.pintaTitulo;
var
   f: DWORD;
begin
   Titulo.pintaTitulo;

   if Titulo.ModoFundo = OPACO then
      f := SRCCOPY
   else
      f := SRCAND;

   bitBlt (bitMap.Handle, 0, 0, Titulo.bmap.Width, Titulo.bmap.Height,
           Titulo.bmap.Canvas.Handle, 0, 0, f);
end;

destructor TTela.destroy;
var
   j: integer;
begin
   frase.Destroy;
   bitMapFundo.Destroy;

   for j := 1 to quantidade do
      dispose (Topicos [j]);

   msg.Destroy;
   Titulo.destroy;
end;

{---------------------------------}
{              TTopico            }
{---------------------------------}
constructor TTopico.create (bitMap: TCanvas; dx, dy: integer);
begin
   subTopico.create (bitMap,dx,dy);
end;

destructor TTopico.destroy;
begin
   subTopico.destroy;
end;

{-----------------------------------}
{             TSubTopico            }
{-----------------------------------}
function TSubTopico.subTopico (i: integer): string;
begin
   if (i <= 0) or (i > quantidade) then
      result := ''
   else
      result := nome [i]^;
end;

function TSubTopico.subTopicoAtual: string;
begin
   if (indice <= 0) or (indice > quantidade) then
      result := ''
   else
      result := nome [indice]^;
end;

procedure TSubTopico.avancaUmSubTopico;
begin
   if indice <= quantidade then
      indice := indice + 1;
end;

procedure TSubTopico.recuaUmSubTopico;
begin
   if indice > 0 then
      indice := indice - 1;
end;

procedure TSubTopico.inserirSubTopico (s: string);
begin
   if quantidade >= 20 then
      begin
         if debug then
            msg.Add ('Foi extrapolado o limite de 20 subtopicos.');
         exit;
      end;

   quantidade := quantidade + 1;
   new (nome [quantidade]);
   nome [quantidade]^ := s;
end;

procedure TSubTopico.desenharSubTopicos;
var
   j: integer;
   f: DWORD;
begin
   if ModoFundo = OPACO then
      f := SRCCOPY
   else
      f := SRCAND;

   for j := 1 to quantidade do
      begin
         desenhaUmSubTopico (j);
         if margem = MD then
            pos.x := deltax - frase.Width
         else if margem = MC then
            pos.x := (deltax - frase.Width) div 2;

         BitBlt (tela.handle, pos.x, pos.y, frase.Width, frase.Height,
                 frase.Canvas.Handle,0,0, f);
      end;
end;

procedure TSubTopico.desenhaUmSubTopico (i: integer);
var
   st: TStrings;

   {------------------------------------}
   function incluiCarac: string;
   begin
      if CaracMarc <> '' then
         result := caracMarc + ' '
      else
         result := caracMarc;
   end;
   {------------------------------------}
   procedure verificaDebug;
   var
      s,s1: string;
   begin
      if st.Count > 1 then
         begin
            str (st.Count, s);
            str (i, s1);
            msg.Add ('O subTopico ' + s1 + ' extrapolou a tela, e foi dividido em ' + s + 'linhas.');
         end;
      if pos.y > deltay then
         msg.Add ('Não coube na tela, a ultima frase é: ' + nome [i]^ + '.');
   end;
   {------------------------------------}
   procedure pintaFrase;
   var
      tam, xquebra, xfrente: integer;
      s, s1,s2: string;
      l: integer;
   begin
      s1 := '';
      s2 := '';
      s := nome [i]^;
      s := s + ' ';
      tam := length (s);
      xquebra := 1;
      xfrente := 0;

      frase.Height := 1;
      frase.Width := 1;

      for l := 1 to tam do
         begin
            xfrente := xfrente + 1;
            if s [l] = ' ' then
               begin
                  if (pos.x + frase.Canvas.TextWidth (s1) + 30) > deltax then
                     begin
                        s2 := copy (s1,1,xquebra-1);
                        delete (s1,1,xquebra);
                        xfrente := xfrente - xquebra;
                        xquebra := 1;
                        st.Add (s2);
                     end
                  else
                     xquebra := xfrente;
               end;
            s1 := s1 + s [l];
         end;

      st.Add (s1);
      st.Insert (0, incluiCarac + st.strings [0]);
      st.Delete (1);

      if st.count > 1 then
         frase.Width := deltax - pos.x
      else
         frase.width := frase.Canvas.TextWidth (st.Strings [0]);

      tam := frase.Canvas.TextHeight (nome [i]^);
      frase.Height :=st.Count*tam;

      xfrente := 0;
      for l := 0 to st.Count-1  do
         begin
            if margem = ME then
               xquebra := 0
            else if margem = MD then
               xquebra := frase.Width - frase.Canvas.TextWidth (st.Strings [l])
            else if margem = MC then
               xquebra := (frase.Width - frase.Canvas.TextWidth (st.Strings [l]) + frase.Canvas.TextWidth (' ')) div 2;

            frase.Canvas.TextOut (xquebra,xfrente, st.Strings [l]);
            xfrente := xfrente + tam;
         end;
   end;

begin
   st := TStringList.Create;
   if i = 1 then
      pos.y := pos.y + TopicoHeight;

   pos.y := pos.y + frase.Height + 8;
   pintaFrase;
   if debug then
      verificaDebug;
   st.free;
end;

procedure TSubtopico.alteraFonte (f: TFonte);
   {--------------------------------------}
   function ExtraiEstilo: TFontStyles;
   begin
      with font do
         begin
            if (negrito) and (italico) and (sublinhado) then
               result := [fsBold, fsItalic, fsUnderline]
            else if (negrito) and (italico) and not (sublinhado) then
               result := [fsBold, fsItalic]
            else if (negrito) and not (italico) and (sublinhado) then
               result := [fsBold, fsUnderline]
            else if not (negrito) and (italico) and (sublinhado) then
               result := [fsItalic, fsUnderline]
            else if (negrito) and not (italico) and not(sublinhado) then
               result := [fsBold]
            else if not (negrito) and (italico) and not (sublinhado) then
               result := [fsItalic]
            else if not (negrito) and not (italico) and (sublinhado) then
               result := [fsUnderline];
         end;
   end;
   {--------------------------------------}
begin
   font := f;
   frase.Canvas.Font.Name := font.Nome;
   frase.Canvas.Font.Size := font.tamanho;
   frase.Canvas.Font.Color := extraiCor (font.cor);
   frase.Canvas.Font.Style := ExtraiEstilo;
end;

constructor TSubTopico.create (bitmap: TCanvas; dx, dy: integer);
begin
   tela := bitmap;
   frase := TBitmap.Create;
   frase.Canvas.LineTo (0,0);
   debug := false;
   quantidade := 0;
   font.Nome := frase.Canvas.Font.Name;
   font.tamanho := frase.Canvas.Font.Size;
   deltax := dx;
   deltay := dy;
   indice := 0;
   pos.x := 50;
   TopicoHeight := 0;
   msg := TStringList.Create;
   naoCoube := false;
   caracMarc := '';
   margem := ME;
   ModoFundo := TRANSPARENTE;
end;

destructor TSubTopico.destroy;
var
   i: integer;
begin
   frase.Destroy;
   for i := 1 to quantidade do
      dispose (nome [i]);

   msg.Destroy;
end;

{-----------------------------------}
{             TTitulo               }
{-----------------------------------}
constructor TTitulo.create (deltax: integer);
begin
   dx := deltax;
   bmap := TBitMap.Create;
   bmap.Canvas.LineTo (0,0);
   dy := 0;
   bmap.Width := dx;
   nome := '';
   ModoFundo := TRANSPARENTE;
end;

procedure TTitulo.alteraFonte (f: TFonte);
   {--------------------------------------}
   function ExtraiEstilo: TFontStyles;
   begin
      with font do
         begin
            if (negrito) and (italico) and (sublinhado) then
               result := [fsBold, fsItalic, fsUnderline]
            else if (negrito) and (italico) and not (sublinhado) then
               result := [fsBold, fsItalic]
            else if (negrito) and not (italico) and (sublinhado) then
               result := [fsBold, fsUnderline]
            else if not (negrito) and (italico) and (sublinhado) then
               result := [fsItalic, fsUnderline]
            else if (negrito) and not (italico) and not(sublinhado) then
               result := [fsBold]
            else if not (negrito) and (italico) and not (sublinhado) then
               result := [fsItalic]
            else if not (negrito) and not (italico) and (sublinhado) then
               result := [fsUnderline];
         end;
   end;
   {--------------------------------------}
begin
   font := f;
   bmap.Canvas.Font.Name := font.Nome;
   bmap.Canvas.Font.Size := font.tamanho;
   bmap.Canvas.Font.Color := extraiCor (font.cor);
   bmap.Canvas.Font.Style := ExtraiEstilo;
end;

procedure TTitulo.alteraCor (c: PChar);
begin
   cor := c;
   bmap.Canvas.Brush.Color := extraiCor (c);
end;

procedure TTitulo.pintaTitulo;
var
   x: integer;
begin
   dy := bmap.Canvas.TextHeight (nome);
   bmap.Height := dy;
   x := (dx - bmap.Canvas.TextWidth (nome)) div 2;
   bmap.Canvas.TextOut (x,0,nome);
end;

destructor TTitulo.destroy;
begin
   bmap.Destroy;
end;

{         rotinas auxiliares   }
function extraiCor (cor: PChar): TColor;
begin
   cor := strUpper (cor);
   if cor = 'BRANCO' then
      result := RGB (255,255,255)
   else if cor = 'AZUL' then
      result := RGB (0,0,255)
   else if cor = 'VERDE' then
      result := RGB (0,255,0)
   else if cor = 'VERMELHO' then
      result := RGB (255,0,0)
   else if cor = 'AMARELO' then
      result := RGB (255, 255,0)
   else if cor = 'ROSA' then
      result := RGB (255, 0, 255)
   else if cor = 'AZUL CLARO' then
      result := RGB (0, 255,255)
   else if cor = 'MARROM' then
      result := RGB (255, 255,0)
   else if cor = 'VERDE ESCURO' then
      result := RGB (0, 100,0)
   else if cor = 'AZUL ESCURO' then
      result := RGB (0, 0,155)
   else if cor = 'CINZA' then
      result := RGB (155, 155,155)
   else if cor = 'ROXO' then
      result := RGB (170, 0, 255)
   else
      result := RGB (0,0,0);
end;
end.

