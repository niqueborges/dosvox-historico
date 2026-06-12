{----------------------------------------------------------------}
{
{    Levox - leitor de documentos
{    Módulo de variáveis
{    Autor: Antonio Borges
{    Em 2/6/2002
{
{----------------------------------------------------------------}

unit levars;

interface
uses classes;

const
    versao = '2.3';
var
    nomeArq: string;
    texto: TStringList;
    pendente: string;
    juntaLinhasAoLer: boolean;
    maxlin, maxcol: integer;
    primLinhaTela: integer;
    posy: integer;
    falaParada: boolean;
    processando: boolean;
    textoBuscado: string;
    posinic: integer;
    falaPont: boolean;

implementation

end.
