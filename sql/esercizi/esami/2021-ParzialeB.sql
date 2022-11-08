-- biblioteche(_codice_, nome, citta, indirizzo)
-- libri(_codice_, titolo, edizione, anno, pagine) 
-- autori(_codice_, cognome, nome, anno_nascita, biografia*) 
-- autori_libri(_libro fk_, _autore fk_, ordine sequenza)
-- copie_libri(_seriale_, libro fk, biblioteca fk, collocazione)
-- prestiti(_codice_, data_inizio, data_fine_prevista, data_fine_effettiva*, copia_libro fk)

-- 1. Scrivere l’istruzione DDL per la definizione della relazione copie libri includendo, 
-- oltre ai vincoli indicati nello schema, il vincolo che impone che ogni biblioteca non 
-- possa avere più copie dello stesso libro.

create table copie_libri (
	seriale serial not null,
	libro integer not null,
	biblioteca integer not null,
	collocazione integer not null,
	primary key (seriale),
	foreign key (libro) references libri(codice),
	foreign key (biblioteca) references biblioteche(codice),
	unique(libro, biblioteca)
)


-- 2. Definire la vista relazionale autori ignorati(codice, cognome, nome) che elenca 
-- gli autori per i cui libri non sono stati registrati prestiti nel corso dell’anno 2021 
-- (considerare la data di inizio del prestito).

create or replace view autori_ignorati as
	select a.codice, a.cognome, a.nome
	from prestiti p, copie_libri cl, autori_libri al, autori a
	where p.copia_libro = cl.seriale
		and cl.libro = al.libro
		and al.autore = a.codice
		and a.codice not in (
				select a.codice
				from prestiti p, copie_libri cl, autori_libri al, autori a
				where p.data_inizio >= '2021-01-01'
					and p.data_inizio <= '2021-12-31'
					and p.copia_libro = cl.seriale
					and cl.libro = al.libro
					and al.autore = a.codice
			)


-- 3. Eliminare i libri per i quali non sono presenti copie nelle biblioteche.

delete from libri 
where codice not in (
	select l.codice
	from copie_libri cl, libri l, biblioteche b
	where cl.libro = l.codice
		and cl.biblioteca = b.codice
);
insert into libri (titolo, edizione, anno, pagine) values ('test', 1, 2022, 1000);


-- 4. Per ogni biblioteca e per ogni autore, calcolare il numero di copie di libri 
-- di quell’autore presenti nella biblioteca 
-- (nota: una copia si considera presente anche se è al momento in prestito).

select b.nome as biblioteca, a.cognome as autore, count(cl.seriale)
from copie_libri cl, autori_libri al, biblioteche b, autori a
where cl.libro = al.libro
	and cl.biblioteca = b.codice
	and al.autore = a.codice
group by b.nome, a.cognome
order by b.nome, a.cognome


-- 5. Modificare lo schema della tabella Prestiti, aggiungendo il vincolo di integrità 
-- che impedisce di avere una data inizio superiore alla data fine prevista 
-- e alla data fine effettiva.

alter table prestiti
add constraint valid_date
check (
	data_inizio < data_fine_prevista
	and
	data inizio < data_fine_effettiva
)








