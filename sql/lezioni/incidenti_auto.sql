-- Assicurazioni (_codice_, nome, sede)
-- Proprietari(_codice_fiscale_, nome, residenza)
-- Auto(_targa_, marca, cilindrata, proprietario fk, assicurazione fk)
-- Sinistro(_codice_, luogo, data)
-- AutoCoinvolte(_sinistro_ fk, _auto_ fk, importo danno*)

create table assicurazioni (
	codice numeric not null,
	nome varchar(100) not null,
	sede varchar(200) not null,
	primary key (codice) --,
	-- unique (nome)
);

create table proprietari (
	codice_fiscale char(16) not null,
	nome varchar(100) not null,
	residenza varchar (100) not null,
	primary key (codice_fiscale)
);

create table auto (
	targa varchar(15) not null,
	marca varchar(100) not null,
	cilindrata integer not null,
	proprietario char(16) not null,
	assicurazione numeric not null,
	primary key (targa),
	foreign key proprietario references proprietari(codice_fiscale),
	foreign key assicurazione references assicurazioni(codice)
);

create table sinistro (
	codice numeric not null,
	luogo varchar(100) not null,
	data date not null,
	primary key (codice)
);

create table auto_coinvolte (
	sinistro numeric not null,
	auto varchar(15) not null,
	importo_danno numeric(10,2),
	primary key (sinistro, auto),
	foreign key sinistro references sinistri(codice),
	foreign key auto references auto(targa)
);


-- Creare una vista relazionale NoSinistri che elenca tutti i proprietari 
-- che non sono stati mai convolti in sinistri
-- (si intende, con nessuna delle auto possedute).
create or replace view no_sinistri as
	select p.*
	from proprietari p
	where not exists (
		select *
		from auto_coinvolte ac, auto a
		where ac.auto = a.targa
			and a.proprietario = p.codice_fiscale
	);

create or replace view no_sinistri as
	select p.*
	from proprietari p
	where p.codice_fiscale not in (
		select a.proprietario
		from auto_coinvolte ac, auto a
		where ac.auto = a.targa
	);


-- Inserire nel database il sinistro di codice 1317, avvenuto a Parma il 17 giugno 2013,
-- che ha coinvolto tutte le auto la cui targa contiene la stringa 13 o la stringa 17,
-- con un danno non ancora quantificato
begin transaction;

insert into sinistri (codice, luogo, data)
values (1317, 'Parma', '2013-06-17');

insert into auto_coinvolte (sinistro, auto, importo_danno)
values (
	select 1317, a.targa, null
	from auto a
	where (a.targa like '%13%')
		or (a.targa like '%17%')
);

commit work;


-- Calcolare, per ogni assicurazione, l'importo totale dei danni riportati
-- dalle auto assicurate nel corso dell'anno 2013
select a.codice, a.nome, sum(ac.importo_danno)
from assicurazioni ass, auto_coinvolte ac, auto a, sinistro s
where ac.auto = a.targa
	and a.assicurazione = ass.codice
	and ac.sinistro = s.codice
	-- and extract(year from s.data) = 2013
	and s.data >= '2013-01-01' 
	and s.data <= '2013-12-31'
group by a.codice, a.nome;


-- Estrarre codice, luogo e data dei sinistri che hanno coinvolto almeno tre auto,
-- ciascuna delle quali con un danno superiore a 2500 EUR.
select s.codice, s.luogo, s.data
from sinistri s, auto_coinvolte ac
where ac.sinistro = s.codice
	and ac.importo_danno >= 2500
group by s.codice, s.luogo, s.data
having count(*) > 2;


-- Calcolare, per ogni marca di auto, il numero di auto coinvolte in sinistri
select a.marca, count(distinct a.targa)
from auto_coinvolte ac, auto a
where ac.auto = a.targa
group by a.marca;


-- Usando l'algebra relazionale, estrarre i proprietari di almeno due automezzi che
-- sono assicurati con compagnie distinte e sono stati entrambi coinvolti in sinistri
p := proprietari
a := auto
ac := auto_coinvolte

botto1 := p JOIN_{ p.codice_fiscale = a.proprietario } a
			JOIN_{ a.targa = ac.auto } ac

botto2 := p JOIN_{ p.codice_fiscale = a.proprietario } a
			JOIN_{ a.targa = ac.auto } ac

PROJ_{ botto1.codice_fiscale } (
	botto1 JOIN_{ 
			botto1.codice_fiscale = botto2.codice_fiscale 
				and 
			botto1.targa != botto2.targa
				 and
			botto1.assicurazione != botto2.assicurazione
			} botto2
)





