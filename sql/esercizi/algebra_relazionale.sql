-- http://dbdmg.polito.it/wordpress/wp-content/uploads/2010/12/Esercizi-AR.pdf

-- Sia dato lo schema relazionale costituito dalle tabelle
-- VELISTI (_Vid_, VNome, Esperienza, DataNascita)
-- PRENOTAZIONI (_Vid_, _Bid_, _Data_)
-- BARCHE (_Bid_, BNome, Colore)

-- Trovare i nomi dei velisti che hanno prenotato almeno una barca rossa oppure una barca verde 
--SQL
create view barche_rosse_e_verdi as
	select b.bid, b.bnome, b.colore
	from barche b
	where b.colore = 'rosso'
		or b.colore = 'verde'

select distinct v.vid, v.nome
from velisti v, prenotazioni p, barche_rosse_e_verdi b
where b.bid = p.bid
	and p.vid = v.vid

-- Algebra Relazionale
barche_rosse_e_verdi := PROJ_{ bid, bnome, colore } ( 
							SEL_ { colore = 'rosso' or colore = 'verde' } ( barche )
						)
v := velisti
p := prenotazioni
b := barche_rosse_e_verdi

PROJ_{ v.vid, v.nome } (
	SEL_{ 
		b.bid = p.bid and p.vid = v.vid -- Selezione sul Prodotto Cartesiano
	} (v JOIN p JOIN b) -- Prodotto Cartesiano
)


-- Trovare i nomi dei velisti che hanno fatto almeno due prenotazioni
-- SQL
select v.vid, v.vnome
from prenotazioni p, velisti v
where p.vid = v.vid
group by v.vid, v.vnome
having count(*) > 1

-- Algebra Relazionale
v := velisti
p1 := REN_{ vidp1, bidp1, datap1 <- vid, bid, data } ( PROJ_{ vid, bid, data } (prenotazioni) )
p2 := REN_{ vidp2, bidp2, datap2 <- vid, bid, data } ( PROJ_{ vid, bid, data } (prenotazioni) )

PROJ_{ vid, vnome } (
	SEL_{ -- Selezione sul Prodotto Cartesiano
		vid = vidp1 and vid = vidp2
		and
		(bidp1 != bidp2 or datap1 != datap2)
	} (v JOIN p1 JOIN p2) -- Prodotto Cartesiano
)


-- Trovare il codice dei velisti che non hanno mai prenotato barche rosse
-- SQL
create view velisti_almeno_una_prenotazione_barca_rossa as
	select distinct p.vid
	from prenotazioni p, barche b
	where p.bid = b.bid
		and b.colore = 'rosso'

select vid
from velisti
except
select vid
from velisti_almeno_una_prenotazione_barca_rossa

-- ALgebra Relazionale
p := REN_{ pvid, pbid, pdata <- vid, bid, pdata } ( PROJ_{vid, bid, pdata} (prenotazioni) )
b := REN_{ bbid, bbnome, bcolore <- bid, bnome, bcolore } ( PROJ_{bid, bnome, bcolore} (barche) ) 
v := REN_{ vvid <- vid } ( PROJ_{ vid } (velisti) )

velisti_almeno_una_prenotazione_barca_rossa :=
	PROJ_{ pvid } (
		SEL_{
			pbid = bbid and bcolore = 'rosso'
		} ( p JOIN b)
	)

velisti_mai_una_prenotazione_barca_rossa :=
	v - velisti_almeno_una_prenotazione_barca_rossa

PROJ_{ vid } ( velisti_mai_una_prenotazione_barca_rossa )

------------------------------------------------------------------------------

-- Sia dato lo schema relazionale costituito dalle tabelle
-- RIVISTA (_CodR_, NomeR, Editore)
-- ARTICOLO (_CodA_, Titolo, Argomento, CodR (fk))

-- Trovare il codice e il nome delle riviste che pubblicano articoli di motociclismo oppure di auto
-- SQL
select r.codr, r.nomer
from articolo a, rivista r
where (a.argomento = 'motociclismo' or a.argomento = 'auto')
	and a.codr = r.codr

-- Algebra Relazionale
r := REN_{ rcodr, rnomer, reditore <- codr, nomer, editore } ( PROJ_{ codr, nomer, editore } (rivista) )
a := REN_{ acoda, atitolo, aargomento, acodr <- coda, titolo, argomento, codr } ( 
		PROJ_{ coda, titolo, argomento, codr } (articolo)
		)

PROJ_{ rcodr, rnomer } (
	SEL_{ -- Selezione sul Prodotto Cartesiano
		( aargomento = 'motociclismo' or aargomento = 'auto' )
		and acodr = rcodr 
	} (a JOIN r) -- Prodotto Cartesiano
)


-- Trovare il codice e il nome delle riviste che pubblicano articoli sia di motociclismo sia di auto
-- SQL
create view riviste_motociclismo as
	select distinct r.codr, r.nomer, r.editore
	from rivista r, articolo a
	where r.codr = a.codr
		and a.argomento = 'motociclismo'

create view riviste_auto as
	select distinct r.codr, r.nomer, r.editore
	from rivista r, articolo a
	where r.codr = a.codr
		and a.argomento = 'auto'

select ra.codr, ra.nomer
from riviste_motociclismo rm, riviste_auto ra
where rm.codr = ra.codr

-- Algebra Relazionale
r := REN_{ rcodr, rnomer, reditore <- codr, nomer, editore } ( PROJ_{ codr, nomer, editore } (rivista) )
a := REN_{ acoda, atitolo, aargomento, acodr <- coda, titolo, argomento, codr } ( 
		PROJ_{ coda, titolo, argomento, codr } (articolo)
		)

riviste_motociclismo := 
	REN_{ rm_codr, rm_nomer, rm_editore <- rcodr, rnomer, reditore } (
		PROJ_{ rcodr, rnomer, reditore } (
			SEL_{ rcodr = acodr
				and aargomento = 'motociclismo' } (r JOIN a)
		)	
	)
riviste_auto := 
	REN_{ ra_codr, ra_nomer, ra_editore <- rcodr, rnomer, reditore } (
		PROJ_{ rcodr, rnomer, reditore } (
			SEL_{ rcodr = acodr
				and aargomento = 'auto' } (r JOIN a)
		)
	)

PROJ_{ rm_codr, rm_nomer } (
	SEL_{ rm_codr = ra_codr } (riviste_auto JOIN riviste_motociclismo)
)

------------------------------------------------------------------------------

-- Sia dato lo schema relazionale costituito dalle tabelle
-- SPETTACOLO(_CodS_, Titolo, Compagnia, Durata)
-- CARTELLONE(_Data_, _OraInizio_, _CodS_, NomeTeatro)

-- Trovare il nome delle compagnie che hanno tenuto spettacoli il 15.10.2003, 
-- ma non il 16.10.2003
-- SQL
create view compagnie_spettacoli_2003_10_15 as
	select distinct s.compagnia
	from cartellone c, spettacolo s
	where c.data = '2003-10-15'
		and c.cods = s.cods
create view compagnie_spettacoli_2003_10_16 as
	select distinct s.compagnia
	from cartellone c, spettacolo s
	where c.data = '2003-10-16'
		and c.cods = s.cods	

select * from compagnie_spettacoli_2003_10_15
except 
select * from compagnie_spettacoli_2003_10_16

-- ALgebra Relazionale
c := 
	REN_{ c_data, c_orainizio, c_cods, c_nometeatro <- data, orainizio, cods, nometeatro } (
		PROJ_{ data, orainizio, cods, nometeatro } (
			cartellone
		)
	)
s := 
	REN_{ s_cods, s_titolo, s_compagnia, s_durata <- cods, titolo, compagnia, durata } (
		PROJ_{ cods, titolo, compagnia, durata } (
			spettacolo
		)
	)

compagnie_spettacoli_2003_10_15 :=
	PROJ_{ s_compagnia } (
		SEL_{ c_data = '2003-10-15'
			and c_cods = s_cods 
		} (c JOIN s)
	)
compagnie_spettacoli_2003_10_16 :=
	PROJ_{ s_compagnia } (
		SEL_{ c_data = '2003-10-16'
			and c_cods = s_cods 
		} (c JOIN s)
	)

compagnie_spettacoli_2003_10_15_ma_non_2003_10_16 :=
	compagnie_spettacoli_2003_10_15 - compagnie_spettacoli_2003_10_16

------------------------------------------------------------------------------

-- Sia dato lo schema relazionale costituito dalle tabelle 
-- PITTORE(_CodP_, NomeP, DataNascita, Nazione)
-- QUADRO(_CodQ_, Titolo, CodP (fk))
-- ESPOSIZIONE(_CodQ_, _DataInizio_, DataFine, NomeGalleria)

-- Trovare il codice e il titolo del quadri che sono stati esposti 
-- almeno due volte nella stessa galleria  
-- SQL
select q.codq, q.titolo
from esposizione e1, esposizione e2, quadro q
where q.codq = e1.codq
	and e1.codq = e2.codq
	and e1.nomegalleria == e2.nomegalleria
	and e1.datainizio != e2.datainizio

-- Algebra Relazionale
q := 
	REN_{ q_codq, q_titolo, q_codp <- codq, titolo, codp} (
		PROJ_{ codq, titolo, codp } (
			quadro
		)
	)

e1 := 
	REN_{ e1_codq, e1_datainizio, e1_nomegalleria <- codq, datainizio, nomegalleria } (
		PROJ_{ codq, datainizio, nomegalleria } (
			esposizione
		)
	)
e2 := 
	REN_{ e2_codq, e2_datainizio, e2_nomegalleria <- codq, datainizio, nomegalleria } (
		PROJ_{ codq, datainizio, nomegalleria } (
			esposizione
		)
	)

PROJ_{ q_codq, q_titolo } (
	SEL_{ 
		q_codq = e1_codq
		and e1_codq = e2_codq
		and e1_nomegalleria == e2_nomegalleria
		and e1_datainizio != e2_datainizio
	} (q JOIN e1 JOIN e2)
)

------------------------------------------------------------------------------

-- Sia dato lo schema relazionale costituito dalle tabelle 
-- VETTURE(_Targa_, Modello, DataImmatricolazione)
-- REVISIONE(_Targa_, _DataRev_, Esito)

-- Tra tutte le vetture immatricolate dopo il 31/12/2003, 
-- selezionare la targa di quelle vetture che sono state revisionate al massimo una volta
-- SQL
create view vetture_revisionate_almeno_una_volta as
	select distinct r.targa
	from revisione r, vettura v
	where r.targa = v.targa
		and v.dataimmatricolazione > '2003-12-31'

create view vetture_mai_revisionate as
	select targa from vetture where dataimmatricolazione > '2003-12-31'
	except
	select targa from vetture_revisionate_almeno_una_volta

select v.targa
from vetture v, revisione r
where v.dataimmatricolazione > '2003-12-31'
	and v.targa = r.targa
group by v.targa
having count(*) = 1

union

select targa from vetture_mai_revisionate

-- Algebra Relazionale
v := REN_{ v_targa, v_modello, v_dataimmatricolazione <- targa, modello, dataimmatricolazione } (
		PROJ_{ targa, modello, dataimmatricolazione } (
			vetture
		)
	)

r := REN_{ r_targa, r_datarev, r_esito <- targa, datarev, esito } (
		PROJ_{ targa, datarev, esito } (
			revisione
		)
	)
r2 := REN_{ r2_targa, r2_datarev, r2_esito <- targa, datarev, esito } (
		PROJ_{ targa, datarev, esito } (
			revisione
		)
	)

vetture_immatricolate_dopo_2003_12_31 := 
	PROJ_{ targa } ( SEL_{ dataimmatricolazione > '2003-12-31' } ( vetture ) )

vx := vetture_immatricolate_dopo_2003_12_31 -- creo alias per abbreviare

vetture_revisionate_almeno_due_volte :=
	REN_{ targa <- r_targa } (
		PROJ_{ r_targa } (
			SEL_{
				r_targa = r2_targa
				and r_datarev != r2_datarev
			} (r JOIN r2)
		)
	)
	
vetture_revisionate_massimo_una_volta :=
	vx - vetture_revisionate_almeno_due_volte

PROJ_{ targa } ( vetture_revisionate_massimo_una_volta )

------------------------------------------------------------------------------

-- product (maker, _model_, type)
-- pc (_model fk(product)_, speed, ram, hd, rd, price)
-- laptop (_model fk(product)_, speed, ram, hd, screen, price)
-- printer (_model fk(product)_, color, type, price)

--  Trovare quelle coppie di modelli di PC che hanno la stessa velocità e la stessa ram. Una coppia
-- deve essere elencata una sola volta; ovvero se elenco (i, j) allora non devo elencare (j, i).
-- SQL
select pc1.model, pc2.model
from pc pc1, pc pc2
where pc1.speed = pc2.speed
	and pc1.ram = pc2.ram
	and pc1.model != pc2.model
	and pc1.model < pc2.model -- stampa solo (i, j) e non anche (j, i), es: pc1.model = 10, pc2.model = 15

-- Algebra Relazionale
pc1 :=
	REN_{ pc1_model, pc1_speed, pc1_ram <- model, speed, ram } (
		PROJ_{ model, speed, ram } (
			pc
		)
	)
pc2 :=
	REN_{ pc2_model, pc2_speed, pc2_ram <- model, speed, ram } (
		PROJ_{ model, speed, ram } (
			pc
		)
	)

PROJ_{ pc1_model, pc2_model } (
	SEL_{ -- Selezione sul Prodotto Cartesiano
		pc1_speed = pc2_speed
		and pc1_ram = pc2_ram
		and pc1_model != pc2_model
		and pc1_model < pc2_model
	} (pc1 JOIN pc2) -- Prodotto Cartesiano 
)


