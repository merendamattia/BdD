-- QUERY RICORSIVE

create table voli (
	partenza varchar,
	arrivo varchar 
);

insert into voli values ('Roma', 'Milano');
insert into voli values ('Milano', 'Parigi');
insert into voli values ('Roma', 'Cagliari');
insert into voli values ('Cagliari', 'Londra');
-- insert into voli values ('Londra', 'Parigi');
-- insert into voli values ('Parigi', 'Roma');
insert into voli values ('Parigi', 'Londra');

with recursive raggiungibile(origine, destinazione) as (
	select partenza, arrivo from voli
	union distinct
	select r.origine, v.arrivo
	from raggiungibile r, voli v
	where r.destinazione = v.partenza
)
select * from raggiungibile where origine = 'Roma'
