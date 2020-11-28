function ltrim(s) { sub(/^[ \t\r\n ]+/, "", s); return s  }
function rtrim(s) { sub(/[ \t\r\n ]+$/, "", s); return s  }
function trim(s)  { return rtrim(ltrim(s));  }

BEGIN {
    FS=";"
    # BATCH=64*1024
    BATCH=1024*1024
    # BATCH=2
    ending=""
    print "PRAGMA journal_mode=MEMORY;"
    # print "PRAGMA syncronous=OFF;"
    print "create table if not exists auxilio ("
        print "mes int not null,"
        print "ibge int not null,"
        print "nome text not null,"
        print "parcela int not null,"
        print "obs text,"
        print "valor int not null"
    print ");"
    print "begin transaction;"
    printf "insert into auxilio (mes, ibge, nome, parcela, obs, valor) values "
}
NR>1{
    printf ending
    gsub("\"", "")
    if ((NR % BATCH) == 0) {
        print "begin transaction;"
        printf "insert into auxilio (mes, ibge, nome, parcela, obs, valor) values "
    }
    printf("(")
    printf $1 # mês
    printf ","
    if ($3 == "") { # ibge
        printf 0
    } else {
        printf $3
    }
    printf ","
    printf "\"" trim($7) "\"" # nome
    printf ","
    printf $12 + 0 # parcela
    printf ","
    if (substr($13, 1, 1) != "N") { # obs
        printf "'" trim($13) "'"
    } else {
        printf "''"
    }
    printf ","
    printf $14 + 0 #valor
    printf ")"
    if ((NR % BATCH) == (BATCH - 1)) {
        printf "." > "/dev/stderr"
        ending=";commit;\n"
    } else {
        ending=","
    }
}
END {
    printf ";\n"
    print "commit;"
}
