# Auxílio Emergencial Pipeline Architecture

This document describes the internal workings of the data transformation pipeline. The pipeline is built using UNIX shell tools and AWK for maximum performance and minimum dependencies.

## 🔄 Core Workflow

The data flows sequentially through small, focused utility scripts:

1.  **`dbify_all_zips`**: The top-level orchestrator. It iterates over a wildcard path of ZIP files, piping each one through the transformation chain and directing the final output to an SQLite database.
2.  **`zipcat`**: Extracts the contents of a ZIP file directly to `stdout`. Since the target ZIPs contain a single CSV file, this is safe.
3.  **`sqlify`**: A wrapper around `sqlify.awk`. It takes the CSV from `stdin` and outputs raw SQL to `stdout`.
4.  **`sql2db`**: Takes the generated SQL from `stdin` and executes it against the specified SQLite database using the `sqlite3` CLI.

## ⚙️ `sqlify.awk` Internals

The `sqlify.awk` script is the heart of the pipeline. It handles the parsing, cleaning, and formatting of the raw CSV data into highly optimized SQL `INSERT` statements.

### 🧠 Optimizations

-   **Memory-Mapped Journaling**: The script begins by emitting `PRAGMA journal_mode=MEMORY;`. This keeps the rollback journal in RAM rather than on disk, significantly accelerating the massive number of inserts.
-   **Batched Transactions**: Emitting one `INSERT` statement per row is slow. `sqlify.awk` batches operations using the `BATCH` variable (currently set to `1024*1024`, or ~1 million rows).
    -   It opens a transaction (`begin transaction;`).
    -   It builds a massive multi-row `INSERT` statement: `insert into auxilio (...) values (...), (...), ...`.
    -   Once the batch limit is reached, it closes the statement and commits the transaction (`commit;`).

### 🧹 Data Transformation

The script processes each CSV row (separated by `;`) and maps it to the SQLite schema:

-   `$1` (Mês): Passed directly.
-   `$3` (IBGE): If empty, defaults to `0`.
-   `$7` (Nome): Leading and trailing whitespace is trimmed.
-   `$12` (Parcela): Cast to an integer (`+ 0`).
-   `$13` (Observação): If the first character is "N" (likely "Não"), it is treated as an empty string (`''`). Otherwise, it is trimmed and quoted.
-   `$14` (Valor): Cast to an integer (`+ 0`).

Quotes inside fields are globally removed (`gsub("\"", "")`) before processing to prevent SQL injection or parsing errors.

## 🗄️ Database Schema

The resulting SQLite database will contain a table named `auxilio`:

```sql
CREATE TABLE IF NOT EXISTS auxilio (
    mes INT NOT NULL,
    ibge INT NOT NULL,
    nome TEXT NOT NULL,
    parcela INT NOT NULL,
    obs TEXT,
    valor INT NOT NULL
);
```

> 💡 **Tip:** After the pipeline finishes importing all data, creating an index on the `nome` column (`CREATE INDEX auxilio_nome on auxilio (nome);`) will dramatically improve query performance, though it will increase the database size.
