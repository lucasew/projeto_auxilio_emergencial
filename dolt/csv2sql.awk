# sqlite3 ../database_fixed.db '.dump' | grep '^INSERT' | sed 's:VALUES:(mes, ibge, nome, parcela, obs, valor) VALUES:g' | dolt sql


BEGIN {
    INSERT_HEADER="insert into auxilio (id, mes, ibge, nome, parcela, obs, valor) VALUES "
    FS=","
    BATCH=1024*256
    # BATCH=5
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
    printf "("
    printf NR
    printf ", "
    printf $1
    printf ", "
    printf $2
    printf ", "
    printf "\"" $3 "\""
    printf ", "
    printf $4
    printf ", "
    printf "\"" $5 "\""
    printf ", "
    printf $6
    printf ")"
    if ((NR%BATCH)==0) {
        LINE_PREFIX=";\n" INSERT_HEADER
    } else {
        LINE_PREFIX=","
    }
}
