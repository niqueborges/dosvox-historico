program mbr;

uses
  SysUtils,
  dvcrt,
  mbrola,
  dvmacro,
  shellapi,
  windows;

var lprect: TRect;
var
   dir: string;

begin
   ScreenSize.y := 3;
   Clrscr;
   setWindowTitle('Ativação do Mbrola');
                                                 
   if (paramCount > 0) then
       begin
           GetWindowRect(GetDesktopWindow, lprect);
           mouseClick (lprect.right div 2, lprect.bottom div 2);
           sleep (3000);
           mouseClick (lprect.right div 2, lprect.bottom div 2);
           sleep (1000);
           keyboardVirtKey(VK_TAB, false, false, false, 100);
           keyboardVirtKey(VK_SPACE, false, false, false, 100);
       end
   else
       begin
           getDir (0, dir);
           dir := dir + '\mbr.exe';
           shellExecute(0,'open', @dir[1],'-k','\',SW_HIDE);
           load_MBR;
           unload_MBR;
       end;
   doneWinCrt;
end.

