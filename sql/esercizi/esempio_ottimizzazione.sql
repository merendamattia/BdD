-- Ottimizzato e senza ridondanze
create table servizi_usati(
	ospite 	int not null,
	camera 	varchar (10) not null,
	nome_albergo varchar (100) not null,
	citta_albergo varchar (100) not null,
	data_arrivo date not null,
	data_partenza date not null,
	struttura varchar(50) not null,

	primary key (ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza, struttura),

	foreign key (ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza) 
		references prenotazioni(ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza),

	foreign key (nome_albergo, citta_albergo, struttura)
		references strutture_presenti(nome_albergo, citta_albergo, struttura)
)

-- Con ridondanza
create table servizi_usati(
	ospite int not null,
	camera varchar (10) not null,
	nome_albergo varchar (100) not null,
	citta_albergo varchar (100) not null,
	data_arrivo date not null,
	data_partenza date not null,
	nome_albergo_strutture varchar (100) not null,
	citta_albergo_strutture varchar (100) not null,
	struttura varchar(50) not null,

	primary key (ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza, 
		nome_albergo_strutture, citta_albergo_strutture, struttura),

	foreign key (ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza) 
		references prenotazioni(ospite, camera, nome_albergo, citta_albergo, data_arrivo, data_partenza),

	foreign key (nome_albergo_strutture, citta_albergo_strutture, struttura)
		references strutture_presenti(nome_albergo, citta_albergo, struttura),

	check(nome_albergo_strutture == nome_albergo and citta_albergo_strutture == citta_albergo)
)
