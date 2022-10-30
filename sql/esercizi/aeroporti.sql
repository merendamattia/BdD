AEROPORTO (_Citta_, Nazione, NumPiste)
VOLO (_IdVolo_, GiornoSett, CittaPart, OraPart, CittaArr, OraArr, TipoAereo fk)
AEREO (_TipoAereo_, NumPasseggeri, QtaMerci)

-- Trovare le città da cui partono voli diretti a Roma, ordinate alfabeticamente 
-- SQL
select distinct v.CittaPart
from volo v
where v.CittaArr = 'Roma'
order by v.CittaArr

-- Algebra Relazionale
PROJ_{ CittaPart } (
	SEL_{ CittaArr = 'Roma' } ( Volo )
)


-- Di ogni volo misto (merci e passeggeri) estrarre il codice e i dati relativi al trasporto 
-- SQL
select v.IdVolo, a.NumPasseggeri, a.QtaMerci
from volo v, aereo a
where a.TipoAereo = v.TipoAereo
	and a.NumPasseggeri > 0
	and a.QtaMerci > 0

-- Algebra Relazionale
v := volo
a := aereo

PROJ_{ v.IdVolo, a.NumPasseggeri, a.QtaMerci } (
	v JOIN_{ v.TipoAereo = a.TipoAereo
		and a.NumPasseggeri > 0
		and a.QtaMerci > 0
	} a
)


-- Le nazioni di partenza e arrivo del volo AZ274
-- SQL
select ap1.Nazione as Partenza, ap2.Nazione as Arrivo
from volo v, aeroporto ap1, aeroporto ap2
where v.IdVolo = 'AZ274'
	and v.CittaPart = ap1.Citta
	and v.CittaArr = ap2.Citta

-- Algebra Relazionale
ap1 := aeroporto
ap2 := aeroporto
v := volo
PROJ_{ ap1.Nazione, ap2.Nazione } (
	SEL_ {
		ap1.Citta = v.CittaPart
		and ap2.Citta = v.CittaArr
		and v.IdVolo = 'AZ274'
	} (ap1 JOIN v JOIN ap2)
)


-- Trovare l’aeroporto italiano con il maggior numero di piste
create view MaxNumPisteItalia as
	select max(NumPiste)
	from aeroporto 
	where Nazione = 'Italia'

select a.Citta
from aeroporto a
where a.Nazione = 'Italia'
	and a.NumPiste = ( select * from MaxNumPisteItalia )


-- Per ogni nazione, trovare quante piste ha l’aeroporto con più piste. 
select a.Nazione, a.Citta, max(NumPiste)
from aeroporto a
group by a.Nazione, a.Citta


-- Per ogni nazione, trovare quante piste ha l’aeroporto con più piste (purché almeno 3).
select a.Nazione, a.Citta, max(NumPiste)
from aeroporto a
group by a.Nazione, a.Citta
having max(NumPiste) >= 3


-- Trovare gli aeroporti da cui partono voli internazionali
-- SQL
select distinct ap1.Citta, ap1.Nazione
from volo v, aeroporto ap1, aeroporto ap2
where v.CittaPart = ap1.Citta
	and v.CittaArr = ap2.Citta
	and ap1.Nazione != ap2.Nazione

-- Algebra Relazionale
ap1 := aeroporto
ap2 := aeroporto
v := volo
PROJ_{ ap1.Citta, ap1.Nazione } (
	SEL_{
		v.CittaPart = ap1.Citta
		and v.CittaArr = ap2.Citta
		and ap1.Nazione != ap2.Nazione
	} ( ap1 JOIN v JOIN ap2 )
)


-- Trovare il numero totale di partenze internazionali (del giovedì) da tutti gli aeroporti 
select ap1.Citta, count(*) as numero_partenze_internazionali
from aeroporto ap1, aeroporto ap2, volo v
where v.CittaPart = ap1.Citta
	and v.CittaArr = ap2.Citta
	and ap1.Nazione != ap2.Nazione
	and v.GiornoSett = 'Giovedi'
group by ap1.Citta


-- Le città francesi da cui ogni settimana partono più di 20 voli diretti per la Germania 
select ap1.Citta as citta_francese_partenza, count(*) as numero_arrivi_in_germania
from aeroporto ap1, aeroporto ap2, volo v
where v.CittaPart = ap1.Citta
	and v.CittaArr = ap2.Citta
	and ap1.Nazione = 'Francia'
	and ap2.Nazione = 'Germania'
group by ap1.Citta
having count(*) > 20


-- Trovare il numero di voli del giovedì di ogni aeroporto da cui partano almeno 100 voli a settimana
create view aeroporto_con_almeno_100_voli as
	select v.CittaPart
	from volo v
	group by v.CittaPart
	having count(*) >= 100

select v.CittaPart, count(*) as num_voli
from volo v
where v.GiornoSett = 'Giovedi'
	and v.CittaPart in ( 
			select * from aeroporto_con_almeno_100_voli
		)
group by v.CittaPart

