{-------------------------------------------------------------}
{                   MircVox - variaveis globais
{-------------------------------------------------------------}

unit mvvars;

interface

uses dvinet;

const
    VERSAO = '1.4 Beta';

Var
servidor:string;                        {Endereço do servidor}
nick, senha:string;                     {Apelido e senha}
Porta:integer;                          {Porta para a conexão}
sock:integer;                           {Socket de conexão}
Buftec:string;                          {Mensagens}
Conversando:boolean;                    {Está em um canal}
Canal:string;                           {Nome do canal em que se está}
msg, aux:string;                        {Variáveis auxiliares de mensagem}
pont:boolean;                           {Fala pontuação}
ffilaFala, rfilaFala: integer;          {Para processamento da fila de mensagens}
filaFala: array [0..254] of string;     {Também para a fila de mensagens}
Buf:Pbufrede;                           {Variavel para bufferização da rede}
Apelido:string;                         {Apelido de quem enviou mensagem}
Arqconf:textfile;                       {Arquivo de configuração}
Nomeconf:String;                        {Nome do arquivo de configurações}
MeuIP:string;                           {Número IP da conexão atual}
Ultmsgparceiro:string;                  {Ultima mensagem chegada}
Ignorados:array[0..127] of string;      {Apelidos ignorados}
MemoNick:array[0..255] of string;        {Memória de apelidos}
Linha:array [0..5000] of string;        {Armazenagem da lista de canais}
i:integer;                              {Índice usado em várias procedures}
Soletrando:boolean;                     {Soletragem: Ligada ou desligada}

implementation
end.
