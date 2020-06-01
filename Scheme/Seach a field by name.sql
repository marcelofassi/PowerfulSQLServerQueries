--USE AdventureWorks
--GO

DECLARE @fieldFinding AS VARCHAR(256)

-- SET VALUE TO FIELD
SET @fieldFinding = 'ClientId' 


SELECT t.name AS table_name, SCHEMA_NAME(t.schema_id) AS schema_name, c.name AS column_name
FROM     sys.tables AS t INNER JOIN
                  sys.columns AS c ON t.object_id = c.object_id
WHERE  (c.name LIKE '%' + @fieldFinding +'%')
ORDER BY schema_name, table_name


 