{--------------------------------------------------------}
{                  AGENVOX - tratamento interno do calendário
{--------------------------------------------------------}

unit agCalen2;

interface
uses classes, dvcrt, winprocs;

const
    nomeDia: array [0..6] of string [20] =
       ('Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado');

    nomeMes: array [1..12] of string [12] =
       ('Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');
        
    posicaoNumero: array [0..6] of integer =
        (2, 6, 10,  14, 18, 22, 26);

    tabmes: array [1..12] of integer =
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

type
   { Erros que são emitidos para o evento caso aconteça }
   TErroCalend = (ErroAno, ErroMes, ErroDia, ErroDiaMarc);

   TCalendErroEvent = procedure (Erro: TErroCalend) of object;

   TCalend = class
   private
      {----------------- Eventos --------------------------------}
      EVTCalendErroEvent: TCalendErroEvent; {do evento CalendErro}

      {----------------- variáveis ------------------------------}
      PMes: word;        {mes do calendário}
      PAno: word;        {ano do calendário}
      PDia: Word;        {dia}
      PNomeDia: String;  {Nome do dia da semana por extenso que estiver em PDia}
      PTotDias: longint; {total de dias até esta data}
      PX,                {posição x do início do calendário}
      PY: integer;       {posição y do inicio do calendário}
      PCorf: byte;       {cor do fundo da janela}
      PCor: byte;        {cor da janela }
      PDiaMarc: word;    {Marca um dia no calendário}
      Mostrando: boolean;{indica se o calendário está sendo mostrado na tela}
      { as duas proximas variáveis salvam uma tela }
      psaveScreenChar,           {salva os caracteres}
      psaveScreenAttrib: pchar;  {salva as cores}

      {--------- procedimentos para as propeties --------}
      procedure PPAno (a: word);
      procedure PPMes (m: word);
      procedure PPDia (d: word);
      procedure PPDiaMarc (dm: word);

      {---------- procedimentos e funcoes ---------------}
      function calcDias (d: integer): longint;
      function checaValidadeDia (d: integer): boolean;
      procedure saveScreen;
      procedure PutScreen;
   public
      property Ano: word read PAno write PPAno;
      property Mes: word read PMes write PPMes;
      property Dia: word read PDia write PPDia;
      property MarcaDia: word read PDiaMarc write PPDiaMarc;
      property NomeDoDia: string read PNomeDia;
      property posX: integer read PX write PX;
      property PosY: integer read PY write PY;
      property corFundo: byte read PCorF write PCorF;
      property corTexto: byte read PCor write PCor;
      procedure mostraCalend;
      procedure ocultaCalend;
      constructor create;
      destructor destroy; override;

      {------------------ eventos ----------------------------------------------------------}
      property CalendErro: TCalendErroEvent read EVTCalendErroEvent write EVTCalendErroEvent;
   end;

implementation

constructor TCalend.create;
var
   ssHoje: word;
begin
   getDate (PAno, PMes, PDia, ssHoje);
   PDiaMarc := PDia;
   PTotDias := calcDias (PDia);
   PNomeDia := nomeDia [(PTotDias + 1) mod 7];
   PX := 1;
   PY := 1;
   PCor := White;
   PCorf := Blue;
   mostrando := false;
   getmem (psaveScreenChar,   30*8);
   getmem (psaveScreenAttrib, 30*8);
end;

destructor TCalend.destroy;
begin
  ocultaCalend;

  freemem (psaveScreenChar, 30*8);
  freemem (psaveScreenAttrib, 30*8);

  inherited Destroy;
end;


procedure TCalend.PPAno(a: word);
begin
   if a >= 1800 then
      begin
         PAno := a;
         if checaValidadeDia (PDia) then
            begin
               PTotDias := calcDias (PDia);
               PNomeDia := nomeDia [(PTotDias+1) mod 7];
            end
         else
            begin
               PDia := 1;
               PTotDias := calcDias (PDia);
               PNomeDia := nomeDia [(PTotDias+1) mod 7];
            end;

         if not checaValidadeDia (PDiaMarc) then
            PDiaMarc := PDia;
      end
   else
     if assigned  (CalendErro) then CalendErro (ErroAno);

   if mostrando then
      mostraCalend;
end;

procedure TCalend.PPMes(m: word);
begin
   if (m <= 12) and (m > 0) then
      begin
         PMes := m;
         if checaValidadeDia (PDia) then
            begin
               PTotDias := calcDias (PDia);
               PNomeDia := nomeDia [(PTotDias+1) mod 7];
            end
         else
            begin
               PDia := 1;
               PTotDias := calcDias (PDia);
               PNomeDia := nomeDia [(PTotDias+1) mod 7];
            end;

         if not checaValidadeDia (PDiaMarc) then
            PDiaMarc := PDia;
      end
   else
      if assigned  (CalendErro) then CalendErro (ErroMes);

   if mostrando then
      mostraCalend;
end;

procedure TCalend.PPDia(d: word);
begin
   if checaValidadeDia (d) then
      begin
         PDia := d;
         PTotDias := calcDias (PDia);
         PNomeDia := nomeDia [(PTotDias+1) mod 7];
      end
   else
     if assigned  (CalendErro) then CalendErro (ErroDia);

   if mostrando then
      mostraCalend;
end;

procedure TCalend.PPDiaMarc(dm: word);
begin
   if checaValidadeDia (dm) then
      PDiaMarc := dm
   else
     if assigned  (CalendErro) then CalendErro (ErroDiaMarc);


   if mostrando then
      mostraCalend;
end;

function TCalend.checaValidadeDia(d: integer): boolean;
begin
   if (d <= tabmes [PMes]) and (d > 0) then
      result := true
   else if (PMes = 2) and ((PAno mod 4) = 0) and (d <= 29) and (d > 0) then
      result := true
   else
      result := false;
end;

function TCalend.calcDias (d: integer): longint;
var l : longint;
    i : integer;
    aa: integer;
begin
    aa := PAno - 1800;
    l := aa * longint(365) + (aa - 1) div 4;

    for i := 1 to PMes -1 do
        l := l + tabMes [i];

    if ((aa mod 4) = 0) and (PMes > 2) then
        l := l + 1;

    l := l + d;

    result := l;
end;

procedure TCalend.mostraCalend;
var
   posicaox: integer;
   posicaoy: integer;

   vetMes: array [0..41] of integer;

   diaPrimeiro: integer;
   y: integer;
   i,n: integer;

   salvaCor: word;    {guarda a cor atual da tela}
begin

   posicaox := wherex;
   posicaoy := wherey;

   salvaCor := textAttr;
   if not mostrando then
      saveScreen;

   mostrando := true;

   diaPrimeiro := (calcDias (1)+1) mod 7;

   textColor (PCor);
   TextBackGround (PCorf);

   for i := 0 to diaPrimeiro-1 do
      VetMes [i] := 0;

   for i := 1 to 42 - diaPrimeiro do
      if checaValidadeDia (i) then
         VetMes [diaPrimeiro + i - 1] := i
      else
         VetMes [diaPrimeiro + i - 1] := 0;

   window (PX, PY, PX + 29, PY + 7);
   clrscr;
   write (' Dom Seg Ter Qua Qui Sex Sab ');

   y := 2;
   n := 0;

   for i := 0 to 41 do
      begin
         if VetMes [i] <> 0 then
            begin
               n := i mod 7;
               gotoXY (posicaoNumero [n] + 1,y);
               if (vetMes [i]) = PDiaMarc then
                  begin
                    textColor (PCorf);
                    TextBackGround (PCor);
                  end;

               write (vetMes [i]);

               if (vetMes [i]) = PDiaMarc then
                  begin
                     textColor (PCor);
                     TextBackGround (PCorf);
                  end;
            end;

         if n = 6 then
            begin
               y := y + 1;
            end;
      end;

   window (1,1,80,25);
   gotoXY (posicaox,PosicaoY);
   textColor (salvaCor and $f);
   textBackground (salvaCor shr 4);
end;

procedure TCalend.ocultaCalend;
var
   posicaox, posicaoy: integer;
begin
   posicaox := wherex;
   posicaoy := wherey;

   mostrando := false;

   putScreen;

   gotoXY (posicaox,PosicaoY);
end;

procedure TCalend.saveScreen;
var
   yy, xx: integer;
   i: integer;
begin
   i := 0;
   for yy := PY to PY + 7 do
       for xx := PX to PX + 29 do
           begin
                psaveScreenChar[i]   := getScreenChar (xx, yy);
                psaveScreenAttrib[i] := chr (getScreenAttrib (xx, yy));
                i := i + 1;
           end;
end;

procedure TCalend.PutScreen;
var
   yy, xx: integer;
   s: string;
   i: integer;
   cor, ultCor: word;
begin
   ultCor := 0;
   i := 0;
   for yy := PY to PY + 7 do
       begin
           gotoxy (PX, yy);
           s := '';
           for xx := PX to PX + 29 do
              begin
                 cor := word(psaveScreenAttrib[i]);
                 if cor <> ultCor then
                    begin
                       if s <> '' then write (s);
                          s := '';
                       ultCor := cor;
                       textColor (cor and $f);
                       textBackground (cor shr 4);
                    end;
                    s := s + psaveScreenChar[i];
                    i := i + 1;
              end;
           if s <> '' then write (s);
           s := '';
       end;
end;

end.
