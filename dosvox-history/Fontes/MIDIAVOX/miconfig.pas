unit miconfig;

interface

uses
    dvCrt, dvForm, dvWin, dvWav,
    mimsg, mivars,
    SysUtils, classes;

procedure configura;

implementation

{--------------------------------------------------------}
{                   configura
{--------------------------------------------------------}

procedure configura;
var
    opcao: ShortString;
    opcoes: string;
    salva: integer;
    salvay: integer;
begin
    salvay := wherey;
    limpabaixo (salvay);

    mensagem('MICONFIG',2);    {'Configuração do midiavox:'}
    mensagem('MIEDCONF',2);    {'Editore as configurações, ao final tecle ESC'}

    if modoSilencioso then begin
                               opcao  := 'SIM';
                               opcoes := 'SIM|NAO';
                           end
                      else begin
                               opcao  := 'NAO';
                               opcoes := 'NAO|SIM';
                           end;

    salva := tamRotulosForm;
    tamRotulosForm := length (pegaTextoMensagem('MIDISPAUD'));
    formCria;
    formCampoLista('MIMODOSIL', pegaTextoMensagem('MIMODOSIL'),opcao,5,opcoes);
    formEdita (true);
    tamRotulosForm := salva;

    opcao := UpperCase(opcao);
    modosilencioso := (opcao = '') or (opcao[1] <> 'N');
    if modosilencioso then opcao := 'SIM'
                      else opcao := 'NAO';
    sintGravaAmbiente ('MIDIAVOX', 'MODOSILENCIOSO', opcao);

    writeln;
    mensagem ('MICONFSA',0);    {'Configurações salvas'}
    gotoxy(1,9);
end;

end.
