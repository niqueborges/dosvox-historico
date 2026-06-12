{***************************************************************************}
{*                             PROGRAMA SENHA                              *}
{*                                                                         *}
{* Autores: Flavio Duarte Pimentel                                         *}
{*          Rui Alexandre Parreira dos Santos                              *}
{*                                                                         *}
{***************************************************************************}

Program Jogo_da_Senha;
Uses dvWin, dvCRT;

Const Tam_Sen=4;

Type Palavra  = String [20];
     Resposta = String[4];

Var Num       : Byte;
    Senha     : Array [1..Tam_Sen] of Byte;
    Jogada    : Array [1..9,1..Tam_Sen] of Byte;
    Tentativa : Array [1..10] of Palavra;
    Resp      : Array [1..Tam_Sen] of Resposta;
    Acertou   : Boolean;

Procedure Inicializa;
Var Tecla : Char;
    Dir: string;
Begin
   Dir := sintambiente('SENHAVOX', 'DIRSENHAVOX');
   if Dir = '' then
      Dir := 'c:\winvox\som\senhavox';
   SintInic (0, Dir);

   ClrScr;

   textBackGround (blue);
   Writeln ('Bem vindo ao jogo SENHAVOX - Versão 1.0 !');
   textBackGround (black);
   Writeln;
   Write ('Deseja instrucoes (S/N) ? ');
   SintSom('Perg');
   Repeat
      Tecla := Upcase(sintReadkey);
      write (tecla);
   Until (Tecla = 'S') or (Tecla = 'N');
   Writeln;
   If Tecla = 'S' Then
     Begin
        Writeln;
        Writeln;
        Writeln('     O objetivo deste jogo e'' descobrir uma senha escolhida por mim.');
        writeln;
        Writeln('     Voce deve escolher quatro numeros de 0 a 5, sem repeticao, para');
        Writeln('tentar adivinhar a senha.  Se voce acertar o numero e o local do mesmo,');
        Writeln('voce escutara'': Plim; se acertar so'' o numero, escutara'': Poin;');
        Writeln('e se errar, escutara'': Clec.');
        Writeln;
        SintSom('Instru');             {****Som****}

        while sintFalando do;
        while keypressed do sintReadkey;
     End;
   ClrScr;
End;

Procedure Inicializa_Tent;

Begin
   Tentativa[1]  := 'Primeira';
   Tentativa[2]  := 'Segunda';
   Tentativa[3]  := 'Terceira';
   Tentativa[4]  := 'Quarta';
   Tentativa[5]  := 'Quinta';
   Tentativa[6]  := 'Sexta';
   Tentativa[7]  := 'Setima';
   Tentativa[8]  := 'Oitava';
   Tentativa[9]  := 'Nona';
   Tentativa[10] := 'Decima';
End;

Procedure Escolhe_Senha;
Var I, J, L, Tam : Byte;
    Aux : Array [0..9] of Byte;

Begin
   Randomize;
   Tam := 6;
   For I := 0 to Tam Do
      Aux[I] := I;
   For I := 1 to Tam_Sen Do
      Begin
         J := Random( Tam );
         Senha[I] := Aux[J];
         For L := J to Tam-1 Do
            Aux[L] := Aux[L+1];
         Tam := Tam-1;
      End;
End;

Function Analiza_Jogada( Vez : Byte; Mostra : Boolean) : Boolean; Forward;

Procedure Fala_Resposta( I : Byte );
Var J : Byte;

Begin
   SintSom(Tentativa[I]);
   SintSom('Tent');
   For J := 1 to Tam_Sen do
      SintSom(Chr(Jogada[I,J]+48));
   if Analiza_Jogada( I, False) then;
End;

Procedure Pega_Jogada(Vez : Byte);
Var I,J,H : Byte;
    N     : Integer;
    Tecla : Char;
    Achou : Boolean;

Begin
   if vez = 1 then
       begin
           clrscr;
           textBackground (BLUE);
           writeln ('S E N H A V O X');
           textBackGround (BLACK);
           writeln;
       end;

   Write(Tentativa[Vez],' tentativa',' ':9-Length(Tentativa[Vez]), ': ');
   SintSom(Tentativa[Vez]);
   delay (20);
   SintSom('Tent');
   I := 1;
   H := Vez;
   While I <= Tam_Sen Do
      Begin
         Achou := False;
         Tecla := sintReadkey;
         Case Tecla of
           #27:  begin     { desiste do jogo }
                     SintSom ('vaia');
                     Acertou := false;
                     num := 10;
                     exit;
                 end;

           #8 :  If (I > 1) Then
                             Begin
                                Achou := True;
                                Write(#8,#8,' ',#8);    {Backspace}
                                I := I - 1;
                             End
                   Else If I = 1 Then
                       Achou := True;
           #0 : Begin
                   Tecla := Readkey;
                   Achou := True;
                   Case Tecla of
                     #72 : If H > 1 Then                {seta para cima}
                             Begin
                                H := H-1;
                                Fala_Resposta( H );
                             End;
                     #71 : If H <> 1 Then               {home}
                             Begin
                                H := 1;
                                Fala_Resposta( H );
                             End;
                     #79 : If H < Vez-1 Then            {end}
                             Begin
                                H := Vez-1;
                                Fala_Resposta( H );
                             End;
                     #80 : If H < Vez-1 Then            {seta para baixo}
                             Begin
                                H := H+1;
                                Fala_Resposta( H );
                             End;
                     End;
                End;
         End;
         N := Ord(Tecla) - 48;
         If (N >= 0) and (N <= Tam_Sen+1) or (N = 23) or (N = 24) or
            (N = 31) or (N = 32) or (N = -40) Then {opcao valida}
           Begin
              If (N <> 23) and (N <> 24) and (N <> 31) and
                 (N <> 32) Then Write(Tecla,' ');
              For J := 1 to I-1 do
                 If N = Jogada[vez,j] then        {numero repetido}
                   Begin
                      Write(#8,#8);
                      SintSom('Num');
                      Achou := True;
                   End;
              If Not (Achou) Then
                Begin
                   Jogada[vez,I] := N;
                   I := I+1;
                End;
           End
         Else
             SintSom('Tecla');
      End;
End;

Function Analiza_Jogada(Vez : Byte; Mostra : Boolean) : Boolean;
Var I,J,L : Byte;

Begin
   Analiza_Jogada := False;
   Acertou := False;
   J := 1;
   For I := 1 to Tam_Sen Do
      If Jogada[Vez,I] = Senha[I] Then
        Begin
           Resp[J] := 'Plim';
           J := J+1;
        End;
   If J = 5 Then
     Begin
        Analiza_Jogada := True;
        Acertou := True;
     End;
   For I := 1 to Tam_Sen Do
      For L := 1 to Tam_Sen Do
          If (Jogada[Vez,L] = Senha[I]) and (I<>L) then
            Begin
               Resp[j] := 'Poin';
               J := J+1;
            End;
   For I := J to Tam_Sen do
      Resp[I] := 'Clec';
   If Mostra Then
     For I := 1 to Tam_Sen do
           Write(Resp[I],' ');
   For I := 1 to Tam_Sen Do
      SintSom(Resp[I]);
   delay (1000);
End;

Function Finaliza : Boolean;
Var Tecla : Char;

Begin
   Finaliza := False;
   Writeln;
   while keypressed do readkey;
   Write ('Deseja jogar de novo ? (S/N) ');
   SintSom('Jogo');
   Repeat
      Tecla := Upcase(sintReadkey);
      write (Tecla);
   Until (Tecla = 'S') or (Tecla = 'N');
   writeln;
   If Tecla = 'N' then
     Finaliza := True;
End;

{**************************** PROGRAMA PRINCIPAL ****************************}

Begin
   Inicializa;
   Repeat
      Inicializa_Tent;
      Escolhe_Senha;
      Num := 0;
      Repeat
          Writeln;
          Num := Num + 1;
          Pega_Jogada(Num);
      Until  Analiza_Jogada(Num,True) or (Num = 10);
      Writeln;
      If (Num = 10) and Not(Acertou) Then
        Begin
          Write('A senha era        : ');
          SintSom('Senha');
          For Num:=1 to Tam_Sen Do
             Begin
                Write( Senha[Num],' ' );
                SintCarac ( Chr(Senha[Num]+48) );
             End;
        End
        Else
           begin
              SintSom ('Aplauso');
              Case Num of
                1,2:   Begin
                          Writeln('Voce esta com muita sorte!');
                          SintSom('Sorte');
                       End;
                3,4,5: Begin
                          Writeln('Parabens voce joga muito bem!');
                          SintSom('Parab');
                       End;
                6,7,8: Begin
                          Writeln('Voce pode fazer melhor!');
                          SintSom('Melhor');
                       End;
                9,10:  Begin
                          Writeln('Quase que nao conseguiu, hein?');
                          SintSom('Quase');
                       End;
             End;
           end;
   Until Finaliza;
   writeln;
   writeln;
   textBackGround (BLUE);
   Write('Obrigado por ter usado o SENHAVOX.  TCHAU !');
   textBackGround (BLACK);
   SintSom ('Tchau');

   while sintFalando do;
   delay (2000);
   SintFim;
   doneWinCrt;
End.
