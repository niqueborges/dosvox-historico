{--------------------------------------------------------}
{
{      Simulador de mouse e teclado
{
{      Vers„o 2 - n„o usa biblioteca externa
{
{      Autor: JosÈ Antonio Borges
{
{      Em 11/05/2008
{
{--------------------------------------------------------}

unit dvmacro;
interface
uses windows, messages, sysUtils;

    procedure SendKeyDown(VKey: Byte; NumTimes: Word; GenUpMsg :Boolean);
    procedure SendKeyUp(VKey: Byte);
    procedure SendKey(MKey: Word; NumTimes: Word; GenUpMsg: Boolean);

    procedure keyboardClick (letra: char);
    procedure keyboardChar (letra: char; delay: integer);
    procedure keyboardAlt (letra: char; delay: integer);
    procedure keyboardString (s: string; delay: integer);
    procedure keyboardVirtKey (key: byte; comControl, comShift, comAlt: boolean; delay: integer);

    procedure mouseMove (x, y: integer);
    procedure mouseClick (x, y: integer);
    procedure mouseRightClick (x, y: integer);
    procedure mouseDoubleClick (x, y: integer);
    procedure mouseBeginDrag (x, y: integer);
    procedure mouseContinueDrag (x, y: integer);
    procedure mouseEndDrag (x, y: integer);
    procedure mouseShiftClick (x, y: integer);
    procedure mouseControlClick (x, y: integer);

implementation

const
    ExtendedVKeys : set of byte =
        [VK_Up,
         VK_Down,
         VK_Left,
         VK_Right,
         VK_Home,
         VK_End,
         VK_Prior,  {PgUp}
         VK_Next,   {PgDn}
         VK_Insert,
         VK_Delete];

const
    VKKEYSCANSHIFTON = $01;
    VKKEYSCANCTRLON = $02;
    VKKEYSCANALTON = $04;

{--------------- simulaÁ„o de teclado ----------------}

function BitSet (BitTable, BitMask: Byte): Boolean;
begin
    Result := ByteBool(BitTable and BitMask);
end;

procedure SetBit (var BitTable: Byte; BitMask: Byte);
begin
    BitTable := BitTable or Bitmask;
end;

procedure KeyboardEvent (VKey, ScanCode: Byte; Flags: Longint);
var
  KeyboardMsg : TMsg;
begin
    keybd_event(VKey, ScanCode, Flags,0);
    While (PeekMessage(KeyboardMsg,0,WM_KEYFIRST, WM_KEYLAST, PM_REMOVE)) do
        begin
            TranslateMessage(KeyboardMsg);
            DispatchMessage(KeyboardMsg);
        end;
end;

procedure SendKeyDown(VKey: Byte; NumTimes: Word; GenUpMsg :Boolean);
var
    Cnt : Word;
    ScanCode : Byte;
    NumState : Boolean;
    KeyBoardState : TKeyboardState;

begin
    If (VKey=VK_NUMLOCK) then
        begin
            NumState:=ByteBool(GetKeyState(VK_NUMLOCK) and 1);
            GetKeyBoardState(KeyBoardState);
            If NumState then
                KeyBoardState[VK_NUMLOCK]:=(KeyBoardState[VK_NUMLOCK] and not 1)
            else
                KeyBoardState[VK_NUMLOCK]:=(KeyBoardState[VK_NUMLOCK] or 1);
            SetKeyBoardState(KeyBoardState);
            exit;
        end;

    ScanCode:=Lo(MapVirtualKey(VKey,0));
    For Cnt:=1 to NumTimes do
        If (VKey in ExtendedVKeys)then
            begin
                KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY);
                If (GenUpMsg) then
                    KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP)
            end
        else
            begin
                KeyboardEvent(VKey, ScanCode, 0);
                If (GenUpMsg) then
                    KeyboardEvent(VKey, ScanCode, KEYEVENTF_KEYUP);
            end;
end;

procedure SendKeyUp(VKey: Byte);
var
    ScanCode : Byte;
begin
    ScanCode:=Lo(MapVirtualKey(VKey,0));
    If (VKey in ExtendedVKeys)then
        KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY and KEYEVENTF_KEYUP)
    else
        KeyboardEvent(VKey, ScanCode, KEYEVENTF_KEYUP);
end;

Procedure SendKey(MKey: Word; NumTimes: Word; GenUpMsg: Boolean);
begin
    If (BitSet(Hi(MKey),VKKEYSCANSHIFTON)) then
        SendKeyDown(VK_SHIFT,1,False);
    If (BitSet(Hi(MKey),VKKEYSCANCTRLON)) then
        SendKeyDown(VK_CONTROL,1,False);
    If (BitSet(Hi(MKey),VKKEYSCANALTON)) then
        SendKeyDown(VK_MENU,1,False);

    SendKeyDown(Lo(MKey), NumTimes, GenUpMsg);

    If (BitSet(Hi(MKey),VKKEYSCANSHIFTON)) then
        SendKeyUp(VK_SHIFT);
    If (BitSet(Hi(MKey),VKKEYSCANCTRLON)) then
        SendKeyUp(VK_CONTROL);
    If (BitSet(Hi(MKey),VKKEYSCANALTON)) then
        SendKeyUp(VK_MENU);
end;

procedure keyboardClick (letra: char);
begin
    if ord (letra) in [32..127] then
        begin
            SendKeyDown(vkKeyScan (letra), 1, false);
            sleep (1);
            SendKeyUp(vkKeyScan (letra));
            sleep (1);
        end
    else
        keyboardChar (letra, 1);
end;

procedure keyboardChar (letra: char; delay: integer);
const
    tabAcentos: string =
        '_Ä_Å_Ç_É_Ñ_Ö_Ü_á_à_â_ä_ã_å_ç_é_è' +
        '_ê_ë_í_ì_î_ï_ñ_ó_ò_ô_ö_õ_ú_ù_û®Y' +
        '_†_°_¢_£_§_•_¶_ß_®_©_™_´_¨_≠_Æ_Ø' +
        '_∞_±_≤_≥_¥_µ_∂_∑_∏_π_∫_ª_º_Ω_æ_ø' +
        '`A¥A^A~A®A_≈_∆_«`E¥E^E®E`I¥I^I®I' +
        '_–~N`O¥O^O~O®O_◊_ÿ`U¥U^U®U¥Y_ﬁ_ﬂ' +
        '`a¥a^a~a®a_Â_Ê_Á`e¥e^e®e`i¥i^i®i' +
        '_~n`o¥o^o~o®o_˜_¯`u¥u^u®u¥y_˛®y';
var
    l1, l2: char;
    k, p: integer;

begin
    if ord (letra) in [32..127] then
        SendKey(vkKeyScan (letra), 1, true)
    else
    if ord (letra) < 32 then
        keyboardVirtKey (ord(letra) + $40, true, false, false, delay)
    else
        begin
            p := (ord(letra) - 128) * 2 + 1;
            l1 := tabAcentos [p];
            l2 := tabAcentos [p+1];
            if l1 <> '_' then
                SendKey(vkKeyScan (l1), 1, true);
            k := vkKeyScan (l2);
            if k >= 0 then
                SendKey(vkKeyScan (l2), 1, true)
            else
                SendKey(vkKeyScan (' '), 1, true)
        end;
    if delay <> 0 then sleep (delay);
end;

procedure keyboardAlt (letra: char; delay: integer);
begin
    SendKey (word(vkKeyScan (letra)) or (VKKEYSCANALTON shl 8), 1, true);
    if delay <> 0 then sleep (delay);
end;

procedure keyboardString (s: string; delay: integer);
var i: integer;
begin
    for i := 1 to length (s) do
         keyboardChar (s[i], delay);
end;

procedure keyboardVirtKey (key: byte; comControl, comShift, comAlt: boolean; delay: integer);
var k: word;
begin
    k := key;
    if comControl then k := k or (VKKEYSCANCTRLON shl 8);
    if comShift   then k := k or (VKKEYSCANSHIFTON shl 8);
    if comAlt     then k := k or (VKKEYSCANALTON shl 8);

    SendKey (k, 1, true);
    if delay <> 0 then sleep (delay);
end;

{--------------- simulaÁ„o de mouse ----------------}

procedure mouseMove (x, y: integer);
begin
    SetCursorPos(x, y);
end;

procedure mouseClick (x, y: integer);
begin
    SetCursorPos(x, y);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure mouseRightClick (x, y: integer);
begin
    SetCursorPos(x, y);
    mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
end;

procedure mouseDoubleClick (x, y: integer);
begin
    SetCursorPos(x, y);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    GetDoubleClickTime;
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure mouseShiftClick (x, y: integer);
begin
    SetCursorPos(x, y);

    SendKeyDown(VK_SHIFT, 1, false);
    sleep (20);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    SendKeyUp(VK_SHIFT);
    sleep (20);
end;

procedure mouseControlClick (x, y: integer);
begin
    SetCursorPos(x, y);

    SendKeyDown(VK_CONTROL, 1, false);
    sleep (20);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    SendKeyUp(VK_CONTROL);
    sleep (20);
end;

procedure mouseBeginDrag (x, y: integer);
begin
    SetCursorPos(x, y);
    mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
end;

procedure mouseContinueDrag (x, y: integer);
begin
    SetCursorPos(x, y);
end;

procedure mouseEndDrag (x, y: integer);
begin
    SetCursorPos(x, y);
    mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

end.
