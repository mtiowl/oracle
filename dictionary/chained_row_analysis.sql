SET SERVEROUTPUT ON SIZE 1000000

DECLARE
  l_full_table_scans NUMBER;
  l_rowid_fetches    NUMBER;
  l_chained_fetches  NUMBER;
BEGIN
  FOR stat_rec IN (SELECT name, value 
                     FROM v$sysstat 
                     WHERE name IN ('table scan rows gotten', 'table fetch by rowid', 'table fetch continued row') ) LOOP
     IF stat_rec.name = 'table scan rows gotten' THEN
         l_full_table_scans := stat_rec.value;
     ELSIF stat_rec.name = 'table fetch by rowid' THEN
         l_rowid_fetches := stat_rec.value;
     ELSIF stat_rec.name = 'table fetch continued row' THEN
         l_chained_fetches := stat_rec.value;
     END IF;
  END LOOP;

  dbms_output.put_line ('Full Table Scans: '||l_full_table_scans);
  dbms_output.put_line ('ROWID fetches: '||l_rowid_fetches);
  dbms_output.put_line ('Chained Row Fetches: '||l_chained_fetches);
  dbms_output.put_line ('Chained Row %: '||round(l_chained_fetches/l_rowid_fetches, 4) * 100 );
  
END;
/
