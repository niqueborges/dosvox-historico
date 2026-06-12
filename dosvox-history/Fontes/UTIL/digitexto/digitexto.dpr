program digitexto;

uses
  dvcrt,
  dvwin,
  dvarq,
  dvdigitexto,
  classes,
  sysutils;

var
    texto: TStringList;
    nomeArq, nomeSai: string;
    c, c2: char;

begin
    sintInic (0, '');

    sintWriteln ('Teste do componente de edição popup dos programas do Dosvox 5.0');
    writeln;
    texto := TStringList.Create;
    chdir (sintAmbiente ('DOSVOX', 'DIRDEFAULT'));
    sintWriteln ('Informe o nome do arquivo a editar: ');
    nomeArq := obtemNomeArq(10);
    writeln (nomeArq);
    writeln;
    if nomeArq = '' then halt;

    if fileExists(nomeArq) then
        texto.LoadFromFile(nomeArq);

    sintWrite ('Quer paragrafar automaticamente? ');
    sintLeTecla (c, c2);
    writeln;
    popupdigiTexto (texto, upcase(c) = 'S', true, wherex+5, wherey, 70, 15, false);

    writeln;
    sintWriteln ('Informe o nome do arquivo de saida: ');
    nomeSai := obtemNomeArq(10);
    if nomeSai <> '' then
        texto.saveToFile (nomeSai);
    texto.free;

    doneWinCrt;
end.

