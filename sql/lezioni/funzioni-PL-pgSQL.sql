create function somma(a integer, b integer) returns integer
$body$
begin
	return a + b;
end
$body$
language plpgsql;