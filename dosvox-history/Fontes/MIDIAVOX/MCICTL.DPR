{ Teste interativo de comandos do MCI }
{ Autor: José Antonio Borges }
{ Em 5/2/98 }

uses
    dvcrt, dvwin,
    winprocs, wintypes, sysUtils, mmsystem;

var
    comando, retorno: array [0..150] of char;
    s: string;
    erro: longint;
    c: char;

label fim;

begin
     writeln;
     sintInic (0, '');
     sintWriteLn('Digite janela para saber o número da janela atual');
     while true do
     begin
         sintWriteln ('Entre comando MCI');
         s := '';
         c := sintEdita(s, wherex, wherey, 255, true);
         writeln;
         if c = ESC then goto fim;
         if s = '' then continue;
         if UpperCase(trim (s)) = 'JANELA' then
         begin
             sintWriteln ('Janela: ' + IntToStr(crtwindow));
             continue;
         end;
         if uppercase (trim (s)) = 'CLS' then
         begin
            Clrscr;
            continue;
         end;

         strPCopy (comando, s);
         erro := mciSendString(comando, retorno, 80, 0);
         if erro <> 0 then
             begin
                 mciGetErrorString(erro, retorno, 80);
                 sintWriteln (strPas (retorno));
             end
         else
             if strLen (retorno) <> 0 then
                 sintWriteln ('retorno ' + strPas(retorno));
     end;

fim:
     sintfim;
     doneWinCrt;
end.
