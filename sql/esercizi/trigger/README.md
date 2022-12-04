# Che cos'è un `Trigger`
Il trigger è una procedura che viene eseguita in maniera automatica in coincidenza di un determinato evento.  
I trigger sono basati sul paradigma Event-Condition-Action:
1. Event: quando un evento si verifica [triggering];
2. Condition: se la condizione è soddisfatta [consideration] (è opzionale);
3. Action: esegue l'azione (execution).
  
Ogni trigger è associato a una tabella (`TARGET`).  
Si attiva solo per eventi che si verificano su quella tabella.
  
I trigger si dividono in:
- Trigger DML: L’evento di innesco è una primitiva per la manipolazione dei dati (INSERT, UPDATE o DELETE). Possono essere eseguiti subito prima (BEFORE) o subito dopo (AFTER) l’evento di innesco. La condizione è espressa in una clausola WHEN all’interno della dichiarazione e può essere anche omessa e sottintesa se il suo valore è sempre TRUE.
- Trigger DDL (o trigger di sistema): Reagiscono a eventi di sistema, quali l’avvio e la chiusura di un database, la creazione o cancellazione di tabelle, ecc. e sono usati come ulteriore misura di sicurezza in una base dati.

I trigger si “accendono“, quindi, per effetto di uno dei seguenti eventi:
- DML statement (INSERT UPDATE o DELETE) su tabelle o viste;
- DDL statement (CREATE, ALTER, DROP);
- Eventi di sistema sulla base di dati (SERVER ERROR, LOGON, LOGOFF, STARTUP, SHUT DOWN).

Per i trigger DML si fa inoltre distinzione per quanto riguarda il modo di esecuzione e la granularità.

Modo di esecuzione:
- Differito (after): considerato ed eseguito dopo che venga applicata sulla base dati l’azione che lo ha attivato;
- Immediato (before): considerato ed eseguito prima che venga applicata alla base dati l’azione che lo ha attivato.

Granularità (con che frequenza):
- di tupla (row – level): attivazione per ogni tupla della tabella coinvolta nell’operazione;
- di operazione (statement – level): una sola attivazione per ogni istruzione DML che attiva il trigger, coinvolgendo tutte le ennuple della tabella target.
  
I trigger vengono eseguiti in ordine alfabetico.  

### A cosa servono i trigger?
Servono per controllare e mantenere i vincoli di integrità.  
Ma possono essere utilizzati anche per molte altre cose, per esempio: backup dei DBMS, gestione delle viste materializzate e/o viste virtuali, tracking dell'utilizzo del DBMS (chi ha modificato quella n-upla, ...).

# Che cos'è il `PL/pgSQL`
Procedural Language PostgreSQL è un linguaggio di programmazione procedurale supportato dal DBMS.  
Permette un maggiore controllo del semplice SQL, includendo l'abilità di usare cicli e strutture di controllo avanzate.  
  
I programmi creati nel linguaggio `PL/pgSQL` sono chiamati `funzioni`, e possono essere richiamati come parti di un'istruzione SQL o attivati da un trigger.  

# Sintassi `Trigger` in `PostgreSQL`
[Documentazione PostgreSQL](https://www.postgresql.org/docs/current/sql-createtrigger.html)  
Creazione trigger:
```
CREATE [ OR REPLACE ] TRIGGER name
	MODE { before | after } 
	EVENT { insert | update | delete }
	ON target_table
	REFERENCING reference
	FOR [ EACH ] { row | statement } 
	WHEN condition
	EXECUTE function_name

	// reference: permette di cambiare il nome degli attributi
```
Creazione funzione da eseguire:
```
CREATE [ OR REPLACE ] FUNCTION name
	RETURN TRIGGER AS
	$body$
	begin
		function_body
	end
	$body$
language plpgsql;
```
