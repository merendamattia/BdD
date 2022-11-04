-- Nazioni(_nome_)

create table nazioni (
  nome varchar(200) not null,
  primary key (nome)
);

-- Edizioni(_anno_, nazione_ospitante(fk) , nazione_vincitrice*(fk) )

create table edizioni (
  anno numeric(4) not null,
  nazione_ospitante varchar(200) not null,
  nazione_vincitrice varchar(200), -- annullabile
  primary key (anno),
  foreign key (nazione_ospitante) references nazioni(nome),
  foreign key (nazione_vincitrice) references nazioni(nome)
);

-- Squadre(_edizione_(fk) , _nazione_(fk) , cognome_nome_allenatore)

create table squadre (
  edizione numeric(4) not null,
  nazione varchar(200) not null,
  cognome_nome_allenatore varchar(200)
);

-- Nota: si è deciso di non mettere i vincoli nella create table
-- allo scopo di mostrare l'uso del comando alter table, che consente
-- di modificare lo schema di una tabella esistente.

alter table squadre
  add constraint squadre_pkey
  primary key (edizione, nazione);

alter table squadre
  add constraint squadre_edizione_fkey
  foreign key (edizione) references edizioni(anno);

alter table squadre
  add constraint squadre_nazione_fkey
  foreign key (nazione) references nazioni(nome);

alter table squadre
  alter column cognome_nome_allenatore
  set not null;

-- Giocatori(_id_, cognome_nome, anno_nascita)

create table giocatori (
  id numeric(10) not null,
  cognome_nome varchar(200) not null,
  anno_nascita numeric(4) not null,
  primary key (id)
);

-- Convocati([_squadra_edizione_, _squadra_nazione_](fk),
--           _numero_maglia_, giocatore(fk) )

create table convocati (
  squadra_edizione numeric(4) not null,
  squadra_nazione varchar(200) not null,
  numero_maglia integer not null,
  giocatore numeric(10) not null,
  primary key (squadra_edizione, squadra_nazione, numero_maglia),
  foreign key (squadra_edizione, squadra_nazione)
    references squadre(edizione, nazione),
    foreign key (giocatore) references giocatori(id)
);