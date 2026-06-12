unit hardmem;

interface
uses
  dvCrt,
  dvExec,
  dvWin,
  dvForm,
  windows,
  sysutils,
  hardmsg;

procedure infoMemoria;

implementation


procedure campo (msg: string; var valor: shortString);
begin
    formCampo(msg, pegaTextoMensagem(msg), valor, 40);
end;

//-----------------------------------------------------------------

type
  TMemoryStatusEx = record
     dwLength : DWORD;
     dwMemoryLoad : DWORD;
     ullTotalPhys : int64;
     ullAvailPhys : int64;
     ullTotalPageFile : int64;
     ullAvailPageFile : int64;
     ullTotalVirtual : int64;
     ullAvailVirtual : int64;
     ullAvailExtendedVirtual : int64;
  end;

function GlobalMemoryStatusEx(var Buffer: TMemoryStatusEx): BOOL; stdcall;
                              external 'kernel32' name 'GlobalMemoryStatusEx';
//-----------------------------------------------------------------

procedure infoMemoria;
var
    MemoryStatus: TMemoryStatusEx;
    sval: array [1..18] of shortString;

begin
    MemoryStatus.dwLength := SizeOf(MemoryStatus) ;
    GlobalMemoryStatusEx(MemoryStatus) ;

    garanteEspacoTela(7);
    writeln;

    defineNovoTamanhoDeRotulos(55);
    formCria;

    with MemoryStatus do
        begin
            sval[1] := IntToStr(int64(ullTotalPhys) div (1024 * 1024));
            campo ('HVMEMFIS', sval[1]);   // 'Memória Física total em mb'

            sval[2] := IntToStr(int64(ullAvailPhys) div (1024 * 1024));
            campo ('HVMEMDIS', sval[2]);   // 'Memória física disponível'

            sval[3] := IntToStr(dwMemoryLoad);
            campo ('HVMEMUSO', sval[3]);   // '% de memória em uso'

            sval[4] := IntToStr(int64(ullTotalPageFile) div (1024 * 1024));
            campo ('HVARQPAG', sval[4]);   // 'Tamanho do arquivo de paginação'

            sval[5] := IntToStr(int64(ullAvailPageFile) div (1024 * 1024));
            campo ('HVDISPAG', sval[5]);   // 'Disponível no arquivo de paginação'

            sval[6] := IntToStr(int64(ullTotalVirtual) div (1024 * 1024));
            campo ('HVENDMB',  sval[6]);   // 'Espaço de endereçamento do usuário em mb'

            sval[7] := IntToStr(ullAvailVirtual div (1024 * 1024));
            campo ('HVENDDIS', sval[7]);   // 'Disponível no Espaço de endereçamento do usuário'

            formEdita (false);
            restauraTamanhoDeRotulos;
        end;
end;

end.
