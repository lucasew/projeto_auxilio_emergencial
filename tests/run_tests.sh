#!/bin/bash
set -ex

# Check dependencies
for cmd in zip unzip sqlite3; do
	if ! command -v $cmd &>/dev/null; then
		echo "Error: $cmd is required but not installed."
		exit 1
	fi
	echo "Found $cmd at $(command -v $cmd)"
done

mkdir -p tests/data tests/output
rm -f tests/output/dummy.sqlite

# Create dummy CSV
echo '"mes";"uf";"ibge";"municipio";"nis";"cpf";"nome";"n_nis";"n_cpf";"valor";"observacao";"parcela";"observacao";"valor"' >tests/data/dummy.csv
echo '"202004";"SP";"3550308";"SAO PAULO";"123";"***.***.***-**";"JOAO DA SILVA";"123";"***";"600";"Nao ha";"1";"Nao ha";"600,00"' >>tests/data/dummy.csv

# Zip it
zip -j tests/data/dummy.zip tests/data/dummy.csv

# Run pipeline
./dbify_all_zips "tests/data/*.zip" tests/output/dummy.sqlite

# Check if DB exists
if [ -f tests/output/dummy.sqlite ]; then
	echo "Database created successfully."
	# Verify content
	count=$(sqlite3 tests/output/dummy.sqlite "SELECT count(*) FROM auxilio WHERE nome='JOAO DA SILVA';")
	# Expect 1
	if [ "$count" -eq "1" ]; then
		echo "Data verification successful."
	else
		echo "Data verification failed. Count: $count"
		exit 1
	fi
else
	echo "Database creation failed."
	exit 1
fi
