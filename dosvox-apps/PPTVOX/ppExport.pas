unit ppExport;

interface

uses
    dvCrt, dvWin, dvForm, dvArq,
    jpeg, windows, messages, sysutils, graphics,
    classes, comObj, variants, activex,
    ppEstilo, ppDesen, ppJanela, ppArq, ppMsg, ppVars;

procedure exportaPowerPoint;
procedure exportaTexto;
procedure defineTipoExport;

implementation

var dirTemplate, sTemplate: string;
    geraArqPPT: char;
    nomeArqPPT: string;

{--------------------------------------------------------}

procedure exportaPowerPoint;
var
    PowerPointApp, oPres, oSlide: OLEVariant;
    tx(*, sel, hl*): oleVariant;
    x, y, dx, dy: integer;
    nslidesPPT: integer;
//    nc: integer;
    i, j: integer;

//Const
//    sTemplate = 'C:\program files\Microsoft Office\Templates\Presentation Designs\Blends.pot';
//      sTemplate = 'D:\bernard\pptvox2\Blends.pot';
//      sTemplate = 'C:\pptvox2\Blends.pot';

const
    ppMouseClick = $00000001;

    // Constants for enum PpSlideLayout
    ppLayoutTitle = $00000001;
    ppLayoutText = $00000002;
    ppLayoutTwoColumnText = $00000003;
    ppLayoutTable = $00000004;
    ppLayoutTextAndChart = $00000005;
    ppLayoutChartAndText = $00000006;
    ppLayoutOrgchart = $00000007;
    ppLayoutChart = $00000008;
    ppLayoutTextAndClipart = $00000009;
    ppLayoutClipartAndText = $0000000A;
    ppLayoutTitleOnly = $0000000B;
    ppLayoutBlank = $0000000C;
    ppLayoutTextAndObject = $0000000D;
    ppLayoutObjectAndText = $0000000E;
    ppLayoutLargeObject = $0000000F;
    ppLayoutObject = $00000010;
    ppLayoutTextAndMediaClip = $00000011;
    ppLayoutMediaClipAndText = $00000012;
    ppLayoutObjectOverText = $00000013;
    ppLayoutTextOverObject = $00000014;
    ppLayoutTextAndTwoObjects = $00000015;
    ppLayoutTwoObjectsAndText = $00000016;
    ppLayoutTwoObjectsOverText = $00000017;
    ppLayoutFourObjects = $00000018;
    ppLayoutVerticalText = $00000019;
    ppLayoutClipArtAndVerticalText = $0000001A;
    ppLayoutVerticalTitleAndText = $0000001B;
    ppLayoutVerticalTitleAndTextOverChart = $0000001C;

function pegaTamanhoImagem (nomeArq: string; var dx, dy: integer): boolean;
var
    FStreamBmp, FStreamJpg: TStream;
    FJpeg     : TJpegImage;
    FBmp      : TBitmap;

begin
    result := false;
    if not FileExists(nomeArq) then exit;

    if ansiUpperCase (copy (nomearq, length(nomeArq)-3, 4)) = '.BMP' then
        begin
            FStreamBmp := TFileStream.Create(nomeArq, fmOpenRead);
            FBmp := TBitmap.Create;
            try
                FBmp.LoadFromStream(FStreamBmp);
                dx := FBmp.Width;
                dy := FBmp.Height;
            finally
                FStreamBmp.Free;
                FBmp.Free;
            end;
        end
    else
        begin
            FStreamJpg := TFileStream.Create(nomeArq, fmOpenRead);
            FJpeg := TJPEGImage.Create;
            try
                FJpeg.LoadFromStream(FStreamJpg);
                dx := FJpeg.Width;
                dy := FJpeg.Height;
            finally
                FStreamJpg.Free;
                FJpeg.Free;
            end;
        end;

    result := true;
end;

{--------------------------------------------------------}

begin
    criaTelaGrafica (@desenhaSlideCompleto, figuraDeFundo <> '');

    try
        PowerPointApp := CreateOleObject('PowerPoint.Application');
    except
        writeln;
        mensagem ('PPNAOPWP', 1); {'Não pude abrir o PowerPoint');}
        exit;
    end;

    writeln;
    mensagem ('PPINFMOD', 0); {'Informe com as setas o modelo desejado : ');}
    garanteEspacoTela (11);
    sTemplate:= obtemNomeArqMasc (10, '*.POT');
    writeln (sTemplate);
    if sTemplate = '' then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end
    else
    begin
        getDir (0, dirTemplate);
        sTemplate:= dirTemplate + '\' + sTemplate;
    end;

    nomeArqPPT:= nomeArq;
    if pos ('.', nomeArqPPT) <> 0 then
        delete (nomeArqPPT, pos ('.', nomeArqPPT), length (nomeArqPPT));
    nomeArqPPT:= nomeArqPPT + '.PPT';

    writeln;
    mensagem ('PPEDIPPT', 1); {'Edite o nome do arquivo PPT a ser gerado');}
    geraArqPPT:= sintEditaCampo (nomeArqPPT, 1, wherey, 200, 80, true);
    if geraArqPPT <> ENTER then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    writeln;
    mensagem ('PPAGUPPT', 1); {'Aguarde, irei exportar para o formato PowerPoint');}

  // Make Powerpoint visible
  PowerPointApp.Visible := True;

  // Create a new presentation based on the specified template.
  oPres := PowerPointApp.Presentations.Open (sTemplate, , , True);

  nslidesPPT := 0;

    for i:= 0 to nSlides -1 do
    begin
        with slides[i] do
        begin

            if modelo = capa then
            begin
                nslidesPPT := nslidesPPT + 1;
                oSlide := oPres.Slides.Add (nSlidesPPT, ppLayoutTitle);
                powerPointApp.ActiveWindow.View.GotoSlide(nSlidesPPT);
                tx := oSlide.Shapes.Item(1).TextFrame.TextRange;
                tx.text := titulo;
                tx := oSlide.Shapes.Item(2).TextFrame.TextRange;
                if linhas.count >= 1 then
                    for j:= 0 to linhas.count - 1 do
                        if linhas[j] <> '' then
                            tx.text := tx.text + linhas[j] + ^m;
            end
            else
            if modelo = listasimples then
            begin
                nslidesPPT := nslidesPPT + 1;
                oSlide := oPres.Slides.Add (nSlidesPPT, ppLayoutText);
                powerPointApp.ActiveWindow.View.GotoSlide(nSlidesPPT);
                tx := oSlide.Shapes.Item(1).TextFrame.TextRange;
                tx.text := titulo;
                tx := oSlide.Shapes.Item(2).TextFrame.TextRange;
                if linhas.count >= 1 then
                    for j:= 0 to linhas.count - 1 do
                        if linhas[j] <> '' then
                            tx.text := tx.text + linhas[j] + ^m;
            end
            else
            if modelo = figura then
            begin
                if (arquivo = '') or (not existeArq(arquivo)) then
                    arquivo:= fundoPadrao;
                nslidesPPT := nslidesPPT + 1;
                oSlide := oPres.Slides.Add (nSlidesPPT, ppLayoutTitleOnly);
                powerPointApp.ActiveWindow.View.GotoSlide(nSlidesPPT);
                tx := oSlide.Shapes.Item(1).TextFrame.TextRange;
                tx.text := titulo;
                pegaTamanhoImagem (arquivo, dx, dy);
                x := 400 - dx div 2;
                y := 150;
                oSlide.Shapes.AddPicture(arquivo, False, True, x, y, dx, dy);
                oSlide.Shapes.AddTextbox (1, 100, 500, 500, 30);
                tx := oSlide.Shapes.Item(3).TextFrame.TextRange;
                if linhas.count >= 1 then
                    for j:= 0 to linhas.count - 1 do
                        if linhas[j] <> '' then
                            tx.text := tx.text + linhas[j] + ^m;
            end;
// Implementar o modelo video
        end;
    end;

//  DeleteFile('c:\pptvox2\meuteste.ppt');
//  oPres.saveAs ('c:\pptvox2\meuteste.ppt');

  DeleteFile (dirTemplate + '\' + nomeArqPPT);
  oPres.saveAs (dirTemplate + '\' + nomeArqPPT);

  oPres.Close;

  oPres := unassigned;

  PowerPointApp.Quit;
  PowerPointApp := unassigned;

  destroiTelaGrafica;

    writeln;
    mensagem ('PPOKPPT', 1); {'OK, salvei em formato PowerPoint');}
    delay (100);
    writeln;
    mensagem ('PPVERPPT', 1); {'Verifique a resolução gráfica da conversão realizada');}

end;

{--------------------------------------------------------}

procedure exportaTexto;
var opcao: char;
    s: string;
begin

    nomeArqTXT:= nomeArq;
    delete (nomeArqTXT, pos ('.', nomeArqTXT), length (nomeArqTXT));
    nomeArqTXT:= nomeArqTXT + '.TXT';

    if existeArq(nomeArqTXT) then
    begin
        sintSom ('PPATESSS');
        delay (100);
        mensagem ('PPATENCT', 1); {('Atenção ! O arquivo TXT a ser gerado irá sobrescrever um já existente !');}
        delay (100);
        mensagem ('PPCONOPP', 0); {('Confirma a operação ? (sim ou não) : ');}
        opcao:= sintReadkey;
        writeln (opcao);
        if upcase(opcao) <> 'S' then
        begin
            mensagem ('PPDESIST', 1);
            exit;
        end
        else
        begin
            s:= nomeArqTXT;
            delete (s, pos ('.', s), length (s));
            s:= s + '_TXT';
            s:= s+ '.$$$';
            renameFile (nomeArqTXT, s);
        end;
    end;

    writeln;
    if salvaArqTxt then
    begin
        sintSom ('PPSSADDI');
        delay (100);
        mensagem ('PPOKTXT', 1); {'OK, salvei em formato texto')}
    end
    else
        mensagem ('PPPROTXT', 1); {'Desculpe, problemas na geração do arquivo texto');}
    writeln;

end;

{--------------------------------------------------------}

procedure defineTipoExport;
var opcao: char;
label erro;
begin

    if nomeArq = '' then
    begin
        writeln;
        mensagem ('PPINFAPR', 0); {('Informe com as setas a apresentação desejada : ');}
        garanteEspacoTela (11);
        nomeArq:= obtemNomeArqMasc (10, '*.PPX');
        writeln (nomeArq);
        if nomeArq = '' then
        begin
            mensagem ('PPDESIST', 1);
            exit;
        end;
    end;

// Caso chegue aqui com nomeArq inválido

    if not existeArq(nomeArq) then
    begin
        sintBip; sintBip;
        nomeArq:= '';
        exit;
    end;

    textBackground (BLUE);
    writeln;
    mensagem ('PPEXPORR', 1); {('Exportando');}
    textBackground (BLACK);
    sintSom ('PPPAICON');
    delay (100);

    writeln;
    mensagem ('PPDIGTP', 0); {'Digite T para formato texto ou P para formato POWERPOINT : ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if upcase (opcao) = 'T' then
        exportaTexto
    else
    if upcase (opcao) = 'P' then
    begin
        exportandoPPT:= true; // Remove comandos de linha e assume '---' para linhas em branco
        capturouEstilo:= false; // Faz com que assuma parâmetros gravados em disco
        if not carregaArq then
            goto erro
        else
            defineEstilo; // Assume parâmetros do estilo
        exportaPowerPoint
    end
    else
        mensagem ('PPDESIST', 1);

    erro:
    exportandoPPT:= false;

    clrscr;
    limpaBufTec;

end;

end.
