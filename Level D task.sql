CREATE PROCEDURE PopulateTimeDimension
    @inputDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @startDate DATE = DATEFROMPARTS(YEAR(@inputDate), 1, 1);
    DECLARE @endDate DATE = DATEFROMPARTS(YEAR(@inputDate), 12, 31);

    ;WITH DateCTE AS (
        SELECT @startDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateCTE
        WHERE DateValue < @endDate
    )

    INSERT INTO TimeDimension (
        Date, CalendarDay, CalendarMonth, CalendarQuarter, CalendarYear,
        DayName, DayNameShort, DayNumOfWeek, DayNumOfYear, DaySuffix,
        FiscalWeek, FiscalPeriod, FiscalQuarter, FiscalYear, FiscalYearPeriod
    )
    SELECT
        DateValue AS Date,
        DAY(DateValue) AS CalendarDay,
        MONTH(DateValue) AS CalendarMonth,
        DATEPART(QUARTER, DateValue) AS CalendarQuarter,
        YEAR(DateValue) AS CalendarYear,
        DATENAME(WEEKDAY, DateValue) AS DayName,
        LEFT(DATENAME(WEEKDAY, DateValue), 3) AS DayNameShort,
        DATEPART(WEEKDAY, DateValue) AS DayNumOfWeek,
        DATEPART(DAYOFYEAR, DateValue) AS DayNumOfYear,
        CAST(DAY(DateValue) AS VARCHAR) + 
            CASE 
                WHEN DAY(DateValue) IN (11,12,13) THEN 'th'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '1' THEN 'st'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '2' THEN 'nd'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '3' THEN 'rd'
                ELSE 'th'
            END AS DaySuffix,
        DATEPART(WEEK, DateValue) AS FiscalWeek,
        MONTH(DateValue) AS FiscalPeriod,
        DATEPART(QUARTER, DateValue) AS FiscalQuarter,
        YEAR(DateValue) AS FiscalYear,
        CAST(YEAR(DateValue) AS VARCHAR) + RIGHT('0' + CAST(MONTH(DateValue) AS VARCHAR), 2) AS FiscalYearPeriod
    FROM DateCTE
    OPTION (MAXRECURSION 366);
END
