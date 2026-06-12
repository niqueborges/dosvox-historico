{
    VoxTube - utilitário de acessibilização do YouTube  ;

Variáveis globais;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_var;

interface
uses classes;

const
    CRLF = ^m^j;

    VERSAO = '6.2a';
maxper = 1000;

type
    TInfoFilme = record
        paginaWeb, titulo, duracao, autor, visto, datapub: array[0..maxper] of string;
    end;

var
    listaDeFilmes: array[0..maxper] of string;
filme : tinfofilme;
    pagAtual : integer;

limite : integer;
limitemin: integer;

    quantTotal: integer;
quantoslinks : integer;
    debug: boolean;
    ultimasBuscas: array [1..10] of string;

implementation

end.
