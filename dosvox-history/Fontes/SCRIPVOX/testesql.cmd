escreve "Teste dos comandos de SQL no scriptvox"
sql abre "func.db" &

escreve "criando tabelas"
sql executa "create table Funcionarios (nomeFunc varchar (30), cargo int)"
sql executa "create table Cargos (nomeCargo varchar (30), codCargo int, salario float)"

escreve "gravando dados na tabela de cargos"
sql prepara #1 "insert into Cargos (nomeCargo, codCargo, salario) Values (?, ?, ?)" "TIF"
sql injeta  #1 "Analista", 1, 5000
sql injeta  #1 "Programador", 2, 4000
sql injeta  #1 "Estagiário", 3, 3000
sql injeta  #1 "Secretário", 4, 3500
sql ultimoid i
sql libera  #1

escreve "Último registro: " i

escreve "gravando dados na tabela de funcionários"
sql prepara #2 "insert into Funcionarios (nomeFunc, cargo) Values (?, ?)" "TI"
sql injeta  #2 "Antonio", 1
sql injeta  #2 "Julio", 1
sql injeta  #2 "Patrick", 3
sql injeta  #2 "Fialho", 2
sql injeta  #2 "Robson", 4
sql injeta  #2 "João", 2
sql libera  #2

escreve "atualizando cargo de um funcionário"
sql prepara #3 "update Funcionarios set cargo=1 where nomeFunc "T"
sql injeta  #3 "Fialho"
sql libera  #3

escreve "Percorre a base de cargos item a item, mostrando o nome do cargo"
sql prepara #4 "select nomeCargo from Cargos"
e = 0
enquanto e = 0
    sql pega #4 c
    sql checa e
    se e = 0 escreve c
fim enquanto
sql libera #4

escreve "Percorre as bases fazendo select com join"
sql prepara #5 "select nomeFunc, codCargo, salario from Funcionarios, Cargos where cargo = codCargo"
e = 0
enquanto e = 0
    sql pega #5 n, c, s
    sql checa e
    se e = 0 escreve n ", " s
fim enquanto
sql libera #5

escreve "Gera lista de funcionarios cujo cargo <> valor dado"
Escreve "Qual o código do cargo entre 1 e 4?"
le x
sql prepara #6 "select nomeFunc, nomeCargo, salario from Funcionarios, Cargos where cargo = codCargo and codCargo <> ?" "I"
sql injeta #6 x &
sql lista #6 l ", "
escreve lista l

escreve "Lista rapidamente os nomes"
sql exibe "select nomeFunc from Funcionarios"

sql fecha
escreve "Aperte enter"
le
