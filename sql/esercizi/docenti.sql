Atenei (_codice_, descrizione)
Dipartimenti (_ateneo fk_, _codice_, descrizione)
Facoltà (_ateneo fk_, _codice_, descrizione)
Fasce (_codice_, descrizione)
Organico (_id_, cognome, nome, genere, fascia fk, ssd fk, 
	sett_conc, ateneo fk, facolta fk, dipartimento fk)
Settori_SD (_codice_, descrizione)

-- Elencare cognome e nome del personale della facoltà di Informatica di Parma
select o.cognome, o.nome, d.descrizione as dipartimento,
       f.descrizione as mansione, sd.codice as codice_corso, sd.descrizione as facolta
from organico o, atenei a, dipartimenti d, fasce f, settori_sd sd
where o.ateneo = a.codice
    and o.dipartimento = d.codice
    and o.fascia = f.codice
    and o.ssd = sd.codice
    and a.descrizione like '%PARMA%'
    and sd.descrizione like '%INFORMATICA%'
order by o.cognome, o.nome, dipartimento, mansione, codice_corso, facolta;

-- Per ogni dipartimento elencare il relativo numero del personale
select d.descrizione as dipartimento, count(*) as num_docenti
from organico o, dipartimenti d
where o.dipartimento = d.codice
group by d.descrizione

-- Per ogni dipartimento di informatica elencare il relativo numero del personale
select d.descrizione as dipartimento, count(*) as num_docenti
from organico o, dipartimenti d
where o.dipartimento = d.codice
    and (d.descrizione like '%INFORMATICA%' or d.descrizione like '%INFORMATICHE%')
group by d.descrizione
order by d.descrizione;

-- Per ogni ateneo elencare il relativo numero di dipartimenti
select a.descrizione as ateneo, count(d.descrizione) as num_dipartimenti
from atenei a, dipartimenti d
where a.codice = d.ateneo
group by a.descrizione
order by a.descrizione;





