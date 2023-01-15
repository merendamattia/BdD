-- (a)
select p.codice_SSN, p.cognome, p.nome, count(v.paziente) as num_visite
from pazienti p, visite v
where v.paziente = p.codice_SSN
	and v.data >= '2016-01-01'
group by v.paziente
having count(v.paziente) >= 12
order by num_visite desc

-- (b)
delete from visite 
where paziente IN (
	select codice_SSN
	from pazienti
	where data_nascita < '1982-07-11'
) and medicinale is null

-- (c)
create view medicine_prescritte as 
	select distinct m.codice, m.nome
	from medicinali m, visite v
	where m.codice = v.medicinale
		and v.data > '2010-12-31'

select m.codice, m.nome
from medicinali m
except 
select m.codice, m.nome
from medicine_prescritte m

--(d)
select distinct m1.cognome, m1.nome, m2.cognome, m2.nome
from medici m1, medici m2, visite v1, visite v2
where m1.codice < m2.codice 
	and m1.codice = v1.medico
	and m2.codice = v2.medico
	and (v1.data between '2018-01-01' and '2018-12-31')
	and (v2.data between '2018-01-01' and '2018-12-31')
	and v1.paziente = v2.paziente
	and m1.specializzazione = m2.specializzazione

--(e)
SEL_{ genere != 'M' and genere != 'F' } (pazienti) = {}




