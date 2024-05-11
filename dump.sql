-- Script pentru generare csv din tabela sau view
-- Parametri de apel owner tabela fisier.csv

set trimspool on
set serverout on
clear buffer
var maxcol number
var linelen number
var dumpfile char(40)
define dumpowner='&1'
define dumptable='&2'
define dumpfile='&3'

col column_id noprint

set pages0 feed off termout on echo off verify off

begin

        select max(column_id) into :maxcol
        from all_tab_columns
        where table_name = rtrim(upper('&dumptable'))
        and owner = rtrim(upper('&dumpowner'));

        select sum(data_length) + ( :maxcol * 3 ) into :linelen
        from all_tab_columns
        where table_name = rtrim(upper('&dumptable'))
        and owner = rtrim(upper('&dumpowner'));

end;
/

print linelen
print maxcol
spool ./_dump.sql

define squote=chr(39)
define dquote=chr(34)
define comma=chr(44)

select 'set trimspool on' from dual;
select 'set termout off pages 0 heading off echo off' from dual;
select 'set line ' || :linelen from dual;
select 'spool ' || lower(replace('&dumpfile$','$','')) from dual;

select 'select' || chr(10) from dual;

select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||
         &&squote || column_name || &&squote
        || ' ||' || &&squote || '",' || &&squote || ' || ',
        column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id < :maxcol
union
select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||
        &&squote || column_name || &&squote
        || ' ||' || &&squote || &&dquote || &&squote ,
        column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id = :maxcol
order by 2
/
select ' from dual' from dual;

select 'union all' from dual;
select 'select' || chr(10) from dual;
select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||
        'replace(' || column_name || &&comma || &&squote ||  &&dquote || &&squote || ') '
        || ' ||' || &&squote || '",' || &&squote || ' || ',
        column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id < :maxcol
union
select '   ' || &&squote || &&dquote  || &&squote || ' || ' ||
        'replace(' || column_name  || &&comma || &&squote ||  &&dquote || &&squote || ') '
        || ' ||' || &&squote || &&dquote || &&squote ,
        column_id
from all_tab_columns
where table_name = upper('&dumptable')
and owner = upper('&dumpowner')
and column_id = :maxcol
order by 2
/

select 'from &dumpowner..&dumptable' from dual;
select '/' from dual;

select 'spool off' from dual;

spool off

@./_dump

undef 1 2

exit

