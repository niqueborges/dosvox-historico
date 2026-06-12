escreve "criando"
sql abre "func.db" &
sql executa "create table Funcionarios (nomeFunc varchar (30), cargo int)"

escreve "injetando funcionarios"
sql prepara #2 "insert into Funcionarios (nomeFunc, cargo) Values (?, ?)" "SI"
sql injeta  #2 "Antonio", 1
sql injeta  #2 "Julio", 1
sql injeta  #2 "Patrick", 3
sql injeta  #2 "Fialho", 2
sql injeta  #2 "Robson", 4
sql libera  #2

escreve "--- listando todos"
sql prepara #2 "select nomeFunc, cargo from Funcionarios where 1"
e = 0
enquanto e = 0
    sql pega #2 n, c
    sql checa e
    se e = 0 escreve n " " c
fim enquanto
sql libera #2

escreve "--- listando funcionários sem Patrick"
sql prepara #2 "select nomeFunc, cargo from Funcionarios where nomeFunc <> ?" "S"
sql injeta  #2 "Patrick" &
e = 0
enquanto e = 0
    sql pega #2 n, c
    sql checa e
    se e = 0 escreve n " " c
fim enquanto
sql libera #2

sql fecha
le


