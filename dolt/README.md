# Migração para o Dolt

Este diretório contém os scripts necessários para exportar os dados do SQLite e importá-los para um banco de dados [Dolt](https://github.com/dolthub/dolt). O Dolt é um banco de dados SQL com controle de versão estilo Git.

A ordem de execução padrão para migração é feita pelo script `import`, que orquestra a leitura do SQLite, transformação via `awk` e inserção no Dolt.

## Detalhes de Implementação e Otimizações

- **`export_csv`**:
  Extrai os dados do SQLite em formato CSV. Uma nuance importante aqui é o uso de `order by nome`. Garantir que os dados sejam exportados já ordenados facilita consultas futuras e otimiza a criação de índices no banco de destino.
- **`csv2sql.awk` e `csv2sql`**:
  O arquivo `csv2sql.awk` é o núcleo da transformação.
  - **Injeção de ID Sequencial (`NR`)**: Como o CSV extraído não possui uma chave primária explícita e o Dolt (ou MySQL) exige ou se beneficia imensamente de uma `primary key`, o script `awk` utiliza a variável interna `NR` (Number of Records) para injetar um `id` sequencial em cada linha inserida.
  - **Batching de Inserções**: Para evitar a sobrecarga de executar milhões de comandos `INSERT` individuais, o `awk` agrupa as inserções. O tamanho do lote (`BATCH`) é configurado para `1024*256` (262.144 registros por `INSERT` múltiplo). Isso reduz drasticamente o tempo de processamento ao importar os dados para o Dolt (`dolt sql`).
- **`mysql_create_table.sql`**:
  Define o esquema da tabela `auxilio` e cria índices para `nome`, combinação de `nome` e `mes`, e `ibge`. Também inclui uma view para facilitar consultas de contagem. O esquema é compatível com o MySQL (que é a interface SQL que o Dolt expõe).
