--
-- Create a list of all cards in the database
-- The list will be a string like card1;card2;
--
CREATE PROCEDURE #GetCardList
    @stCardList nvarchar(256) OUTPUT
AS

    DECLARE @stCard nvarchar(64)
    SET @stCardList = ""

    DECLARE CardCursor CURSOR FOR
        SELECT DISTINCT CARD 
        FROM Winlogon.dbo.AuthMonitor
        WHERE CARD <> ""
        ORDER BY CARD DESC

    OPEN CardCursor
    FETCH NEXT FROM CardCursor
    INTO @stCard

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @stCardList = RTRIM(@stCard) + ";" + @stCardList
        FETCH NEXT FROM CardCursor
        INTO @stCard
    END

    CLOSE CardCursor
    DEALLOCATE CardCursor
GO

--
-- Create a list of all readers
-- Like the card list this will look like reader1;reader2
--
CREATE PROCEDURE #GetReaderList
    @stReaderList nvarchar(256) OUTPUT
AS

    SET @stReaderList = ""

    DECLARE ReaderCursor CURSOR FOR
        SELECT DISTINCT READER 
        FROM Winlogon.dbo.AuthMonitor
        WHERE READER <> ""
        ORDER BY READER DESC

    DECLARE @stReader nvarchar(64)

    OPEN ReaderCursor
    FETCH NEXT FROM ReaderCursor
    INTO @stReader

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @iLen int
 
        SET @stReader = RTRIM(@stReader)
        SET @iLen = LEN(@stReader)

        IF RIGHT(@stReader, 1) = "0"
            SET @stReaderList = LEFT(@stReader, @iLen - 2) + ";" + @stReaderList

        FETCH NEXT FROM ReaderCursor
        INTO @stReader
    END

    CLOSE ReaderCursor
    DEALLOCATE ReaderCursor
GO

CREATE PROCEDURE #GetCard
    @stCard nvarchar(64) OUTPUT,
    @iStart int OUTPUT
AS
    DECLARE @stCardList nvarchar(256), @iPos int

    EXEC #GetCardList @stCardList OUTPUT
    SET @iPos = CHARINDEX ( ";", @stCardList, @iStart) 

    IF @iPos = 0
        SET @stCard = ""
    ELSE
        SET @stCard = SUBSTRING(@stCardList, @iStart, @iPos - @iStart)

    SET @iStart = @iPos + 1
GO

CREATE PROCEDURE #GetReader
    @stReader nvarchar(64) OUTPUT,
    @iStart int OUTPUT
AS
    DECLARE @stReaderList nvarchar(256), @iPos int

    EXEC #GetReaderList @stReaderList OUTPUT
    SET @iPos = CHARINDEX ( ";", @stReaderList, @iStart) 

    IF @iPos = 0
        SET @stReader = ""
    ELSE
        SET @stReader = SUBSTRING(@stReaderList, @iStart, @iPos - @iStart)

    SET @iStart = @iPos + 1
GO

