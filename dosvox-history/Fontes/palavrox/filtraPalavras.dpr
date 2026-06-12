program filtraPalavras;

uses
  dvcrt,
  dvwin,
  dvdic,
  SysUtils,
  classes;

var sl: TStringList;
    dicStatus : integer;

procedure carregaDicionario;
begin
    dicStatus := carregaDic(
                 sintAmbiente('DICIONARIO', 'ARQDIC'),
                 sintAmbiente('DICIONARIO', 'ARQSUFIXOS'),
                 sintAmbiente('DICIONARIO', 'ARQINEXIST'),
                 sintAmbiente('DICIONARIO', 'ARQNOMES'),
                 sintAmbiente('DICIONARIO', 'ARQSUGERE') );
    if dicStatus <> 0 then
       writeln ('Dicionario nao achado');
end;

procedure filtra (nomearq: string);
var
  i, naoAchadas: integer;
begin
  writeln (nomearq);
  sl.LoadFromFile(nomeArq);
  naoAchadas := 0;

  writeln ('Originalmente: ', sl.count);
  for i := sl.Count-1 downto 0 do
      begin
          sl[i] := trim(sl[i]);
          if (sl[i] = '') or (pos (' ', sl[i]) <> 0) or (pos ('-', sl[i]) <> 0) or
              (not procuraDic(sl[i])) then
                 begin
                     sl.Delete(i);
                     inc(naoAchadas);
                 end;
      end;
  sl.saveToFile(nomeArq);
  writeln ('Não achadas: ', naoAchadas);
  writeln ('Agora: ', sl.count);
end;

begin
  chdir ('c:\winvox\som\palavrox');
  sl := TStringList.Create;
  carregaDicionario;

  filtra('nivel1.pal');
  filtra('nivel2.pal');
  filtra('nivel3.pal');
  readln;
end.

