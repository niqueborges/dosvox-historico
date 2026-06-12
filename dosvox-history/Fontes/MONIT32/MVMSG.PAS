{--------------------------------------------------------}
{
{     Monitvox - módulo de mensagens
{     Autor: Antonio Borges
{     Em 23/3/2003
{
{--------------------------------------------------------}

unit mvMsg;
interface
uses windows, dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation    

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'MONITVOX' then
        s := 'Monitvox'
    else
    if nomeArq = 'MOAPERT' then
        s := 'Aperte control-alt-espaço para acionamento'
    else
    if nomeArq = 'MOMONDLG' then
        s := 'Monitor desligado'
    else
    if nomeArq = 'MOMONITO' then
        s := 'Monitorando'
    else
    if nomeArq = 'MOSCRIPT' then
        s := 'Nome do script: '
    else
    if nomeArq = 'MOMOEXEC' then
        s := 'Monitora enquando executa? '

    else
    if nomeArq = 'MOEDICNF' then
        s := 'Editore as configurações, ao final tecle ESC'
    else
    if nomeArq = 'MOVELSIN' then
        s := 'Velocidade do sintetizador'
    else
    if nomeArq = 'MOUSASAP' then
        s := 'Usa fala Sapi'
    else
    if nomeArq = 'MOTIPSAP' then
        s := 'Tipo Sapi (4 ou 5)'
    else
    if nomeArq = 'MOVOZSAP' then
        s := 'Número da voz Sapi'
    else
    if nomeArq = 'MOVELSAP' then
        s := 'Velocidade Sapi'
    else
    if nomeArq = 'MOTOMSAP' then
        s := 'Tonalidade Sapi'
    else
    if nomeArq = 'MOCORTAF' then
        s := 'Corta fala automática'
    else
    if nomeArq = 'MOCONFIR' then
        s := 'Confirma configuração? '

    else
    if nomeArq = 'MOOPCAO' then
        s := 'Monitor - opção: '
    else
    if nomeArq = 'MOSEMACC' then
        s := 'Acessibililidade não pode ser ativada'
    else
    if nomeArq = 'MONOMARQ' then
        s := 'Informe o nome do arquivo destino'
    else
    if nomeArq = 'MOERRARQ' then
        s := 'Erro ao criar o arquivo'
    else
    if nomeArq = 'MOREGCOR' then
        s := 'Registra coordenadas ? '
    else
    if nomeArq = 'MOCALCUL' then
        s := 'Calculando'
    else
    if nomeArq = 'MVEDITA' then
        s := 'Editando'
    else
    if nomeArq = 'MODESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'MOLETRA' then
        s := 'Que letra associa a esta posição?'
    else
    if nomeArq = 'MOJAREG' then
        s := 'Letra já registrada, sobrescreve? '
    else
    if nomeArq = 'MOQLETRA' then
        s := 'Que letra? '
    else
    if nomeArq = 'MONAOREG' then
        s := 'Letra não registrada'
    else
    if nomeArq = 'MOOKREP' then
        s := 'Mouse reposicionado'
    else
    if nomeArq = 'MOSUSP' then
        s := 'Monitor suspenso'
    else
    if nomeArq = 'MOTECMOU' then
        s := 'Mouse pelas setas'
    else
    if nomeArq = 'MOSETNOR' then
        s := 'Setas normais'

    else
    if nomeArq = 'MOAJUDA1' then
        s := 'As principais opções são:'
    else
    if nomeArq = 'MOAJUDA2' then
        s := 'Enter monitora, L le área de texto, M sonoriza mouse, ESC cancela.'
    else
    if nomeArq = 'MOAJUDA3' then
        s := 'T lê área de transferência, I informações sobre a janela.'
    else
    if nomeArq = 'MOAJUDA4' then
        s := 'Control-alt-enter ativa editor de campo.'
    else
    if nomeArq = 'MOAJUDA5' then
        s := 'Leia o manual de operação para conhecer todas as opções.'
    else
    if nomeArq = 'MVNOMECP' then
        s := 'Nome deste objeto:'
    else
    if nomeArq = 'MVDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'MVREPROG' then
        s := 'Cuidado, nome sendo reprogramado'
    else
    if nomeArq = 'MVSEMPRG' then
        s := 'Nada foi programado'

    else
    if nomeArq = 'DISP_E_MEMBERNOTFOUND' then
        s := 'Membro não encontrado'
    else
    if nomeArq = 'E_INVALIDARG' then
        s := 'Argumento inválido'
    else
    if nomeArq = 'E_FAIL' then
        s := 'Falha'
    else
    if nomeArq = 'E_NOTIMPL' then
        s := 'Não implementado'
    else
    if nomeArq = 'E_OUTOFMEMORY' then
        s := 'Sem memória'
    else
    if nomeArq = 'S_FALSE' then
        s := 'Falso'
    else
    if nomeArq = 'S_OK' then
        s := 'Ok'

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

end.
