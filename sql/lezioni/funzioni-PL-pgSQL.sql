create function somma(a integer, b integer) returns integer
$body$
begin
	return a + b;
end
$body$
language plpgsql;

-------------------------------------------------

create or replace function pippo() returns void as
$body$
begin
	create table pippo(a integer primary key);
	-- insert into pippo values (1) (2) (3);
end
$body$
language plpgsql;