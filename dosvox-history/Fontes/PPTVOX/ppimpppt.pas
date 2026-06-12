unit ppImpPpt;

interface

uses
    dvcrt, dvwin, dvWav, dvMacro,
    ppMsg, ppVars,
    windows, messages, sysutils, classes,
    comObj, comutils, variants, activex;

procedure pptToTxt;

implementation

type
    TMyEvent = class
    public
        MyEventDisp: TEventDispatch;
        procedure MyPowerPointEvent(Sender: TObject;
                  DispatchID: TDispID; Parameters: OleVariant);
    end;

var
    arq: text;
    primeiraVez: boolean;
    ppt_aplic: OLEVariant;
    myEvent: TMyevent;
    ppt_terminou: boolean;
    listaFala: TStringList;
    seqAnimAtual: integer;
    anim: TStringList;

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

(*
Lista de eventos para tratamento eventual :
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
            insereFala ('FIM:', '');
            ppt_terminou := true;
        end
    else
    if nomeEvento = 'SlideShowNextSlide' then
        begin
            anim.Clear;
            listaFala.Clear;   // cancela falas pendentes
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
//            if anim.count = 0 then

            listaFala.Clear;   // cancela falas pendentes
            if seqAnimAtual < anim.count then
                insereFala ('BLD:', anim[seqAnimAtual]);
            seqAnimAtual := seqAnimAtual + 1;
         end;
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
    ppt_aplic.presentations.open (dirEstilos + '\' + nomeArqTransf, false, false, true);
    ppt_aplic.Presentations.Item(1).SlideShowSettings.Run;

end;

{-------------------------------------------------------------------}
{                   fecha o powerpoint
{-------------------------------------------------------------------}

procedure fechaPowerPoint;
begin

    if nomeArqTransf <> '' then
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

    if tipo = 'TIT:' then
        begin
            if not PrimeiraVez then
                writeln (arq, '');
            primeiraVez:= false;
        end
    else
    if tipo = 'TXT:' then
        begin
            sintClek;
            writeln (arq, aFalar);
        end
    else
    if tipo = 'BLD:' then
        begin
            sintBip;
            writeln (arq, aFalar);
       end
    else
    if tipo = 'ALT:' then
        begin
            sintBip;
            writeln (arq, aFalar);
        end
    else
    if tipo = 'FIM:' then
        begin
        end
    else
    begin
        sintBip;
    end;

end;

{-------------------------------------------------------------------}

procedure pptToTxt;
label fim;
begin

    nomeArqTXT:= nomeArqTransf;
    delete (nomeArqTXT, pos ('.', nomeArqTXT), length (nomeArqTXT));
    nomeArqTXT:= nomeArqTXT + '.TXT';

    assign (arq, nomeArqTXT);
    {$I-} rewrite(arq); {$I+}
    if ioResult <> 0 then
        goto fim;

    writeln;
    mensagem ('PPAGIRPP', 1); {('Aguarde, irei abrir o POWERPOINT');}
    delay (100);
    sintBip; sintBip;
    mensagem ('PPNATENA', 1); {('Não tecle nada até retornar ao menu');}
    writeln;

    primeiraVez:= true;
    ppt_terminou := false;

    listaFala := TStringList.Create;
    anim := TStringList.Create;

    abrePowerPoint;
    delay (500);
    keyBoardClick (#46);  // Interrompe eventual fundo musical

    while not ppt_terminou do
        begin
            while listaFala.count > 0 do
                exibeFala; // Grava em disco ocorrencias
            keyBoardClick (#32);  // Avança slide
            delay (500);
         end;

fim:
    nomeArqTransf:= nomeArqTXT;
    {$I-} close(arq); {$I+}

    delay (500);
    fechaPowerPoint;
    delay (1000);

end;

end.
