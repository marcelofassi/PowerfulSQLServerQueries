DECLARE @Sourcedb sysname 
DECLARE @Destdb sysname 
DECLARE @Tablename sysname 
DECLARE @SQL varchar(max) 
 
SELECT @Sourcedb = '<<SourceDatabaseName>>' 
SELECT @Destdb   = '<<DestinationDatabaseName>>' 
SELECT @Tablename = '<<Tablename>>' --  '%' for all tables 
 
SELECT @SQL = ' SELECT Tablename  = ISNULL(Source.tablename,Destination.tablename) 
                      ,ColumnName = ISNULL(Source.Columnname,Destination.Columnname) 
                      ,Source.Datatype 
                      ,Source.Length 
                      ,Source.precision 
                      ,Destination.Datatype 
                      ,Destination.Length 
                      ,Destination.precision 
                      ,[Column]  = 
                       Case  
                       When Source.Columnname IS NULL then ''Column Missing in the Source'' 
                       When Destination.Columnname IS NULL then ''Column Missing in the Destination'' 
                       ELSE '''' 
                       end 
                      ,DataType = CASE WHEN Source.Columnname IS NOT NULL  
                                        AND Destination.Columnname IS NOT NULL  
                                        AND Source.Datatype <> Destination.Datatype THEN ''Data Type mismatch''  
                                  END 
                      ,Length   = CASE WHEN Source.Columnname IS NOT NULL  
                                        AND Destination.Columnname IS NOT NULL  
                                        AND Source.Length <> Destination.Length THEN ''Length mismatch''  
                                  END 
                      ,Precision = CASE WHEN Source.Columnname IS NOT NULL  
                                        AND Destination.Columnname IS NOT NULL 
                                        AND Source.precision <> Destination.precision THEN ''precision mismatch'' 
                                    END 
                      ,Collation = CASE WHEN Source.Columnname IS NOT NULL  
                                        AND Destination.Columnname IS NOT NULL 
                                        AND ISNULL(Source.collation_name,'''') <> ISNULL(Destination.collation_name,'''') THEN ''Collation mismatch'' 
                                        END 
                        
   FROM  
 ( 
 SELECT Tablename  = so.name  
      , Columnname = sc.name 
      , DataType   = St.name 
      , Length     = Sc.max_length 
      , precision  = Sc.precision 
      , collation_name = Sc.collation_name 
  FROM ' + @Sourcedb + '.SYS.objects So 
  JOIN ' + @Sourcedb + '.SYS.columns Sc 
    ON So.object_id = Sc.object_id 
  JOIN ' + @Sourcedb + '.SYS.types St 
    ON Sc.system_type_id = St.system_type_id 
   AND Sc.user_type_id   = St.user_type_id 
 WHERE SO.TYPE =''U'' 
   AND SO.Name like ''' + @Tablename + ''' 
  ) Source 
 FULL OUTER JOIN 
 ( 
  SELECT Tablename  = so.name  
      , Columnname = sc.name 
      , DataType   = St.name 
      , Length     = Sc.max_length 
      , precision  = Sc.precision 
      , collation_name = Sc.collation_name 
  FROM ' + @Destdb + '.SYS.objects So 
  JOIN ' + @Destdb + '.SYS.columns Sc 
    ON So.object_id = Sc.object_id 
  JOIN ' + @Destdb + '.SYS.types St 
    ON Sc.system_type_id = St.system_type_id 
   AND Sc.user_type_id   = St.user_type_id 
WHERE SO.TYPE =''U'' 
  AND SO.Name like ''' + @Tablename + ''' 
 ) Destination  
 ON source.tablename = Destination.Tablename  
 AND source.Columnname = Destination.Columnname ' 
 
EXEC (@Sql)