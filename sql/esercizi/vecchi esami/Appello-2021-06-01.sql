-- Appello 2021-06-01

-- MEDICI (_codice_, cognome, nome)
-- PAZIENTI (_codice_, cognome, nome, data_nascita)
-- MEDICINALI (_codice_, nome, principio_attivo, marca)
-- VISITE (_medico_[fk], _paziente_[fk], _data_[fk], diagnosi, medicinale[fk]*)

-- Elencare i medici che sono omonimi (stesso nome e stesso cognome) di almeno un paziente
-- SQL
select m.*
from medici m, pazienti p
where m.nome = p.nome and m.cognome = p.cognome

-- Algebra Relazionale
m := REN_{ m_codice, m_cognome, m_nome <- codice, cognome, nome } (
		PROJ_{ codice, cognome, nome } (
			medici
		)
	)
p := REN_{ p_codice, p_cognome, p_nome <- codice, cognome, nome } (
		PROJ_{ codice, cognome, nome } (
			pazienti
		)
	)
PROJ_{ m_codice, m_cognome, m_nome } (
	SEL_{
		m_nome = p_nome and m_cognome = p_cognome
	} (m JOIN_ p)
)


-- Elencare i pazienti visitati almeno una volta e ai quali non sono mai stati prescritti medicinali
-- SQL
create view pazienti_visitati_con_medicinali_prescritti as
	select distinct v.paziente
	from visite v
	where v.medicinale is not null

select distinct paziente from visite 
except
select * from pazienti_visitati_con_medicinali_prescritti

-- Algebra Relazionale
pazienti_visitati_con_medicinali_prescritti :=
	PROJ_{ paziente } (
		SEL_{ medicinale != null } ( visite )
	)
pazienti_visitati :=
	PROJ_{ paziente } ( visite )

pazienti_visitati_mai_medicinali_prescritti :=
	pazienti_visitati - pazienti_visitati_con_medicinali_prescritti


-- Eliminare dal database le visite effettuate a pazienti nati prima dell'anno 1950
create view pazienti_visitati_nati_prima_del_1950 as
	select distinct v.paziente
	from visite v, pazienti p
	where v.paziente = p.codice
		and p.data_nascita < '1950-01-01'

delete from visite
	where paziente in pazienti_visitati_nati_prima_del_1950


-- Elencare, in ordine alfabetico, i medici che nel 2020 hanno prescritto medicinali di una ed una sola marca
-- SQL
select me.codice, me.cognome, me.nome
from visite v, medicinali m, medici me
where v.medicinale = m.codice 
	and v.data >= '2020-01-01' and v.data <= '2020-12-31'
	and v.medico = me.codice
group by me.codice, me.cognome, me.nome
having count(distinct m.marca) = 1
order by me.cognome, me.nome, me.codice

-- Alebra Relazionale
m := REN_{ m_codice, m_marca <- codice, marca } ( PROJ_{ codice, marca } ( medicinali ) )
m2 := REN_{ m2_codice, m2_marca <- m_codice, m_marca } ( m )
me := REN_{ me_codice, me_cognome, me_nome <- codice, cognome, nome } (
		PROJ_{ codice, cognome, nome } ( medici ) )
v := REN_{ v_medico, v_paziente, v_data, v_medicinale <- medico, paziente, data, medicinale } (
		PROJ_{ medico, paziente, data, medicinale } (
			SEL_{ data >= '2020-01-01' and data <= '2020-12-31' and medicinale != null } ( visite ) ) )
v2 := REN_{ v2_medico, v2_paziente, v2_data, v2_medicinale <- v_medico, v_paziente, v_data, v_medicinale } ( v )

medici_che_hanno_prescritto_medicinali_di_piu_marche_nel_2020 := 
	REN_{ medico <- v_medico } (
		PROJ_{ v_medico } (
			SEL_{ 
				v_medico = v2_medico
				and ( v_paziente != v2_paziente or v_data != v2_data )
				and v_medicinale = m_codice
				and v2_medicinale = m2_codice
				and m_marca != m2_marca
			} (v JOIN_ v2 JOIN_ m JOIN_ m2)
		)
	)

medici_che_hanno_fatto_visite_nel_2020 :=
	REN_{ medico <- v_medico } (
		PROJ_{ v_medico } ( v )
	)

medici_che_hanno_prescritto_medicinali_di_una_unica_marca_nel_2020 :=
	medici_che_hanno_fatto_visite_nel_2020 - medici_che_hanno_prescritto_medicinali_di_piu_marche_nel_2020

mm := medici_che_hanno_prescritto_medicinali_di_una_unica_marca_nel_2020 -- Uso alias per abbreviare

PROJ_{ codice, cognome, nome } (
	SEL_{ medico = codice } (mm JOIN_ medici)
)


-- Sapendo che le relazioni MEDICI, PAZIENTI e VISITE hanno cardinalità m,p,v € N, 
-- indicare (motivando la risposta) le cardinalità minime e massime delle seguenti interrogazioni:
select p.cognome, p.nome, v.data 
from pazienti p, visite v
where v.paziente = p.codice
cardinalità minima: 0 -> non sono mai state effettuate visite
cardinalità massima: v -> tutte le visite presenti nel database sono state effettuate dallo stesso paziente

select m.cognome 
from medici m, pazienti p
where m.nome = p.nome
cardinalità minima: 0 -> nessun medico ha lo stesso cognome di un paziente
cardinalità massima: m * p -> tutti i medici e tutti i pazienti possono avere lo stesso nome



