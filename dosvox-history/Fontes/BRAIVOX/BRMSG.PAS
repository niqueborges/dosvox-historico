{--------------------------------------------------------}
{                 módulo de mensagens
{--------------------------------------------------------}

unit brmsg;
interface
uses dvCrt, dvWin, windows, sysutils;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    s := '';

    if nomeArq = 'BRCNFERR' then
        s := 'Arquivo de configuração inexistente, programa cancelado'
    else
    if nomeArq = 'BRERRLIN' then
        s := 'Erro no arquivo de configuração na linha '
    else
    if nomeArq = 'BRERRBRL' then
        s := 'Erro no arquivo BRAILLE.AMB perto da linha '
    else
    if nomeArq = 'BRLPPAG' then
        s := 'Quantas linhas por página (0 para não paginar) ? '
    else
    if nomeArq = 'BRCPLIN' then
        s := 'Quantos caracteres por linha ? '
    else
    if nomeArq = 'BRDOEDIT' then
        s := 'Texto foi digitado no EDIT do DOS ? '
    else
    if nomeArq = 'BRAUTOJU' then
        s := 'Deseja auto-reformatação para Braille (s/n) ? '
    else
    if nomeArq = 'BRFREVER' then
        s := 'Frente e verso (s/n) ? '
    else
    if nomeArq = 'BRNUMINI' then
        s := 'Número a imprimir na página inicial: '
    else
    if nomeArq = 'BRFAZTIT' then
        s := 'Deseja títulos e numeração (s/n) ? '
    else
    if nomeArq = 'BRNCOP' then
        s := 'Quantas cópias ? '
    else
    if nomeArq = 'BRPAGINI' then
        s := 'Página inicial (sugiro 1): '
    else
    if nomeArq = 'BRPAGFIN' then
        s := 'Página final (sugiro 9999): '

    else
    if nomeArq = 'BRINTRO' then
        s := 'Programa de impressão Braille - v '
    else
    if nomeArq = 'BRNOMARQ' then
        s := 'Digite o nome do arquivo a imprimir: '
    else
    if nomeArq = 'BRARQNAO' then
        s := 'Arquivo não foi achado'
    else
    if nomeArq = 'BRERRCRI' then
        s := 'Erro ao criar arquivo de impressão.  Programa cancelado.'
    else
    if nomeArq = 'BRTIT' then
        s := 'Informe o título:'
    else
    if nomeArq = 'BRPADRAO' then
        s := 'Assumo valores padrão (s/n) ? '
    else
    if nomeArq = 'BRFIMCOP' then
        s := 'Fim de impressão da copia '
    else
    if nomeArq = 'BRFIMTRA' then
        s := 'Fim de trabalho'
    else
    if nomeArq = 'BRERRLEI' then
        s := 'Erro de leitura do arquivo'
    else
    if nomearq = 'BRFAZTIT' then
        s := 'Deseja titulos e/ou numeração ? '
    else
    if nomearq = 'BRTITFV' then
        s := 'Título em ambos os lados ? '
    else
    if nomearq = 'BRNUMORG' then
        s := 'Indica numeração do texto original no cabeçalho ? '
    else
    if nomearq = 'BRAFASTA' then
        s := 'Afasta para a direita os cabeçalhos pares ? '
    else
    if nomearq = 'BRLINDIV' then
        s := 'Linhas grandes foram divididas'
    else
    if nomearq = 'BRERRLEI' then
        s := 'Erro de leitura do arquivo'
    else
    if nomearq = 'BRERRESC' then
        s := 'Erro de escrita no dispositivo de impressão'
    else
    if nomearq = 'BRESCCAN' then
        s := 'ENTER continua, ESC cancela'
    else
    if nomearq = 'BRSEPARA' then
        s := 'Separa sílabas ao fim da linha ? '
    else
    if nomearq = 'BRINGLES' then
        s := 'Maiúsculas e grifo estilo inglês ? '

    else
    if nomeArq = 'BRARQIMP' then
        s := 'Arquivo ou dispositivo de saida (sugiro LPT1): '
    else
    if nomearq = 'BRGRFNAO' then
        s := 'Arquivo gráfico não foi achado'
    else
    if nomeArq = 'BRANTIGO' then
        s := 'Usa Braille antigo: '
    else
    if nomeArq = 'BRCNFDEF' then
        s := 'Use a configuração avançada do Dosvox para mudar definitivamente.'
    else
    if nomeArq = 'BRCNFDF2' then
        s := 'Para configurar, edite ali a seção BRAIVOX.'
    else
    if nomeArq = 'BRIMPCAN' then
        s := 'Impressão cancelada.'
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
