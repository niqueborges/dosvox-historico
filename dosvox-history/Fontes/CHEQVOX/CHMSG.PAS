{--------------------------------------------------------}
{
{    Programa para emissão de cheques
{
{    Módulo de variáveis
{
{    Autor: Antonio Borges
{
{    Em Agosto de 2001
{
{--------------------------------------------------------}

{$N+}

unit chMsg;

interface
uses dvcrt, dvwin, windows, chvars;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure bipSpeaker (pitch: integer);
procedure titulo;


implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'CHINIC'   then   s := 'Cheque Vox - versão '
    else
    if nomeArq = 'CHBANATU' then   s := 'Banco atual: '
    else
    if nomeArq = 'CHOPCAO'  then   s := 'Sua opção: '
    else
    if nomeArq = 'CHF1AJUD' then   s := 'Aperte F1 se precisar de ajuda.'
    else
    if nomeArq = 'CHFIM'    then   s := 'Fim do programa'
    else
    if nomeArq = 'CHAJUD0'  then   s := 'As opções são:'
    else
    if nomeArq = 'CHAJUD1'  then   s := '   C  configurar'
    else
    if nomeArq = 'CHAJUD2'  then   s := '   E  emitir cheque'
    else
    if nomeArq = 'CHAJUD3'  then   s := '   L  lançamento bancário'
    else
    if nomeArq = 'CHAJUD4'  then   s := '   F  folhear lançamentos'
    else
    if nomeArq = 'CHAJUD5'  then   s := '   X  gera extrato dos lançamentos'
    else
    if nomeArq = 'CHAJUD9'  then   s := '   ESC  fim'
    else
    if nomeArq = 'CHOPCONF' then   s := 'O que deseja configurar?'
    else
    if nomeArq = 'CHAJC0'   then   s := 'As opções de configuração são:'
    else
    if nomeArq = 'CHAJC1'   then   s := '   P    altera dados pessoais'
    else
    if nomeArq = 'CHAJC2'   then   s := '   N    registra novo banco'
    else
    if nomeArq = 'CHAJC3'   then   s := '   B    troca banco atual'
    else
    if nomeArq = 'CHAJC4'   then   s := '   C    altera a configuração do banco atual'
    else
    if nomeArq = 'CHAJC5'   then   s := '   R    remove um banco registrado'
    else
    if nomeArq = 'CHAJC9'   then   s := '   ESC  fim das configurações'
    else
    if nomeArq = 'CHOKCONF' then   s := 'Ok, configurado'
    else
    if nomeArq = 'CHALTPES' then   s := 'Use as setas para alterar os dados pessoais, ESC termina'
    else
    if nomeArq = 'CHSEMREG' then   s := 'Nenhum banco foi registrado'
    else
    if nomeArq = 'CHCNFNOV' then   s := 'Por favor, configure o banco atual'
    else
    if nomeArq = 'CHSELBNK' then   s := 'Use as setas para selecionar o banco, ESC termina'
    else
    if nomeArq = 'CHEXECAD' then   s := 'Dados estão incompletos, atualize seus dados pessoais'
    else
    if nomeArq = 'CHDESIST' then   s := 'Desistiu...'
    else
    if nomeArq = 'CHNOVBNK' then   s := 'Informe o nome do novo banco'
    else
    if nomeArq = 'CHPREVRG' then   s := 'Atenção, este banco havia sido anteriormente cadastrado'
    else
    if nomeArq = 'CHAJUSP'  then   s := 'Ajustando posições de escrita.'
    else
    if nomeArq = 'CHREGUA'  then   s := 'Alguém vai ajudá-lo a medir com uma régua.'
    else
    if nomeArq = 'CHPRECHE' then   s := 'Preencha os dados a seguir para pré-edição do cheque.'
    else
    if nomeArq = 'CHCAMPOB' then   s := 'Os campos com * são opcionais, porém desejáveis.'
    else
    if nomeArq = 'CHINIMPR' then   s := 'Posso iniciar a impressão? '
    else
    if nomeArq = 'CHOPINV'  then   s := 'Opção inválida, aperte F1 para ajuda'
    else
    if nomeArq = 'CHVERERR' then   s := 'Quer corrigir os erros e tentar de novo? '
    else
    if nomeArq = 'CHREEDIT' then   s := 'Reveja os campos do cheque.'
    else
    if nomeArq = 'CHDATERR' then   s := 'Campo data está com erro, aperte enter'
    else
    if nomeArq = 'CHVALERR' then   s := 'Campo valor está com erro, aperte enter'
    else
    if nomeArq = 'CHDCERR'  then   s := 'Campo débito/crédito está com erro, aperte enter'
    else
    if nomeArq = 'CHVALINV' then   s := 'Valor inválido, não use pontos.  Use vírgula e 2 dígitos nos centavos.'
    else
    if nomeArq = 'CHDATINV' then   s := 'Data inválida'
    else
    if nomeArq = 'CHFRENT'  then   s := 'Coloque a frente do cheque na impressora e aperte ENTER'
    else
    if nomeArq = 'CHVERSO'  then   s := 'Coloque o verso do cheque na impressora e aperte ENTER para imprimir'
    else
    if nomeArq = 'CHVERSO2' then   s := 'ESC não quiser dados no verso'
    else
    if nomeArq = 'CHAJUSTE' then   s := 'Últimos ajustes, edite como vai ser impresso'
    else
    if nomeArq = 'CHPREFOR' then   s := 'Preencha o formulário com o lançamento a registrar'
    else
    if nomeArq = 'CHCAMOPC' then   s := 'Os campos com * são opcionais'
    else
    if nomeArq = 'CHOKLANC' then   s := 'Ok, lançado'
    else
    if nomeArq = 'CHLANNAO' then   s := 'Lançamento não foi registrado.  Nome do arquivo não foi definido.'
    else
    if nomeArq = 'CHLANERR' then   s := 'Lançamento não foi registrado.  Erro no arquivo de lançamentos.'
    else
    if nomeArq = 'CHARQNDF' then   s := 'Nome do arquivo de lançamentos não foi definido.'
    else
    if nomeArq = 'CHARQERR' then   s := 'Arquivo de lançamentos está vazio ou não foi achado.'
    else
    if nomeArq = 'CHLANREG' then   s := 'Lançamento foi registrado'
    else
    if nomeArq = 'CHLANNAT' then   s := 'Erro no arquivo de lançamentos.'
    else
    if nomeArq = 'CHAJFL00' then   s := 'Opções de folheamento:'
    else
    if nomeArq = 'CHAJFL01' then   s := 'E - editar'
    else
    if nomeArq = 'CHAJFL02' then   s := 'R - remover lançamento'
    else
    if nomeArq = 'CHAJFL03' then   s := 'N - novo lançamento'
    else
    if nomeArq = 'CHAJFL04' then   s := 'S - saldo final'
    else
    if nomeArq = 'CHAJFL05' then   s := 'F5 - procura um lançamento'
    else
    if nomeArq = 'CHAJFL06' then   s := 'CTL F5 - procura próximo'
    else
    if nomeArq = 'CHAJFL09' then   s := 'ESC - termina'
    else
    if nomeArq = 'CHEABIMP' then   s := 'Erro ao abrir a impressora.'
    else
    if nomeArq = 'CHERESOL' then   s := 'Modo selecionado para a impressora não é adequado.'
    else
    if nomeArq = 'CHPOSALT' then   s := 'Posições de impressão foram alteradas.'
    else
    if nomeArq = 'CHMODOK'  then   s := 'O modelo foi impresso nas posições corretas?'
    else
    if nomeArq = 'CHATUALM' then   s := 'Atualmente '
    else
    if nomeArq = 'CHINFARQ' then   s := 'Informe o nome do arquivo de registro (sugiro usar extensão .chq):'
    else
    if nomeArq = 'CHCNFREM' then   s := 'Confirma remoção? '
    else
    if nomeArq = 'CHSALFIN' then   s := 'Saldo final: '
    else
    if nomeArq = 'CHTXTBUS' then   s := 'Qual o texto buscado? '
    else
    if nomeArq = 'CHNAOACH' then   s := 'Não achou'
    else
    if nomeArq = 'CHACHOU'  then   s := 'Achou'
    else
    if nomeArq = 'CHTERESC' then   s := 'Termine com ESC'
    else
    if nomeArq = 'CHPFMESC' then   s := 'Preencha o formulário a seguir, termine com ESC'
    else
    if nomeArq = 'CHESCDSJ' then   s := 'Selecione com as setas o campo desajustado e aperte enter'
    else
    if nomeArq = 'CHSELDSL' then   s := 'Selecione agora o deslocamento a realizar'
    else
    if nomeArq = 'CHOK'     then   s := 'OK.'
    else
    if nomeArq = 'CHESQ'    then   s := 'Esquerda'
    else
    if nomeArq = 'CHDIR'    then   s := 'Direita'
    else
    if nomeArq = 'CHCIMA'   then   s := 'Cima'
    else
    if nomeArq = 'CHBAIXO'  then   s := 'Baixo'
    else
    if nomeArq = 'CHNOME'   then   s := 'Nome'
    else
    if nomeArq = 'CHIDENT'  then   s := 'Identidade'
    else
    if nomeArq = 'CHEXPEDI' then   s := 'Expedidor'
    else
    if nomeArq = 'CHCPF'    then   s := 'CPF'
    else
    if nomeArq = 'CHTELEFO' then   s := 'Telefone'
    else
    if nomeArq = 'CHENDERE' then   s := 'Endereço'
    else
    if nomeArq = 'CHBAIRRO' then   s := 'Bairro'
    else
    if nomeArq = 'CHCIDADE' then   s := 'Cidade'
    else
    if nomeArq = 'CHARQLAN' then   s := 'Nome do Arquivo Lançamento'
    else
    if nomeArq = 'CHANO4'   then   s := 'Escreve ano com 4 digitos'
    else
    if nomeArq = 'CHIMPDEI' then   s := 'Imprime cheque deitado'
    else
    if nomeArq = 'CHRESTAU' then   s := 'Restaura valores de fábrica'
    else
    if nomeArq = 'CHMILDIR' then   s := 'Milímetros para a direita'
    else
    if nomeArq = 'CHMILBAI' then   s := 'Milímetros para baixo'
    else
    if nomeArq = 'CHDATA'   then   s := 'Data'
    else
    if nomeArq = 'CHTIPDOC' then   s := 'Tipo do documento'
    else
    if nomeArq = 'CHVALDOC' then   s := 'Valor'
    else
    if nomeArq = 'CHDEBCRE' then   s := 'Débito ou crédito?'
    else
    if nomeArq = 'CHNUMSER' then   s := '*Número de Série'
    else
    if nomeArq = 'CHNUMDOC' then   s := '*Número do documento'
    else
    if nomeArq = 'CHFAVDOC' then   s := '*Favorecido'
    else
    if nomeArq = 'CHFINDOC' then   s := '*Finalidade'
    else
    if nomeArq = 'CHVALOR'  then   s := 'Valor'
    else
    if nomeArq = 'CHFAVORE' then   s := 'Favorecido'
    else
    if nomeArq = 'CHCIDEMI' then   s := 'Cidade de emissão'
    else
    if nomeArq = 'CHDATEMI' then   s := 'Data da emissão'
    else
    if nomeArq = 'CHCHCRUZ' then   s := 'Cheque é cruzado'
    else
    if nomeArq = 'CHFINALI' then   s := '*Finalidade'
    else
    if nomeArq = 'CHSERCHQ' then   s := '*Série do cheque'
    else
    if nomeArq = 'CHNUMCHQ' then   s := '*Número do cheque'
    else
    if nomeArq = 'CHEXT1'   then   s := 'Primeiro número extenso'
    else
    if nomeArq = 'CHEXT2'   then   s := 'Segundo número extenso'
    else
    if nomeArq = 'CHDIA'    then   s := 'Dia'
    else
    if nomeArq = 'CHMES'    then   s := 'Mês'
    else
    if nomeArq = 'CHANO'    then   s := 'Ano'
    else
    if nomeArq = 'CHDESAJU' then   s := 'Selecione com as setas o campo desajustado e aperte enter'
    else
    if nomeArq = 'CHSELDSL' then   s := 'Escolha com as setas a direção a deslocar e aperte enter'
    else
    if nomeArq = 'CHINFMIL' then   s := 'Quantos milímetros desloco ? '
    else
    if nomeArq = 'CHQTXT'   then   s := 'Informe o nome do arquivo TXT a gerar'
    else
    if nomeArq = 'CHARQINC' then   s := 'Nome de arquivo incorreto'
    else
    if nomeArq = 'CHARQNCR' then   s := 'Arquivo não pôde ser criado.'
    else
    if nomeArq = 'CHARQATU' then   s := 'O nome do arquivo de lançamentos é'
    else
    if nomeArq = 'CHDESALT' then   s := 'Deseja trocar de arquivo? '
    else
    if nomeArq = 'CHDIGNOM' then   s := 'Digite o novo nome do arquivo atual (use extensão .CHQ)'
    else
    if nomeArq = 'CHCNFPOS' then   s := 'Quer configurar a impressão? '
    else
    if nomeArq = 'CHCNFIMP' then   s := 'Configuração da impressão'
    else
    if nomeArq = 'CHCNFLAN' then   s := 'Confirma lançamento? '

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
{                    dá uma mensagem
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
   SpeakerSound (pitch);
   delay (100);
   SpeakerNoSound;
end;

{--------------------------------------------------------}
{                   título do programa
{--------------------------------------------------------}

procedure titulo;
begin
    clrscr;
    setWindowText (crtWindow, 'Cheque Vox');
    textbackground (BLUE);
    writeln (' ***   *   * *****  ***   *   *  *****     *   *  ***  *   *');
    writeln ('*   *  *   * *     *   *  *   *  *         *   * *   *  * * ');
    writeln ('*      *   * *     *   *  *   *  *         *   * *   *  *** ');
    writeln ('*      ***** ****  *   *  *   *  ***        * *  *   *   *  ');
    writeln ('*      *   * *     *   *  *   *  *          * *  *   *  *** ');
    writeln ('*   *  *   * *     *  **  *   *  *           *   *   *  * * ');
    writeln (' ***   *   * *****  ****   ***   *****       *    ***  *   *');
    textbackground (BLACK); clreol;
    writeln;
    mensagem ('CHINIC', 0);      {'Chequevox - versão '}
    sintWriteln (versao);
    writeln;
end;

end.
