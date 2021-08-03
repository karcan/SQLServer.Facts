USE [KARCAN_DEV]
GO
/****** Object:  StoredProcedure [dbo].[SP_Update_Fact]    Script Date: 3.08.2021 21:18:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC  [dbo].[SP_Update_Fact]
	@pResult BIT OUTPUT,
	@pErrorMessage NVARCHAR(4000) OUTPUT,
	@pErrorSeverity INT OUTPUT,
	@pErrorState INT OUTPUT
AS
BEGIN
	SET @pResult = 1

	SET NOCOUNT , XACT_ABORT ON;
	BEGIN TRY
		BEGIN TRANSACTION Fact;

		/* CODE BLOCK */
			SELECT 1 / 0
		/* CODE BLOCK */

		ROLLBACK TRANSACTION Fact;
	END TRY
	BEGIN CATCH
		SELECT @pErrorMessage = ERROR_MESSAGE(),  
        @pErrorSeverity = ERROR_SEVERITY(),  
        @pErrorState = ERROR_STATE();  

		IF @@TRANCOUNT > 0
		BEGIN
			SET @pResult = 0;
			ROLLBACK TRANSACTION Fact;
		END;

		RETURN;
	END CATCH;
	SET NOCOUNT , XACT_ABORT OFF;

	RETURN;
END
