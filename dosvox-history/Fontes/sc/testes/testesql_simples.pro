escreve "Teste dos comandos de SQL no scriptvox"
sql abre "blibli.db" &

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

sql fecha
escreve "Aperte enter"
le
