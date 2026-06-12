program testaArquivos;
uses dvcrt, sysutils, classes;
var
    sl: TStringList;

procedure testa (nomeArq, msg: string);
var
    cod, mens: string;
    i, p: integer;
begin
    if not fileExists (nomeArq) then
        begin
            write (copy (nomeArq+'                    ', 1, 15));
//            write ('    ',msg);

            for i := 1 to sl.count-1 do
                begin
                    p := pos (' ', sl[i]);
                    cod := copy (sl[i], 1, p-1);
                    mens := trim (copy (sl[i], p, 999));
                    if AnsiUpperCase(mens) = trim (ansiUpperCase(msg)) then
                        begin
                            write ('    ', cod, '    ', msg);
                            RenameFile(cod+'.WAV', nomeArq);
                            break;
                        end;
                end;
            writeln;
        end;
end;

begin
chdir ('c:\winvox\som\dosvox50');
sl := TStringlist.Create;
sl.LoadFromFile('dosvox50.dat');

    testa ('DV_SISTOP.WAV', 'Sistema DOSVOX');
    testa ('DV_VERSAO.WAV', ' - Versão ');
    testa ('DV_NCE.WAV', 'Instituto Tércio Pacitti - NCE/UFRJ');
    testa ('DV_BOMDIA.WAV', 'Bom dia ! ');
    testa ('DV_BOATAR.WAV', 'Boa tarde !');
    testa ('DV_BOANOI.WAV', 'Boa noite !');
    testa ('DV_SEF1.WAV', 'Aperte F1 para ajuda.');
    testa ('DV_DOSVOX.WAV', 'DOSVOX - ');
    testa ('DV_OQUE.WAV', 'O que você deseja ? ');

    testa ('DV_TRAB.WAV', 'Trabalhar com você é sempre bom !');
    testa ('DV_TCHAU.WAV', 'Tchau !');
    testa ('DV_CONFFIM.WAV', 'Confirma o fim do DOSVOX (S/N) ? ');

    testa ('DV_OPCINV.WAV', 'Opção inválida.');

    testa ('DV_SUBDIR.WAV', 'Subdiretórios - ');
    testa ('DV_DIRATU.WAV', 'O diretório atual é ');
    testa ('DV_COMPSDIR.WAV', 'Compactar subdiretório');
    testa ('DV_EXECSDIR.WAV', 'Executar subdiretório');

    testa ('DV_ABRWEXP.WAV', 'Abrindo diretório no Windows Explorer');

    testa ('DV_OK.WAV', 'Ok ! ');

    testa ('DV_INFNDISC.WAV', 'Informe novo disco de trabalho: ');
    testa ('DV_ERRNDISC.WAV', 'Não consegui mudar de disco. Sinto muito.');

    testa ('DV_INFNDIR.WAV', 'Informe o novo diretório de trabalho: ');
    testa ('DV_ERRMUD.WAV', 'Desculpe, não consegui mudar para o diretório pedido.');
    testa ('DV_OKMUD.WAV', 'Ok, troquei diretório de trabalho.');

    testa ('DV_DIRCRI.WAV', 'Nome do diretório a criar: ');
    testa ('DV_ERRDIRCRI.WAV', 'Desculpe mas não consegui criar o diretório pedido.');
    testa ('DV_OKDIRCRI.WAV', 'Ok, criei o diretório !');

    testa ('DV_ERRREMDIR.WAV', 'Desculpe: não consegui remover o diretório pedido.');
    testa ('DV_OKREMDIR.WAV', 'Ok, apaguei o diretório !');

    testa ('DV_DISCOS.WAV', 'Discos - ');
    testa ('DV_TAMANHO.WAV', 'Tamanho: ');
    testa ('DV_TAMDSK.WAV', 'Tamanho do disco em K: ');
    testa ('DV_LIVDSK.WAV', 'Espaço livre em K: ');

    testa ('DV_DRVINV.WAV', 'Unidade inválida.');
    testa ('DV_FORMRAP.WAV', 'Posso usar formatação rápida ? ');
    testa ('DV_PROBFORM.WAV', 'Problemas na formatação, verifique proteção de escrita.');
    testa ('DV_FORMCANC.WAV', 'Formatação cancelada.');

    testa ('DV_SEMSDIR.WAV', 'Nao existem subdiretórios aqui.');
    testa ('DV_AJUSDIR1.WAV', 'Subdiretórios: Use as setas para selecionar');
    testa ('DV_AJUSDIR2.WAV', 'Depois tecle sua opção');

    testa ('DV_TECLEFAL.WAV', 'Aperte as teclas e eu falarei.');
    testa ('DV_FIMTECESC.WAV', 'O teste será terminado quando você apertar ESCAPE');

    (***** dostec.pas *********************************************************)
    testa ('DV_TEC_BS.WAV', '<backspace>');
    testa ('DV_TEC_TAB.WAV', '<tab>');
    testa ('DV_TEC_ENTER.WAV', '<enter>');
    testa ('DV_TEC_ESC.WAV', '<escape>');
    testa ('DV_TEC_BRNCO.WAV', '<barra de espaços>');
    testa ('DV_TEC_F1.WAV', 'F1');
    testa ('DV_TEC_F2.WAV', 'F2');
    testa ('DV_TEC_F3.WAV', 'F3');
    testa ('DV_TEC_F4.WAV', 'F4');
    testa ('DV_TEC_F5.WAV', 'F5');
    testa ('DV_TEC_F6.WAV', 'F6');
    testa ('DV_TEC_F7.WAV', 'F7');
    testa ('DV_TEC_F8.WAV', 'F8');
    testa ('DV_TEC_F9.WAV', 'F9');
    testa ('DV_TEC_F10.WAV', 'F10');
    testa ('DV_TEC_F11.WAV', 'F11');
    testa ('DV_TEC_F12.WAV', 'F12');
    testa ('DV_TEC_INS.WAV', '<ins>');
    testa ('DV_TEC_DEL.WAV', '<del>');
    testa ('DV_TEC_HOME.WAV', '<home>');
    testa ('DV_TEC_END.WAV', '<end>');
    testa ('DV_TEC_PGUP.WAV', '<page up>');
    testa ('DV_TEC_PGDN.WAV', '<page down>');
    testa ('DV_TEC_CIMA.WAV', '<cima>');
    testa ('DV_TEC_BAIX.WAV', '<baixo>');
    testa ('DV_TEC_ESQ.WAV', '<esquerda>');
    testa ('DV_TEC_DIR.WAV', '<direita>');
    testa ('DV_TEC_AGU.WAV', '<agudo>');
    testa ('DV_TEC_APOST.WAV', '<apóstrofo>');

    testa ('DV_SHIFT.WAV', '<shift>');
    testa ('DV_CONTRL.WAV', '<control>');
    testa ('DV_NUM.WAV', '<num.lock>');
    testa ('DV_NONUM.WAV', '<sem num.lock>');
    testa ('DV_CAPS.WAV', '<caps lock>');
    testa ('DV_NOCAPS.WAV', '<sem caps lock>');
    testa ('DV_ALT.WAV', '<alt>');
    testa ('DV_CTLALT.WAV', '<control alt>');
    testa ('DV_BLWIN.WAV', '<iniciar>');
    testa ('DV_BRWIN.WAV', '<iniciar>');
    testa ('DV_BRAPPL.WAV', '<aplicações>');
    testa ('DV_BPAUSE.WAV', '<pause>');
    testa ('DV_BSLOCK.WAV', '<scroll lock>');
    testa ('DV_BPRSCR.WAV', '<print screen>');
    testa ('DV_FIMTESTE.WAV', 'O teste está encerrado.');

    (***** doscopia.pas - Mensagens de operações com arquivos *****************)
    testa ('DV_ERRARQ_0K.WAV', 'Operação completada.');
    testa ('DV_ERRARQ_NOK.WAV', 'Operação não completada.');
    testa ('DV_ERRARQ_*.WAV', 'Erro genérico de operação com arquivos ou pastas.');
    testa ('DV_ERRARQ_02.WAV', 'Erro: arquivo não encontrado.');
    testa ('DV_ERRARQ_03.WAV', 'Erro: caminho não encontrado.');
    testa ('DV_ERRARQ_05.WAV', 'Erro: acesso negado.');
    testa ('DV_ERRARQ_15.WAV', 'Erro: drive não encontrado.');
    testa ('DV_ERRARQ_17.WAV', 'Erro: arquivo não pode ser movido para outro drive.');
    testa ('DV_ERRARQ_19.WAV', 'Erro: mídia protegida para escrita.');
    testa ('DV_ERRARQ_23.WAV', 'Erro: CRC.');
    testa ('DV_ERRARQ_26.WAV', 'Erro: unidade inacessível.');
    testa ('DV_ERRARQ_29.WAV', 'Erro de escrita no dispositivo.');
    testa ('DV_ERRARQ_30.WAV', 'Erro de leitura no dispositivo.');
    testa ('DV_ERRARQ_39.WAV', 'Erro: disco ou mídia sem espaço.');
    testa ('DV_ERRARQ_80.WAV', 'Erro: arquivo já existente.');
    testa ('DV_ERRARQ_82.WAV', 'Erro: pasta não pode ser criada.');
    testa ('DV_ERRARQ_83.WAV', 'Erro fatal: INT 24.');
    testa ('DV_ERRARQ_108.WAV', 'Erro: disco inacessível.');
    testa ('DV_ERRARQ_110.WAV', 'Erro: arquivo ou dispositivo não pode ser aberto.');
    testa ('DV_ERRARQ_111.WAV', 'Erro: nome de arquivo muito longo.');
    testa ('DV_ERRARQ_112.WAV', 'Erro: disco ou mídia sem espaço.');
    testa ('DV_ERRARQ_123.WAV', 'Erro: nome inválido de arquivo, pasta ou unidade.');
    testa ('DV_ERRARQ_161.WAV', 'Erro: caminho inválido.');
    testa ('DV_ERRARQ_183.WAV', 'Erro: criação de arquivo já existente.');
    testa ('DV_ERRARQ_206.WAV', 'Erro: nome ou extensão de arquivo muito longos.');
    testa ('DV_ERRARQ_267.WAV', 'Erro: nome inválido de pasta.');
    testa ('DV_ERRARQ_1112.WAV', 'Erro: sem mídia na unidade.');
    testa ('DV_ERRARQ_1235.WAV', 'Operação abortada pelo usuário.');

    (***** dosdir.pas *********************************************************)
    testa ('DV_ESCARQ.WAV', 'Arquivos - ');

    (***** dosarq.pas *********************************************************)
    testa ('DV_ARQ1.WAV', 'Arquivos: use as setas para selecionar.');
    testa ('DV_ARQ2.WAV', 'Depois tecle sua opção.');

    (***** dosarq.pas - editaLeUmArquivo *****)
    testa ('DV_ERRNAOED.WAV', 'Este arquivo não pode ser editado.');
    testa ('DV_ERRNAOTXT.WAV', 'Este arquivo não pode ser processado textualmente.');
    testa ('DV_ERRZIP.WAV', 'Este é um arquivo compactado. Use a função executar.');

    testa ('DV_OPCAO.WAV', ' opção ');
    testa ('DV_PROBDISC.WAV', 'Cuidado, houve problemas no disco !');
    testa ('DV_NAOSELEC.WAV', 'Não posso fazer: não existe nenhum arquivo selecionado.');

    testa ('DV_DATACRI.WAV', 'Data de criação: ');
    testa ('DV_HORACRI.WAV', 'Hora de criação: ');

    testa ('DV_CNF_ARQLIX.WAV', 'Confirma envio para a lixeira de ');
    testa ('DV_CNF_ARQEXC.WAV', 'Confirma exclusão definitiva de ');
    testa ('DV_SIMNAO.WAV', ' (S/N)? ');
    testa ('DV_SNTOD.WAV', 'Sim, não ou todos? ');
    testa ('DV_ARQLIX.WAV', 'Arquivo movido para a lixeira.');
    testa ('DV_ARQEXC.WAV', 'Arquivo excluído.');

    testa ('DV_CNFAPA.WAV', 'Confirma remoção de ');
    testa ('DV_FOIAPA.WAV', 'Apaguei o arquivo ');

    testa ('DV_PROTEG.WAV', 'Arquivo está protegido para regravação');
    testa ('DV_DESPRO.WAV', 'Arquivo está desprotegido');
    testa ('DV_EDITRO.WAV', 'Edite o novo nome');
    testa ('DV_TROCAD.WAV', 'Troquei o nome do arquivo para ');

    testa ('DV_MASC.WAV', 'Informe a máscara de seleção, p. ex., *.TXT');
    testa ('DV_MASCSE.WAV', 'Informe a máscara de seleção: ');
    testa ('DV_TROCMASC.WAV', 'Troquei a máscara de seleção de arquivos para ');

    testa ('DV_TIPOCOP.WAV', 'Qual o tipo de cópia ? ');

    testa ('DV_TODSEL.WAV',  'Copia todos os selecionados? ');
    testa ('DV_INFDEST.WAV', 'Informe o diretório destino: ');
    testa ('DV_OPCANCEL.WAV', 'Certo, operação foi cancelada');
    testa ('DV_NAOPOD.WAV', 'O arquivo não pode ser copiado sobre si mesmo !');
    testa ('DV_ERRCOPIA.WAV', 'Sinto muito, deu erro no disco, portanto não copiei.');
    testa ('DV_MOVIDO.WAV', ' movido.');
    testa ('DV_COPIADO.WAV', ' copiado.');

    testa ('DV_ERROLEIT.WAV', 'Houve um erro de leitura no arquivo original.');
    testa ('DV_FALESP.WAV', 'Não existia espaço suficiente para escrever.');
    testa ('DV_NOMECOP.WAV', 'Informe nome do arquivo replica: ');
    testa ('DV_CONTSEL.WAV', 'Continue selecionando ou tecle ESC.');
    testa ('DV_NOMEINV.WAV', 'Esse nome que você escolheu não é valido.');
    testa ('DV_FOIREPL.WAV', ' foi replicado.');

    testa ('DV_TECLCMD.WAV', 'Tecle o comando.');

    testa ('DV_COMFBR.WAV', 'Impressão comum, formatada ou braille ? ');
    testa ('DV_IMPRCANC.WAV', 'A impressão foi cancelada.');

    testa ('DV_ESCVOLTA.WAV', 'Tecle ESC para voltar ao DOSVOX.');

    testa ('DV_NOMEAIMP.WAV', 'Digite o nome do arquivo a imprimir: ');
    testa ('DV_ARQNAOEX.WAV', 'Arquivo não existe, sinto muito.');

    testa ('DV_QUERD.WAV', 'Ele vai ser o novo diretório de trabalho ');
    testa ('DV_QERSOLET.WAV', 'Quer que soletre');

    testa ('DV_TECPGM.WAV', 'Qual a letra do programa ? ');
    testa ('DV_TECJOG.WAV', 'Qual a letra do jogo ? ');
    testa ('DV_TECRED.WAV', 'Qual a letra do programa de rede ? ');
    testa ('DV_TECMUL.WAV', 'Qual a letra do programa de multimídia ? ');

    testa ('DV_PRGNAOEX.WAV', 'Não existe programa registrado com esta letra.');
    testa ('DV_F1ESC.WAV', 'Tecle F1 para ajuda ou ESC para cancelar.');

    testa ('DV_ERROPRGCOD.WAV', 'Erro na execução do programa: código ');
    testa ('DV_PRGNAOENC.WAV', 'Programa não encontrado.');

    (***** dosvox.dpr *********************************************************)
    testa ('DV_AJU_OPC.WAV', 'As opções do DOSVOX são:');
    testa ('DV_AJU_T.WAV', 'T - testar o teclado');
    testa ('DV_AJU_E.WAV', 'E - editar texto');
    testa ('DV_AJU_L.WAV', 'L - ler texto');
    testa ('DV_AJU_I.WAV', 'I - imprimir');
    testa ('DV_AJU_A.WAV', 'A - arquivos');
    testa ('DV_AJU_D.WAV', 'D - discos e mídias');
    testa ('DV_AJU_ESC.WAV', 'A tecla ESC é sempre usada para cancelar');
    testa ('DV_AJU_SET.WAV', 'Pode usar as setas para selecionar ou conhecer todas as opções');
    testa ('DV_AJU_ENT.WAV', 'Aperte Enter para outras opções');

    testa ('DV_AJU_OUT.WAV', 'Outras opções:');
    testa ('DV_AJU_J.WAV', 'J - jogos');
    testa ('DV_AJU_U.WAV', 'U - utilitários falados');
    testa ('DV_AJU_R.WAV', 'R - acesso à rede e internet');
    testa ('DV_AJU_M.WAV', 'M - multimídia');
    testa ('DV_AJU_P.WAV', 'P - executar um programa do Windows');
    testa ('DV_AJU_S.WAV', 'S - subdiretórios');
    testa ('DV_AJU_Q.WAV', 'Q - informa a quem pertence este DOSVOX');
    testa ('DV_AJU_V.WAV', 'V - vai para outra janela');
    testa ('DV_AJU_C.WAV', 'C - configurar o DOSVOX');

    (***** dosarq.pas *********************************************************)
    testa ('DV_NUMARQD.WAV', 'Número de arquivos neste diretório: ');
    testa ('DV_NUMARQ.WAV', 'Número de arquivos: ');
    testa ('DV_NUMPAST.WAV', 'Número de pastas:   ');
    testa ('DV_ERRDIRNA.WAV', 'Erro: este diretório não está acessível');

    testa ('DV_AJUA_SET.WAV', 'Use as setas para escolher e tecle');
    testa ('DV_AJUA_E.WAV', 'E - editar o arquivo');
    testa ('DV_AJUA_I.WAV', 'I - imprimir');
    testa ('DV_AJUA_L.WAV', 'L - ler');
    testa ('DV_AJUA_R.WAV', 'R - remover');
    testa ('DV_AJUA_X.WAV', 'X - executar o arquivo');
    testa ('DV_AJUA_N.WAV', 'N - trocar o nome');
    testa ('DV_AJUA_C.WAV', 'C - tirar uma cópia');
    testa ('DV_AJUA_D.WAV', 'D - obter dados sobre o arquivo');
    testa ('DV_AJUA_Q.WAV', 'Q - informar qual arquivo do total');
    testa ('DV_AJUA_G.WAV', 'G - exibir um grupo de arquivos');
    testa ('DV_AJUA_T.WAV', 'T - falar o tamanho total dos arquivos');
    testa ('DV_AJUA_P.WAV', 'P - desproteger o arquivo');
    testa ('DV_AJUA_B.WAV', 'B - buscar arquivo contendo texto');
    testa ('DV_AJUA_O.WAV', 'O - ordenar os arquivos');
    testa ('DV_AJUA_M.WAV', 'M - enviar arquivo como email');
    testa ('DV_AJUA_Z.WAV', 'Z - compactar o arquivo');

    testa ('DV_AJUA_CTL_B.WAV', 'Ctrl+B - buscar novamente');
    testa ('DV_AJUA_CTL_T.WAV', 'Ctrl+T - falar o tamanho dos selecionados');
    testa ('DV_AJUA_CTL_P.WAV', 'Ctrl+P - proteger o arquivo');
    testa ('DV_AJUA_CTL_C.WAV', 'Ctrl+C - copiar nomes para área de transferência');
    testa ('DV_AJUA_CTL_V.WAV', 'Ctrl+V - copiar arquivos da área de transferência');
    testa ('DV_AJUA_CTL_X.WAV', 'Ctrl+X - mover arquivos para área de transferência');
    testa ('DV_AJUA_CTL_N.WAV', 'Ctrl+N - jogar os nomes sem incluir diretório');
    testa ('DV_AJUA_CTL_Q.WAV', 'Ctrl+Q - informar quantos selecionados do total');
    testa ('DV_AJUA_CTL_D.WAV', 'Ctrl+D - informar o nome do diretório atual');

    (***** dosdisco.pas *******************************************************)
    testa ('DV_AJUD_OPC.WAV', 'As opcoes de manuseio de discos );e mídias são:');
    testa ('DV_AJUD_P.WAV', '  P - pastas preferidas');
    testa ('DV_AJUD_T.WAV', '  T - trocar a pasta atual');
    testa ('DV_AJUD_D.WAV', '  D - escolher disco ou mídia atual');
    testa ('DV_AJUD_I.WAV', '  I - informar qual a pasta atual');
    testa ('DV_AJUD_V.WAV', '  V - voltar à pasta anterior');
    testa ('DV_AJUD_B.WAV', '  B - busca de arquivos por nome');
    testa ('DV_AJUD_C.WAV', '  C - criar pasta');
    testa ('DV_AJUD_E.WAV', '  E - espaço livre e tamanho da mídia');
    testa ('DV_AJUD_G.WAV', '  G - gravar mídia');
    testa ('DV_AJUD_R.WAV', '  R - remover mídia');
    testa ('DV_AJUD_N.WAV', '  N - renomear mídia');
    testa ('DV_AJUD_F.WAV', '  F - formatar mídia');
    testa ('DV_AJUD_L.WAV', '  L - esvaziar a lixeira do Dosvox');

    (***** dosBuscaArq.pas ****************************************************)
    testa ('DV_AJUDA_PRMPT.WAV', 'Selecione os parâmetros para a pesquisa de arquivos. Ao final, tecle ESC.');
    testa ('DV_AJUDA_NOME.WAV', 'Nome do arquivo ou máscara');
    testa ('DV_AJUDA_DIRET.WAV', 'Procurar na pasta');
    testa ('DV_AJUDA_SUBDIR.WAV', 'Procurar nas subpastas?');
    testa ('DV_AJUDA_DIRNAO.WAV', 'pasta inexistente ou inacessível.');
    testa ('DV_AJUDA_NENHUM.WAV', 'Nenhum arquivo encontrado.');
    testa ('DV_AJUDA_ARQENC.WAV', 'Arquivos encontrados: ');
    testa ('DV_AJUDA_SELEC.WAV', 'Selecione com as setas e tecle opção (ou F9 para menu).');
    testa ('DV_AJUDA_UMARQ.WAV', 'Item selecionado: ');
    testa ('DV_AJUDA_MUIARQ.WAV', ' itens selecionados.');
    testa ('DV_AJUDA_SELOPC.WAV', 'Selecione opção: ');
    testa ('DV_AJUDA_ERR1ARQ.WAV', 'Esta opção se aplica a apenas um arquivo selecionado.');

    testa ('DV_EDITARQ.WAV', 'Editar arquivo: ');
    testa ('DV_LEARQ.WAV', 'Ler arquivo: ');
    testa ('DV_EXECARQ.WAV', 'Executar: ');
    testa ('DV_MUDADIR.WAV', 'Vai para a pasta: ');
    testa ('DV_SELLIX.WAV', 'Mover para lixeira: ');
    testa ('DV_SELEXC.WAV', 'Exclusão definitiva: ');
    testa ('DV_APLISEL.WAV', 'aplica aos selecionados? ');
    testa ('DV_REPBUSCA.WAV', 'Repetir busca anterior? ');
    testa ('DV_NOVBUSCA.WAV', 'Realiza nova busca? ');

    (***** dosBuscaArq.pas - selSetasArquivos *****)
    testa ('DV_AJUDA_E.WAV', 'E - editar arquivo selecionado');
	testa ('DV_AJUDA_L.WAV', 'L - ler arquivo selecionado');
	testa ('DV_AJUDA_X.WAV', 'X - executar arquivo selecionado');
	testa ('DV_AJUDA_D.WAV', 'D - ir para a pasta do arquivo selecionado');
	testa ('DV_AJUDA_R.WAV', 'R - remover arquivos selecionados');
	testa ('DV_AJUDA_C.WAV', 'C - copiar arquivos selecinados');
	testa ('DV_AJUDA_B.WAV', 'B - repetir busca');
	testa ('DV_AJUDA_N.WAV', 'N - nova busca');

    (***** dosdisco.pas - esvaziarLixeira *****)
    testa ('DV_AJUDL_PRMPT.WAV', 'Esvaziar a lixeira do Dosvox. Confirma? ');
    testa ('DV_AJUDL_OK.WAV', 'Ok. A lixeira do Dosvox foi esvaziada.');
    testa ('DV_AJUDL_NOK.WAV', 'Erro: a lixeira do Dosvox não foi esvaziada.');

    testa ('DV_AJU_MA.WAV', 'F - folhear mais opções');
    testa ('DV_AJU_F9.WAV', 'Aperte F9 para conhecer outras opções');

    testa ('DV_AJUAC_OPC.WAV', 'As opções de cópia de arquivos são:');
    testa ('DV_AJUAC_R.WAV', 'R - criar réplica de um arquivo');
    testa ('DV_AJUAC_D.WAV', 'D - copiar arquivos para outro diretório');
    testa ('DV_AJUAC_M.WAV', 'M - mover arquivos para outro diretório');
    testa ('DV_AJUAC_T.WAV', 'T - copiar todos');

    (***** dosdir.pas *********************************************************)
    testa ('DV_AJUS_OPC.WAV', 'Use as setas, depois acione');
    testa ('DV_AJUS_ENTER.WAV', 'ENTER - seleciona diretório e continua');
    testa ('DV_AJUS_T.WAV', 'T - seleciona e sai');
    testa ('DV_AJUS_S.WAV', 'S - sai indo para o diretório pai');
    testa ('DV_AJUS_C.WAV', 'C - cria novo subdiretório');
    testa ('DV_AJUS_R.WAV', 'R - remove');
    testa ('DV_AJUS_N.WAV', 'N - troca o nome');
    testa ('DV_AJUS_K.WAV', 'K - copia');
    testa ('DV_AJUS_D.WAV', 'D - obtém dados');
    testa ('DV_AJUS_V.WAV', 'V - volta ao penúltimo diretório');
    testa ('DV_AJUS_I.WAV', 'I - informa diretório atual');
    testa ('DV_AJUS_P.WAV', 'P - diretórios preferidos');
    testa ('DV_AJUS_X.WAV', 'X - executar o diretório atual');
    testa ('DV_AJUS_Z.WAV', 'Z - compactar subdiretório');
    testa ('DV_AJUS_G.WAV', 'G - exibir um grupo de subdiretórios');

    testa ('DV_SELJAN.WAV', 'Selecione a nova janela com as setas depois ENTER');

    testa ('DV_TAMMEGA.WAV', 'Tamanho do disco em Mb: ');
    testa ('DV_LIVRMEGA.WAV', 'Espaço livre em Mb: ');

    testa ('DV_SELDIR.WAV', 'Selecione o diretório com as setas');

    testa ('DV_APGSELEC.WAV', 'Apaga todos os selecionados? ');
    testa ('DV_ARQEXIS1.WAV', 'Arquivo destino ');
    testa ('DV_ARQEXIS2.WAV', ' já existe.  Sobrescreve (S/N/T/ESC)? ');
    testa ('DV_DIREXIS.WAV', 'Diretório já existe - ');
    testa ('DV_SOBRE_SN.WAV', 'Sobrescreve (S/N)? ');
    testa ('DV_NAOAPAOR.WAV', 'Não pude apagar o arquivo original');

    (***** dosconf.pas ********************************************************)
    testa ('DV_CONF_HEADR.WAV', 'DOSVOX - Configuração');
    testa ('DV_CONF_PRMPT.WAV', 'Configurações - ');
    testa ('DV_AJUC_OPC.WAV', 'As opções de configuração são:');
    testa ('DV_AJUC_P.WAV', 'P - pastas principais');
    testa ('DV_AJUC_D.WAV', 'D - selecionar dispositivo de áudio');
    testa ('DV_AJUC_F.WAV', 'F - fala gravada');
    testa ('DV_AJUC_S.WAV', 'S - fala sintetizada');
    testa ('DV_AJUC_C.WAV', 'C - retorno sonoro em cópias de arquivos');
    testa ('DV_AJUC_A.WAV', 'A - atualização do sistema');
    testa ('DV_AJUC_W.WAV', 'W - iniciar o Dosvox com o Windows');
    testa ('DV_AJUC_I.WAV', 'I - informações sobre o sistema Dosvox');
    testa ('DV_AJUC_AST.WAV', '* - configuração avançada');

    testa ('DV_AJUC_IMP.WAV', 'Funcionalidade em fase de implementação');
    testa ('DV_EDITCONF.WAV', 'Editore as configurações, ao final tecle ESC');

    (***** dosconf.pas - definePastaPadraoTrabalho *****)
    testa ('DV_PPADR_MANT.WAV', 'Pasta padrão de trabalho mantida. ');
    testa ('DV_PPADR_ALT.WAV', 'Ok. Pasta padrão de trabalho alterada para: ');
    testa ('DV_PPADR_ALT2.WAV', 'Pasta de trabalho também foi alterada.');

    (***** dosconf.pas - leNovaPastaPadraoTrabalho *****)
    testa ('DV_NOVA_PPADR.WAV', 'Informe nome da nova pasta padrão de trabalho:');
    testa ('DV_PASTA_NEX.WAV', 'Pasta não existe. ');

    (***** dosconf.pas - configPastaPadraoTrabalho *****)
    testa ('DV_AJUCPT_PRMPT.WAV', 'Escolha a nova pasta padrão: ');
    testa ('DV_AJUCPT_PRMPT2.WAV', 'Configuração da pasta padrão de trabalho');
    testa ('DV_AJUCPT_CORR.WAV', 'A pasta corrente é: ');
    testa ('DV_AJUCPT_PADR.WAV', 'A pasta padrão de trabalho é: ');

    testa ('DV_AJUCPT_OPC.WAV', 'As opções de definição da pasta padrão de trabalho são:');
    testa ('DV_AJUCPT_T.WAV', 'T - Treino');
    testa ('DV_AJUCPT_D.WAV', 'D - Meus Documentos');
    testa ('DV_AJUCPT_A.WAV', 'A - pasta de trabalho atual');
    testa ('DV_AJUCPT_O.WAV', 'O - outra pasta');

    (***** dosconf.pas - configPastas *****)
    testa ('DV_AJUCP_PRMPT.WAV', 'Configurações de pastas - ');
    testa ('DV_AJUCP_OPC.WAV', 'As opções de configuração de pastas são:');
    testa ('DV_AJUCP_T.WAV', 'T - pasta padrão de trabalho');
    testa ('DV_AJUCP_P.WAV', 'P - configurar pastas preferidas');

    (***** dosconf.pas - selecionaDispAudio *****)
    testa ('DV_AJUCD_PRMPT.WAV', 'Selecione o dispositivo de áudio: ');
    testa ('DV_AJUCD_SEL.WAV', 'Ok. Selecionado dispositivo de áudio: ');

    (***** dosconf.pas - configFalaGravada *****)
    testa ('DV_AJUCF_PRMPT.WAV', 'Selecione a velocidade da fala gravada: ');
    testa ('DV_AJUCF_OPC.WAV', 'As opções de fala gravada são: ');
    testa ('DV_AJUCF_N.WAV', 'N - velocidade normal');
    testa ('DV_AJUCF_R.WAV', 'R - voz mais rápida');
    testa ('DV_AJUCF_B.WAV', 'B - voz de boneca');

    (***** dosconf.pas - configFalaSintetizada *****)
    testa ('DV_AJUCS_PRMPT.WAV', 'Configurações de fala sintetizada');
    testa ('DV_AJUCS_S.WAV', 'Sintetizador (F9 para mudar)');
    testa ('DV_AJUCS_V.WAV', 'Velocidade (-10 a 10)');
    testa ('DV_AJUCS_T.WAV', 'Tonalidade (-10 a 10)');
    testa ('DV_AJUCS_NAO.WAV', 'Voz não encontrada');
    testa ('DV_AJUCS_NAT.WAV', 'Fala nativa ativada');
    testa ('DV_AJUCS_SINT.WAV', 'Sintetizador ativado: ');

    (***** dosconf.pas - configRetornoCopia *****)
	testa ('DV_AJUCC_PRMPT.WAV', 'Configure o retorno sonoro em cópias de arquivos');
    testa ('DV_AJUCC_RETORNO.WAV', 'Retorno sonoro');
    testa ('DV_AJUCC_INSTRUM.WAV', 'Instrumento (de 1 a 127)');
    testa ('DV_AJUCC_OK.WAV', 'Ok. Retorno sonoro configurado.');

    (***** dosconf.pas - configInicia *****)
    testa ('DV_AJUCW_PRMPT.WAV', 'Selecione opção de iniciar o Dosvox');
    testa ('DV_AJUCW_PRMPT2.WAV', 'Iniciar o Dosvox com o Windows');
    testa ('DV_AJUCW_ERR.WAV', 'Erro: Não consegui modificar inicialização automática do Dosvox.');
    testa ('DV_AJUCW_OKS.WAV', 'Ok. O Dosvox será iniciado com o Windows.');
    testa ('DV_AJUCW_OKN.WAV', 'Ok. O Dosvox não será iniciado com o Windows.');

    (***** dosconf.pas - configAtualiza *****)
    testa ('DV_AJUCA_PRMPT.WAV', 'Atualização do Dosvox - ');
    testa ('DV_AJUCA_OPC.WAV', 'As opções de atualização são:');
    testa ('DV_AJUCA_P.WAV', 'P - Atualizar programa pela Internet');
    testa ('DV_AJUCA_V.WAV', 'V - verificar programas com atualização pendente');
    testa ('DV_AJUCA_A.WAV', 'A - Atualizar configuração por arquivo .ATU');
    testa ('DV_AJUCA_Z.WAV', 'Z - Atualizar programa por arquivo .ZIP');
    testa ('DV_AJUCA_I.WAV', 'I - Informações sobre os programas instalados');
    testa ('DV_AJUCA_S.WAV', 'S - Atualizar todo o sistema pela Internet');

    (***** dosconf.pas - configInforma *****)
    testa ('DV_AJUCI_PRMPT.WAV', 'Informações do sistema Dosvox - ');
    testa ('DV_AJUCI_OPC.WAV', 'As opções de informação do Dosvox são:');
    testa ('DV_AJUCI_D.WAV', 'D - Dados gerais sobre o sistema');
    testa ('DV_AJUCI_Q.WAV', 'Q - Proprietário da versão instalada DOSVOX');

    (***** dosconf.pas - configAvançada *****)
    testa ('DV_CUIDAD.WAV', 'A configuração avançada só deve ser feita por usuários experientes');
    testa ('DV_TECLECCONT.WAV', 'Aperte a tecla C para continuar');
    testa ('DV_CONFG_PRMPT.WAV', 'Configuração avançada - ');
    testa ('DV_AJUCG_OPC.WAV', 'As opções de configuração avançada são:');
    testa ('DV_AJUCG_E.WAV', 'E - editar uma seção');
    testa ('DV_AJUCG_I.WAV', 'I - incluir item em uma seção');
    testa ('DV_AJUCG_R.WAV', 'R - remover item de uma seção');
    testa ('DV_AJUCG_C.WAV', 'C - criar nova seção');
    testa ('DV_AJUCG_M.WAV', 'M - editar os macrocomandos de F2 a F7');

    (***** dosconf.pas - escolheSecao *****)
    testa ('DV_SELSEC.WAV', 'Selecione com as setas a seção a configurar');

    (***** dosconf.pas - removeItem *****)
    testa ('DV_SELITEMREM.WAV', 'Escolha com as setas o item a remover');
    testa ('DV_CNFREMITEM.WAV', 'Confirma remoção do item ');
    testa ('DV_OKREMOV.WAV', 'Ok, removido');

    (***** dosconf.pas - criaNovaSecao *****)
    testa ('DV_NOVASECAO.WAV', 'Informe o nome da nova seção do DOSVOX.INI');

    (***** dosconf.pas - atualizarDosvoxIni *****)
    testa ('DV_REALTERASN.WAV', 'Deseja realterar itens anteriormente criados?');
    testa ('DV_ARQMUDANCA.WAV', 'Informe o nome do arquivo que contém as mudanças');
    testa ('DV_CHAVEINVAL.WAV', 'Chave inválida');

    testa ('DV_OPPREF.WAV', 'Folhear, incluir este ou editar?');
    testa ('DV_NOMEPREF.WAV', 'Que nome este diretório terá na lista de preferidos?');
    testa ('DV_MACNAODEF.WAV', 'Este macrocomando não foi definido');
    testa ('DV_DESIST.WAV', 'Desistiu...');

    testa ('DV_ITEMINC.WAV', 'Nome do item a incluir');
    testa ('DV_CONTITEM.WAV', 'Informe o conteúdo deste item');
    testa ('DV_NUMSDIR.WAV', 'Número de subdiretórios aqui: ');

    testa ('DV_DIGPALAV.WAV', 'Digite a palavra ou frase a buscar');
    testa ('DV_ACHEI.WAV', 'Achei ');
    testa ('DV_NACHEI.WAV', 'Não achei');

    testa ('DV_DARQEXIS.WAV', 'Dados do arquivo existente');
    testa ('DV_DARQNOVO.WAV', 'Dados do novo arquivo');
    testa ('DV_DINDISP.WAV', 'Dado não disponível');

    testa ('DV_TIPORD.WAV', 'Ordena por Nome, Tamanho, Extensão ou Data? ');
    testa ('DV_SAPINAO.WAV', 'Nenhuma fala SAPI está instalada');

    testa ('DV_EMAILDEST.WAV', 'Email do destinatário');
    testa ('DV_ASSUNTCART.WAV', 'Assunto da carta');
    testa ('DV_VOUENVIAR.WAV', 'Vou enviar ');
    testa ('DV_CONFIRMA.WAV', 'Confirma? ');
    testa ('DV_CARTPREPVOX.WAV', 'Carta preparada para transmissão pelo Cartavox');
    testa ('DV_ERRCARQENV.WAV', 'Erro ao criar arquivo para envio');

    testa ('DV_CTODSL.WAV', 'Tecle T para todo diretório ou S para selecionados: ');
    testa ('DV_NAOCOMPAC.WAV', 'Não consegui acionar o compactador');
    testa ('DV_NOMECOMPAC.WAV', 'Qual o nome do arquivo compacto? ');
    testa ('DV_AGUCOMPACT.WAV', 'Um momento, compactando');
    testa ('DV_UMMOMENTO.WAV', 'Um momento...');
    testa ('DV_OKCOMPAC.WAV', 'Ok, compactado');

    testa ('DV_EDITNOVNOME.WAV', 'Editore o novo nome');
    testa ('DV_OKNOMEMUD.WAV', 'OK, nome mudado');
    testa ('DV_ERRNOMEMUD.WAV', 'Não pude mudar o nome');
    testa ('DV_SELEC.WAV', ' selecionado ');
    testa ('DV_SELECS.WAV', ' selecionados');
    testa ('DV_DE.WAV', ' de ');

    testa ('DV_PERIGO.WAV', 'Atenção, essa operação é irreversível e pode causar imensos danos.');
    testa ('DV_DISCOREMOV.WAV', 'Disco foi removido.');
    testa ('DV_AUDIOCDDETEC.WAV', 'Audio CD foi detectado');
    testa ('DV_CDNAODIR.WAV', 'CD de áudio não tem diretórios');

    testa ('DV_INFLDRV.WAV', 'Informe a letra da unidade a formatar: ');
    testa ('DV_ROTULOGRAV.WAV', 'Edite o nome do rótulo a gravar (10 letras): ');
    testa ('DV_TECENTFORMAT.WAV', 'Aperte enter para formatar');
    testa ('DV_UNIFOR.WAV', 'Unidade bem formatada');
    testa ('DV_PROBFR.WAV', 'Problemas na formatação');

    testa ('DV_GMIDIA.WAV', 'Gravação de mídia');
    testa ('DV_TAMGRM.WAV', 'Tamanho de gravação em MB: ');
    testa ('DV_PROBLG.WAV', 'Problemas no processo de gravação');
    testa ('DV_LUNGRV.WAV', 'Qual a unidade de gravação? ');
    testa ('DV_UNGRAV.WAV', 'Unidade de gravação: ');
    testa ('DV_NOMECD.WAV', 'Informe o nome do CD a gravar (12 letras): ');
    testa ('DV_DIRGCD.WAV', 'Informe o nome do diretorio a gravar (aperte ENTER se for o atual)');
    testa ('DV_TRANSC.WAV', 'Transcrevendo arquivos para a área de montagem');
    testa ('DV_DEMORA.WAV', 'Esta é uma operação demorada');
    testa ('DV_INGRCD.WAV', 'Iniciando a gravação, aperte ENTER após inserir a mídia');
    testa ('DV_CANESC.WAV', 'Para cancelar aperte ESC');
    testa ('DV_GRAVND.WAV', 'Gravando...');

    testa ('DV_UNIREM.WAV', 'Informe a unidade a remover: ');
    testa ('DV_EXSUPC.WAV', 'Remove todo o dispositivo? ');
    testa ('DV_UNIRM.WAV', 'Ok, unidade removida.');
    testa ('DV_NAORM.WAV', 'Não foi possível remover.');
    testa ('DV_UNRENO.WAV', 'Informe a unidade a renomear: ');
    testa ('DV_NOMERN.WAV', 'Qual o novo nome (12 letras): ');
    testa ('DV_OKRENO.WAV', 'Ok, unidade renomeada.');
    testa ('DV_NORENO.WAV', 'Não foi possível renomear.');

    testa ('DV_REMSEG.WAV', 'A mídia pode ser removida com toda segurança');
    testa ('DV_ABERTO.WAV', 'O dispositivo está aberto');
    testa ('DV_USUOUT.WAV', 'O dispositivo está sendo utilizado no momento por outro processo');
    testa ('DV_EJDINT.WAV', 'É impossível ejetar um disco interno!');

    testa ('DV_DISINV.WAV', 'Dispositivo inválido');
    testa ('DV_NAOABV.WAV', 'Não pude abrir o volume');
    testa ('DV_SEMACX.WAV', 'Não pude garantir acesso exclusivo');
    testa ('DV_NDISMO.WAV', 'Não pude desmontar o volume');
    testa ('DV_NTIRPR.WAV', 'Não pude tirar a proteção contra remoção');
    testa ('DV_NAOEJE.WAV', 'Não pude ejetar a mídia');
    testa ('DV_NLIBV.WAV', 'Não pude liberar o acesso da mídia');

    testa ('DV_VARSEL.WAV', 'Vários arquivos estão selecionados, processo todos? ');

    testa ('DV_EDDIA.WAV', 'Editore dia e hora, use as setas, ESC termina');
    testa ('DV_HORA.WAV', 'Hora');
    testa ('DV_MINUT.WAV', 'Minuto');
    testa ('DV_DIA.WAV', 'Dia');
    testa ('DV_MES.WAV', 'Mês');
    testa ('DV_ANO.WAV', 'Ano');

    testa ('DV_NOPRV.WAV', 'Para mudar a hora é necessário rodar o Dosvox em modo administrador.');

    testa ('DV_MESTRE.WAV', 'Quer fazer dele o diretório mestre do Dosvox? ');
    testa ('DV_MSTMUD.WAV', 'Diretório mestre mudado');

    (***** dosupdat.pas ********************************************************)
    testa ('DV_EXTZIP.WAV', 'Extraindo o arquivo ZIP.');
    testa ('DV_NARQZP.WAV', 'Informe o nome do arquivo .ZIP: ');
    testa ('DV_ZIPNEC.WAV', 'Nenhum arquivo .ZIP foi selecionado.');
    testa ('DV_ATUNEC.WAV', 'Nenhum arquivo .ATU foi selecionado.');

    testa ('DV_ERRODC.WAV', 'Descompactador não pôde ser executado.');
    testa ('DV_EXTSCS.WAV', 'Arquivo extraido com sucesso.');

    testa ('DV_NMPROG.WAV', 'Informe o nome do programa ou selecione com as setas:');
    testa ('DV_ATUPRO.WAV', 'Deseja atualizar o programa: ');

    testa ('DV_PROGEX.WAV', 'O programa está em execução. Não posso atualizar.');
    testa ('DV_ERRBXR.WAV', 'Erro ao baixar o arquivo.');
    testa ('DV_PEXTE1.WAV', 'O programa está em execução.');
    testa ('DV_PEXTE2.WAV', 'Por favor feche o programa e aperte Enter ou Esc para cancelar.');
    testa ('DV_BAIXND.WAV', 'Baixando...');
    testa ('DV_PROGAT.WAV', 'O programa foi atualizado.');

    testa ('DV_INTOUT.WAV', 'A internet está fora do ar');
    testa ('DV_ACBLOQ.WAV', 'Acesso ao site de atualização do DosVox está bloqueado.');
    testa ('DV_ERRSRV.WAV', 'Erro na comunicação com o site de atualização do DosVox');
    testa ('DV_ERRWAR.WAV', 'Erro de escrita do arquivo');
    testa ('DV_GEROPC.WAV', 'Erro ao gerar a lista de opções.');

    testa ('DV_VER64B.WAV', 'O Sistema Operacional deste computador é de 64 bits');
    testa ('DV_VER32B.WAV', 'O Sistema Operacional deste computador é de 32 bits');
    testa ('DV_VERESC.WAV', 'Escolha com as setas a versão do Dosvox a baixar:');
    testa ('DV_SETUPS.WAV', 'Arquivo de Setup foi gravado em: ');
    testa ('DV_PORCEN.WAV', ' por cento');
    testa ('DV_CUIDATU.WAV', 'Cuidado! Para atualizar o sistema nenhum programa dele pode estar ativo.');
    testa ('DV_NENHUM.WAV', 'Todos os arquivos estão atualizados.');
    readln;
end.
