function ltrim(s) { sub(/^[ \t\r\n ]+/, "", s); return s  }
function rtrim(s) { sub(/[ \t\r\n ]+$/, "", s); return s  }
function trim(s)  { return rtrim(ltrim(s));  }

BEGIN {
    FS=";"
    # Extract constants
    BATCH_SIZE=1048576 # Evaluated 1024*1024

    # Column mappings
    COL_MES=1
    COL_IBGE=3
    COL_NOME=7
    COL_PARCELA=12
    COL_OBS=13
    COL_VALOR=14

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
    if ((NR % BATCH_SIZE) == 0) {
        print "begin transaction;"
        printf "insert into auxilio (mes, ibge, nome, parcela, obs, valor) values "
    }

    # Extract variables
    val_mes = $COL_MES
    val_ibge = $COL_IBGE
    val_nome = $COL_NOME
    val_parcela = $COL_PARCELA
    val_obs = $COL_OBS
    val_valor = $COL_VALOR

    printf("(")
    printf val_mes
    printf ","
    if (val_ibge == "") {
        printf 0
    } else {
        printf val_ibge
    }
    printf ","
    printf "\"" trim(val_nome) "\""
    printf ","
    printf val_parcela + 0
    printf ","
    if (substr(val_obs, 1, 1) != "N") {
        printf "'" trim(val_obs) "'"
    } else {
        printf "''"
    }
    printf ","
    printf val_valor + 0
    printf ")"
    if ((NR % BATCH_SIZE) == (BATCH_SIZE - 1)) {
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
