create table anagrafica(
    nome varchar(255),
    cognome varchar(255),
    cod_fiscale varchar(16),
    primary key (cod_fiscale)
)

-- Controllo correttezza codice fiscale
create or replace trigger controllo_codice_fiscale_trg
	before insert or update on anagrafica
	for each row 
	execute procedure controllo_codice_fiscale();
 
create or replace function controllo_codice_fiscale()
	returns trigger as
	$body$
	begin
        if length(new.cod_fiscale) != 16 
            then return null;
		end if;

		new.cod_fiscale := upper(new.cod_fiscale);
        
		if new.cod_fiscale ~ '^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$' 
		    then -- do nothing
		    else return null;
        end if;

		return new;
	end
	$body$
language plpgsql;

-- Prime lettere del nome e cognome in maiuscolo
create or replace trigger primo_carattere_maiuscolo_trg
	before insert or update on anagrafica
	for each row
	execute procedure primo_carattere_maiuscolo();

create or replace function primo_carattere_maiuscolo()
	returns trigger as
	$body$
	begin
		new.nome := concat(
			upper(
				substring(new.nome, 1, 1)), 
				substring(new.nome, 2, length(new.nome)
			)
		);
		new.cognome := concat(
			upper(
				substring(new.cognome, 1, 1)), 
				substring(new.cognome, 2, length(new.cognome)
			)
		);
		return new;
	end
	$body$
language plpgsql;



