CREATE TABLE auxilio (id int auto_increment, mes int not null, ibge int not null, nome text not null, parcela int not null, obs text, valor int not null, primary key(id) );

CREATE INDEX auxilio_nome on auxilio (nome);
