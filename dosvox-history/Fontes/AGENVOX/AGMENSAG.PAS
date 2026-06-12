{--------------------------------------------------------}
{                     tratamento de mensagens
{--------------------------------------------------------}

unit agmensag;
interface
uses dvcrt, dvWin, agDados;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
Procedure limpatela;
Procedure limpabaixo;

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'AGINIC'   then s := 'AGENDA ELETRÔNICA - VOX - v.1.4'
    else
    if nomeArq = 'AGERRO'   then s := 'Erro no diretório do tradutor'
    else
    if nomeArq = 'AGOPCAO'  then s := 'Tecle a inicial de sua opcao: '
    else
    if nomeArq = 'AGTCHAU'  then s := 'Agenda fechada - até logo.'
    else
    if nomeArq = 'AGINFDIA' then s := 'Informe o dia/mes/ano: '
    else
    if nomeArq = 'AGERRDIA' then s := 'Dia incorreto'
    else
    if nomeArq = 'AGINFHOR' then s := 'Informe a hora desejada: '
    else
    if nomeArq = 'AGDIGITE' then s := 'Digite o compromisso a registrar: '
    else
    if nomeArq = 'AGLIVRE'  then s := 'Agenda livre'
    else
    if nomeArq = 'AGDUPLI'  then  s := 'Nao posso registrar dois compromissos na mesma hora'
    else
    if nomeArq = 'AGIGNORA' then s := 'Registro foi ignorado'
    else
    if nomeArq = 'AGERRHOR' then s := 'Hora incorreta'
    else
    if nomeArq = 'AGERRINC' then s := 'Erro ao incluir, nao coube na memória.'
    else
    if nomeArq = 'AGNOMARQ' then s := 'Digite o nome da agenda: '
    else
    if nomeArq = 'AGCARGA'  then s := 'Carregando a agenda na memória'
    else
    if nomeArq = 'AGERRLEI' then s := 'A agenda foi lida com erro do disco !'
    else
    if nomeArq = 'AGARQNOV' then s := 'Foi criada uma agenda nova.'
    else
    if nomeArq = 'AGNOMINV' then s := 'Este nome de agenda nao foi aceito'
    else
    if nomeArq = 'AGOK'     then s := 'OK !'
    else
    if nomeArq = 'AGERRGRV' then s := 'Erro na gravação do arquivo! '
    else
    if nomeArq = 'AGARQGRV' then s := 'Arquivo gravado'
    else
    if nomeArq = 'AGINSER'  then s := 'Registro foi inserido'
    else
    if nomeArq = 'AGCONFRM' then s := 'Tecle ''S'' para confirmar remoção de'
    else
    if nomeArq = 'AGSIMNAO' then s := '(S/N) ? '
    else
    if nomeArq = 'AGOPREM'  then s := 'Opção de remoção'
    else
    if nomeArq = 'AGREMOV'  then s := 'Ok, removido'
    else
    if nomeArq = 'AGREGMAR' then s := 'Registro foi marcado como especial'
    else
    if nomeArq = 'AGREGDSM' then s := 'Registro foi desmarcado como especial'
    else
    if nomeArq = 'AGINFPRO' then s := 'Informe o texto a procurar:'
    else
    if nomeArq = 'AGPROCAN' then s := 'Procura cancelada'
    else
    if nomeArq = 'AGACHEI'  then s := 'Achei.'
    else
    if nomeArq = 'AGPODEDI' then {s := 'Pode editar')}
    else
    if nomeArq = 'AGQUERAL' then s := 'Confirme a alteração no compromisso (s/n): '
    else
    if nomeArq = 'AGNAOALT' then s := 'O registro nao foi alterado'
    else
    if nomeArq = 'AGALT'    then s := 'O registro foi alterado'
    else
    if nomeArq = 'AGNAOACH' then s := 'Nao encontrei mais ninguem.'
    else
    if nomeArq = 'AGPODEDI' then s := 'Pode editar:'
    else
    if nomeArq = 'AGVAZIA'  then s := 'Agenda vazia'
    else
    if nomeArq = 'AGSETAS'  then s := 'Use as setas para ler os compromissos. ESC termina.'
    else
    if nomeArq = 'AGAJUDA0' then  s := 'Os controles da agenda são: '
    else
    if nomeArq = 'AGAJUDA1' then  s := '   D - selecionar dia'
    else
    if nomeArq = 'AGAJUDA2' then  s := '   H - selecionar hora'
    else
    if nomeArq = 'AGAJUDA3' then  s := '   I - incluir um compromisso'
    else
    if nomeArq = 'AGAJUDA4' then  s := '   E - editar compromissos existentes'
    else
    if nomeArq = 'AGAJUDA5' then  s := '   P - procurar um compromisso'
    else
    if nomeArq = 'AGAJUDA6' then  s := '   R - remover um compromisso'
    else
    if nomeArq = 'AGAJUDA7' then  s := '   * - por uma marca especial num compromisso'
    else
    if nomeArq = 'AGAJUDA9' then  s := '   ESC - terminar a agenda'
    else
    if nomeArq = 'AGPLIM' then
        begin
            s := '';
            delay (500);
        end

    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;

begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom (nomearq) then
        sintSom (nomearq)
    else
        sintetiza (s);
end;

{--------------------------------------------------------}
{                    limpa a tela
{--------------------------------------------------------}

Procedure limpatela;
var i: integer;
begin
    gotoxy (1, 1);
    textBackground (BLUE);
    writeln ('  **     *****   ******   *    **   **   **   *****   **   **');
    writeln ('**  **  **    *  **       **   **   **   **  **   **   ** ** ');
    writeln ('**  **  **       **       ***  **   **   **  **   **    ***  ');
    writeln ('******  **  ***  *****    **** **   **   **  **   **     *   ');
    writeln ('**  **  **   **  **       ** ****    ** **   **   **    ***  ');
    writeln ('**  **  **   **  **       **  ***     ***    **   **   ** ** ');
    writeln ('**  **   *****   *******  **   **      *      *****   **   **');
    textBackground (BLACK);
    writeln;
    writeln ( 'AGENDA ELETRONICA - VOX' );

    for i := 11 to 25 do
       begin
           gotoxy (1, i);
           clreol;
       end;
end;

{--------------------------------------------------------}
{                 limpa a tela em baixo
{--------------------------------------------------------}

Procedure limpabaixo;
var i: integer;
begin
    for i := 12 to 25 do
       begin
           gotoxy (1, i);
           clreol;
       end;
    gotoxy (1, 12);
end;

end.
