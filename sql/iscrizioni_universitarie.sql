create table corsi_laurea (
    codice integer not null,
    nome varchar(200) not null,
    descrizione varchar(500) not null,
    primary key (codice)
);

insert into corsi_laurea (codice, nome, descrizione) values (1, 'Informatica', 'Corso di Laurea triennale in Informatica');
insert into corsi_laurea (codice, nome, descrizione) values (2, 'Scienze Informatiche', 'Corso di Magistrale in Scienze Informatiche');
insert into corsi_laurea (codice, nome, descrizione) values (3, 'Informatica', 'Corso di Laurea triennale in Informatica');

alter table corsi_laurea add unique(nome);

delete from corsi_laurea where codice = 3;