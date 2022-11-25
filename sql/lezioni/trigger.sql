create table anagrafica(
    nome varchar(255),
    cognome varchar(255),
    cod_fiscale varchar(16),
    primary key (cod_fiscale)
)

create or replace function cognome_maiuscolo()
    returns trigger as
    $body$
    begin
        new.cognome := upper(new.cognome);
        return new;
    end
    $body$
language plpgsql;


create trigger cognome_maiuscolo_trg
    before insert or update on anagrafica
    for each row
    execute procedure cognome_maiuscolo();


insert into anagrafica values('Enea', 'Zaffanella', 'ewdbhjhjbdh');


select * from anagrafica;


create or replace function zaffanella_immortali()
    returns trigger as
    $body$
    begin
        if upper(new.cognome) = 'ZAFFANELLA' then
            return null; -- Manda in abort solo la n-upla su cui sta lavorando
            raise exception 'ZAFFANELLA è immortale'; -- Manda in abort la transazione (tutte le n-uple su cui sta lavorando)
        end if;
        return new;
    end
    $body$
language plpgsql;

create trigger zaffanella_immortali_trg
    before delete on anagrafica
    for each row
    execute procedure zaffanella_immortali();