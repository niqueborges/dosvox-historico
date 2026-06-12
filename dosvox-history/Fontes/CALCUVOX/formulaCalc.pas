//==============================================================================
// Product name: CalcExpress  (adapted)
// Copyright 2000-2002 AidAim Software.
// Description:
//  CalcExpress is an interpreter for quick and easy
//  evaluation of mathematical expressions.
//  It is a smart tool easy in use.
//  Supports 5 operators, parenthesis, 18 mathematical functions and
//  user-defined variables.
// Date: 06/14/2001
// Small adjusts by Antonio Borges (Dosvox Project)
// Date: 05/10/2019
//==============================================================================

unit formulaCalc;

interface

uses
  SysUtils, Classes, Math;

type
  TTree = record
    num: integer;
    con: string;
    l, r: pointer;
  end;

  PTree = ^TTree;

  TFormCalc = class
  private
    Bc: integer;
    PrevLex, Curlex: integer;
    FPos: integer;
    FFormula: string;
    Tree: pointer;
    FVariables: TStrings;
    FDefaultNames: boolean;
    procedure init(s: string);
    function gettree(s: string): pointer;
    function deltree(t: PTree): pointer;
    procedure Error(s: string);
    procedure SetVariables(Value: TStrings);
    function adjustFormula (f: string): string;

  public
    Err: boolean;
    constructor Create;
    destructor Destroy; override;
    function calc(args: array of extended): extended;

  published
    property Formula: string read FFormula write init;
    property Variables: TStrings read FVariables write SetVariables;

  end;

implementation

function TFormCalc.adjustFormula (f: string): string;
var i, p: integer;
begin
    f := lowerCase (trim (f));

    if DecimalSeparator = '.' then
        f := StringReplace(f, ',', '.', [rfReplaceAll])
    else
        f := StringReplace(f, '.', ',', [rfReplaceAll]);
    repeat
         p := pos(' ', f);
         if p <> 0 then
             delete (f, p, 1);
    until p = 0;
    for i := length(f) downto 2 do
        begin
             if f[i] in ['a'..'z'] then
                if f[i-1] in ['0'..'9'] then
                     insert ('*', f, i);
        end;
    result := f;
end;

function TFormCalc.calc(args: array of extended): extended;

  function c(t: PTREE): extended;
  var
    r: extended;
    i: integer;
    salvaErr: boolean;
  begin
  c := 0;

  salvaErr := Err;
  Err := true;
  if t = NIL then exit;
  if (t^.l = NIL) and (t^.num in [3..6, 9..27, 31]) then exit;
  if (t^.r = NIL) and (t^.num in [3..6,31]) then exit;

  Err := salvaErr;
  try
    case t^.num of
      3: c := c(t^.l) + c(t^.r);
      4: c := c(t^.l) - c(t^.r);
      5: c := c(t^.l) * c(t^.r);
      6: if c(t^.r) = 0 then
           begin
               c := 0;
               Err := true;
           end
         else
           c := c(t^.l) / c(t^.r);
      7: c := strtofloat(t^.con);
      8: begin
            i := StrToInt(t^.con);
            if (i < 0) or (i >= length(args)) then
               begin
                   c := 0;
                   Err := true;
               end
            else
               c := args[i];
         end;
      9: c := -c(t^.l);
      10: c := cos(c(t^.l));
      11: c := sin(c(t^.l));
      12: c := tan(c(t^.l));
      13: c := 1 / tan(c(t^.l));
      14: c := abs(c(t^.l));
      15:
      begin
        r := c(t^.l);
        if r < 0 then c := -1
        else if r > 0 then c := 1
        else
          c := 0;
      end;
      16: if (t^.l = NIL) or (c(t^.l) < 0) then
           begin
               c := 0;
               Err := true;
           end
         else
            c := sqrt(c(t^.l));
      17: c := ln(c(t^.l));
      18: c := exp(c(t^.l));
      19: c := arcsin(c(t^.l));
      20: c := arccos(c(t^.l));
      21: c := arctan(c(t^.l));
      22: c := pi / 2 - arctan(c(t^.l));
      23:
      begin
        r := c(t^.l);
        c := (exp(r) - exp(-r)) / 2;
      end;
      24:
      begin
        r := c(t^.l);
        c := (exp(r) + exp(-r)) / 2;
      end;
      25:
      begin
        r := c(t^.l);
        c := (exp(r) - exp(-r)) / (exp(r) + exp(-r));
      end;
      26:
      begin
        r := c(t^.l);
        c := (exp(r) + exp(-r)) / (exp(r) - exp(-r));
      end;
      27:
      begin
        r := c(t^.l);
        if r >= 0 then c := 1
        else
          c := 0;
      end;
      31: c := power(c(t^.l), c(t^.r));
    end;
    except
      Err := true;
    end;
  end;

begin
  calc := c(tree);
end;

procedure TFormCalc.Error(s: string);
begin
  Err := True;
  //raise Exception.Create(s);
end;

constructor TFormCalc.Create;
begin
  inherited;
  Tree := nil;
  FDefaultNames := False;
  FVariables := TStringList.Create;
  Formula := '0';
end;

destructor TFormCalc.Destroy;
begin
  DelTree(Tree);
  FVariables.Free;
  inherited;
end;

function TFormCalc.GetTree(s: string): pointer;
  //Get number from string
  function getnumber(s: string): string;
  begin
    Result := '';
    try
      //Begin
      while (FPos <= length(s)) and (s[FPos] in ['0'..'9']) do
      begin
        Result := Result + s[FPos];
        inc(FPos);
      end;
      if FPos > length(s) then exit;
      if s[FPos] = DecimalSeparator then
      begin
        //Fraction part
        Result := Result + DecimalSeparator;
        inc(FPos);
        if (FPos > length(s)) or not (s[FPos] in ['0'..'9']) then Error('Número errado.');
        while (FPos <= length(s)) and
          (s[FPos] in ['0'..'9']) do
        begin
          Result := Result + s[FPos];
          inc(FPos);
        end;
      end;
      if FPos > length(s) then exit;
      //Power
      if (s[FPos] <> 'e') and (s[FPos] <> 'E') then exit;
      Result := Result + s[FPos];
      inc(FPos);
      if FPos > length(s) then Error('Número errado.');
      if s[FPos] in ['-', '+'] then
      begin
        Result := Result + s[FPos];
        inc(FPos);
      end;
      if (FPos > length(s)) or not (s[FPos] in ['0'..'9']) then Error('Número errado.');
      while (FPos <= length(s)) and
        (s[FPos] in ['0'..'9']) do
      begin
        Result := Result + s[FPos];
        inc(FPos);
      end;
    except
    end;
  end;
  //Read lexem from string
  procedure getlex(s: string; var num: integer; var con: string);
  begin
    con := '';
    //skip spaces
    while (FPos <= length(s)) and (s[FPos] = ' ') do inc(FPos);
    if FPos > length(s) then 
    begin 
      num := 0;  
      exit; 
    end;

    case s[FPos] of
      '(': num := 1;
      ')': num := 2;
      '+': num := 3;
      '-': 
      begin
        num := 4;
        if (FPos < length(s)) and (s[FPos + 1] in ['1'..'9', '0']) and (curlex in [0,1]) then
        begin
          inc(FPos);
          con := '-' + getnumber(s);
          dec(FPos);
          num := 7;
        end;
      end;
      '*': num := 5;
      '/': num := 6;
      '^': num := 31;
      'a'..'z', {'A'..'Z',} '_':
      begin
        while (FPos <= length(s)) and
          (s[FPos] in ['a'..'z', {'A'..'Z',} '_', '1'..'9', '0']) do
        begin
          con := con + s[FPos];
          inc(FPos);
        end;
        dec(FPos);
        num := 8;
        if con = 'cos' then num := 10;
        if con = 'sin' then num := 11;
        if (con = 'tg') or (con = 'tan') then num := 12;
        if con = 'ctg' then num := 13;
        if con = 'abs' then num := 14;
        if (con = 'sgn') or (con = 'sign') then num := 15;
        if con = 'sqrt' then num := 16;
        if con = 'ln' then num := 17;
        if con = 'exp' then num := 18;
        if con = 'arcsin' then num := 19;
        if con = 'arccos' then num := 20;
        if (con = 'arctg') or (con = 'arctan') then num := 21;
        if con = 'arcctg' then num := 22;
        if (con = 'sh') or (con = 'sinh') then num := 23;
        if (con = 'ch') or (con = 'cosh') then num := 24;
        if (con = 'th') or (con = 'tanh') then num := 25;
        if (con = 'cth') or (con = 'coth') then num := 26;
        if (con = 'heaviside') or (con = 'h') then num := 27;
        if num = 8 then  con := IntToStr(FVariables.IndexOf(con));
      end;
      '0'..'9':
      begin
        con := getnumber(s);
        dec(FPos);
        num := 7;
      end;
    end;
    inc(FPos);
    PrevLex := CurLex;
    CurLex := num;
  end;

var
  neg: boolean;
  l, r, res: PTree;
  n, op: integer;
  c: string;

  function newnode: PTree;
  begin
    Result := allocmem(sizeof(TTree));
    Result^.l := nil;
    Result^.r := nil;
  end;

  function getsingleop: pointer;
  var 
    op, bracket: integer;
    opc: string;
    l, r, res: PTree;
  label erro;
  begin
    l := nil;

  if n = 1 then
  begin
    inc(bc);
    l := gettree(s);
  end
  else
  begin
    // First operand
    if not (n in [7,8,10..30]) then goto erro;  // Error('');  xxxxxxxxxxxxxx
    op := n;
    opc := c;
    if n in [7,8] then
    begin
      // Number or variable
      l := newnode; 
      l^.num := op;
      l^.con := opc;
    end
    else
    begin
      //Function
      getlex(s, n, c);
      if n <> 1 then goto erro;  // Error('');  xxxxxxxxxxxxxx
      inc(bc);
      l := newnode;
      l^.l := gettree(s); 
      l^.num := op; 
      l^.con := opc;
    end;
  end;
  //Operation symbol
  getlex(s, n, c);
  //Power symbol
  while n = 31 do
    begin
      getlex(s, n, c);
    bracket := 0;
    if n = 1 then  
    begin
      bracket := 1;
      getlex(s, n, c);
    end;
    if (n <> 7) and (n <> 8) then goto erro;  // Error('');  xxxxxxxxxxxxxx
    r := newnode;
    r^.num := n;
    r^.con := c;
    res := newnode;
    res^.l := l;
    res^.r := r;
    res^.num := 31;
    l := res;
    if bracket = 1 then
    begin
      getlex(s, n, c);
      if n <> 2 then goto erro;  // Error('');  xxxxxxxxxxxxxx
    end;
    getlex(s, n, c);
  end;
  Result := l;
  exit;

erro:
  DelTree(l);
  Result := nil;
end;

  function getop: pointer;
  var
    op: integer;
    l, r, res: PTree;
  begin
    neg := False;
    getlex(s, n, c);
    // Unary - or +
    if prevlex in [0,1] then
    begin
      if n = 4 then  
      begin  
        neg := True; 
        getlex(s, n, c);  
      end;
      if n = 3 then getlex(s, n, c);
    end;
    l := getsingleop;
    // 2nd operand **************
    while n in [5,6] do
    begin
      op := n;
      getlex(s, n, c);
      r := getsingleop;
      res := allocmem(sizeof(TTree));
      res^.l := l; 
      res^.r := r; 
      res^.num := op;
      l := res;
    end;
    // Unary minus
    if neg then
    begin
      res := allocmem(sizeof(TTree));
      res^.l := l; 
      res^.r := nil; 
      res^.num := 9;
      l := res;
    end;
    Result := l;
  end;

begin
  l := nil;
  try
    l := getop;
    while True do
    begin
      if n in [0,2] then
      begin
        if n = 2 then dec(bc);
        Result := l;
        exit;
      end;
      if not (n in [3,4]) then Error('');
      op := n;
      r := getop;
      res := allocmem(sizeof(TTree));
      res^.l := l; 
      res^.r := r; 
      res^.num := op;
      l := res;
    end;
    Result := l;
  except
    DelTree(l);
    Result := nil;
  end;
end;

procedure TFormCalc.init(s: string);
begin
  deltree(tree);
  Err := False;
  FFormula := adjustFormula (s);
  Prevlex := 0;
  Curlex := 0;  
  FPos := 1;  
  bc := 0;
  Tree := GetTree(FFormula);
  if (bc <> 0) or Err then
  begin
    Error ('Erro na fórmula.');
    Tree := DelTree(Tree);
  end;
end;

function TFormCalc.deltree(t: PTree): pointer;
begin
  Result := nil;
  if t = nil then exit;
  if t^.l <> nil then Deltree(t^.l);
  if t^.r <> nil then Deltree(t^.r);
  freemem(t);
end;

procedure TFormCalc.SetVariables(Value: TStrings);
begin
  FVariables.Clear;
  FVariables.Assign(Value);
  Init(Formula);
end;


end.