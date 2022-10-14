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


-- Codice e nome degli Insegnamenti disattivati 
-- (che tacciono, cioè non compaiono in nessun manifesto)
select i.codice, i.nome
from insegnamenti i, manifesti m
where i.codice not in (
    select insegnamento from manifesti
)
order by nome;

-- altra versione
select codice, nome
from insegnamenti
except 
select codice, nome
from insegnamenti i, manifesti m
where i.codice = m.insegnamento
order by nome;


-- Codice e nome degli Insegnamenti obbligatori
select distinct i.codice, i.nome
from insegnamenti i, manifesti m
where i.codice = m.insegnamento
    and m.fondamentale
order by i.nome;


-- Codice e nome degli Insegnamenti a scelta
select distinct i.codice, i.nome
from insegnamenti i, manifesti m
where i.codice = m.insegnamento
    and not m.fondamentale
order by i.nome;


-- Codice e nome degli Insegnamenti solo a scelta
select distinct i.codice, i.nome
from insegnamenti i, manifesti m
where i.codice = m.insegnamento
    and not m.fondamentale
    and not exists (
        select * 
        from manifesti m2 
        where m2.insegnamento = i.codice
            and m2.fondamentale
    )
order by i.nome;


-- Iscricioni "proseguimento" nel 2022
create or replace view proseguimenti (codice, cognome, nome) 
as
select s.codice, s.cognome, s.nome
from studenti s, iscrizione i22, iscrizione i21
where i22.studente = i21.studente
    and i22.anno_iscrizione = 2022
    and i21.anno_iscrizione = 2021
    and i22.laurea = i21.laurea
    and i22.anno_corso = i21.anno_corso + 1
    and s.matricola = i22.studente

select * 
from proseguimento 
order by cognome, nome;


-- Iscricioni "naturali" nel 2022
select * from proseguimenti

union

select s.*
from studenti s, iscrizione i22
where i22.anno_iscrizione = 2022
    and i22.anno_corso = 1
    and s.matricola = i22.studente
    and not exists (
        select *
        from iscrizioni i_old
        where i_old.studente = s.matricola
            and i_old.anno_iscrizione < 2022
    )

order by cognome, nome;

