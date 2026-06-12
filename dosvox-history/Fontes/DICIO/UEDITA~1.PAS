unit ueditadic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFormEditar = class(TForm)
    b_removerPalavra: TButton;
    b_adicionarPalavra: TButton;
    b_salvarDicionario: TButton;
    Memo1: TMemo;
    e_palavra: TEdit;
    b_recuar: TSpeedButton;
    b_avancar: TSpeedButton;
    Label1: TLabel;
    b_escolherPalavra: TButton;
    procedure FormActivate(Sender: TObject);
    procedure b_recuarClick(Sender: TObject);
    procedure b_avancarClick(Sender: TObject);
    procedure b_escolherPalavraClick(Sender: TObject);
    procedure b_salvarDicionarioClick(Sender: TObject);
    procedure b_adicionarPalavraClick(Sender: TObject);
    procedure b_removerPalavraClick(Sender: TObject);
  private
    emAtividade: boolean;
    listaCB: array [0..100] of TCheckBox;
    procedure CheckBox1Click(Sender: TObject);
    procedure montaSufixosTela;
    function selPrimeiraPalavra (buscada: string): integer;
    procedure exibePalavra (indPalavra: integer);
  public
    { Public declarations }
  end;

var
  FormEditar: TFormEditar;
  listaSufixos: TStringList;
  listaDic: TStringList;
  indPal: integer;

implementation

uses uescolhedic;

{$R *.dfm}

{----------------------------------------------------------------}

function carregaListaSufixos (nomeArqSufixos: string): boolean;
var arqSufixos: text;
    s, chave: string;
    sufixos: TStringList;
begin
    carregaListaSufixos := false;
    listaSufixos := TStringList.Create;

    assign (arqSufixos, nomeArqSufixos);
    {$I-}  reset (arqSufixos);  {$I+}
    if ioresult <> 0 then
        exit;

    chave := '';
    sufixos := NIL;
    while not eof (arqSufixos) do
        begin
            readln (arqSufixos, s);
            trim (s);
            if s = '' then continue;
            if s[1] = '*' then continue;

            if s[1] = '[' then
                begin
                    if chave <> '' then
                        begin
                            sufixos.sort;
                            listaSufixos.addObject (chave, sufixos);
                        end;

                    sufixos := TStringList.Create;
                    chave := copy (s, 2, 999);
                    if chave [length(chave)] = ']' then
                        delete (chave, length(chave), 1);
                    trim (chave);
                end
            else
                sufixos.Add(s);
        end;

    if chave <> '' then
        listaSufixos.addObject (chave, sufixos);

    close (arqSufixos);
    carregaListaSufixos := true;
end;

{----------------------------------------------------------------}

function carregaListaDic (nomeArqDic: string): boolean;
var arqDic: text;
    s, s2: string;
    fimpal: integer;
    sufixosPal: TStringList;
begin
    carregaListaDic := false;
    listaDic := TStringList.Create;

    assign (arqDic, nomeArqDic);
    {$I-}  reset (arqDic);  {$I+}
    if ioresult <> 0 then
        exit;

    while not eof (arqDic) do
        begin
            readln (arqDic, s);
            trim (s);
            if s = '' then continue;
            if s[1] = '*' then continue;

            fimpal := pos (' ', s);
            if fimpal = 0 then
                s2 := '='
            else
                begin
                    s2 := copy (s, fimpal+1, 999);
                    s := copy (s, 1, fimpal-1);
                end;

            sufixosPal := TStringList.Create;
            trim (s2);
            while s2 <> '' do
                begin
                    fimpal := pos (' ', s2);
                    if fimPal = 0 then
                        fimPal := length(s2)+1;
                    sufixosPal.add (copy (s2, 1, fimpal-1));
                    delete (s2, 1, fimpal);
                    trim (s2);
                end;

            listaDic.addObject (s, sufixosPal);
        end;

    listaDic.sorted := true;

    close (arqDic);
    carregaListaDic := true;
end;

{----------------------------------------------------------------}

procedure guardaListaDic (nomeArqDic: string);
var arqDic: text;
    l, p: integer;
    listaSufPal: TStringList;
begin
    assign (arqDic, nomeArqDic);
    {$I-}  rewrite (arqDic);  {$I+}
    if ioresult <> 0 then
        begin
            showMessage ('Não consegui gravar o dicionário');
            exit;
        end;

    for l := 0 to listaDic.count-1 do
        begin
            write (arqDic, listaDic[l]);
            listaSufPal := listaDic.Objects[l] as TStringList;
            for p := 0 to listaSufPal.count-1 do
                write (arqDic, ' ', listaSufPal[p]);
            writeln (arqDic);
        end;
    close (arqDic);
end;

{----------------------------------------------------------------}

function TFormEditar.selPrimeiraPalavra (buscada: string): integer;
var ind: integer;
begin
   selPrimeiraPalavra := listaDic.count-1;
   for ind := 0 to listaDic.count-1 do
       if ansiCompareText(listaDic[ind], buscada) >= 0 then
           begin
               selPrimeiraPalavra := ind;
               break;
           end;
end;

{----------------------------------------------------------------}

procedure TFormEditar.exibePalavra (indPalavra: integer);
var listaSufPal, lsuf: TStringList;
    i, isuf, posic: integer;
    s: string;
begin
    emAtividade := false;

    e_palavra.text := listaDic[indPalavra];
    listaSufPal := listaDic.Objects[indPalavra] as TStringList;

    for i := 0 to listaSufixos.count-1 do
      listaCb[i].checked := false;

    s := '';
    for i := 0 to listaSufPal.Count-1 do
        begin
            posic := listaSufixos.indexOf(listaSufPal[i]);
            if posic >= 0 then
                begin
                    listaCb[posic].checked := true;
                    if listaSufixos[posic] = '=' then
                        s := s + listaDic[indPalavra] + ' '
                    else
                        begin
                            lsuf := listaSufixos.Objects[posic] as TStringList;
                            for isuf := 0 to lsuf.count-1 do
                                s := s + listaDic[indPalavra] + lsuf[isuf] + ' ';
                        end;
                end
            else
                showMessage ('Sufixo não achado: ' + listaSufPal[i]);
        end;

    memo1.clear;
    memo1.lines.add (s);

    emAtividade := true;
end;

{----------------------------------------------------------------}

procedure TFormEditar.montaSufixosTela;
var l, i: integer;
    novoLabel: TLabel;
    sufixos: TStringList;
    s: string;
begin
    for l := 0 to listaSufixos.count-1 do
        begin
            listaCB[l] := TCheckBox.create (self);
            with listaCB[l] do
                begin
                    tag := l;
                    top := l*15;
                    left := 10;
                    width := 60;
                    Caption := listaSufixos[l];
                    parent := self;
                    onClick := CheckBox1Click;
                end;

            sufixos := listaSufixos.Objects[l] as TStringList;

            novoLabel := TLabel.create (self);
            with novoLabel do
                begin
                    top := l*15;
                    left := 80;
                    s := '';
                    for i := 0 to sufixos.count-1 do
                        s := s + sufixos[i] + ' ';
                    if length (s) > 30 then
                        caption := copy (s, 1, 30) + '...'
                    else
                        caption := s;
                    parent := self;
                end;
        end;
end;

{----------------------------------------------------------------}

procedure TFormEditar.FormActivate(Sender: TObject);
begin
    formEscolher.showModal;
    carregaListaSufixos (formEscolher.e_nomesuf.text);
    montaSufixosTela;
    carregaListaDic (formEscolher.e_nomedic.text);
    indPal := selPrimeiraPalavra (formEscolher.e_primPal.text);
    exibePalavra (indPal);
end;

{----------------------------------------------------------------}

procedure TFormEditar.b_recuarClick(Sender: TObject);
begin
    indPal := indPal - 1;
    if indPal < 0 then
        indPal := 0;
    exibePalavra (indPal);
end;

{----------------------------------------------------------------}

procedure TFormEditar.b_avancarClick(Sender: TObject);
begin
    indPal := indPal + 1;
    if indPal > listaDic.Count-1 then
        indPal := listaDic.Count-1;
    exibePalavra (indPal);
end;

{----------------------------------------------------------------}

procedure TFormEditar.b_escolherPalavraClick(Sender: TObject);
var novaPal: string;
begin
  novaPal := e_palavra.Text;
  if InputQuery('Escolher palavra', 'Qual a palavra a buscar?', novaPal) then
      begin
          indPal := selPrimeiraPalavra (novaPal);
          exibePalavra (indPal);
      end;
end;

{----------------------------------------------------------------}

procedure TFormEditar.CheckBox1Click(Sender: TObject);
var lsuf: TStringList;
    i: integer;
begin
    if emAtividade then
        begin
            lsuf := TStringList.create;
            for i := 0 to listaSufixos.count-1 do
                 if listaCb[i].checked then
                     lsuf.add (listaSufixos[i]);

            listaDic.Objects[indPal].Free;
            listaDic.Objects[indPal] := lsuf;
            exibePalavra (indPal);
        end;
end;

procedure TFormEditar.b_salvarDicionarioClick(Sender: TObject);
var nomeArqDic: string;
begin
  nomeArqDic := formEscolher.e_nomedic.text;
  if InputQuery('Salvar como', 'Digite arquivo a salvar', nomeArqDic) then
      guardaListaDic (nomeArqDic);
end;

procedure TFormEditar.b_adicionarPalavraClick(Sender: TObject);
var novaPal: string;
    sufixosPal: TStringList;
begin
  novaPal := e_palavra.Text;
  if InputQuery('Inserir palavra', 'Qual a nova palavra?', novaPal) then
      begin
          e_palavra.text := novaPal;
          sufixosPal := TStringList.Create;
          listaDic.addObject (novaPal, sufixosPal);
          indPal := selPrimeiraPalavra (e_palavra.text);
          exibePalavra (indPal);
      end;
end;

procedure TFormEditar.b_removerPalavraClick(Sender: TObject);
var novaPal: string;
begin
  novaPal := e_palavra.Text;
  if InputQuery('Remover palavra', 'Qual a palavra a remover?', novaPal) then
      begin
          indPal := selPrimeiraPalavra (novaPal);
          if listaDic[indPal] = novaPal then
              begin
                  listaDic.objects[indpal].Free;
                  listaDic.Delete(indpal);
              end
          else
              showMessage ('Palavra inexistente');
      end;

  indPal := selPrimeiraPalavra (novapal);
  exibePalavra (indPal);
end;

end.

