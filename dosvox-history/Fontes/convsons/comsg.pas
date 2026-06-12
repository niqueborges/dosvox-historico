unit comsg;

interface
uses dvwin, dvcrt;

procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';

    if nomeArq = 'COINIC'    then s := 'Conversor de formatos de Som'
    else
    if nomeArq = 'COINFDIRARQ'  then s := 'Informe nome do diretório ou arquivo a converter'
    else
    if nomeArq = 'CODIRARQNAO'  then s := 'Diretório ou arquivo inexistente'
    else
    if nomeArq = 'COVELOC'   then s := 'Velocidade final (sugiro 11025, 22050 ou 44100): '
    else
    if nomeArq = 'COBITS'    then s := 'Bits por amostra (8 ou 16): '
    else
    if nomeArq = 'COCANAIS'  then s := 'Canais (1 ou 2):'
    else
    if nomeArq = 'CONUMARQ'  then s := 'Número de arquivos a converter: '
    else
    if nomeArq = 'COERRGRG'  then s := 'Erro de gravação: '
    else
    if nomeArq = 'COAPTENT'  then s := 'Aperte enter'
    else
    if nomeArq = 'COOK'      then s := 'OK'
    else
    if nomeArq = 'CODEVWAV'      then s := 'Deve ser arquivo WAV.'
    else

        s := '--> Mensagem inválida: ' + nomeArq;

   result := s;
end;

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
