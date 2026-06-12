unit pptMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleCtrls, ACTIVEVOICEPROJECTLib_TLB, MPlayer, ppmssg;

type
  TFormPptvox = class(TForm)
    DirectSS1: TDirectSS;
    MediaPlayer1: TMediaPlayer;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure avancaUmaTela;
    procedure recuaUmaTela;
    procedure avancaUmTopico;
    procedure recuaUmTopico;
    procedure avancaUmSubTopico;
    procedure recuaUmSubTopico;
    procedure leSubTopicos;
    procedure leTopicos;
    procedure leSubTopicoAtual;
    procedure leTopicoAtual;
    procedure leTitulo;
    procedure pagina;
    procedure leTudo;
    procedure executaMedia;
    procedure executaPrograma;
  end;

var
  FormPptvox: TFormPptvox;
  conf: boolean;

implementation
uses pptVars,pptGeral,pptObject, shellApi;
{$R *.DFM}

procedure naoFazNada;
var
  M: TMsg;
begin
  while PeekMessage(M, 0, 0, 0, pm_Remove) do
  begin
    if M.Message = wm_Quit then Halt(255);
    TranslateMessage(M);
    DispatchMessage(M);
  end;
end;

procedure TFormPptVox.executaMedia;
var
   ret: TRect;
begin
   mediaPlayer1.FileName := apresent [cont.indice]^.Media;
   if mediaPlayer1.FileName = '' then
   begin
       DirectSS1.Speak ('não há midia associada');
       exit;
   end;
   mediaPlayer1.Display := formPptvox;
   mediaPlayer1.Open;
   ret.Left := 0;
   ret.Top := 0;
   ret.Right := screen.Width;
   ret.Bottom := screen.Height;
   mediaPlayer1.DisplayRect := ret;
   mediaPlayer1.Play;
end;

procedure TFormPptVox.pagina;
var
   s: string;
begin
   str (cont.indice,s);
//   showMessage (s);
   directSS1.Speak ('Tela ' + s)
end;

procedure TFormPptVox.leTitulo;
var
   s: string;
begin
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;

   s := apresent [cont.indice]^.Titulo.nome;

//   showMessage (s);
   directSS1.Speak (s)
end;

procedure TFormPptVox.leTudo;
var
   s: string;
   i,j: integer;
begin
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;
   for i := 1 to apresent [cont.indice]^.quant do
      begin
         s := apresent [cont.indice]^.Topico (i);
//         showMessage (s);
         directSS1.Speak (s);
         for j := 1 to apresent [cont.indice]^.Topicos [i]^.subTopico.quant do
            begin
               s := apresent [cont.indice]^.Topicos [i]^.subTopico.subTopico (j);
//               showMessage (s);
               directSS1.Speak (s);
            end;
      end;
end;

procedure TFormPptVox.leSubTopicos;
var
   s: string;
   i: integer;
begin
   if apresent [cont.indice]^.posAtual < 1 then
      apresent [cont.indice]^.avancaUmTopico
   else if apresent [cont.indice]^.posAtual > apresent [cont.indice]^.quant then
      apresent [cont.indice]^.recuaUmTopico;

   for i := 1 to apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.quant do
      begin
         s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopico (i);
//         showMessage (s);
         directSS1.Speak (s)
      end;
end;

procedure TFormPptVox.leTopicos;
var
   s: string;
   i: integer;
begin
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;

   for i := 1 to apresent [cont.indice]^.quant do
      begin
         s := apresent [cont.indice]^.Topico (i);
//         showMessage (s);
         directSS1.Speak (s)
      end;
end;

procedure TFormPptVox.avancaUmaTela;
begin
   tocawav ('tela');
   if cont.indice < cont.count then
      begin
         cont.indice := cont.indice + 1;
         BitMap.Width := 1;
         BitMap.Width := Width;
         apresent [cont.indice]^.desenharTela;
         canvas.Draw (0,0,BitMap);
         directSS1.Speak (apresent [cont.indice]^.Titulo.nome);
         directSS1.Speak (apresent [cont.indice]^.Topico (1));
      end
   else
      directSS1.Speak ('Ultima tela');
end;

procedure TFormPptVox.recuaUmaTela;
begin
   tocawav ('tela');
   if cont.indice > 1 then
      begin
         cont.indice := cont.indice - 1;
         BitMap.Width := 1;
         BitMap.Width := Width;
         apresent [cont.indice]^.desenharTela;
         canvas.Draw (0,0,BitMap);
         directSS1.Speak (apresent [cont.indice]^.Titulo.nome);
         directSS1.Speak (apresent [cont.indice]^.Topico (1));
      end
   else
      directSS1.Speak ('primeira tela');
end;

procedure TFormPptVox.avancaUmTopico;
var
   s: string;
begin
   tocawav ('topico');
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;

   apresent [cont.indice]^.avancaUmTopico;
   s := apresent [cont.indice]^.TopicoAtual;

   if s <> '' then
//      showMessage (s)
      directSS1.Speak (s)
   else
//      showMessage ('último tópico');
      directSS1.Speak ('último topico');
end;

procedure TFormPptVox.recuaUmTopico;
var
   s: string;
begin
   tocaWav ('topico');
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;

   apresent [cont.indice]^.recuaUmTopico;
   s := apresent [cont.indice]^.TopicoAtual;

   if s <> '' then
//      showMessage (s)
      directSS1.Speak (s)
   else
//      showMessage ('primeiro topico');
      directSS1.Speak ('primeiro topico');
end;

procedure TFormPptVox.avancaUmSubTopico;
var
   s: string;
begin
   tocawav ('subtopic');
   if apresent [cont.indice]^.posAtual < 1 then
      apresent [cont.indice]^.avancaUmTopico
   else if apresent [cont.indice]^.posAtual > apresent [cont.indice]^.quant then
      apresent [cont.indice]^.recuaUmTopico;

   apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.avancaUmSubTopico;
   s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopicoAtual;

   if s <> '' then
//      showMessage (s)
      directSS1.Speak (s)
   else
//      showMessage ('último subtopico');
      directSS1.Speak ('último subtopico');
end;

procedure TFormPptVox.recuaUmSubTopico;
var
   s: string;
begin
   tocawav ('subtopic');
   if apresent [cont.indice]^.posAtual < 1 then
      apresent [cont.indice]^.avancaUmTopico
   else if apresent [cont.indice]^.posAtual > apresent [cont.indice]^.quant then
      apresent [cont.indice]^.recuaUmTopico;

   apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.recuaUmSubTopico;
   s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopicoAtual;

   if s <> '' then
//      showMessage (s)
      directSS1.Speak (s)
   else
//      showMessage ('primeiro subtopico');
      directSS1.Speak ('primeiro subtopico');
end;

procedure TFormPptVox.leTopicoAtual;
var
   s: string;
begin
   if cont.indice < 1 then
      cont.indice := 1
   else if cont.indice > cont.count then
      cont.indice := cont.count;

   s := apresent [cont.indice]^.TopicoAtual;

   if s = '' then
      begin
         if apresent [cont.indice]^.posAtual < 1 then
            s := apresent [cont.indice]^.Topico (1)
         else
            s := apresent [cont.indice]^.Topico (apresent [cont.indice]^.quant);
      end;
//   showMessage (s);
   directSS1.Speak (s);
end;

procedure TFormPptVox.leSubTopicoAtual;
var
   s: string;
begin
   if apresent [cont.indice]^.posAtual < 1 then
      apresent [cont.indice]^.avancaUmTopico
   else if apresent [cont.indice]^.posAtual > apresent [cont.indice]^.quant then
      apresent [cont.indice]^.recuaUmTopico;

   s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopicoAtual;

   if s = '' then
      begin
         if apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.posAtual < 1 then
            s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopico (1)
         else
            s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTopico.subTopico (apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.subTop
ico.quant);
      end;
//      showMessage (s);
      directSS1.Speak (s);
end;

procedure TFormPptvox.executaPrograma;
var
   s: string;
   s1: string;
   p: integer;
   c1: array [0..79] of char;
   c2: array [0..79] of char;
   tam: integer;
begin
   if apresent [cont.indice]^.posAtual < 1 then
      apresent [cont.indice]^.avancaUmTopico
   else if apresent [cont.indice]^.posAtual > apresent [cont.indice]^.quant then
      apresent [cont.indice]^.recuaUmTopico;

   s := apresent [cont.indice]^.Topicos [apresent [cont.indice]^.posAtual]^.programa;
   if s = '' then
      begin
         DirectSS1.Speak ('não há programa associado');
         exit;
      end;

   s1 := '';

   p := pos (' ',s);
   tam := length(s);
   if p <> 0 then
      begin
         s1 := copy (s,p+1,tam-p);
         delete (s,p,tam-p+1);
      end;
   strPcopy (c1,s);
   strPcopy (c2,s1);
   if shellExecute (0,'open',c1,c2,'',sw_shownormal) > 32 then
      begin
         repeat naoFazNada until getActiveWindow <> handle;
         repeat naoFazNada until getActiveWindow = handle;
      end;
//   directSS1.Speak ('voltei');
end;

procedure TFormPptvox.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t: word;
  resultado: word;
begin
   directSS1.AudioReset;

   t := Key;

   if (ssShift in shift) or (ssAlt in shift) then exit (* shift ou alt pressionados*)
   else if (ssCtrl in shift) then (*ctrl pressionado*)
      begin
         if t = 35 then  (* end *)
            leSubTopicos
         else if t = 36 then  (* home *)
            leTopicos
         else if t = 32 then  (* space *)
            mediaPlayer1.Close
         else if t = 17 then  (* seta baixo *)
            leTudo;
         exit;
      end;

   if t = ord (#27) then  (*esc*)
      begin
         resultado := ppmsg.ShowModal;
         case resultado of
            mrOK: begin
                     close;
                  end;
            mrCancel: begin
                     tocaWav ('pptOk');
                     exit;
                  end;
         end;
      end
   else if t = 39 then  (*direita*)
      avancaUmaTela
   else if t = 37 then (*esquerda*)
      recuaUmaTela
   else if t = 33 then (*page Up*)
      recuaUmTopico
   else if t = 34 then  (*page Down*)
      avancaUmTopico
   else if t = 38 then  (* cima*)
      recuaUmSubTopico
   else if t = 40 then   (* baixo *)
      avancaUmSubTopico
   else if t = 35 then  (* end *)
      leSubTopicoAtual
   else if t = 36 then  (* home *)
      leTopicoAtual
   else if t = 45 then  (* insert *)
      leTitulo
   else if t = 46 then  (* delete *)
      pagina
   else if t = 32 then  (* space *)
      executaMedia
   else if t = ord (#13) then  (* enter *)
      begin
         executaPrograma;
         tocaWav ('pptfecha');
      end;
end;

procedure carregaConfiguracao;
{--------------------------------------------------------}
   procedure iniciaSapi (s: string);
   var
      voz: string;
      velo: string;
      tona: string;
      num : integer;
      p: integer;
      erro: integer;
   begin
      p := pos (' ',s);
      if p = 0 then
         begin
            val (s,num,erro);
            if erro = 0 then
               FormPptVox.DirectSS1.Select (num);
            exit;
         end;
      voz := copy (s,1,p-1);
      val (voz,num,erro);
      if erro = 0 then
         FormPptVox.DirectSS1.Select (num);
      delete (s,1,p);

      p := pos (' ',s);
      if p = 0 then
         begin
            val (s,num,erro);
            if erro = 0 then
               FormPptVox.DirectSS1.Speed := num;
            exit;
         end;
      velo := copy (s,1,p-1);
      val (velo,num,erro);
      if erro = 0 then
         FormPptVox.DirectSS1.Speed := num;
      delete (s,1,p);

      p := pos (' ',s);
      if p = 0 then
         begin
            val (s,num,erro);
            if erro = 0 then
               FormPptVox.DirectSS1.Pitch := num;
            exit;
         end;
      tona := copy (s,1,p-1);
      val (tona,num,erro);
      if erro = 0 then
         FormPptVox.DirectSS1.Pitch := num;
   end;
{--------------------------------------------------------}
var
   p: string;
   num: integer;
   erro: integer;
begin
   conf := true;
   new (temp.tiulo.cor);
   new (temp.tituloCorFundo);
   new (temp.topico.cor);
   new (temp.subTopico.cor);

   p := pegaString (arq2, 'DEBUG', 'DEBUGAR');
   if p = 'SIM' then
      temp.debug := true
   else
      temp.debug := false;

   p := pegaString (arq2, 'TITULO', 'FONTENOME');
   temp.tiulo.Nome := p;

   p := pegaString (arq2, 'TITULO', 'TAMANHO');
   val (p,num,erro);
   if erro <> 0 then
      num := 10;
   temp.tiulo.tamanho := num;

   p := pegaString (arq2, 'TITULO', 'NEGRITO');
   if p = 'SIM' then
      temp.tiulo.negrito := true
   else
      temp.tiulo.negrito := false;

   p := pegaString (arq2, 'TITULO', 'SUBLINHADO');
   if p = 'SIM' then
      temp.tiulo.sublinhado := true
   else
      temp.tiulo.sublinhado := false;

   p := pegaString (arq2, 'TITULO', 'ITALICO');
   if p = 'SIM' then
      temp.tiulo.italico := true
   else
      temp.tiulo.italico := false;

   p := pegaString (arq2, 'TITULO', 'COR');
   strPCopy (temp.tiulo.cor, p);

   p := pegaString (arq2, 'TITULO', 'FUNDO');
   if p = 'OPACO' then
      temp.tituloFundo := OPACO
   else
      temp.tituloFundo := TRANSPARENTE;

   p := pegaString (arq2, 'TITULO', 'CORFUNDO');
   strPCopy (temp.tituloCorFundo, p);

   p := pegaString (arq2, 'TOPICO', 'FONTENOME');
   temp.topico.Nome := p;

   p := pegaString (arq2, 'TOPICO', 'TAMANHO');
   val (p,num,erro);
   if erro <> 0 then
      num := 10;
   temp.topico.tamanho := num;

   p := pegaString (arq2, 'TOPICO', 'NEGRITO');
   if p = 'SIM' then
      temp.topico.negrito := true
   else
      temp.topico.negrito := false;

   p := pegaString (arq2, 'TOPICO', 'SUBLINHADO');
   if p = 'SIM' then
      temp.topico.sublinhado := true
   else
      temp.topico.sublinhado := false;

   p := pegaString (arq2, 'TOPICO', 'ITALICO');
   if p = 'SIM' then
      temp.topico.italico := true
   else
      temp.topico.italico := false;

   p := pegaString (arq2, 'TOPICO', 'COR');
   strPCopy (temp.topico.cor, p);

   p := pegaString (arq2, 'TOPICO', 'FUNDO');
   if p = 'OPACO' then
      temp.topicoFundo := OPACO
   else
      temp.topicoFundo := TRANSPARENTE;

   p := pegaString (arq2, 'TOPICO', 'MARGEM');
   if p = 'MC' then
      temp.topicoMargem := MC
   else if p = 'MD' then
      temp.topicoMargem := MD
   else
      temp.topicoMargem := ME;

   p := pegaString (arq2, 'SUBTOPICO', 'MARCADOR');
   temp.marcador := p;

   p := pegaString (arq2, 'SUBTOPICO', 'FONTENOME');
   temp.subtopico.Nome := p;

   p := pegaString (arq2, 'SUBTOPICO', 'TAMANHO');
   val (p,num,erro);
   if erro <> 0 then
      num := 10;
   temp.subtopico.tamanho := num;

   p := pegaString (arq2, 'SUBTOPICO', 'NEGRITO');
   if p = 'SIM' then
      temp.subtopico.negrito := true
   else
      temp.subtopico.negrito := false;

   p := pegaString (arq2, 'SUBTOPICO', 'SUBLINHADO');
   if p = 'SIM' then
      temp.subtopico.sublinhado := true
   else
      temp.subtopico.sublinhado := false;

   p := pegaString (arq2, 'SUBTOPICO', 'ITALICO');
   if p = 'SIM' then
      temp.subtopico.italico := true
   else
      temp.subtopico.italico := false;

   p := pegaString (arq2, 'SUBTOPICO', 'COR');
   strPCopy (temp.subtopico.cor, p);

   p := pegaString (arq2, 'SUBTOPICO', 'FUNDO');
   if p = 'OPACO' then
      temp.subTopicoFundo := OPACO
   else
      temp.subTopicoFundo := TRANSPARENTE;

   p := pegaString (arq2, 'SUBTOPICO', 'MARGEM');
   if p = 'MC' then
      temp.subTopicoMargem := MC
   else if p = 'MD' then
      temp.subTopicoMargem := MD
   else
      temp.subTopicoMargem := ME;

   p := pegaString (arq2, 'SAPI', 'FALA');
   iniciaSapi (p);
end;

procedure novaTela (s: string);
begin
   cont.count := cont.count + 1;
   delete (s,1,1);
   new (apresent [cont.count]);
   with apresent [cont.count]^ do
      begin
         create (BitMap.Canvas, BitMap.Width, BitMap.Height);
         Titulo.nome := s;
         Titulo.ModoFundo := temp.tituloFundo;
         Titulo.corFundo := temp.tituloCorFundo;
         Titulo.fonte := temp.tiulo;
         margem := temp.topicoMargem;
         debug := temp.debug;
         ModoFundo := temp.topicoFundo;
         fonte := temp.topico;
      end;
end;

procedure incluiFundo (s: string);
var
   c: array [0..79] of char;
   p: integer;
   s1: string;
   s2: string;
begin
   if cont.count < 1 then
      exit;
   delete (s,1,1);
   s := s + ' ';
   s1 := s;

   p := pos (' ', s);
   if p <> 0 then
      begin
         s1 := copy (s,1,p-1);
         while p <> 0 do
            begin
               s2 := copy (s,1,p-1);
               if s2 = 'DIREITA' then
                  apresent [cont.count]^.posImagem.Direita := true
               else if s2 = 'ESQUERDA' then
                  apresent [cont.count]^.posImagem.Esquerda := true
               else if s2 = 'CIMA' then
                  apresent [cont.count]^.posImagem.Topo := true
               else if s2 = 'BAIXO' then
                  apresent [cont.count]^.posImagem.Fundo := true;

               delete (s,1,p);
               trim (s);
               p := pos (' ', s);
            end;
      end;

   strPcopy (c,s1);
   apresent [cont.count]^.fundo := c;
end;

procedure incluiSom (s: string);
begin
   if cont.count < 1 then
      exit;
   delete (s,1,1);
   apresent [cont.count]^.Media := s;
end;

procedure incluiTopico (s: string);
var
   p: integer;
   s1: string;
   tam: integer;
begin
   if cont.count < 1 then
      exit;
   delete (s,1,1);

   p := pos (' &',s);
   if p <> 0 then
      begin
         tam := length (s);
         s1 := copy (s,p+2, tam - p -1);
         delete (s,p,tam-p+1);
      end;
   apresent [cont.count]^.novoTopico (s);
   if p <> 0 then
      apresent [cont.count]^.Topicos [apresent [cont.count]^.quant]^.programa := s1;

   with apresent [cont.count]^.Topicos [apresent [cont.count]^.quant]^.subTopico do
      begin
         margem := temp.subtopicoMargem;
         caracMarc := temp.marcador;
         ModoFundo := temp.subtopicoFundo;
         fonte := temp.subTopico;
      end;
end;

procedure incluiSubTopico (s: string);
begin
   if cont.count < 1 then
      exit;
   if apresent [cont.count]^.quant < 1 then
      exit;

   delete (s,1,1);
   apresent [cont.count]^.Topicos [apresent [cont.count]^.quant]^.subTopico.inserirSubTopico (s);
end;

procedure carregaApresentacao;
var
   arqApre: TStrings;
   pos: integer;
   s: string;
begin
   arqApre := TStringList.Create;
   try
      arqApre.LoadFromFile (arq1);
   except
      FormPptvox.Close;
      exit;
   end;

   for pos := 0 to arqApre.Count-1 do
      begin
         s := arqApre.Strings [pos];
         if (s <> '') and (s [1] <> ';') then
            begin
               case s [1] of
                  '{':novaTela (s);
                  '#':incluiFundo (s);
                  '$':incluiSom (s);
                  '*':incluiTopico (s);
                  '-':incluiSubTopico (s);
               end;
            end;
      end;
end;

procedure TFormPptvox.FormCreate(Sender: TObject);
{-----------------------------------}
   procedure carregaArquivo;
   begin
      if paramCount >= 1 then
         begin
            arq1 := paramStr (1);
            if paramCount >= 2 then
               begin
                  arq2 := paramStr (2);
                  carregaConfiguracao;
               end;
            carregaApresentacao;
         end;
   end;
{----------------------------------}
var
   i: integer;
   p: array [0..79] of char;
begin
   conf := false;
   cont.indice := 1;
   bitmap := TBitmap.Create;
   bitmap.Width := Screen.Width;
   bitmap.Height := Screen.Height;
   bitmap.canvas.lineto (0, 0);

   getPrivateProfileString ('PPTVOX', 'DIRPPTVOX', '', p, 80, 'DOSVOX.INI');
   dirPPTVOX := strPas (p);

   carregaArquivo;

   apresent [cont.indice]^.desenharTela;

   if apresent [cont.indice]^.debug then
      for i := 0 to apresent [cont.indice]^.msg.Count -1 do
         directSS1.Speak (apresent [cont.indice]^.msg.Strings [i]);

   directSS1.Speak (apresent [cont.indice]^.Titulo.nome);
   directSS1.Speak (apresent [cont.indice]^.Topico (1));
end;

procedure TFormPptvox.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
   i: integer;
begin
   for i := 1 to cont.count do
      apresent [i]^.destroy;

   canClose := true;
end;

procedure TFormPptvox.FormPaint(Sender: TObject);
begin
   canvas.Draw (0,0,BitMap);
end;

end.
