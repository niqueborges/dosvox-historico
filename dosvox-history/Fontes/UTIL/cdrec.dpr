program cdrec;

uses
  dvcrt,
  dvcdrec,
  windows,
  classes,
  sysutils;

var i, ndrives, indGrav: integer;
    sl: TStringList;
    dir, nomeDisco, nomeArq, unidsLogs: string;
    c: char;
begin
    writeln ('gravando cd');
    if not inicializaCD then
        writeln ('Mifu');

    unidsLogs := pegaUnidsCD;

    writeln ('descobrindo drives');
    sl := listaDrivesCD;
    for i:= 0 to sl.count-1 do
        writeln (unidsLogs[i+1] + ' '+ sl[i]);
    ndrives := sl.count;
    sl.Free;

    if ndrives = 1 then
        begin
            indgrav := 0;
            writeln ('Unidade de gravação: ', unidsLogs);
    else
        begin
            writeln ('Escolha a unidade de gravação (', unidsLogs,'): ');
            readln (c);
            indGrav := pos (upcase(c), unidsLogs) - 1;
        end;

    writeln ('Informe o nome do CD a gravar');
    readln (nomeDisco);

    writeln ('Informe o nome do diretorio a gravar');
    readln (dir);
    if dir <> '' then
        begin
            writeln ('Transcrevendo arquivos para a área de montagem');
            writeln ('Esta é uma operação demorada');
            if not geraDirCD (dir) then
                writeln ('mifu');
        end;

    while true do
        begin
            writeln ('Informe o nome de um arquivo a gravar, em branco termina');
            readln (nomeArq);
            if nomeArq = '' then break;
            if not geraArqCD (dir) then
                writeln ('mifu');
        end;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          writeln ('Gerando a imagem do disco');
    if not criaImagemCD (nomeDisco, indGrav) then
        writeln ('mifu');

    writeln ('iniciando gravação, aperte enter');
    readln;
    if not gravaCd then;
        writeln ('mifu');

    finalizaCD;
readln;
end.
