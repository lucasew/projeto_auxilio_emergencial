CREATE TABLE auxilio (id int auto_increment, mes int not null, ibge int not null, nome text not null, parcela int not null, obs text, valor int not null, primary key(id) );

CREATE INDEX auxilio_nome on auxilio (nome);
CREATE INDEX auxilio_nome_mes on auxilio (nome, mes);
CREATE INDEX auxilio_ibge on auxilio (ibge);

CREATE VIEW qt_beneficiarios_mes AS
    SELECT mes, count(mes) FROM auxilio GROUP BY mes;

