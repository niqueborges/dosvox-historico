{-------------------------------------------------------------}
{
{    Traduvox - tradutor de textos usando o Google Translator
{
{    Módulo de variáveis
{
{    Autor: José Antonio Borges
{
{    Atualizado por Patrick Barboza
{
{    Em dezembro/2023
{
{-------------------------------------------------------------}

unit trvars;

interface

const
    versao = '4.0';
    tipoVersao = '';

type
    TLingua = record
        cod, nome, som: string;
    end;

const
    maxLinguas = 8;
    linguas: array [1..maxLinguas] of Tlingua = (
        (cod:'AUTO'; nome:'Detectar idioma'; som:'TRDETEID'),
        (cod:'pt'; nome:'Português'; som:'TRPORTUG'),
        (cod:'en'; nome:'Inglês';    som:'TRINGLES'),
        (cod:'es'; nome:'Espanhol';  som:'TRESPAN'),
        (cod:'fr'; nome:'Francês';   som:'TRFRANC'),
        (cod:'it'; nome:'Italiano';  som:'TRITALI'),
        (cod:'de'; nome:'Alemão';    som:'TRALEMAO'),
        (cod:'eo'; nome:'Esperanto';    som:'TRESPERANTO')
    );

var
    interativo: boolean;
    linguaOrig, linguaDest: string;
    nomeArqOrig, nomeArqDest: string;

implementation

end.
