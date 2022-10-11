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

create table insegnamenti (
    codice integer not null,
    nome varchar(100) not null,
    crediti integer not null,
    ssd varchar(10) not null,
    primary key (codice),
    check (crediti between 1 and 30)        -- check: https://www.w3schools.com/sql/sql_check.asp
);

insert into insegnamenti values (1, 'Basi di Dati', 9, 'INF/01');
insert into insegnamenti values (2, 'Metodologie di Programmazione', 6, 'INF/01');

create table manifesti (
    laurea integer not null;
    insegnamento integer not null,
    fondamentale boolean not null,
    anno_corso integer not null,
    primary key (laurea, insegnamento),
    foreign key (laurea) references corsi_laurea(codice),
    foreign key (insegnamento) references insegnamenti(codice)
);

insert into manifesti values (1, 1, true, 2);

create table studenti (
    matricola varchar(10) not null,
    nome varchar(100) not null,
    cognome varchar(100) not null,
    data_nascita date not null,
    primary key (matricola)
);

create table iscrizioni (
    studente varchar(10) not null,
    anno_iscrizione integer not null,
    laurea integer not null,
    data_iscrizione date not null,
    anno_corso integer not null,
    primary key (studente, anno_iscrizione),
    foreign key (laurea) references corsi_laurea(codice),
    foreign key (studente) references studenti(matricola)
);

