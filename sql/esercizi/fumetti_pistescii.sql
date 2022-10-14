-- link esercizi: http://www.imparando.net/sito/database/SQL/Esercizio%202%20DDL%20e%20DML%20MySQL.pdf
-- ES 1
-- Creare una tabella all’interno del proprio database definita come segue:
-- Fumetti(ID intero, Titolo stringa(150), Serie stringa(150), Presentazione stringa (1000), DataUscita
-- data, Autori stringa(150), Disegnatori stringa (300))

create table if not exists Fumetti (
	id int not null,
	titolo varchar(150) not null,
	serie varchar(150) not null,
	presentazione varchar(1000) not null,
	data_uscita date not null,
	autori varchar(150) not null,
	disegnatori varchar(300) not null
	primary key (id)
);

-- popolare la tabella
insert into Fumetti (id, titolo, serie, presentazione, data_uscita, autori, disegnatori) values (1, 'Chicanos', 'Julia', 'Testimone di due omicidi...', 2007-12-01, 'Giancarlo Berardi, Lorenzo Calza', 'Enio, Valerio Piccioni' )
insert into Fumetti (id, titolo, serie, presentazione, data_uscita, autori, disegnatori) values (2, 'Uvolone', 'Roberta', 'Testimone di tre omicidi...', 2004-12-01, 'Giancarlo Berardi, Lorenzo Calza', 'Enio, Valerio Piccioni' )
insert into Fumetti (id, titolo, serie, presentazione, data_uscita, autori, disegnatori) values (3, 'Ciaone', 'Chicos', 'Testimone di zero omicidi...', 2009-12-01, 'Giancarlo Berardi, Lorenzo Calza', 'Enio, Valerio Piccioni' )
insert into Fumetti (id, titolo, serie, presentazione, data_uscita, autori, disegnatori) values (4, 'aaaaa', 'Chicfdsvfdos', 'Testimdvfvfdvone di zero omicidi...', 2012-12-01, 'Giancarlo Berardi, Lorenzo Calza', 'Enio, Valerio Piccioni' )

-- aggiungere una colonna per memorizzare l'autore della copertina chiamandola DisegnatoreCopertina
alter table Fumetti add DisegnatoreCopertina varchar(300);

-- inserire gli autori delle copertine dei record già presenti mettendo nomi di fantasia
update fumetti set disegnatorecopertina = 'giggino1' where id = 1;
update fumetti set disegnatorecopertina = 'giggino2' where id = 2;
update fumetti set disegnatorecopertina = 'giggino3' where id = 3;
update fumetti set disegnatorecopertina = 'giggino4' where id = 4;

-- eliminare la colonna DataUscita
alter table fumetti drop column data_uscita;

-- aggiungere una colonna Costo di tipo int
alter table Fumetti add costo integer;

-- modificare il tipo della colonna appena creata da int a float
alter table fumetti drop column costo;
alter table Fumetti add costo float;

-- eliminare il record con ID uguale a 2
delete from fumetti where id = 2;

-- modificare la sequenza degli ID in modo da eliminare i buchi e far ripartire i conteggio da 1
??




