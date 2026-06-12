unit brdevice;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Printers, winSpool, brvars;

function abreDispositivo (nomeDisp: string): boolean;
procedure fechaDispositivo;
function escreveDispositivo (s: string): boolean;

var
    dispositivo: string;

implementation
uses brcom, brlpt;

var
    arqSai: textFile;
    hPrn: THandle;

function StartRawPrintJob(PrinterName: pChar; Port: pChar; DocName: pChar) : THandle;
var
   hPrn : THandle;
   DocInfo1 : TDocInfo1;

begin
   Result := THandle(-1);
   if not OpenPrinter(PChar(PrinterName), hPrn, nil)  then Exit;

   DocInfo1.pDocName := DocName;
   DocInfo1.pOutputFile := Port;
   DocInfo1.pDataType := 'RAW';
   if StartDocPrinter(hPrn, 1, @DocInfo1) = 0 then Exit;

   Result := hPrn;
end;

function prnPrint (s: string): boolean;
var
    nesc: cardinal;

begin
    result := true;
    while (s <> '') and (s[1] = #$0c) do
        begin
            WritePrinter(hPrn, @s[1], 1, nesc);
            EndPagePrinter(hPrn);
            delete (s, 1, 1);
            StartPagePrinter(hPrn);
        end;

    if s <> '' then   // sempre vem CRLF, exceto no último salto de página
        begin
            WritePrinter(hPrn, @s[1], length(s), nesc);
            result := integer(nesc) = integer(length(s));
        end;
end;

function abreDispositivo (nomeDisp: string): boolean;
begin
    abreDispositivo := true;
    dispositivo := nomeDisp;
    charUpper (pchar(dispositivo));

    if (dispositivo = 'COM1') or (dispositivo = 'COM2') then
        abreDispositivo := abreCom (dispositivo)
    else
    if (dispositivo = 'LPT1') or (dispositivo = 'LPT2') or (dispositivo = 'LPT3') then
        abreDispositivo := abreLpt (dispositivo)
    else
    if dispositivo = 'PRN' then
        begin
            printer.GetPrinter(adev, adriv, aport, adevmode);
            hPrn := StartRawPrintJob(adev, aport, pchar(nomeArq));
            if hprn <> THandle(-1) then
                StartPagePrinter(hPrn)
            else
                abreDispositivo := false;
        end
    else
        begin
            assignFile (arqSai, nomeDisp);
            dispositivo := nomeDisp;
            try
                rewrite (arqSai);
            except
                abreDispositivo := false;
            end;
        end;
end;

function escreveDispositivo (s: string): boolean;
begin
    if (dispositivo = 'COM1') or (dispositivo = 'COM2') then
        escreveDispositivo := escreveCom (s)
    else
    if (dispositivo = 'LPT1') or (dispositivo = 'LPT2') or (dispositivo = 'LPT3') then
        escreveDispositivo := escreveLpt (s)
    else
    if dispositivo = 'PRN' then
        escreveDispositivo := prnPrint (s)
    else
        try
            escreveDispositivo := true;
            write (arqSai, s);
        except
            escreveDispositivo := false;
        end;
end;

procedure fechaDispositivo;
begin
    if (dispositivo = 'COM1') or (dispositivo = 'COM2') then
        fechaCom
    else
    if (dispositivo = 'LPT1') or (dispositivo = 'LPT2') or (dispositivo = 'LPT3') then
        fechaLpt
    else
    if dispositivo = 'PRN' then
        begin
            EndPagePrinter(hPrn);
            EndDocPrinter(hPrn);
            ClosePrinter(hPrn);
        end
    else
        try
            closeFile (arqSai);
        except end;
end;

end.


