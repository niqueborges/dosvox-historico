unit dosHoraDia;

interface
uses
    windows, sysutils, classes,
    dvcrt, dvwin,
    dvHora, dvArq, dosmsg, dvForm, messages,
    dosVars;

procedure mostraDataHora;
procedure alteraDataHora;
procedure calculaDiaDaSemana;

implementation

{--------------------------------------------------------}
{                 fala o dia e a hora
{--------------------------------------------------------}

procedure mostraDataHora;
var
    hora, minuto, segundo, cent: word;
    diaSemana, dia, mes, ano: word;

    function d2 (n: integer): string;
    begin
         result := intToStr(n);
         if length(result) = 1 then result := '0' + result;
    end;

begin
    getDate (ano, mes, dia, diaSemana);
    dvcrt.gettime (hora, minuto, segundo, cent);

    writeln;
    writeln (tabNomesDias[diaSemana+1], ', ',
             d2(dia), '/', d2(mes), '/', ano, ' - ',
             d2(hora), ':', d2(minuto), ':', d2(segundo));
    writeln;
    writeln;

    falaDiaQualquer (dia, mes, ano);
    falaHoraQualquer (hora, minuto);
end;

{--------------------------------------------------------}

procedure ajustaPrivilegios;
const
    SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege';
var
    hToken: THandle;
    luid: TLargeInteger;
    ReturnLength: DWORD;
    tkp, PrevTokenPriv: TTokenPrivileges;
begin
    if (Win32Platform = VER_PLATFORM_WIN32_NT) then
        begin
            if OpenProcessToken(GetCurrentProcess,
                      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
                begin
                    try
                        if not LookupPrivilegeValue(nil, SE_SYSTEMTIME_NAME, luid) then Exit;
                        tkp.PrivilegeCount := 1;
                        tkp.Privileges[0].luid := luid;
                        tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
                        if not AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TTOKENPRIVILEGES),
                                                PrevTokenPriv, ReturnLength) then
                                Exit;
                        if (GetLastError <> ERROR_SUCCESS) then
                            begin
                               mensagem ('DV_NOPRV', 1);  // Para mudar a hora é rodar o Dosvox em modo administrador.
                               Exit;
                            end;
                    finally
                          CloseHandle(hToken);
                    end;
                end;
        end;
end;

{--------------------------------------------------------}
{                 altera o relógio
{--------------------------------------------------------}

procedure alteraDataHora;
var
    hora, minuto, segundo, cent: word;
    diaSemana, dia, mes, ano: word;

    hh, mm, d, m, a: integer;
    c: char;

    SystemTime: TSystemTime;

begin
    writeln;
    garanteEspacoTela(10);

    getDate (ano, mes, dia, diaSemana);
    a := ano;
    m := mes;
    d := dia;
    dvcrt.gettime (hora, minuto, segundo, cent);
    hh := hora;
    mm := minuto;

    mensagem ('DV_EDDIA', 1);  {'Editore dia e hora, use as setas, ESC termina'}
    formCria;
    formCampoInt('DV_HORA',  'Hora', hh);
    formCampoInt('DV_MINUT', 'Minuto', mm);
    formCampoInt('DV_DIA',   'Dia', d);
    formCampoInt('DV_MES',   'Mês', m);
    formCampoInt('DV_ANO',   'Ano', a);
    formEdita(true);

    writeln;
    mensagem ('DV_CONFIRMA', 0);   {'Confirma? '}
    c := popupMenuPorLetra('SN');
    if (c = ESC) or (c = 'N') then
        mensagem ('DV_DESIST', 2)       {'Desistiu...'}
    else
        begin
            ajustaPrivilegios;
            fillChar (SystemTime, sizeOf(SystemTime), 0);
            SystemTime.wYear := a;
            SystemTime.wMonth := m;
            SystemTime.wDay := d;
            SystemTime.wHour := hh;
            SystemTime.wMinute := mm;
            SystemTime.wSecond := 0;
            SystemTime.wMilliseconds := 0;
            SetLocalTime(SystemTime);
            PostMessage(HWND_BROADCAST, WM_TIMECHANGE, 0, 0);
        end;
end;

{--------------------------------------------------------}
{                 Retorna true se todos os caracteres forem números
{-------------------------------------------------------------}

function tudoNumeral (s: string): boolean;
var l: integer;
begin
    for l := 1 to length(s) do
        if not (s[l] in ['0' .. '9']) then
            begin
                result := false;
                exit;
            end;

    result := true;
end;

{--------------------------------------------------------}
{                 Fala a data completa com o dia da semana
{--------------------------------------------------------}

procedure calculaDiaDaSemana;
var
    s, dia, mes, ano: string;
    d2, m2, a2, s2: word;
begin
    writeln;
    mensagem ('DV_DIADESEJ', 0);   {'Qual o dia desejado? No formato dia/mês/ano '}
    sintReadln (s);
    s := trim (s);
    if s = '' then exit;

    // Acerta número de dígitos do dia, mês e ano
    dia := copy(s, 1, pos('/', s)-1);
    if length (dia) = 1 then dia := '0' + dia;
    delete (s, 1, pos('/', s));
    mes := copy(s, 1, pos('/', s)-1);
    if length (mes) = 1 then mes := '0' + mes;
    delete (s, 1, pos('/', s));
    ano := s;
    if length (ano) < 4 then
        begin
            getDate (a2, m2, d2, s2);
            str (a2, s);
            ano := copy(s, 1, 4-length(ano)) + ano;
        end;
    // Refaz a variável da entrada.
    s := dia + '/' + mes + '/' + ano;

    if (length(s) <> 10) or
       (s[3] <> '/') or
       (s[6] <> '/') or
       (not tudoNumeral (dia)) or
       (not tudoNumeral (mes)) or
       (not tudoNumeral (ano)) then
        begin
            mensagem ('DV_DATAINV', 0); {'Data inválida.'}
            exit;
        end;

    // Para testar se a data é uma data válida.
    try
        formatdatetime('AAAA, DD/MM/YYYY', strToDate(s));
    except
        mensagem ('DV_DATAINV', 2); {'Data inválida.'}
        exit;
    end;

    writeln (diaPorExtenso (strToInt(dia), strToInt(mes), strToInt(ano)));
    falaDiaQualquer (strToInt(dia), strToInt(mes), strToInt(ano));
end;

{--------------------------------------------------------}

begin
end.
