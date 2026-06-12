{--------------------------------------------------------}
{
{   Fala um arquivo do PowerPoint (PPT ou PPS)
{
{   Exige PowerPoint >= 2000
{
{   Autores: Antonio Borges e Bernard Condorcet
{
{   Em agosto/2008
{
{--------------------------------------------------------}

program pptfala;

uses
    dvcrt, dvwin, dvForm, dvArq, dvwav,
    windows, messages, sysutils, classes,
    comObj, comutils, variants, activex;

type
    TMyEvent = class
    public
        MyEventDisp: TEventDispatch;
        procedure MyPowerPointEvent(Sender: TObject;
                  DispatchID: TDispID; Parameters: OleVariant);
    end;

var
    ppt_aplic: OLEVariant;
    myEvent: TMyevent;
    ppt_terminou: boolean;
    listaFala: TStringList;
    nomeArq: string;
    seqAnimAtual: integer;
    anim: TStringList;

label fim;

{--------------------------------------------------------}
{                   mensagens
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'PPNOMARQ' then
        s := 'Informe o arquivo PPT ou PPS a ler: '
    else
    if nomeArq = 'PPDESIST' then
        s := 'Desistiu'
    else
    if nomeArq = 'PPARQNAO' then
        s := 'Arquivo inexistente'
    else
    if nomeArq = 'PPFIMAPR' then
        s := 'Fim da apresentação'

    else   // mensagem inválida
        s := nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                   lista de sons
{--------------------------------------------------------}

const
    NOVO_SLIDE = 'Novo sláide';
(*
    'PPTIT' - para indicar um título
    'PPTXT' - antes de cada texto
    'PPBLD' - ao entrar numa região animada
    'PPALT' - para indicar um alternate name
    'PPFIM' - para indicar o fim da apresentação
*)

{--------------------------------------------------------}
{                 exibe uma mensagem
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
{                   silencia
{--------------------------------------------------------}

Procedure silencia;
const
    TAMBIP = 512;
var i: integer;
    bip:  array [-TAMCABWAV..TAMBIP-1] of byte;

    procedure esperaSapi;
    begin
        if falandoSapi then
            begin
                while sintFalando do waitMessage;
                falandoSapi := false;
            end;
    end;

begin
    esperaSapi;

    while keypressed do readkey;
    i := 0;
    while i < TAMBIP do
        begin
            bip[i] := $80; inc (i);
        end;

    geraCabWav (@bip, TAMBIP, 11025, 8, 1);
    wavePlayMem (@bip);
    while sintFalando do waitMessage;
end;

{-------------------------------------------------------------------}
{               insere uma fala no buffer
{-------------------------------------------------------------------}

procedure insereFala (tipo, txt: string);
var fala: string;
    c: char;
begin
    if txt = '' then
        begin
            listaFala.add (tipo);
            exit;
        end;

    fala := '';
    txt :=  txt + #$0d + #$0a;
    while txt <> '' do
        begin
            c := txt[1];
            delete (txt, 1, 1);
            case c of
            #11: fala := fala + ' ';
            #$0d:
                begin
                    if fala <> '' then
                        begin
                            listaFala.add (tipo + fala);
                            fala := '';
                        end;
                    if txt[1] = #$0a then
                        delete (txt, 1, 1);
                end;
            #$0a:  ;
            #$09:  listaFala.add ('TAB:');
            else
                fala := fala + c;
            end;
        end;
end;

{-------------------------------------------------------------------}
{                   Trata os eventos do PowerPoint
{-------------------------------------------------------------------}

procedure TMyEvent.MyPowerPointEvent(Sender: TObject; DispatchID: TDispID;
  Parameters: OleVariant);
var
    view, shape: OleVariant;
    nomeEvento: string;
    j: integer;
    tipo, s: string;
    animado: boolean;

(*  Lista de eventos para tratamento eventual

    NewPresentation Event                   PresentationClose Event
    PresentationNewSlide Event              PresentationOpen Event
    PresentationPrint Event                 PresentationSave Event
    SlideShowBegin Event                    SlideShowEnd Event
    SlideShowNextBuild Event                SlideShowNextSlide Event
    WindowActivate Event                    WindowBeforeDoubleClick Event
    WindowBeforeRightClick Event            WindowDeactivate Event
    WindowSelectionChange Event
*)


begin
    nomeEvento := MyEventDisp.EventName[DispatchID];

    if nomeEvento = 'SlideShowEnd' then
        begin
            listaFala.Clear;   // cancela falas pendentes
            sintPara;
            insereFala ('FIM:', '');
            ppt_terminou := true;
        end
    else
    if nomeEvento = 'SlideShowNextSlide' then
        begin
            anim.Clear;
            listaFala.Clear;   // cancela falas pendentes
            processWindowsQueue;

            insertKeyBuf (#0);
            while sintFalando do delay (100);
            processWindowsQueue;

            insereFala ('SLD:', '');

            try
                view := ppt_aplic.ActivePresentation.SlideShowWindow.View;
                if view.Slide.Shapes.HasTitle then
                    insereFala ('TIT:', '');
                            // view.Slide.Shapes.Title.TextFrame.TextRange.Text

                seqAnimAtual := 0;
                for j := 1 to view.Slide.Shapes.Count do
                    begin
                        shape := view.Slide.Shapes.item(j);
                        animado := false;
                        if shape.AnimationSettings.Animate <> 0 then
                            animado := shape.AnimationSettings.TextLevelEffect > 0;

                        if shape.HasTextFrame then
                        begin
                            if shape.HasTextFrame then
                                begin
                                    tipo := 'TXT:';
                                    s := shape.TextFrame.TextRange.Text;
                                end
                            else
                                begin
                                    tipo := 'ALT:';
                                    s := shape.AlternativeText;
                                end;

                            if animado then
                                anim.Add(s)
                            else
                                insereFala (tipo, s);
                        end;
                    end;
            except
            end;
        end
    else
    if nomeEvento = 'SlideShowNextBuild' then
         begin
            if anim.count = 0 then

            listaFala.Clear;   // cancela falas pendentes
            if seqAnimAtual < anim.count then
                insereFala ('BLD:', anim[seqAnimAtual]);
            seqAnimAtual := seqAnimAtual + 1;
         end;

end;

{-------------------------------------------------------------------}
{                   obtem arquivo para apresentação
{-------------------------------------------------------------------}

function preparaArquivo: boolean;
var
    dir: string;
begin
    TextBackground(Blue);
    writeln ('PPTFALA - v1.0 alfa');
    TextBackground(BLACK);
    writeln;
    preparaArquivo := false;

    if paramStr(1) <> '' then
        nomeArq:= paramStr(1)
    else
        begin
            mensagem ('PPNOMARQ', 1);  {'Informe o arquivo PPT ou PPS a ler: '}
            nomeArq:= obtemNomeArqMasc (10, '*.pp*');
            writeln (nomeArq);
            if nomeArq = '' then
                begin
                    sintBip; sintBip; sintBip;
                    mensagem ('PPDESIST', 1);  {'Desistiu'}
                    exit;
                end;
        end;

    if pos ('\', nomeArq) = 0 then
        begin
            getDir (0, dir);
            nomeArq:= dir + '\' + nomeArq;
        end;

    if not FileExists(nomeArq) then
        begin
            sintBip; sintBip; sintBip;
            mensagem ('PPARQNAO', 2);   {'Arquivo inexistente'}
            exit;
        end;

    preparaArquivo := true;
end;

{-------------------------------------------------------------------}
{                   abre o powerpoint
{-------------------------------------------------------------------}

procedure abrePowerPoint;
begin
    ppt_aplic := CreateOleObject('PowerPoint.Application');

    MyEvent := TMyEvent.Create;
    with MyEvent do
       begin
           MyEventDisp := TEventDispatch.Create(ppt_aplic);
           MyEventDisp.OnEvent := MyPowerPointEvent;
           MyEventDisp.Active := True;
       end;

    ppt_aplic.visible := true;
    ppt_aplic.presentations.open (nomeArq, false, false, true);
    ppt_aplic.Presentations.Item(1).SlideShowSettings.Run;
end;

{-------------------------------------------------------------------}
{                   fecha o powerpoint
{-------------------------------------------------------------------}

procedure fechaPowerPoint;
begin
    if nomeArq <> '' then
        ppt_aplic.quit;
    ppt_aplic := Unassigned;
end;

{-------------------------------------------------------------------}
{                   exibe a fala
{-------------------------------------------------------------------}

procedure exibeFala;
var
    aFalar, tipo: string;
begin
    if listaFala.count = 0 then exit;

    aFalar:= listaFala[0];
    listaFala.Delete (0);
    tipo := copy (aFalar, 1, 4);
    delete (aFalar, 1, 4);

    silencia;
    if tipo = 'SLD:' then
        begin
            if existeArqSom ('PPNOVO') then
                sintSom ('PPNOVO')
            else
                sintetiza (NOVO_SLIDE);
            writeln ('-------------------------------------');
        end
    else
    if tipo = 'TIT:' then
        begin
            if existeArqSom ('PPTIT') then
                sintSom ('PPTIT')
            else
                sintBip;
        end
    else
    if tipo = 'TXT:' then
        begin
            if existeArqSom ('PPTXT') then
                sintSom ('PPTXT')
            else
                sintClek;
            while sintFalando do waitMessage;
            sintWriteln (aFalar);
        end
    else
    if tipo = 'BLD:' then
        begin
            sintWriteln (aFalar);
            if existeArqSom('PPBLD') then
                sintSom ('PPBLD');
       end
    else
    if tipo = 'ALT:' then
        begin
            if existeArqSom('PPALT') then
                sintSom ('PPALT');
            sintWriteln (aFalar);
        end
    else
    if tipo = 'FIM:' then
    begin
        if existeArqSom('PPFIM') then
            sintSom ('PPFIM')
        else
            begin
                sintBip; sintClek; sintBip; sintClek; sintBip;
            end;
    end
    else
    begin
        sintClek; sintClek;
    end;
end;

{-------------------------------------------------------------------}
{                   Rotina principal
{-------------------------------------------------------------------}

var
    dir: string;
begin
    dir := sintAmbiente ('PPTFALA', 'DIRPPTFALA');
    if dir = '' then
        dir := 'c:\winvox\som\pptfala';
    sintinic (0, dir);

    if not preparaArquivo then
        goto fim;

    listaFala := TStringList.Create;
    anim := TStringList.Create;
    abrePowerPoint;

    ppt_terminou := false;
    while not ppt_terminou do
        begin
            while listaFala.count > 0 do
                exibeFala;
            delay (100);
         end;

fim:
    fechaPowerPoint;

    delay (1000);
    mensagem ('PPFIMAPR', 1);  {'Fim da apresentação'}
    sintFim;
    doneWinCrt;
end.
