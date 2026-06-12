{--------------------------------------------------------}
{    Programa SuecaVox
{    mostra as mensagens
{--------------------------------------------------------}

unit svMensa;

interface

uses  dvcrt, dvwin, svvars;

procedure escreveAjuda;
procedure fala (nomeArq:string; nLinha:integer);

const
    nomeJog: array [1..MAXJOGADORES] of string [20] = (
        'Cebolinha', 'Mônica', 'Cascão', 'Magali',
        'Thinkie Winkie', 'Lala', 'Gipsie', 'Po',
        'Mickey', 'Minie', 'Pateta',
        'He Man', 'She Ra',
        'Batman', 'Robin', 'Mulher Gato'
    );

implementation


procedure escreveAjuda;       { mensagem svajuda }
begin
   writeln ('Funcionamento básico');
   writeln;
   writeln ('  Use as setas para selecionar ');
   writeln ('  uma carta, ENTER para jogar.');
   writeln ('  F2 para ver as cartas da mesa.');
   writeln ('  F3 para ver o placar geral.');
   writeln ('  F4 para rever o trunfo ');
   writeln ('  ESC para desistir.');
end;


procedure fala (nomeArq:string; nLinha:integer);
var s:string;
    i:integer;

begin
   s := '';

   if nomeArq = 'svabert' then
      s := 'SuecaVox'

   else
   if nomeArq = 'svinfnom' then
      s := 'Escolha seu nome '

   else
   if nomeArq = 'svinfpar' then
      s := 'Escolha o nome do seu parceiro '

   else
   if nomeArq = 'svopon1' then
      s := 'Escolha seu primeiro oponente: '

   else
   if nomeArq = 'svopon2' then
      s := 'Seu segundo oponente '

   else
   if nomeArq = 'svjogord' then
      s := 'Os jogadores na ordem são :'

   else
   if nomeArq = 'svvocee' then
      s := 'Você é '

   else
   if nomeArq = 'svjogesq' then
      s := 'Seu adversário da esquerda é '

   else
   if nomeArq = 'svseupar' then
      s := 'Seu parceiro é '

   else
   if nomeArq = 'svposi2' then
      s := ' está a sua direita'

   else
   if nomeArq = 'svjogan' then
      s := 'Deseja jogar novamente ? '

   else
   if nomeArq = 'svfim' then
      s := 'Fim do SuecaVox'

   else
   if nomeArq = 'svtrunf' then
      s := 'TRUNFO'

   else
   if nomeArq = 'svtruest' then
      s := 'Está com '

   else
   if nomeArq = 'svembca' then
      s := 'Embaralhando cartas '

   else
   if nomeArq = 'svcorta' then
      s := 'Cortando as cartas '

   else
   if nomeArq = 'svdistca' then
      s := 'Distribuindo cartas '

   else
   if nomeArq = 'svConfDe' then
      s := 'Confirma desistência ? '

   else
   if nomeArq = 'svPJoga' then
      s := ', pode jogar!'

   else
   if nomeArq = 'svJogaa' then
      s := ' joga'

   else
   if nomeArq = 'svrenun' then
      s := 'Você renunciou, por isso perdeu o jogo.'

   else
   if nomeArq = 'svfqlevo' then
      s := 'Quem levou foi '

   else
   if nomeArq = 'svqueem' then
      s := 'Quem embaralha é '

   else
   if nomeArq = 'svparab' then
      s := 'Parabéns a dupla vencedora '

   else
   if nomeArq = 'svadupla' then
      s := 'A dupla '

   else
   if nomeArq = 'svband' then
      s := ' perdeu de bandeira !'

   else
   if nomeArq = 'svdupla' then
      s := 'Dupla: '

   else
   if nomeArq = 'svpontos' then
      s := ' pontos '

   else
   if nomeArq = 'svescore' then
      s := 'ESCORE'

   else
   if nomeArq = 'svjogou' then
      s := ' jogou '

   else
   if nomeArq = 'svPprama' then
      s := 'Precisam praticar mais !'

   else
   if nomeArq = 'sv1ajuda' then
      s := 'Use as setas para selecionar os nomes e aperte ENTER. '

   else
   if nomeArq = 'sve' then
      s := ' e ';


   if s = '' then
      sintwrite (nomeArq)

   else
   begin
      write (s);
      sintSom (nomeArq);
   end;

   for i := 1 to nlinha do
      writeln;


end;
end.

