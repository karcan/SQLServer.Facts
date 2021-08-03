USE [KARCAN_DEV]
GO
/****** Object:  StoredProcedure [dbo].[SP_RunFacts]    Script Date: 3.08.2021 21:18:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[SP_RunFacts]
AS
BEGIN
DECLARE @vErrorListCursor CURSOR;

EXEC SP_FactLogic @ErrorList = @vErrorListCursor OUTPUT
DECLARE 
		@vErrorList		TABLE (
			ProcedureName	NVARCHAR(255),
			ErrorMessage	NVARCHAR(4000),
			ErrorSeverity	INT,
			ErrorState		INT
		);

DECLARE 
		@vProcedureName		NVARCHAR(255),
		@vErrorMessage		NVARCHAR(4000),
		@vErrorSeverity		INT,
		@vErrorState		INT;

FETCH NEXT FROM @vErrorListCursor INTO @vProcedureName, @vErrorMessage, @vErrorSeverity, @vErrorState

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO @vErrorList
	VALUES (@vProcedureName, @vErrorMessage, @vErrorSeverity, @vErrorState);

	FETCH NEXT FROM @vErrorListCursor INTO @vProcedureName, @vErrorMessage, @vErrorSeverity, @vErrorState
END

CLOSE @vErrorListCursor
DEALLOCATE @vErrorListCursor

SELECT * FROM @vErrorList
END
