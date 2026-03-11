# sqlite3 ../database_fixed.db '.dump' | grep '^INSERT' | sed 's:VALUES:(mes, ibge, nome, parcela, obs, valor) VALUES:g' | dolt sql


BEGIN {
    INSERT_HEADER="insert into auxilio (id, mes, ibge, nome, parcela, obs, valor) VALUES "
    FS=","
    # Extract constants
    BATCH_SIZE=262144 # Evaluated 1024*256

    # Column mappings
    COL_MES=1
    COL_IBGE=2
    COL_NOME=3
    COL_PARCELA=4
    COL_OBS=5
    COL_VALOR=6

    printf INSERT_HEADER
    LINE_PREFIX=""
}


END {
    printf ";"
    exit(0)
}

NR>0 {
    printf LINE_PREFIX
    gsub(/"/, "")

    # Extract variables
    val_mes = $COL_MES
    val_ibge = $COL_IBGE
    val_nome = $COL_NOME
    val_parcela = $COL_PARCELA
    val_obs = $COL_OBS
    val_valor = $COL_VALOR

    printf "("
    printf NR
    printf ", "
    printf val_mes
    printf ", "
    printf val_ibge
    printf ", "
    printf "\"" val_nome "\""
    printf ", "
    printf val_parcela
    printf ", "
    printf "\"" val_obs "\""
    printf ", "
    printf val_valor
    printf ")"
    if ((NR%BATCH_SIZE)==0) {
        LINE_PREFIX=";\n" INSERT_HEADER
    } else {
        LINE_PREFIX=","
    }
}
