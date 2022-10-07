--- This PLSQL script defines 2 procedures to bulk set sequence values
--- 1. ResetSequenceByValue
--- 2. ResetSequenceByTable
--- One is smart, one is dumb
--- @Warning: Watch on the max and min values for your sequence
--- Oracle

DECLARE
--- 1. ResetSequenceByValue(seqOwner IN  varchar2, seqName IN  varchar2, newValue IN  NUMBER)
---    Advances the sequence to the value passed
---    @param seqOwner: schema the sequence is on
---    @param seqName:  the sequence whose value is to be modified
---    @param newValue: the value to be returned when nexval is requested on the sequence
  PROCEDURE ResetSequenceByValue( seqOwner IN  varchar2, seqName IN  varchar2, newValue IN  NUMBER) IS
        curr_value number;
        inc_value number;
        min_value number;
        max_value number;
        jmp_value number;
        
        BEGIN
            -- Get current sequence values
            EXECUTE IMMEDIATE 'SELECT INCREMENT_BY, MIN_VALUE, MAX_VALUE FROM DBA_SEQUENCES WHERE SEQUENCE_NAME=''' || seqName || ''' AND SEQUENCE_OWNER=''' || seqOwner || '''' INTO inc_value, min_value, max_value ;
            EXECUTE IMMEDIATE 'SELECT "' || seqOwner || '"."' || seqName || '".nextval FROM DUAL' INTO curr_value;
            
            -- set new increment value
            -- dbms_output.put_line(seqName || ' from: ' || curr_value || ' to: ' || newValue ); 
            -- Calculate increment value
            jmp_value := newValue - curr_value - 1;
            
            -- dbms_output.put_line( 'jmp = ' || jmp_value ); 
            
            
            EXECUTE IMMEDIATE 'ALTER SEQUENCE "' || seqOwner || '"."' || seqName || '" INCREMENT BY ' || jmp_value ;
            COMMIT;
            
            EXECUTE IMMEDIATE 'SELECT "' || seqOwner || '"."' || seqName || '".nextval FROM DUAL' INTO jmp_value;

            -- reset increment value
            EXECUTE IMMEDIATE  'ALTER SEQUENCE "' || seqOwner || '"."' || seqName || '" INCREMENT BY ' || 1;
            
            COMMIT;
            
        END ResetSequenceByValue;
        
        
--- 2. ResetSequenceByTable
---   This procedure is useful if you know for which table and column the sequence belongs to
---    Advances the sequence to the max value + 1 of the table column
---    @param tabOwner: schema the table belongs to
---    @param tabName: name of the table the sequence is used on
---    @param tabColumn: column on the table the sequence is used 
---    @param seqOwner: owner of the sequence
---    @param seqName:  the sequence whose value is to be modified
    PROCEDURE ResetSequenceByTable( tabOwner IN  varchar2, tabName IN  varchar2, tabColumn IN  varchar2, seqOwner IN  varchar2, seqName IN  varchar2) IS
        curr_value number;
        trgt_value number;
        inc_value number;
        min_value number;
        max_value number;
        jmp_value number;
        
        BEGIN
            -- Get current sequence values
            EXECUTE IMMEDIATE 'SELECT INCREMENT_BY, MIN_VALUE, MAX_VALUE FROM DBA_SEQUENCES WHERE SEQUENCE_NAME=''' || seqName || ''' AND SEQUENCE_OWNER=''' || seqOwner || '''' INTO inc_value, min_value, max_value ;
            EXECUTE IMMEDIATE 'SELECT "' || seqOwner || '"."' || seqName || '".nextval FROM DUAL' INTO curr_value;
            
            -- Get max column value
            EXECUTE IMMEDIATE 'SELECT NVL(MAX("' || tabColumn || '"), 0) FROM "' || tabOwner || '"."' || tabName || '" ' INTO trgt_value;

            
            -- dbms_output.put_line( ' from: ' || curr_value || ' to: ' || trgt_value ); 
            -- Calculate increment value
            jmp_value := trgt_value - curr_value - 1;
            
            -- dbms_output.put_line( 'jmp = ' || jmp_value ); 
            
            EXECUTE IMMEDIATE 'ALTER SEQUENCE "' || seqOwner || '"."' || seqName || '" INCREMENT BY ' || jmp_value ;
            EXECUTE IMMEDIATE 'SELECT "' || seqOwner || '"."' || seqName || '".nextval FROM DUAL' INTO jmp_value;

            -- reset increment value
            EXECUTE IMMEDIATE  'ALTER SEQUENCE "' || seqOwner || '"."' || seqName || '" INCREMENT BY ' || 1;
            
            COMMIT;
            
             --dbms_output.put_line( '-> ' || jmp_value );
             
        END ResetSequenceByTable;

BEGIN
  
  ---- Here is usage example for both procedures
  
  -- ResetSequenceByValue('<sequence_owner>', '<sequence>', <next_value> );
  -- ResetSequenceByTable('<table_owner>', '<table>', '<column>', '<sequence_owner>', '<sequence>', <next_value> ); 
  
END;
/
