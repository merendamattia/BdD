-- REGISTA (_Nome_, DataNascita, Nazionalita)
-- ATTORE (_Nome_, DataNascita, Nazionalità)
-- INTERPRETA (_Attore fk_, _Film fk_, _Personaggio_)
-- FILM (_Titolo_, NomeRegista fk, Anno)
-- PROIEZIONE (_NomeCinema fk_, _CittàCinema fk_, _TitoloFilm fk_)
-- CINEMA (_Nome_, _Città_, #Sale, #Posti)

-- Selezionare le Nazionalità dei registi che hanno diretto 
-- qualche film nel 1992 ma non hanno diretto alcun film nel 1993
select distinct r.Nazionalita
from film f, regista r
where f.NomeRegista = r.Nome
	and f.anno = 1992

except

select distinct r.Nazionalita
from film f, regista r
where f.NomeRegista = r.Nome
	and f.anno = 1993


-- Nomi dei registi che hanno diretto nel 1993 più film di quanti ne avevano diretti nel 1992 
create view registri_film_1993 as
	select r.Nome, count(*) as num_film
	from regista r, film f
	where r.Nome = f.NomeRegista
		and f.anno = 1993
	group by r.nome;

create view registri_film_1992 as
	select r.Nome, count(*) as num_film
	from regista r, film f
	where r.Nome = f.NomeRegista
		and f.anno = 1992
	group by r.nome;

select r93.Nome
from registri_film_1993 r93, registri_film_1992 r92
where r93.Nome = r92.Nome
	and r93.num_film > r92.num_film;


-- Le date di nascita dei registi che hanno diretto film in proiezione sia a Torino sia a Milano 
select distinct r.Nome, r.Datanascita
from regista r, film f, proiezione p1, proiezione p2
where r.Nome = f.NomeRegista
	and f.Titolo = p1.TitoloFilm
	and p1.CittaCinema = 'Torino'
	and f.Titolo = p2.TitoloFilm
	and p2.CittaCinema = 'Milano'


-- Film proiettati nel maggior numero di cinema di Milano
select p.TitoloFilm, count(*) as num_cinema
from proiezione p
where p.CittaCinema = 'Milano'
group by p.TitoloFilm


-- Trovare gli attori che hanno interpretato più personaggi in uno stesso film (+ di 1 !!)
select i.Film, i.Attore, count(i.Personaggio)
from interpreta i
group by i.Film, i.Attore
having count(i.Personaggio) > 1


-- Trovare i film in cui recita un solo attore che però interpreta più personaggi 
select i.Film
from interpreta i
group by i.Film
having count(i.Attore) = 1 
	and count(i.Personaggio) > 1


-- Attori italiani che non hanno mai recitato con altri italiani
select *
from attore a
where a.Nazionalita = 'Italiana'
	and a.Nome not in (
			select
			from interpreta i1, interpreta i2, attore a2
			where i1.Film = i2.Film
				and i2.Attore = a2.Nome
				and a2.Nome != a1.Nome
				and a2.Nazionalita = 'Italiana'
		)
