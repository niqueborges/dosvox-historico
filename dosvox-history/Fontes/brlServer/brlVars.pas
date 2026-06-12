{--------------------------------------------------------}
{
{    brlServer, servidor de linhas Braille multi cliente
{
{    Módulo de variáveis globais e constantes
{
{    Autores: Patrick Barboza e Antonio Borges
{
{    Em julho/agosto/2023
{
{    Atualizado em Agosto/2024
{
{--------------------------------------------------------}

unit brlVars;

interface

uses classes;

type
    TServer = record
        serverPort: integer;
        buf: TStringList;   {   Mensagens a serem escritas na linha Braille   }
    end;

const
    MAXSERVER = 20;   {   Máximo de programas (clientes) que podem se conectar }
    VERSAO = '1.0';
    TIPOVERSAO = 'alfa 4';
    PORTA = 80;
    SEM_BRAILLE = 'SEM BRAILLE';
    MAXDISP = 2;   //Máximo de dispositivos suportados
    nomesDisp: array [1..MAXDISP] of string = (
        'HIMS:Linhas Braille HIMS/Selvas BLV',
        'FOCUS:Linhas Braille Freedom Scientific Focus 80 Blue'
        //Adicionar mais aqui
    );

var
    listenSock: integer;
    nservers: integer = 0;
    serverSock: array [1..MAXSERVER] of TServer;
    debug: boolean = false;
    nomeDisp: string;

implementation
end.
