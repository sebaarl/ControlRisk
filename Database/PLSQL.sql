/****** Object:  CreateTRIGGER [dbo].[TRG_ACTIVIDAD_ASESORIA]    Script Date: 18-10-2022 0:35:19 ******/
CREATE OR ALTER TRIGGER [dbo].[TRG_ACTIVIDAD_ASESORIA] ON [Asesoria]
AFTER INSERT
AS
BEGIN
	DECLARE @tipo NVARCHAR(59) = 'Asesoria'
	DECLARE @fechacreacion DATETIME
	DECLARE @estado BIT
	DECLARE @id INT
	DECLARE @empleado NVARCHAR(12)
	DECLARE @contrato INT

	SELECT @fechacreacion = FechaCreado FROM inserted
	SELECT @estado = Estado FROM inserted
	SELECT @id = AsesoriaID FROM inserted
	SELECT @contrato = ContratoID FROM inserted

	SELECT @empleado = RutEmpleado FROM Contrato WHERE ContratoID = @contrato AND Estado = 1

	BEGIN TRY
		INSERT INTO HistorialActividad (TipoActividad, FechaCreacion, Estado, RutEmpleado, AsesoriaID)
		VALUES (@tipo, @fechacreacion, @estado, @empleado, @id)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento TRG_ACTIVIDAD_ASESORIA' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  CreateTRIGGER [dbo].[TRG_VALOR_ASESORIA_ESPECIAL]    Script Date: 18-10-2022 0:35:19 ******/
CREATE OR ALTER TRIGGER [dbo].[TRG_VALOR_ASESORIA_ESPECIAL] ON [Asesoria]
AFTER INSERT
AS
BEGIN
	DECLARE @contrato INT
	DECLARE @fecha DATE
	DECLARE @inicio DATE
	DECLARE @fechapago DATE
	DECLARE @id INT
	DECLARE @asesoriaextra BIT
	DECLARE @total MONEY
	DECLARE @valorasesoria MONEY
	DECLARE @valorpago MONEY
	DECLARE @valorextra MONEY

	SELECT @contrato = ContratoID FROM inserted
	SELECT @fecha = CAST(FechaAsesoria AS DATE) FROM inserted
	SELECT @asesoriaextra = Extra FROM inserted
	SELECT @valorasesoria = Valor FROM ValorExtra WHERE Nombre = 'Asesoria' 

	DECLARE Pagos CURSOR FOR SELECT CAST(Pagos.FechaPago AS DATE), CAST(DATEADD(MONTH, -1,Pagos.FechaPago) AS DATE),
							PagosID, ValorCuota, MontoExtra
							FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID) 
							WHERE Pagos.ContratoID = @contrato AND Contrato.Estado = 1
	
	OPEN Pagos
	FETCH Pagos INTO @fechapago, @inicio, @id, @valorpago, @valorextra

	SET @total = @valorpago + @valorextra

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @asesoriaextra = 1
		BEGIN
			SET @total = @total + @valorasesoria
			IF @fecha BETWEEN @inicio AND @fechapago
			BEGIN
				BEGIN TRY
					UPDATE Pagos
					SET MontoExtra = @total
					WHERE PagosID = @id
				END TRY
				BEGIN CATCH
					DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

					INSERT INTO Error (MensajeError, Descripcion)
					VALUES ('Error en el procedimiento TRG_VALOR_ASESORIA_ESPECIAL' + GETDATE(), @mensaje)
				END CATCH
			END
		END
		FETCH Pagos INTO @fechapago, @inicio, @id, @valorpago, @valorextra
	END
	CLOSE Pagos
	DEALLOCATE Pagos 
END
GO


/****** Object:  CreateTRIGGER [dbo]-[TRG_GENERAR_ASESORIAS]    Script Date: 18-10-2022 0:35:19 ******/
CREATE OR ALTER TRIGGER [dbo]-[TRG_GENERAR_ASESORIAS] ON [Contrato]
AFTER INSERT
AS
BEGIN
	DECLARE @cantidad INT
	DECLARE @cliente NVARCHAR(12)
	DECLARE @empleado NVARCHAR(12)
	DECLARE @empresa NVARCHAR(50)
	DECLARE @id INT
	DECLARE @n INT = 1
	DECLARE @fecha DATETIME

	SELECT @cantidad = CantidadAsesorias FROM inserted
	SELECT @cliente = RutCliente FROM inserted
	SELECT @empleado = RutEmpleado FROM inserted
	SELECT @id = ContratoID FROM inserted
	SELECT @fecha = CAST(FechaCreacion AS DATETIME) FROM inserted

	SELECT @empresa = RazonSocial FROM Cliente WHERE RutCliente = @cliente

	WHILE @n <= @cantidad
	BEGIN
		BEGIN TRY
			INSERT INTO Asesoria (FechaCreado, DescripcionAsesoria, Estado, ContratoID, Extra)
			VALUES (@fecha, 'ASESORIA GENERADA ' + CAST(@fecha AS NVARCHAR) + ' PARA CLIENTE ' + @cliente + ' - ' + @empresa, 1, @id, 0)
		END TRY
		BEGIN CATCH
			DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

			INSERT INTO Error (MensajeError, Descripcion)
			VALUES ('Error en el TRG_GENERAR_ASESORIAS' + GETDATE(), @mensaje)
		END CATCH
		SET @n = @n + 1
	END
END
GO
 

/****** Object:  CreateTRIGGER [dbo].[TRG_ESTADO_ACTIVIDAD_ASESORIA]    Script Date: 18-10-2022 0:35:19 ******/
CREATE OR ALTER TRIGGER [dbo].[TRG_ESTADO_ACTIVIDAD_ASESORIA] ON [Asesoria]
FOR UPDATE
AS
BEGIN
	DECLARE @estado NVARCHAR(20)
	DECLARE @id INT

	SELECT @id = AsesoriaID FROM inserted
	SELECT @estado = Estado FROM inserted

	BEGIN TRY
		UPDATE HistorialActividad 
		SET Estado = @estado
		WHERE AsesoriaID = @id
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()
		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento TRG_ESTADO_ACTIVIDAD_ASESORIA' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  Trigger [dbo].[TRG_GENERAR_VISITAS]    Script Date: 18-10-2022 22:25:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER TRIGGER [dbo].[TRG_GENERAR_VISITAS] ON [dbo].[Contrato]
AFTER INSERT
AS
BEGIN
	DECLARE @cantidad INT = 2
	DECLARE @cliente NVARCHAR(12)
	DECLARE @empleado NVARCHAR(12)
	DECLARE @empresa NVARCHAR(50)
	DECLARE @id INT
	DECLARE @n INT = 1
	DECLARE @fecha DATETIME

	SELECT @cantidad = CantidadAsesorias FROM inserted
	SELECT @cliente = RutCliente FROM inserted
	SELECT @empleado = RutEmpleado FROM inserted
	SELECT @id = ContratoID FROM inserted
	SELECT @fecha = CAST(FechaCreacion AS DATETIME) FROM inserted

	SELECT @empresa = RazonSocial FROM Cliente WHERE RutCliente = @cliente

	WHILE @n <= @cantidad
	BEGIN
		BEGIN TRY
			INSERT INTO Visita(FechaCreacion, Estado, ContratoID, Extra)
			VALUES (@fecha, 'SIN REALIZAR', @id, 0)
		END TRY
		BEGIN CATCH
			DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

			INSERT INTO Error (MensajeError, Descripcion)
			VALUES ('Error en el TRG_GENERAR_ASESORIAS' + GETDATE(), @mensaje)
		END CATCH
		SET @n = @n + 1
	END
END


/****** Object:  Trigger [dbo].[TRG_ACTIVIDAD_VISITA]    Script Date: 18-10-2022 22:25:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER TRIGGER [dbo].[TRG_ACTIVIDAD_VISITA] ON [dbo].[Visita]
AFTER INSERT
AS
BEGIN
	DECLARE @tipo NVARCHAR(59) = 'Visita'
	DECLARE @fechacreacion DATETIME
	DECLARE @estado BIT
	DECLARE @id INT
	DECLARE @empleado NVARCHAR(12)
	DECLARE @contrato INT

	SELECT @fechacreacion = FechaCreacion FROM inserted
	SELECT @estado = Estado FROM inserted
	SELECT @id = VisitaID FROM inserted
	SELECT @contrato = ContratoID FROM inserted

	SELECT @empleado = RutEmpleado FROM Contrato WHERE ContratoID = @contrato AND Estado = 1

	BEGIN TRY
		INSERT INTO HistorialActividad (TipoActividad, FechaCreacion, Estado, RutEmpleado, AsesoriaID)
		VALUES (@tipo, @fechacreacion, @estado, @empleado, @id)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento TRG_ACTIVIDAD_VISITA' + GETDATE(), @mensaje)
	END CATCH
END


/****** Object:  Trigger [dbo].[TRG_ESTADO_ACTIVIDAD_VISITA]    Script Date: 18-10-2022 22:41:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER TRIGGER [dbo].[TRG_ESTADO_ACTIVIDAD_VISITA] ON [dbo].[Visita]
FOR UPDATE
AS
BEGIN
	DECLARE @estado NVARCHAR(20)
	DECLARE @id INT

	SELECT @id = VisitaID FROM inserted
	SELECT @estado = Estado FROM inserted

	BEGIN TRY
		UPDATE HistorialActividad 
		SET Estado = @estado
		WHERE VisitaID = @id
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()
		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento TRG_ESTADO_ACTIVIDAD_VISITA' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  Trigger [dbo].[TRG_VALOR_VISITA_ESPECIAL]    Script Date: 18-10-2022 22:41:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_VALOR_VISITA_ESPECIAL] ON [dbo].[Visita]
AFTER INSERT
AS
BEGIN
	DECLARE @contrato INT
	DECLARE @fecha DATE
	DECLARE @inicio DATE
	DECLARE @fechapago DATE
	DECLARE @id INT
	DECLARE @visitaextra BIT
	DECLARE @total MONEY
	DECLARE @valorvisita MONEY
	DECLARE @valorpago MONEY
	DECLARE @valorextra MONEY

	SELECT @contrato = ContratoID FROM inserted
	SELECT @fecha = CAST(FechaVisita AS DATE) FROM inserted
	SELECT @visitaextra = Extra FROM inserted
	SELECT @valorvisita = Valor FROM ValorExtra WHERE Nombre = 'Visita' 

	DECLARE Pagos CURSOR FOR SELECT CAST(Pagos.FechaPago AS DATE), CAST(DATEADD(MONTH, -1,Pagos.FechaPago) AS DATE),
							PagosID, ValorCuota, MontoExtra
							FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID) 
							WHERE Pagos.ContratoID = @contrato AND Contrato.Estado = 1
	
	OPEN Pagos
	FETCH Pagos INTO @fechapago, @inicio, @id, @valorpago, @valorextra

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @total = @valorextra + @valorvisita
		IF @visitaextra = 1
		BEGIN
			IF @fecha BETWEEN @inicio AND @fechapago
			BEGIN
				BEGIN TRY
					UPDATE Pagos
					SET MontoExtra = @total
					WHERE PagosID = @id
				END TRY
				BEGIN CATCH
					DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

					INSERT INTO Error (MensajeError, Descripcion)
					VALUES ('Error en el procedimiento TRG_VALOR_VISITA_ESPECIAL' + GETDATE(), @mensaje)
				END CATCH
			END
		END
		FETCH Pagos INTO @fechapago, @inicio, @id, @valorpago, @valorextra
	END
	CLOSE Pagos
	DEALLOCATE Pagos 
END
GO


/****** Object:  UserDefinedFunction [dbo].[FN_CONTRATO_ACTIVO]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_CONTRATO_ACTIVO] (@rut NVARCHAR(12))
RETURNS INT
AS
BEGIN
	DECLARE @contrato INT
	SELECT @contrato = COUNT(ContratoID) FROM Contrato WHERE RutCliente = @rut AND Estado = 1

	RETURN @contrato
END
GO


/****** Object:  UserDefinedFunction [dbo].[FN_COUNT_ACTIVIDAD_EMP]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_COUNT_ACTIVIDAD_EMP] (@rut NVARCHAR(12))
RETURNS INT
AS
BEGIN
	DECLARE @cantidad INT 
	SELECT @cantidad = COUNT(HistorialActividad.HistorialActividadID)
	FROM HistorialActividad JOIN Asesoria ON (HistorialActividad.AsesoriaID = Asesoria.AsesoriaID)
	WHERE HistorialActividad.RutEmpleado = @rut AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Asesoria.FechaAsesoria)) * -1, 
		CONVERT(DATETIME, Asesoria.FechaAsesoria)) + 1, CONVERT(DATETIME, Asesoria.FechaAsesoria)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1 
	RETURN @cantidad
END
GO


/****** Object:  UserDefinedFunction [dbo].[FN_FormatearRut]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_FormatearRut](@Rut VARCHAR(12))
RETURNS VARCHAR(12)
AS
BEGIN
	DECLARE @cont INT = 0;
	DECLARE @i INT = 0;
	DECLARE @nuevo_rut VARCHAR(12);
	
	SET @Rut = SUBSTRING(@Rut, PATINDEX('%[^0]%', @Rut+'.'), LEN(@Rut));
	
	IF (LEN(@Rut) = 0)
	BEGIN
		RETURN '';
	END
	ELSE
	BEGIN
		SET @Rut = REPLACE(@Rut,'.', '');
		SET @Rut = REPLACE(@Rut, '-', '');
		
		SET @nuevo_rut = '-' + RIGHT(@Rut,1);
		
		SET @i = LEN(@Rut);
		
		WHILE(@i >= 2)
		BEGIN
			SET @i = @i - 1;
			SET @nuevo_rut = SUBSTRING(@rut,@i, 1) + @nuevo_rut;
			SET @cont = @cont + 1;
			
			IF(@cont = 3 AND @i <> 0)
			BEGIN
				SET @nuevo_rut = '.' + @nuevo_rut;
				SET @cont = 0;
			END
		END;
	END;
	RETURN (@nuevo_rut)
END
GO


/****** Object:  UserDefinedFunction [dbo].[FN_GET_ID]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_GET_ID] (@rut NVARCHAR(12))
RETURNS INT
AS
BEGIN
	DECLARE @id INT
	SELECT @id = ContratoID FROM Contrato WHERE RutCliente = @rut AND Estado = 1
	RETURN @id
END
GO


/****** Object:  UserDefinedFunction [dbo].[FN_TASA_ACCIDENTABILIDAD]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_TASA_ACCIDENTABILIDAD] (@rut NVARCHAR(12), @periodo DATE)
RETURNS DECIMAL(3,2)
AS
BEGIN
	DECLARE @resultado INT
	DECLARE @tasa DECIMAL(3,2) 
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)

	SELECT @tasa = COUNT(AccidenteID)*100/CantidadTrabajadores 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE Cliente.RutCliente = @rut 
		AND CONVERT(NVARCHAR, Accidente.Fecha,23) BETWEEN  DATEADD(DAY, 1, EOMONTH(@periodo, -1)) AND EOMONTH(@periodo)
	GROUP BY CantidadTrabajadores
	RETURN @tasa
END
GO


/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ACTIVIDAD_EMPLEADO] (@rut NVARCHAR(12)) 
AS
BEGIN
	SELECT HistorialActividadID, TipoActividad, ISNULL(CAST(CONVERT(NVARCHAR, FechaAsesoria, 110) AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(SUBSTRING(CAST(CONVERT(NVARCHAR, Hora, 8) AS NVARCHAR), 0, 6), 'SIN ASIGNAR'), 
		HistorialActividad.Estado, Empleado.RutEmpleado, HistorialActividad.AsesoriaID,
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente)
	FROM HistorialActividad JOIN Empleado ON (HistorialActividad.RutEmpleado = Empleado.RutEmpleado)
		JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN Asesoria ON (HistorialActividad.AsesoriaID = Asesoria.AsesoriaID)
	WHERE HistorialActividad.RutEmpleado = @rut 
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,FechaAsesoria)) * -1, 
		CONVERT(DATETIME, FechaAsesoria)) + 1, CONVERT(DATETIME, FechaAsesoria)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1 
END
GO


/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO_CAPACITACION]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_ACTIVIDAD_EMPLEADO_CAPACITACION] (@rut NVARCHAR(12)) 
AS
BEGIN
	SELECT HistorialActividadID, TipoActividad, Capacitacion.FechaCapacitacion, 
		HistorialActividad.Estado, Empleado.RutEmpleado, HistorialActividad.CapacitacionID,
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente)
	FROM HistorialActividad JOIN Empleado ON (HistorialActividad.RutEmpleado = Empleado.RutEmpleado)
		JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN Capacitacion ON (HistorialActividad.CapacitacionID = Capacitacion.CapacitacionID)
	WHERE HistorialActividad.RutEmpleado = @rut 
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Capacitacion.FechaCapacitacion)) * -1, 
		CONVERT(DATETIME, Capacitacion.FechaCapacitacion)) + 1, CONVERT(DATETIME, Capacitacion.FechaCapacitacion)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1
END
GO


/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO_VISITA]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ACTIVIDAD_EMPLEADO_VISITA] (@rut NVARCHAR(12)) 
AS
BEGIN
	SELECT HistorialActividadID, TipoActividad, Visita.FechaVisita, 
		HistorialActividad.Estado, Empleado.RutEmpleado, HistorialActividad.VisitaID,
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente)
	FROM HistorialActividad JOIN Empleado ON (HistorialActividad.RutEmpleado = Empleado.RutEmpleado)
		JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN Visita ON (HistorialActividad.VisitaID = Visita.VisitaID)
	WHERE HistorialActividad.RutEmpleado = @rut 
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Visita.FechaVisita)) * -1, 
		CONVERT(DATETIME, Visita.FechaVisita)) + 1, CONVERT(DATETIME, Visita.FechaVisita)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1
END
GO


/****** Object:  StoredProcedure [dbo].[SP_ASESORIA_ESPECIAL]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ASESORIA_ESPECIAL] 
	(@fecha DATE, @desc NVARCHAR(500), @hora TIME, @rut NVARCHAR(12))
AS
BEGIN
	DECLARE @id INT

	SELECT @id = ContratoID FROM Contrato WHERE RutCliente = @rut AND Estado = 1

	BEGIN TRY
		INSERT INTO Asesoria (FechaCreado, FechaAsesoria, DescripcionAsesoria, Estado, ContratoID, Hora, Extra)
		VALUES (GETDATE(), @fecha, @desc, 1, @id, @hora, 1)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_ASESORIA_ESPECIAL' + GETDATE(), @mensaje)
	END CATCH 
END
GO


/****** Object:  StoredProcedure [dbo].[SP_ASESORIAS_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ASESORIAS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Asesoria.AsesoriaID, ISNULL(CAST(FechaAsesoria AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Asesoria.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Asesoria JOIN HistorialActividad ON (Asesoria.AsesoriaID = HistorialActividad.AsesoriaID)
		JOIN Empleado ON (Empleado.RutEmpleado = HistorialActividad.RutEmpleado)
	WHERE ContratoID =  dbo.FN_GET_ID(@rut)
	ORDER BY Extra ASC	
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CAMBIAR_ESTADO_ASESORIA]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CAMBIAR_ESTADO_ASESORIA] (@estado NVARCHAR(20), @id INT)
AS
BEGIN
	BEGIN TRY
		UPDATE Asesoria 
		SET Estado = @estado
		WHERE AsesoriaID = @id
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()
		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CAMBIAR_ESTADO_ASESORIA' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CONTRACT_DETAIL]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CONTRACT_DETAIL] (@id NVARCHAR(100))
AS
BEGIN
	SELECT CAST(ContratoID as NVARCHAR) ContratoID, 
		CAST(dbo.Fn_FormatearRut(Cliente.RutCliente) AS NVARCHAR) ClienteRut, 
		CAST(dbo.Fn_FormatearRut(Empleado.RutEmpleado) AS NVARCHAR) EmpeladoRut, 
		CAST(CantidadAsesorias AS NVARCHAR) CantidadAsesorias, 
		CAST(CantidadCapacitaciones AS NVARCHAR) CantidadCapacitaciones, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato, 
		CAST(Pagado AS NVARCHAR), 
		CAST(CuotasContrato AS NVARCHAR) Cuotas, 
		CAST(UPPER(FechaCreacion) AS NVARCHAR) Creación, 
		CAST(UPPER(FechaPago) AS NVARCHAR) PrimerPago,  
		CAST(UPPER(FechaTermino) AS NVARCHAR) Termino, 
		CAST(UPPER(RazonSocial) AS NVARCHAR) RazónSocial, 
		CAST(UPPER(Direccion) AS NVARCHAR) Dirección, 
		CAST(UPPER(Representante) AS NVARCHAR) RepresentanteLegal, 
		CAST('+ 59 22 ' + CAST(Telefono AS NVARCHAR) AS NVARCHAR ) Telefono, 
		CAST(UPPER(RubroEmpresa.Nombre) AS NVARCHAR) RubroEmpresa, 
		CAST(UPPER(Empleado.Nombre + ' ' + Apellido) AS NVARCHAR) NombreEmpleado, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato/12  AS MONEY), 1))AS NVARCHAR) ValorMensual, 
		CAST(Contrato.Estado AS NVARCHAR)
	FROM Contrato JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE CAST(ContratoID AS NVARCHAR) = CAST(@id AS NVARCHAR)
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CONTRATO_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_CONTRATO_CLIENTE]
AS
BEGIN
	SELECT ContratoID , dbo.Fn_FormatearRut(Cliente.RutCliente) Cliente, dbo.Fn_FormatearRut(Empleado.RutEmpleado) Empelado, 
		CantidadAsesorias, CantidadCapacitaciones, 
		'$' + CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ValorContrato  AS MONEY), 1)) ValorContrato, 
		Pagado, CuotasContrato, UPPER(FechaCreacion), UPPER(FechaPago), UPPER(FechaTermino), 
		UPPER(RazonSocial), UPPER(Direccion), UPPER(Representante), 
		'+ 59 22 ' + CAST(Telefono AS NVARCHAR) Telefono, UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Apellido), 
		UPPER(RazonSocial), Contrato.Estado
	FROM Contrato JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CREATE_ACCIDENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CREATE_ACCIDENTE]
	(@fech DATETIME, @des NVARCHAR(500), @medidas NVARCHAR(500), @rut NVARCHAR(12))
AS
BEGIN
	DECLARE @id INT
	SELECT @id = ContratoID FROM Contrato WHERE RutCliente = @rut AND Estado = 1
	BEGIN TRY  
		INSERT INTO Accidente(Fecha,Descripcion,Medidas,ContratoID)
		VALUES(@fech, @des, @medidas, @id)	
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CREATE_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CREATE_CLIENTE]
	(@rut NVARCHAR(12), @razon NVARCHAR(50), @rubro INT, @direccion NVARCHAR(100),
	@telefono NVARCHAR(12), @representante NVARCHAR(50), @rutrepre NVARCHAR(12))
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Cliente (RutCliente,RazonSocial,direccion,telefono,Representante, RutRepresentante,RubroID, Estado)
		VALUES(@rut,@razon,@direccion,@telefono,@representante, @rutrepre, @rubro, 1)	
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()
		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_CLIENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CREATE_CONTRATO]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_CREATE_CONTRATO]
	(@asesorias INT, @capacitaciones INT, @fechaterm DATETIME, @fechapago DATE,
	@cuotas INT, @valor INT, @cliente NVARCHAR(12), @empleado NVARCHAR(12), @fecha DATETIME)
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Contrato(CantidadAsesorias,CantidadCapacitaciones,FechaCreacion,FechaTermino,FechaPago,
			CuotasContrato,ValorContrato,Pagado, Estado,RutCliente,RutEmpleado)
		VALUES (@asesorias,@capacitaciones,@fecha,@fechaterm,@fechapago, @cuotas,@valor,0,1,@cliente,@empleado)
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_CONTRATO' + GETDATE(), @mensaje)

	END CATCH
END
GO


/****** Object:  StoredProcedure [dbo].[SP_CREATE_EMPLEADO]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_CREATE_EMPLEADO]
	(@rut NVARCHAR(12), @nombre NVARCHAR(50), @apellido NVARCHAR(50), @cargo NVARCHAR(50))
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Empleado(RutEmpleado,Nombre,Apellido,Cargo, Estado)
		VALUES(@rut, @nombre, @apellido, @cargo, 1)
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_EMPLEADO' + GETDATE(), @mensaje)
	END CATCH
END
GO


/****** Object:  StoredProcedure [dbo].[SP_DETALLE_ASESORIA]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_ASESORIA] (@id INT)
AS
BEGIN
	SELECT AsesoriaID, ISNULL(CAST(FechaAsesoria AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		UPPER(DescripcionAsesoria), Asesoria.Estado, Extra,
		dbo.FN_FormatearRut(Cliente.RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono,
		UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Empleado.Apellido)
	FROM Asesoria JOIN Contrato ON (Asesoria.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE AsesoriaID = @id AND Contrato.Estado = 1
END
GO


/****** Object:  StoredProcedure [dbo].[SP_DETALLE_VISITA]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_VISITA] (@id INT)
AS
BEGIN
	SELECT VisitaID, ISNULL(CAST(FechaVisita AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), Visita.Estado, Extra,
		dbo.FN_FormatearRut(Cliente.RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono,
		UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Empleado.Apellido)
	FROM Visita JOIN Contrato ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE VisitaID = @id AND Contrato.Estado = 1
END
GO


/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CLIENTES]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_LISTAR_CLIENTES]
AS
BEGIN
	SELECT dbo.Fn_FormatearRut(RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono, 
		UPPER(Representante),UPPER(RubroEmpresa.Nombre), dbo.Fn_FormatearRut(RutRepresentante) 
	FROM Cliente JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
END
GO


/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CAST(ContratoID as NVARCHAR) ContratoID, 
		CAST(dbo.Fn_FormatearRut(Cliente.RutCliente) AS NVARCHAR) ClienteRut, 
		CAST(dbo.Fn_FormatearRut(Empleado.RutEmpleado) AS NVARCHAR) EmpeladoRut, 
		CAST(CantidadAsesorias AS NVARCHAR) CantidadAsesorias, 
		CAST(CantidadCapacitaciones AS NVARCHAR) CantidadCapacitaciones, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato, 
		CAST(Pagado AS NVARCHAR), 
		CAST(CuotasContrato AS NVARCHAR) Cuotas, 
		CAST(UPPER(CONVERT(NVARCHAR, Contrato.FechaCreacion, 106)) AS NVARCHAR) as Creacion,
		CAST(UPPER(FechaPago) AS NVARCHAR) PrimerPago,  
		CAST(UPPER(CONVERT(NVARCHAR, Contrato.FechaTermino, 106)) AS NVARCHAR) as Termino,
		CAST(UPPER(RazonSocial) AS NVARCHAR) RazónSocial, 
		CAST(UPPER(Direccion) AS NVARCHAR) Dirección, 
		CAST(UPPER(Representante) AS NVARCHAR) RepresentanteLegal, 
		CAST('+ 59 22 ' + CAST(Telefono AS NVARCHAR) AS NVARCHAR ) Telefono, 
		CAST(UPPER(RubroEmpresa.Nombre) AS NVARCHAR) RubroEmpresa, 
		CAST(UPPER(Empleado.Nombre + ' ' + Apellido) AS NVARCHAR) NombreEmpleado, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato/12  AS MONEY), 1))AS NVARCHAR) ValorMensual, 
		CAST(Contrato.Estado AS NVARCHAR),
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR),
		CAST(Cliente.RutCliente AS NVARCHAR) RutCliente
	FROM Contrato JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE Cliente.RutCliente = @rut
	ORDER BY Contrato.FechaCreacion DESC
END
GO


/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CAST(ContratoID as NVARCHAR) ContratoID, 
		CAST(dbo.Fn_FormatearRut(Cliente.RutCliente) AS NVARCHAR) ClienteRut, 
		CAST(dbo.Fn_FormatearRut(Empleado.RutEmpleado) AS NVARCHAR) EmpeladoRut, 
		CAST(CantidadAsesorias AS NVARCHAR) CantidadAsesorias, 
		CAST(CantidadCapacitaciones AS NVARCHAR) CantidadCapacitaciones, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato, 
		CAST(Pagado AS NVARCHAR), 
		CAST(CuotasContrato AS NVARCHAR) Cuotas, 
		CAST(UPPER(CONVERT(NVARCHAR, Contrato.FechaCreacion, 106)) AS NVARCHAR) as Creacion,
		CAST(UPPER(FechaPago) AS NVARCHAR) PrimerPago,  
		CAST(UPPER(CONVERT(NVARCHAR, Contrato.FechaTermino, 106)) AS NVARCHAR) as Termino,
		CAST(UPPER(RazonSocial) AS NVARCHAR) RazónSocial, 
		CAST(UPPER(Direccion) AS NVARCHAR) Dirección, 
		CAST(UPPER(Representante) AS NVARCHAR) RepresentanteLegal, 
		CAST('+ 59 22 ' + CAST(Telefono AS NVARCHAR) AS NVARCHAR ) Telefono, 
		CAST(UPPER(RubroEmpresa.Nombre) AS NVARCHAR) RubroEmpresa, 
		CAST(UPPER(Empleado.Nombre + ' ' + Apellido) AS NVARCHAR) NombreEmpleado, 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato/12  AS MONEY), 1))AS NVARCHAR) ValorMensual, 
		CAST(Contrato.Estado AS NVARCHAR),
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR)
	FROM Contrato JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE Contrato.RutEmpleado = @rut
END
GO


/****** Object:  StoredProcedure [dbo].[SP_LISTAR_EMPELADOS]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_LISTAR_EMPELADOS]
AS
BEGIN
	SELECT * FROM Empleado
END
GO


/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_PAGOS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), CAST(Pagos.FechaPago AS DATE), CAST(FechaVencimiento AS DATE), 
	CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato,
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorCuota  AS MONEY), 1))AS NVARCHAR) ValorCuota, Pagos.Estado
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE Cliente.RutCliente = @rut
END
GO


/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CONTRATO]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [dbo].[SP_PAGOS_CONTRATO] (@id NVARCHAR(100))
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), 
	CAST(Pagos.FechaPago AS DATE), 
	CAST(FechaVencimiento AS DATE), 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato,
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorCuota  AS MONEY), 1))AS NVARCHAR) ValorCuota, Pagos.Estado,
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR), Contrato.RutCliente, CAST(Pagos.ContratoID AS nvarchar),
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(MontoExtra  AS MONEY), 1))AS NVARCHAR) MontoExtra
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE CAST(Contrato.ContratoID AS NVARCHAR) = @id
END
GO


/****** Object:  StoredProcedure [dbo].[SP_VISITAS_CLIENTE]    Script Date: 19-10-2022 18:41:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_VISITAS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Visita.VisitaID, ISNULL(CAST(Visita.FechaVisita AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Visita.Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Visita.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Visita JOIN Contrato ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE Contrato.ContratoID = dbo.FN_GET_ID(@rut)
	ORDER BY Extra ASC	
END
GO