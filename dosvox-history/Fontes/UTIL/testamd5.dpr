program testamd5;

uses
  dvwin,
  dvcrt,
  dvarq,
  umd5,
  classes,
  sysutils;

var
    s, criptog, binaryResult, nomearq: string;
    MD5: TMD5Stream;
    l: TStringList;
    p: pchar;

const
    cr = ^m^j;

var i: integer;
begin
  sintInic (0, '');
  sintWriteln ('Qual o nome do arquivo a calcular');
  nomearq := obtemNomeArq(10);
  writeln (nomeArq);

  l := TStringList.create;
  l.LoadFromFile(nomeArq);

{$r-}
  MD5 := TMD5Stream.Create;
  for i := 0 to l.count-1 do
  begin
    MD5.WriteBuffer(l[i][1], Length(l[i]));
    MD5.WriteBuffer(cr[1], 2);
  end;
  binaryResult := MD5.DigestString;

  for i := 1 to Length(binaryResult) do
    criptog := criptog + Format('%.2x', [Ord(BinaryResult[I])]);

  l.free;
  MD5.Free;

  sintEdita (criptog, wherex, wherey, 160, true);
  sintFim;
  doneWincrt;

end.

