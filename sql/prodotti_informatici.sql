-- DOC: https://www.w3schools.com/sql/default.asp

-- Quali modelli di PC hanno una velocità di almeno 1000
PROJ_{ model } (
	SEL_{ speed >= 1000 } ( 
		pc 
	)
)

-- Quali costruttori fanno laptop con un hard disk di almeno 1 GB
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

-- Trovare il numero di modello e il prezzo di tutti i prodotti (di qualunque tipo) costruiti da B

-- Trovare i modelli di tutte le stampanti laser a colori
PROJ_{ model } (
	SEL_{ type = "laser" AND color } (
		printer
	)
)

-- Trovare quei costruttori che vendono laptop ma non vendono pc
laptop_makers( maker ) := PROJ_{maker} (product JOIN_NAT laptop);
pc_makers( maker ) := PROJ_{maker} (product JOIN_NAT pc);
laptop_makers - pc_makers

-- Trovare le dimensioni di disco fisso che occorrono almeno due PC distinti
PC1 := REN_{ model1, hd1 <- model, hd } ( PROJ_{model, hd} (pc) )
PC2 := REN_{ model2, hd2 <- model, hd } ( PROJ_{model, hd} (pc) )
PROJ_{ hd1 } (
	PC1 JOIN_{ hd1 = hd2 AND model1 != model2 } PC2 
)	


-- Trovare quelle coppie di modelli di pc che hanno la stessa velocità e la stessa ram. 
-- Una coppia deve essere elencata una sola volta (ovvero se elenco (i,j) allora non devo elencare (j,i) )

-- Trovare quei costruttori di almeno due differenti computer (pc o laptop) con velocità di almeno 700


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
-- Trovare il numero di modello e il prezzo di tutti i prodotti (di qualunque tipo) costruiti da B
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

-- Quali modelli di PC hanno una velocità di almeno 1000
select model from pc where speed >= 1000;

-- Quali costruttori fanno laptop con un hard disk di almeno 1 GB
select distinct maker 	-- distinct: https://www.w3schools.com/sql/sql_distinct.asp
from product as p
inner join laptop l
on l.model = p.model AND l.hd >= 1000;

-- Trovare i modelli di tutte le stampanti laser a colori
select model
from printer
where type = 'laser' AND color

-- Trovare quei costruttori che vendono laptop ma non vendono pc
select distinct maker 
from laptop
join product p 
on p.model = laptop.model
where p.maker not in ( 		-- in: https://www.w3schools.com/sql/sql_in.asp
    select maker from pc
    inner join product p 
    on p.model = pc.model
)

-- Trovare le dimensioni di disco fisso che occorrono almeno due PC distinti
select hd
from pc
group by hd 				-- group by: https://www.w3schools.com/sql/sql_groupby.asp
having count(model) > 1 	-- having: https://www.w3schools.com/sql/sql_having.asp

-- Trovare quei costruttori di almeno due differenti computer (pc o laptop) con velocità di almeno 700
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

-- Trovare quelle coppie di modelli di pc che hanno la stessa velocità e la stessa ram. 
-- Una coppia deve essere elencata una sola volta (ovvero se elenco (i,j) allora non devo elencare (j,i) )

???