{--------------------------------------------------------}
{                  levox - mensagens
{--------------------------------------------------------}

unit lemsg;
interface
uses windows, dvcrt, dvWin;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);
procedure bipSpeaker (pitch: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if  nomeArq = 'LEINIC' then
        s := 'Leitor de documentos - '
    else
    if  nomeArq = 'LEARQNAO' then
        s := 'Arquivo não encontrado.'
    else
    if  nomeArq = 'LENOMARQ' then
        s := 'Informe o nome do arquivo'
    else
    if  nomeArq = 'LEFIM' then
        s := 'Fim do Leitor'
    else
    if  nomeArq = 'LEFIMARQ' then
        s := 'Fim de arquivo'
    else
    if  nomeArq = 'LETXTBUS' then
        s := 'Texto a buscar: '
    else
    if  nomeArq = 'LENENC' then
        s := 'Não encontrado'
    else
    if  nomeArq = 'LEENC' then
        s := 'Achei.'
    else
    if  nomeArq = 'LERETOMA' then
        s := 'Retomando a leitura.'
    else
    if  nomeArq = 'LEFALPNT' then
        s := 'Falando pontuação'
    else
    if  nomeArq = 'LESEMPNT' then
        s := 'Sem pontuação'

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
{                    bipa no speaker
{--------------------------------------------------------}

procedure bipSpeaker (pitch: integer);
begin
    SpeakerSound (80);
    delay (10);
    SpeakerNoSound;
end;

end.
