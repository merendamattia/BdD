-- musei(_nome_, citta)
-- artisti(_nome_, anno nascita, anno morte *, nazionalita)
-- opere(_codice_, artista * fk , titolo, anno, museo fk, tipo, altezza, larghezza, profondita *) 
-- prestiti(_opera fk_, museo fk , data inizio, data fine)
-- restauri(_opera fk_, data inizio, data fine *)

-- 1. Scrivere l’istruzione DDL per la definizione della relazione prestiti includendo, 
-- oltre ai vincoli indicati nello schema, gli ovvi vincoli di ennupla.
create table prestiti (
	opera integer not null,
	museo varchar(200) not null,
	data_inizio date not null,
	data_fine date not null,
	primary key (opera),
	foreign key (opera) references opere(codice),
	foreign key (museo) references musei(nome),
	check (data_inizio <= data_fine)
);


-- 2. Scrivere l’istruzione DDL per la definizione della relazione restauri, 
-- includendo, oltre ai vincoli indicati nello schema, gli ovvi vincoli di ennupla.
create table restauri (
	opera integer not null,
	data_inizio date not null,
	data_fine date,
	primary key (opera),
	foreign key (opera) references opere(codice),
	check ( data_fine is null 
			or 
			data_inizio <= data_fine
	)
);


-- 3. Il tipo di un’opera pu`o essere “dipinto”, “scultura” o “installazione”. 
-- Aggiungere alla tabella opere un vincolo di integrit`a che, oltre al requisito suddetto, 
-- imponga che la profondit`a sia valorizzata per tutte le opere di tipo diverso da “dipinto”.
alter table opere
add constraint tipo_e_profondita 
	-- check(tipo = 'dipinto' || tipo = 'scultura' || tipo = 'installazione')
	check ( 
		tipo in ('dipinto', 'scultura', 'installazione') 
			and
		(tipo = 'dipinto' or profondita is not null)
	)


-- 4. La larghezza ed l’altezza delle opere, espresse in centimetri, sono strettamente positive 
-- e minori o uguali a 5 metri. Aggiungere alla tabella opere un vincolo di integrit`a che, 
-- oltre al requisito suddetto, imponga che l’area di un’opera di tipo “dipinto” sia inferiore a 10 metri quadrati.
alter table opere
add constraint larghezza_altezza
	check (
		altezza between 1 and 500
			and
		larghezza between 1 and 500
			and
		(tipo = 'dipinto' or larghezza * altezza < 10 * 100 * 100)
	)


-- 5. Eliminare dal database tutti i prestiti conclusi da almeno cinque anni.
delete from prestiti
where data_fine + 365 * 5 <= current_date


-- 6. Modificare tutti i prestiti aventi data fine nel novembre 2015, prorogandola alla fine dell’anno.
update prestiti
set data_fine = '2015-12-31'
where data_fine >= '2015-11-01'
	and data_fine <= '2015-11-30'


-- 7. Elencare gli artisti le cui opere non sono mai state oggetto di restauro.
select nome
from artisti
where nome not in (
	select distinct a.nome
	from restauri r, opere o, artisti a
	where r.opera = o.codice
		and o.artista = a.nome
)


-- 8. Elencare i musei che non hanno mai concesso un prestito di una loro opera ad un altro museo.
select nome
from musei
where nome not in (
	select distinct m.nome
	from prestiti p, musei m
	where p.museo = m.nome
)


-- 9. Definire la vista relazionale opere fruibili, che associa ad ogni museo le opere che sono di 
-- proprietà del museo oppure sono attualmente concesse in prestito a questo museo da parte di altri 
-- musei e sono effettivamente fruibili per il pubblico, in quanto non sono oggetto di restauro e non 
-- sono state concesse in prestito ad altro museo. Nota: fare riferimento alla situazione valida in data odierna.

-- METODO MIO
-- Restauri in corso
create view restauri_in_corso (opera) as
	select r.opera
	from restauri r
	where ( current_date between r.data_inizio and r.data_fine
				or
			current_date >= r.data_inizio and r.data_fine is null
		)
-- Prestiti in corso
create view prestiti_in_corso (opera) as
	select p.opera
	from prestiti p
	where current_date between p.data_inizio and p.data_fine 

-- Opere in un museo
create view opere_in_museo (museo, opera) as
	select o.museo, o.codice
	from opere o
	where 	o.codice not in ( select * from prestiti_in_corso )
		and
			o.codice not in ( select * from restauri_in_corso )
			
-- Opere in prestito in un museo
create view opere_in_prestito_in_museo (museo, opera) as
	select p.museo, p.opera
	from prestiti p
	where 	p.opera in ( select * from prestiti_in_corso )
		and
			p.opera not in ( select * from restauri_in_corso )

-- Opere fruibili
create view opere_fruibili (museo, opera) as
	select * from opere_in_museo
	union
	select * from opere_in_prestito_in_museo


-- METODO PROF
create view opere_fruibili (museo, opera) as
-- opere in un museo 
	select o.museo, o.codice
	from opere o
	where o.codice not in 
		( select p.opera from prestiti p
			where current_date between p.data_inizio and p.data_fine - 1)
		and
		( select r.opera from restauri r
			where current_date between r.data_inizio and r.data_fine - 1
				or current_date >= r.data_inizio and r.data_fine is null)

	union

	--opere in prestito a un museo
	select p.museo, p.opera
	from prestiti p
	where current_date between p.data_inizio and p.data_fine - 1
		and p.opera not in
			( select r.opera from restauri r
				where current_date between r.data_inizio and r.data_fine - 1
					or current_date >= r.data_inizio and r.data_fine is null)


-- 10. Durante tutto il mese di maggio 2016, il museo “Uffizi” di Firenze propone una mostra sull’artista Giotto. 
-- A tale scopo, si fa prestare (da tutti gli altri musei) le opere di Giotto di loro propriet`a, per il periodo 
-- dal 15 aprile al 5 giugno 2016. Modificare la tabella prestiti per tenere traccia di questo evento. 
-- Nota: per semplicit`a, ignorare eventuali prestiti preesistenti di opere di Giotto che riguardano il periodo in questione
-- e i restauri
insert into prestiti (opera, museo, data_inizio, data fine)
	select o.codice, 'Uffizi', '2016-04-15', '2016-06-05'
	from opere o
	where o.artista = 'Giotto'
		and o.museo != 'Uffizi'


-- 11. A causa di un guasto, un’ala del museo “Uffizi” di Firenze, che esponeva tutti i dipinti fruibili del periodo dal 1200 al 1500, 
-- `e stata soggetta a tassi di umidit`a particolarmente elevati. Modificare la tabella restauri per fare in modo che tali dipinti siano 
-- sottoposti a restauro a partire dalla data odierna, lasciando la data di fine restauro non valorizzata.
insert into restauri (opera, data_inizio, data_fine)
	select o.codice, current_date, null
	from opere o
	where o.anno between 1200 and 1500
		and o.codice in (
				select opera
				from opere_fruibili
				where museo = 'Uffizi'
			)


-- 12. Elencare gli artisti che, nell’insieme di tutti i musei, hanno almeno 10 opere, ordinandoli in base al numero 
-- di opere realizzate (a parit`a di opere, usare l’ordinamento in base al nome dell’artista). 
-- Per ogni artista, indicare il numero di musei che possiedono almeno un’opera dell’artista.
select o.artista as nome_artista, count(distinct o.museo) as numero_di_musei_che_espongono_un_opera_dell_artista
from opere o
where o.artista is not null
group by o.artista
having count(*) > 9
order by count(*) desc, o.artista asc


-- 13. Elencare i musei che sono proprietari di opere di almeno 10 artisti, ordinandoli in base al numero di opere 
-- di cui sono proprietari (a parit`a di opere, usare l’ordinamento in base al nome del museo). 
-- Per ogni museo, indicare il numero di artisti per i quali il museo `e proprietario di almeno un’opera.
select o.museo, count(distinct o.artista) as numero_artisti
from opere o
where o.artista is not null
group by o.museo
having count(distinct o.artista) > 9
order by count(*) desc, o.museo asc


-- 14. Usando l’algebra relazionale, codificare il vincolo di chiave primaria per la relazione musei.
m1 := REN_{ m1_nome, m1_citta <- nome, citta } ( PROJ_{ nome, citta } ( musei ) )
m2 := REN_{ m2_nome, m2_citta <- nome, citta } ( PROJ_{ nome, citta } ( musei ) )

SEL_{ 
	m1_nome = m2_nome and m1_citta != m2_citta 
	} (m1 JOIN_{NAT} m2) = {} 


-- 15. Usando l’algebra relazionale, esprimere il vincolo di integrità che impedisce ad un artista di 
-- realizzare un’opera quando non è in vita.
a := artisti
o := opera

o _JOIN { o.artista = a.nome and 
			(a.anno_morte not null or a.anno_morte < o.anno)
		} a = {}