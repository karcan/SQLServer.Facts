USE [KARCAN_DEV]
GO
/****** Object:  StoredProcedure [dbo].[SP_FactLogic]    Script Date: 3.08.2021 21:17:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[SP_FactLogic]
@ErrorList CURSOR VARYING OUTPUT
AS
BEGIN
	DECLARE 
		@vResult		BIT,
		@vErrorMessage	NVARCHAR(4000),
		@vErrorSeverity	INT,
		@vErrorState	INT;

	DECLARE 
		@vErrorList		TABLE (
			ProcedureName	NVARCHAR(255),
			ErrorMessage	NVARCHAR(4000),
			ErrorSeverity	INT,
			ErrorState		INT
		);

	DECLARE 
		Cursor_RunFacts CURSOR LOCAL
		FOR
		SELECT name
		FROM dbo.sysobjects
		WHERE (type = 'P')
		AND name LIKE '%[_]Fact';

	DECLARE 
		@ProcedureName	NVARCHAR(255),
		@ExecutionName NVARCHAR(300);

	OPEN Cursor_RunFacts

	FETCH NEXT FROM Cursor_RunFacts INTO @ProcedureName
  
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ExecutionName	=	N'EXEC ' + @ProcedureName + '
									@pResult			=	@pResult			OUTPUT,
									@pErrorMessage		=	@pErrorMessage		OUTPUT,
									@pErrorSeverity		=	@pErrorSeverity		OUTPUT,
									@pErrorState		=	@pErrorState		OUTPUT'

 		EXEC sp_executesql		@ExecutionName, 					
								  N'@pResult				BIT					OUTPUT,
									@pErrorMessage			NVARCHAR(4000)		OUTPUT,
									@pErrorSeverity			INT					OUTPUT,
									@pErrorState			INT					OUTPUT',

									@pResult			=	@vResult			OUTPUT,
									@pErrorMessage		=	@vErrorMessage		OUTPUT,
									@pErrorSeverity		=	@vErrorSeverity		OUTPUT,
									@pErrorState		=	@vErrorState		OUTPUT;

		IF @vResult = 0
		BEGIN
			INSERT INTO @vErrorList (ProcedureName, ErrorMessage, ErrorSeverity, ErrorState)
							  VALUES(@ProcedureName, @vErrorMessage, @vErrorSeverity, @vErrorState)
		END

		SET @vResult			= NULL
		SET @vErrorMessage		= NULL
		SET @vErrorSeverity		= NULL
		SET @vErrorState		= NULL

		FETCH NEXT FROM Cursor_RunFacts INTO @ProcedureName
	END
	 
	CLOSE Cursor_RunFacts;
	DEALLOCATE Cursor_RunFacts;
	
	SET @ErrorList = CURSOR LOCAL FORWARD_ONLY STATIC FOR
	SELECT * FROM @vErrorList

	OPEN @ErrorList
END
