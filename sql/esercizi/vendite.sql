-- AGENTE(_Nome_, Percentuale)        
-- ARTICOLO(_Nome_, Descrizione, Tipo)   
-- CLIENTE(_Nome_, Indirizzo, Telefono)      
-- VENDITA(_Cliente_, _Articolo_, _Agente_, _Data_, Quanità, Importo, Validità)


-- Nomi degli agenti che hanno venduto piu di 5 articoli di tipo 'automobile' nel 1993
select v.agente
from vendita v, articolo a
where v.articolo = a.nome
    and a.tipo = 'automobile'
    and v.data between '1993-01-01' and '1993-12-31'
group by v.agente
having count(*) > 5;


-- Selezionare gli agenti che hanno venduto qualche articolo di tipo 'scarpa' 
-- ma non hanno venduto nulla a clienti il cui indirizzo è 'via Po, Milano'
create view agenti_che_hanno_venduto_a_clienti_che_abitano_in_via_po_milano as
    select distinct v.agente
    from vendita v, cliente c
    where v.cliente = c.nome
        and c.indirizzo = 'via Po, Milano'

select distinct v.agente
from vendita v, articolo a
where v.articolo = a.nome
    and a.tipo = 'scarpa'
except
select * from agenti_che_hanno_venduto_a_clienti_che_abitano_in_via_po_milano


-- Calcolare il totale dei guadagni degli agenti che vendono articoli di tipo 'immobile'
select v.agente as agente, sum(v.importo) as totale_guadagni_vendite
from vendita v, articolo a
where v.articolo = a.nome
    and a.tipo = 'immobile'
group by v.agente




