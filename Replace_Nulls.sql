SELECT 
    Date,
    BU,
    LAST_VALUE(Value) IGNORE NULLS OVER (
        PARTITION BY BU 
        ORDER BY Date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Value
FROM HZL_Table;
