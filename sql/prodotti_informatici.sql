-- DOC: https://www.w3schools.com/sql/default.asp

-- 1) Quali modelli di PC hanno una velocità di almeno 1000
PROJ_{ model } (
	SEL_{ speed >= 1000 } ( 
		pc 
	)
)

-- 2) Quali costruttori fanno laptop con un hard disk di almeno 1 GB
PROJ_{ maker } (
	SEL_{ hd >= 1 } (
		product JOIN_{NAT} laptop 
	)
)

PROJ_{ maker } (
	product JOIN_{NAT} 
		SEL_{ hd >= 1 } (
			laptop
		)
)

-- 3) Trovare il numero di modello e il prezzo di tutti i prodotti (di qualunque tipo) costruiti da B

-- 4) Trovare i modelli di tutte le stampanti laser a colori
PROJ_{ model } (
	SEL_{ type = "laser" AND color } (
		printer
	)
)

-- 5) Trovare quei costruttori che vendono laptop ma non vendono pc
laptop_makers( maker ) := PROJ_{maker} (product JOIN_NAT laptop);
pc_makers( maker ) := PROJ_{maker} (product JOIN_NAT pc);
laptop_makers - pc_makers

-- 6) Trovare le dimensioni di disco fisso che occorrono almeno due PC distinti
PC1 := REN_{ model1, hd1 <- model, hd } ( PROJ_{model, hd} (pc) )
PC2 := REN_{ model2, hd2 <- model, hd } ( PROJ_{model, hd} (pc) )
PROJ_{ hd1 } (
	PC1 JOIN_{ hd1 = hd2 AND model1 != model2 } PC2 
)	


-- 7) Trovare quelle coppie di modelli di pc che hanno la stessa velocità e la stessa ram. 
-- Una coppia deve essere elencata una sola volta (ovvero se elenco (i,j) allora non devo elencare (j,i) )
PC1 := REN_{ model1, speed1, ram1 <- model, speed, ram} ( PROJ_{model, speed, ram} (pc) )
PC1 := REN_{ model2, speed2, ram2 <- model, speed, ram} ( PROJ_{model, speed, ram} (pc) )
PROJ_{ model1, model2 } (
	PC1 JOIN_{ speed1 = speed2 AND ram1 = ram2 AND model1 < model2 } PC2 
)

-- 8) Trovare quei costruttori di almeno due differenti computer (pc o laptop) con velocità di almeno 700
computer_veloci(model) :=
	PROJ_{model} ( SEL_{speed >= 700} (pc) )
	UNION
	PROJ_{model} ( SEL_{speed >= 700} (laptop) )

CV1 := REN_{model1 <- model} ( computer_veloci )
CV2 := REN_{model2 <- model} ( computer_veloci )

maker1(maker1, model1) :=
	REN_{maker1, model1 <- maker, model} ( PROJ_{maker, model} (product) )
maker2(maker2, model2) :=
	REN_{maker2, model2 <- maker, model} ( PROJ_{maker, model} (product) )

PROJ_{maker1} (
	(CV1 JOIN_NAT maker1)
		JOIN_{ maker1 = maker2 and model1 != model2 }
	(CV2 JOIN_NAT maker2)
)

-- 9) Trovare il/i costruttore/i del computer (pc o laptop) con la piu alta velocita disponibile
C1(model, speed) := PROJ_{model, speed} (pc)
C2(model, speed) := PROJ_{model, speed} (laptop)

CM(maker, model, speed) :=
	PROJ_{maker, model, speed} ( product JOIN_NAT (C1 UNION C2) )

CM2(maker2, model2, speed2) := CM(maker, model, speed)

C_LENTO(maler, model) :=
	PROJ_{maker, model} ( CM1 JOIN_{ speed < speed2 } CM2 )

C_TUTTI(maker, model) :=
	PROJ_{maker, model} ( product JOIN_NAT (C1 UNION C2) )

PROJ_{maker} ( C_TUTTI - C_LENTI )

-- 10) Trovare tutti i costruttori di pc con almeno 3 velocità distinte
-- 11) Trovare i costruttori che vendono esattamente 3 modelli di pc
-- 12) Esprimere i vincoli di chiave primaria usando l'algebra relazionale
** model è la chiave per product

product1(maker1, model1, type1) := product(maker, model, type)
product2(maker2, model2, type2) := product(maker, model, type)

product1 JOIN_{ model1 = model2 AND (maker1 != maker2 OR type1 != type2 ) }
	product2 = {}

------------- DDL
create table product(
	maker 	varchar(255) 	not null,
	model 	int 			not null,
	primary key	(model)
);

create table pc(
	model 	int 	not null,
	speed 	int 	not null,
	hd 		int 	not null,
	rd 		int 	not null,
	price 	int 	not null,
	primary key (model),
	foreign key (model) references product(model)
);

create table laptop(
	model 	int 	not null,
	speed 	int 	not null,
	hd 		int 	not null,
	screen 	int 	not null,
	price 	int 	not null,
	primary key (model),
	foreign key (model) references product(model)
);

create table printer(
	model 	int 			not null,
	color 	boolean 		not null,
	type 	varchar(255) 	not null,
	price 	int 			not null,
	primary key (model),
	foreign key (model) references product(model)
);

insert into product(maker, model) VALUES ('Apple', 1);
insert into product(maker, model) VALUES ('Samsung', 2);
insert into product(maker, model) VALUES ('Hp', 3);
insert into product(maker, model) VALUES ('Acer', 4);
insert into product(maker, model) VALUES ('Samsung', 5);
insert into product(maker, model) VALUES ('Apple', 6);
insert into product(maker, model) VALUES ('Samsung', 7);
insert into product(maker, model) VALUES ('Acer', 8);
insert into product(maker, model) VALUES ('Hp', 9);
insert into product(maker, model) VALUES ('Samsung', 10);


insert into laptop(model, speed, hd, screen, price) VALUES (1, 2000, 1000, 15, 899);
insert into laptop(model, speed, hd, screen, price) VALUES (6, 1500, 3000, 23, 1299);
insert into laptop(model, speed, hd, screen, price) VALUES (3, 3000, 500, 15, 699);


insert into pc(model, speed, hd, rd, price) VALUES (2, 2000, 1500, 500, 799);
insert into pc(model, speed, hd, rd, price) VALUES (4, 1000, 2000, 1500, 999);
insert into pc(model, speed, hd, rd, price) VALUES (5, 3000, 2500, 1000, 599);
insert into pc(model, speed, hd, rd, price) VALUES (7, 1000, 1000, 500, 699);


insert into printer(model, color, type, price) VALUES (8, true, 'laser', 199);
insert into printer(model, color, type, price) VALUES (9, false, 'toner', 59);
insert into printer(model, color, type, price) VALUES (10, false, 'laser', 99);


------------- DML
-- 1) Trovare il numero di modello e il prezzo di tutti i prodotti (di qualunque tipo) costruiti da B
select * from (

    select p.maker, p.model, l.price 
    from laptop as l
    inner join product p on p.model = l.model

    UNION

    select p.maker, p.model, pc.price 
    from pc
    inner join product p on p.model = pc.model

    UNION

    select p.maker, p.model, pr.price 
    from printer as pr
    inner join product p on p.model = pr.model

) as pippo

where maker = 'Samsung';

-- 2) Quali modelli di PC hanno una velocità di almeno 1000
select model from pc where speed >= 1000;

-- 3) Quali costruttori fanno laptop con un hard disk di almeno 1 GB
select distinct maker 	-- distinct: https://www.w3schools.com/sql/sql_distinct.asp
from product as p
inner join laptop l
on l.model = p.model AND l.hd >= 1000;

-- 4) Trovare i modelli di tutte le stampanti laser a colori
select model
from printer
where type = 'laser' AND color

-- 5) Trovare quei costruttori che vendono laptop ma non vendono pc
select distinct maker 
from laptop
join product p 
on p.model = laptop.model
where p.maker not in ( 		-- in: https://www.w3schools.com/sql/sql_in.asp
    select maker from pc
    inner join product p 
    on p.model = pc.model
)

-- 6) Trovare le dimensioni di disco fisso che occorrono almeno due PC distinti
select hd
from pc
group by hd 				-- group by: https://www.w3schools.com/sql/sql_groupby.asp
having count(model) > 1 	-- having: https://www.w3schools.com/sql/sql_having.asp

-- 7) Trovare quelle coppie di modelli di pc che hanno la stessa velocità e la stessa ram.
-- Una coppia deve essere elencata una sola volta (ovvero se elenco (i,j) allora non devo elencare (j,i) )
create view pc1 as 			-- view: https://www.w3schools.com/sql/sql_view.asp
    select model, speed, rd
    from pc;

create view pc2 as
    select model, speed, rd
    from pc;

select pc1.model as model1, pc2.model as model2,
       pc1.speed as speed1, pc2.speed as speed2,
       pc1.rd as ram1, pc2.rd as ram2
from pc1
inner join pc2
on pc1.speed = pc2.speed AND
   pc1.rd = pc2.rd AND
   pc1.model < pc2.model;

-- 8) Trovare quei costruttori di almeno due differenti computer (pc o laptop) con velocità di almeno 700
select distinct maker
from laptop
join product p
	on p.model = laptop.model
where speed > 700 AND
    p.maker in (
        select maker from pc
        join product p
        on p.model = pc.model
        where pc.speed > 700
    )

-- 9) Trovare il/i costruttore/i del computer (pc o laptop) con la piu alta velocita disponibile
create view pc_laptop as 		
    select model, speed from pc
    UNION
    select model, speed from laptop;

create view pc_laptop_product as
    select p.maker, pl.model, pl.speed
    from pc_laptop pl
    inner join product p on pl.model = p.model;

create view max_speed as
    select max(speed)
    from pc_laptop_product;

select plp.maker, plp.model, plp.speed
from pc_laptop_product as plp
inner join max_speed m
	on plp.speed = m.max;

-- 10) Trovare tutti i costruttori di pc con almeno 3 velocità distinte
select maker
from pc
inner join product p
    on pc.model = p.model
group by maker
having count(distinct "speed") >= 3;

-- 11) Trovare i costruttori che vendono esattamente 3 modelli di pc
select maker, count("speed")
from pc
inner join product p on pc.model = p.model
group by maker
having count("speed") = 3
