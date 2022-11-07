-- ATTORI (_CodAttore_, Nome, AnnoNascita, Nazionalità);
-- RECITA (_CodAttore_ [fk], _CodFilm_ [fk])
-- FILM (_CodFilm_, Titolo, AnnoProduzione, Nazionalità, Regista, Genere)
-- PROIEZIONI (_CodProiezione_, CodFilm [fk], CodSala [fk], Incasso, DataProiezione)
-- SALE (_CodSala_, Posti, Nome, Città) 

-- 27) Per ogni sala di Pisa, che nel mese di gennaio 2005 ha incassato più di 20000 €, 
-- il nome della sala e l’incasso totale (sempre del mese di gennaio 2005) 
select s.nome as nome_sala, sum(p.incasso)
from sale s, proiezioni p
where s.codsala = p.codsala
	and p.dataproiezione >= '2005-01-01'
	and p.dataproiezione <= '2005-01-31'
	and s.citta = 'Pisa'
group by s.codsala, s.nome 
having sum(p.incasso) > 20000


-- 28) I titoli dei film che non sono mai stati proiettati a Pisa 
create view codice_film_proiettati_a_pisa(codfilm) as 
	select distinct f.codfilm
	from film f, proiezioni p, sale s
	where f.codfilm = p.codfilm
		and p.codsala = s.codsala
		and s.citta = 'Pisa'

create view codice_film_non_proiettati_a_pisa(codfilm) as 
	select f.codfilm from film f
	except
	select * from codice_film_proiettati_a_pisa

select f.codfilm, f.titolo
from film f, codice_film_non_proiettati_a_pisa cf
where cf.codfilm = f.codfilm


-- 29) I titoli dei film che sono stati proiettati solo a Pisa 
create view cod_film_non_proiettati_solo_a_pisa(codfilm) as
	select distinct p1.codfilm
	from proiezioni p1, proiezioni p2, sale s1, sale s2
	where p1.codfilm = p2.codfilm 		-- Seleziono gli stessi film
		and p1.codsala = s1.codsala 
		and s1.citta = 'Pisa'			-- Una proiezione a Pisa
		and p2.codsala = s2.codsala
		and s2.citta != 'Pisa'			-- Una proiezione non a pisa

create view cod_film_proiettati_solo_a_pisa(codfilm) as
	select distinct codfilm from proiezioni
	except 
	select codfilm from cod_film_non_proiettati_solo_a_pisa

select f.codfilm, f.titolo
from film f, cod_film_non_proiettati_solo_a_pisa cf
where cf.codfilm = f.codfilm


-- 30) I titoli dei film dei quali non vi è mai stata una proiezione con incasso superiore a 500 € 
create view codfilm_con_proiezioni_con_incasso_superiore_a_500_almeno_una_volta(codfilm) as
	select distinct f.codfilm
	from proiezioni p, film f
	where p.codfilm = f.codfilm
		and p.incasso > 500

create view codfilm_con_proiezioni_con_incasso_mai_superiore_a_500(codfilm) as
	select codfilm from film
	except
	select codfilm from codfilm_con_proiezioni_con_incasso_superiore_a_500_almeno_una_volta

select f.codfilm, f.titolo
from film f, codfilm_con_proiezioni_con_incasso_mai_superiore_a_500 cf
where cf.codfilm = f.codfilm

-- ATTORI (_CodAttore_, Nome, AnnoNascita, Nazionalità);
-- RECITA (_CodAttore_ [fk], _CodFilm_ [fk])
-- FILM (_CodFilm_, Titolo, AnnoProduzione, Nazionalità, Regista, Genere)
-- PROIEZIONI (_CodProiezione_, CodFilm [fk], CodSala [fk], Incasso, DataProiezione)
-- SALE (_CodSala_, Posti, Nome, Città) 


