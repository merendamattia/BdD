-- biblioteche(_codice_, nome, citta, indirizzo)
-- libri(_codice_, titolo, edizione, anno, pagine) 
-- autori(_codice_, cognome, nome, anno_nascita, biografia*) 
-- autori_libri(_libro fk_, _autore fk_, ordine sequenza)
-- copie_libri(_seriale_, libro fk, biblioteca fk, collocazione)
-- prestiti(_codice_, data_inizio, data_fine_prevista, data_fine_effettiva*, copia_libro fk)


-- 1. Scrivere l’istruzione DDL per la definizione della relazione autori_libri includendo, 
-- oltre ai vincoli indicati nello schema, il vincolo che impone che per ogni libro non vi 
-- possano essere più autori con la stessa posizione (ordine sequenza) nella sequenza degli autori.

create table autore_libri (
	libro integer not null,
	autore integer not null,
	ordine_sequenza integer not null,
	unique(ordine_sequenza),
	primary key (libro, autore),
	foreign key (libro) references libri(codice),
	foreign key (autore) references autori(codice)
);


-- 2. Definire la vista relazionale libri_con_prestiti_scaduti(codice_libro, titolo) 
-- che elenca i codici e i titoli dei libri per i quali esiste almeno un prestito in corso 
-- la cui data prevista di restituzione è precedente alla data odierna.

create or replace view libri_con_prestiti_scaduti as
	select distinct l.codice as codice_libro, l.titolo as titolo
	from prestiti p, copie_libri cl, libri l
	where p.data_fine_prevista < CURRENT_DATE
		and p.copia_libro = cl.seriale
		and cl.libro = l.codice


-- 3. Modificare i prestiti in corso per le copie di libri della biblioteca di nome 
-- “Biblioteca Pavese” di Parma, spostando in avanti di 30 giorni la data fine prevista.

update prestiti
set data_fine_prevista = data_fine_prevista + 30
where copia_libro = (
    select cl.seriale
    from prestiti p, copie_libri cl, biblioteche b, libri l
    where p.copia_libro = cl.seriale
        and cl.biblioteca = b.codice
        and cl.libro = l.codice
        and b.nome = 'Biblioteca Pavese'
        and b.citta = 'Parma'
        and data_fine_prevista > current_date
);


-- 4. Per ogni città e per ogni autore, calcolare il numero di prestiti registrati, 
-- dall’inizio del 2015 alla fine del 2019, in una biblioteca di quella città e 
-- che hanno riguardato (una copia di) un libro di quell’autore.

select b.citta, a.cognome, count(p.codice) as prestiti_redistrati
from biblioteche b, autori a, prestiti p, copie_libri cl, libri l, autori_libri al
where p.data_inizio >= '2015-01-01'
	and p.data_inizio <= '2019-12-31'
	and p.copia_libro = cl.seriale
	and cl.libro = l.codice
	and cl.biblioteca = b.codice
	and al.libro = l.codice
	and al.autore = a.codice
group by b.citta, a.cognome
order by b.citta, a.cognome;


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
