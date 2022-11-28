USE [master]
GO
/****** Object:  Database [AccidentesDB]    Script Date: 27-11-2022 22:05:16 ******/
CREATE DATABASE [AccidentesDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AccidentesDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AccidentesDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AccidentesDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AccidentesDB_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [AccidentesDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AccidentesDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AccidentesDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AccidentesDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AccidentesDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AccidentesDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AccidentesDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [AccidentesDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AccidentesDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AccidentesDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AccidentesDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AccidentesDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AccidentesDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AccidentesDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AccidentesDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AccidentesDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AccidentesDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [AccidentesDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AccidentesDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AccidentesDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AccidentesDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AccidentesDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AccidentesDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AccidentesDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AccidentesDB] SET RECOVERY FULL 
GO
ALTER DATABASE [AccidentesDB] SET  MULTI_USER 
GO
ALTER DATABASE [AccidentesDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AccidentesDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AccidentesDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AccidentesDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AccidentesDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [AccidentesDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'AccidentesDB', N'ON'
GO
ALTER DATABASE [AccidentesDB] SET QUERY_STORE = OFF
GO
USE [AccidentesDB]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_ACCIDENTES_PERIODO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   FUNCTION [dbo].[FN_ACCIDENTES_PERIODO] (@id INT, @periodo NVARCHAR(12))
RETURNS INT
AS
BEGIN
	DECLARE @c INT
	SELECT @c = COUNT(AccidenteID) FROM Accidente WHERE CONVERT(NVARCHAR, FORMAT(Fecha, 'yyyy-MM')) = @periodo
	RETURN @c
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_CONTRATO_ACTIVO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_CONTRATO_ACTIVO] (@rut NVARCHAR(12))
RETURNS INT
BEGIN
	DECLARE @activo INT
	SELECT @activo = ContratoID 
	FROM Contrato 
	WHERE Estado = 1 
	AND SUBSTRING(Contrato.RutCliente, 0, len(Contrato.RutCliente)-0) = @rut
	RETURN @activo
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_COUNT_ACTIVIDAD_EMP]    Script Date: 27-11-2022 22:05:16 ******/
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
	WHERE SUBSTRING(HistorialActividad.RutEmpleado, 0, len(HistorialActividad.RutEmpleado)-0) = @rut AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Asesoria.FechaAsesoria)) * -1, 
		CONVERT(DATETIME, Asesoria.FechaAsesoria)) + 1, CONVERT(DATETIME, Asesoria.FechaAsesoria)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1 
	RETURN @cantidad
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_FINAL_MES_PAGO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_FINAL_MES_PAGO] (@id INT)
RETURNS DATE
AS
BEGIN
	DECLARE @final DATE
	SELECT @final = CONVERT(DATE, FechaPago, 23) FROM Pagos WHERE PagosID = @id
	RETURN @final
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_FormatearRut]    Script Date: 27-11-2022 22:05:16 ******/
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
/****** Object:  UserDefinedFunction [dbo].[FN_GET_ID]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_GET_ID] (@rut NVARCHAR(12))
RETURNS INT
AS
BEGIN
	DECLARE @id INT
	SELECT @id = ContratoID 
	FROM Contrato 
	WHERE CONVERT(NVARCHAR, SUBSTRING(RutCliente, 0, len(RutCliente)-0)) = @rut AND Estado = 1
	RETURN @id
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GET_PAGO_ATRASADO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_GET_PAGO_ATRASADO] (@rut VARCHAR(12))
RETURNS BIT
AS
BEGIN
	DECLARE @estado BIT
	DECLARE @fechaPago DATETIME
	DECLARE @fechaVenc DATETIME
	DECLARE @pagado BIT

	SELECT @estado = Estado, @fechaPago = @fechaPago, @fechaVenc = FechaVencimiento
	FROM [Pagos]
	WHERE [ContratoID] = [dbo].[FN_GET_ID](@rut) AND MONTH(FechaPago) = MONTH(GETDATE())

	IF @fechaVenc < CONVERT(DATETIME, GETDATE())
	BEGIN
		SET @pagado = @estado
	END
	ELSE
	BEGIN
		SET @pagado = 1
	END

	RETURN @pagado
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_INICIO_MES_PAGO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_INICIO_MES_PAGO] (@id INT)
RETURNS DATE
AS
BEGIN
	DECLARE @inicio DATE
	SELECT @inicio = CONVERT(DATE, DATEADD(MONTH, -1, FechaPago), 23) FROM Pagos WHERE PagosID = @id
	RETURN @inicio
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TASA_ACCIDENTABILIDAD]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[FN_TASA_ACCIDENTABILIDAD] (@rut NVARCHAR(12), @periodo DATE)
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @resultado INT
	DECLARE @tasa DECIMAL(5,2) 
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)
	DECLARE @contrato INT

	SELECT @contrato = ContratoID 
	FROM Contrato 
	WHERE SUBSTRING(Contrato.RutCliente, 0, len(Contrato.RutCliente)-0) = @rut AND Estado = 1

	SELECT @tasa = COUNT(AccidenteID)*100/CantidadTrabajadores 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE Contrato.ContratoID = @contrato 
		AND CONVERT(NVARCHAR, Accidente.Fecha,23) BETWEEN  DATEADD(DAY, 1, EOMONTH(@periodo, -1)) AND EOMONTH(@periodo)
	GROUP BY CantidadTrabajadores
	RETURN @tasa
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TASA_ACCIDENTABILIDAD_ANUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     FUNCTION [dbo].[FN_TASA_ACCIDENTABILIDAD_ANUAL] (@id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @resultado INT
	DECLARE @tasa DECIMAL(5,2) 
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)

	SELECT @inicio = CONVERT(DATE, FechaCreacion, 23) FROM Contrato WHERE ContratoID = @id AND Estado = 1
	SELECT @final = CONVERT(DATE, FechaTermino, 23) FROM Contrato WHERE ContratoID = @id AND Estado = 1

	SELECT @tasa = COUNT(AccidenteID)*100/CantidadTrabajadores 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE Contrato.ContratoID = @id 
		AND CONVERT(DATE, Accidente.Fecha, 23) BETWEEN @inicio AND @final
	GROUP BY CantidadTrabajadores
	RETURN @tasa
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_TASA_ACCIDENTABILIDAD_MENSUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_TASA_ACCIDENTABILIDAD_MENSUAL] (@id INT, @periodo NVARCHAR(12))
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @resultado INT
	DECLARE @tasa DECIMAL(5,2) 
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)

	SELECT @tasa = COUNT(AccidenteID)*100/CantidadTrabajadores 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE Contrato.ContratoID = @id 
		AND CONVERT(NVARCHAR, FORMAT(Accidente.Fecha, 'yyyy-MM')) = @periodo
	GROUP BY CantidadTrabajadores;
	RETURN @tasa
END
GO
/****** Object:  UserDefinedFunction [dbo].[FN_VALOR_EXTRA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[FN_VALOR_EXTRA] (@tipo NVARCHAR(50))
RETURNS MONEY
AS
BEGIN
	DECLARE @valor MONEY
	SELECT @valor = Valor FROM ValorExtra WHERE Nombre = @tipo
	RETURN @valor
END
GO
/****** Object:  Table [dbo].[Accidente]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Accidente](
	[AccidenteID] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Descripcion] [nvarchar](500) NOT NULL,
	[Medidas] [nvarchar](500) NOT NULL,
	[ContratoID] [int] NULL,
 CONSTRAINT [PK_Accidente] PRIMARY KEY CLUSTERED 
(
	[AccidenteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser_user]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser_user](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[password] [nvarchar](128) NOT NULL,
	[is_superuser] [bit] NOT NULL,
	[NombreUsuario] [nvarchar](50) NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
	[Last_login] [datetime2](7) NOT NULL,
	[Is_staff] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
	[Is_Profesional] [bit] NOT NULL,
	[CorreoElectronico] [nvarchar](254) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[NombreUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser_user_groups]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser_user_groups](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[group_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser_user_user_permissions]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppUser_user_user_permissions](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [bigint] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Asesoria]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Asesoria](
	[AsesoriaID] [int] IDENTITY(1,1) NOT NULL,
	[FechaCreado] [datetime] NOT NULL,
	[FechaAsesoria] [date] NULL,
	[DescripcionAsesoria] [nvarchar](500) NOT NULL,
	[Estado] [nvarchar](20) NOT NULL,
	[ContratoID] [int] NULL,
	[Hora] [time](7) NULL,
	[Extra] [bit] NOT NULL,
 CONSTRAINT [PK_Asesoria] PRIMARY KEY CLUSTERED 
(
	[AsesoriaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AsesoriaTelefonica]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AsesoriaTelefonica](
	[AsesoriaTelefonicaID] [int] IDENTITY(1,1) NOT NULL,
	[DudaCliente] [nvarchar](250) NOT NULL,
	[RespuestaEmpleado] [nvarchar](250) NOT NULL,
	[FechaHora] [datetime] NOT NULL,
	[ContratoID] [int] NULL,
 CONSTRAINT [PK_AsesoriaTelefonica] PRIMARY KEY CLUSTERED 
(
	[AsesoriaTelefonicaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](150) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [auth_group_name_a6ea08ec_uniq] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group_permissions](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[auth_permission]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_permission](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[content_type_id] [int] NOT NULL,
	[codename] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Capacitacion]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Capacitacion](
	[CapacitacionID] [int] IDENTITY(1,1) NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaCapacitacion] [date] NULL,
	[CantidadAsistentes] [int] NOT NULL,
	[Materiales] [nvarchar](200) NULL,
	[Descripcion] [nvarchar](200) NULL,
	[Estado] [nvarchar](20) NOT NULL,
	[ContratoID] [int] NULL,
	[Extra] [bit] NOT NULL,
	[Hora] [time](7) NULL,
 CONSTRAINT [PK_Capacitacion] PRIMARY KEY CLUSTERED 
(
	[CapacitacionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Checklist]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Checklist](
	[ChecklistID] [int] IDENTITY(1,1) NOT NULL,
	[FechaChecklist] [date] NOT NULL,
	[VisitaID] [int] NOT NULL,
 CONSTRAINT [PK_Checklist] PRIMARY KEY CLUSTERED 
(
	[ChecklistID] ASC,
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cliente]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cliente](
	[RutCliente] [nvarchar](12) NOT NULL,
	[RazonSocial] [nvarchar](50) NOT NULL,
	[Direccion] [nvarchar](100) NOT NULL,
	[Telefono] [nvarchar](12) NOT NULL,
	[Representante] [nvarchar](50) NOT NULL,
	[RutRepresentante] [nvarchar](12) NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioID] [bigint] NULL,
	[RubroID] [int] NOT NULL,
	[CantidadTrabajadores] [int] NULL,
	[CorreoElectronico] [nvarchar](254) NULL,
 CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED 
(
	[RutCliente] ASC,
	[RubroID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [RutCliente] UNIQUE NONCLUSTERED 
(
	[RutCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contrato]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contrato](
	[ContratoID] [int] IDENTITY(1,1) NOT NULL,
	[CantidadAsesorias] [int] NOT NULL,
	[CantidadCapacitaciones] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaTermino] [datetime] NOT NULL,
	[FechaPago] [date] NOT NULL,
	[CuotasContrato] [int] NOT NULL,
	[ValorContrato] [money] NOT NULL,
	[Pagado] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
	[RutEmpleado] [nvarchar](12) NULL,
	[RutCliente] [nvarchar](12) NULL,
	[RubroID] [int] NULL,
 CONSTRAINT [PK_Contrato] PRIMARY KEY CLUSTERED 
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_admin_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[action_time] [datetime2](7) NOT NULL,
	[object_id] [nvarchar](max) NULL,
	[object_repr] [nvarchar](200) NOT NULL,
	[action_flag] [smallint] NOT NULL,
	[change_message] [nvarchar](max) NOT NULL,
	[content_type_id] [int] NULL,
	[user_id] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_content_type]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_content_type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app_label] [nvarchar](100) NOT NULL,
	[model] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_migrations]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_migrations](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[app] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[applied] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[django_session]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_session](
	[session_key] [nvarchar](40) NOT NULL,
	[session_data] [nvarchar](max) NOT NULL,
	[expire_date] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[session_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Empleado]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empleado](
	[RutEmpleado] [nvarchar](12) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Apellido] [nvarchar](50) NOT NULL,
	[Cargo] [nvarchar](50) NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioID] [bigint] NULL,
	[CorreoElectronico] [nvarchar](254) NULL,
 CONSTRAINT [PK_Empleado] PRIMARY KEY CLUSTERED 
(
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [Rut] UNIQUE NONCLUSTERED 
(
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Error]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Error](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[MensajeError] [nvarchar](500) NOT NULL,
	[Descripcion] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_Error] PRIMARY KEY CLUSTERED 
(
	[ErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [ErrorID] UNIQUE NONCLUSTERED 
(
	[ErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HistorialActividad]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistorialActividad](
	[HistorialActividadID] [int] IDENTITY(1,1) NOT NULL,
	[TipoActividad] [nvarchar](50) NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaRealizada] [datetime] NULL,
	[Estado] [nvarchar](20) NOT NULL,
	[RutEmpleado] [nvarchar](12) NOT NULL,
	[AsesoriaID] [int] NULL,
	[CapacitacionID] [int] NULL,
	[VisitaID] [int] NULL,
 CONSTRAINT [PK_HistorialActividad] PRIMARY KEY CLUSTERED 
(
	[HistorialActividadID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InformeVisita]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InformeVisita](
	[InformeVisitaID] [int] IDENTITY(1,1) NOT NULL,
	[Situacion] [nvarchar](500) NOT NULL,
	[Fecha] [date] NOT NULL,
	[ContratoID] [int] NOT NULL,
	[VisitaID] [int] NOT NULL,
 CONSTRAINT [PK_InformeVisita] PRIMARY KEY CLUSTERED 
(
	[InformeVisitaID] ASC,
	[VisitaID] ASC,
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ItemsChecklist]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemsChecklist](
	[ItemCheclistID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Aprobado] [bit] NULL,
	[Reprobado] [bit] NULL,
	[SemiAprobado] [bit] NULL,
	[ChecklistID] [int] NOT NULL,
	[VisitaID] [int] NOT NULL,
 CONSTRAINT [PK_ItemsChecklist] PRIMARY KEY CLUSTERED 
(
	[ItemCheclistID] ASC,
	[ChecklistID] ASC,
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Mejora]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mejora](
	[MejoraID] [int] IDENTITY(1,1) NOT NULL,
	[PlanMejora] [nvarchar](500) NOT NULL,
	[Fecha] [date] NOT NULL,
	[AplicoMejora] [bit] NOT NULL,
	[InformeVisitaID] [int] NULL,
	[VisitaID] [int] NULL,
	[ContratoID] [int] NULL,
 CONSTRAINT [PK_Mejora] PRIMARY KEY CLUSTERED 
(
	[MejoraID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pagos]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pagos](
	[PagosID] [int] IDENTITY(1,1) NOT NULL,
	[FechaPago] [datetime] NOT NULL,
	[FechaVencimiento] [datetime] NOT NULL,
	[ValorCuota] [money] NOT NULL,
	[MontoExtra] [money] NOT NULL,
	[ValorPago] [money] NOT NULL,
	[TipoPagoID] [int] NULL,
	[ContratoID] [int] NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Pagos] PRIMARY KEY CLUSTERED 
(
	[PagosID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RubroEmpresa]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RubroEmpresa](
	[RubroID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_RubroEmpresa] PRIMARY KEY CLUSTERED 
(
	[RubroID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TasaAccidente]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TasaAccidente](
	[TasaID] [int] IDENTITY(0,1) NOT NULL,
	[Tasa] [decimal](5, 2) NOT NULL,
	[ContratoID] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Periodo] [nvarchar](30) NOT NULL,
	[CantidadAccidentes] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoPagos]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoPagos](
	[TipoPagoID] [int] NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_TipoPagos] PRIMARY KEY CLUSTERED 
(
	[TipoPagoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValorExtra]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValorExtra](
	[ValorID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Valor] [money] NOT NULL,
 CONSTRAINT [PK_ValorExtra] PRIMARY KEY CLUSTERED 
(
	[ValorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Visita]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visita](
	[VisitaID] [int] IDENTITY(1,1) NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[FechaVisita] [date] NULL,
	[Estado] [nvarchar](20) NOT NULL,
	[ContratoID] [int] NULL,
	[Extra] [bit] NOT NULL,
	[Hora] [time](7) NULL,
 CONSTRAINT [PK_Visita] PRIMARY KEY CLUSTERED 
(
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship37]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship37] ON [dbo].[Accidente]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_group_id_e2ed4738]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_groups_group_id_e2ed4738] ON [dbo].[AppUser_user_groups]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_user_id_83d94a1d]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_groups_user_id_83d94a1d] ON [dbo].[AppUser_user_groups]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_user_id_group_id_e1f5f27d_uniq]    Script Date: 27-11-2022 22:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AppUser_user_groups_user_id_group_id_e1f5f27d_uniq] ON [dbo].[AppUser_user_groups]
(
	[user_id] ASC,
	[group_id] ASC
)
WHERE ([user_id] IS NOT NULL AND [group_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_permission_id_c1d03c50]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_user_permissions_permission_id_c1d03c50] ON [dbo].[AppUser_user_user_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_user_id_a4819296]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_user_permissions_user_id_a4819296] ON [dbo].[AppUser_user_user_permissions]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_user_id_permission_id_bde4c76d_uniq]    Script Date: 27-11-2022 22:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AppUser_user_user_permissions_user_id_permission_id_bde4c76d_uniq] ON [dbo].[AppUser_user_user_permissions]
(
	[user_id] ASC,
	[permission_id] ASC
)
WHERE ([user_id] IS NOT NULL AND [permission_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship49]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship49] ON [dbo].[Asesoria]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship31]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship31] ON [dbo].[AsesoriaTelefonica]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_group_id_b120cbf9]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_group_id_b120cbf9] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_group_id_permission_id_0cd325b0_uniq]    Script Date: 27-11-2022 22:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [auth_group_permissions_group_id_permission_id_0cd325b0_uniq] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC,
	[permission_id] ASC
)
WHERE ([group_id] IS NOT NULL AND [permission_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_permission_id_84c5c92e]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_permission_id_84c5c92e] ON [dbo].[auth_group_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_permission_content_type_id_2f476e4b]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [auth_permission_content_type_id_2f476e4b] ON [dbo].[auth_permission]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [auth_permission_content_type_id_codename_01ab375a_uniq]    Script Date: 27-11-2022 22:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [auth_permission_content_type_id_codename_01ab375a_uniq] ON [dbo].[auth_permission]
(
	[content_type_id] ASC,
	[codename] ASC
)
WHERE ([content_type_id] IS NOT NULL AND [codename] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship48]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship48] ON [dbo].[Capacitacion]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship10]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship10] ON [dbo].[Cliente]
(
	[UsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Relationship13]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship13] ON [dbo].[Contrato]
(
	[RutCliente] ASC,
	[RubroID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Relationship16]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship16] ON [dbo].[Contrato]
(
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_content_type_id_c4bce8eb]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_content_type_id_c4bce8eb] ON [dbo].[django_admin_log]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_user_id_c564eba6]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_user_id_c564eba6] ON [dbo].[django_admin_log]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [django_content_type_app_label_model_76bd3d3b_uniq]    Script Date: 27-11-2022 22:05:16 ******/
CREATE UNIQUE NONCLUSTERED INDEX [django_content_type_app_label_model_76bd3d3b_uniq] ON [dbo].[django_content_type]
(
	[app_label] ASC,
	[model] ASC
)
WHERE ([app_label] IS NOT NULL AND [model] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_session_expire_date_a5c62663]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [django_session_expire_date_a5c62663] ON [dbo].[django_session]
(
	[expire_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship4]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship4] ON [dbo].[Empleado]
(
	[UsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Relationship50]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship50] ON [dbo].[HistorialActividad]
(
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship53]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship53] ON [dbo].[HistorialActividad]
(
	[AsesoriaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship54]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship54] ON [dbo].[HistorialActividad]
(
	[CapacitacionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship55]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship55] ON [dbo].[HistorialActividad]
(
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship45]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship45] ON [dbo].[Mejora]
(
	[InformeVisitaID] ASC,
	[VisitaID] ASC,
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship12]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship12] ON [dbo].[Pagos]
(
	[TipoPagoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship14]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship14] ON [dbo].[Pagos]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship51]    Script Date: 27-11-2022 22:05:16 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship51] ON [dbo].[Visita]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accidente]  WITH CHECK ADD  CONSTRAINT [Relationship37] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Accidente] CHECK CONSTRAINT [Relationship37]
GO
ALTER TABLE [dbo].[AppUser_user_groups]  WITH CHECK ADD  CONSTRAINT [AppUser_user_groups_group_id_e2ed4738_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[AppUser_user_groups] CHECK CONSTRAINT [AppUser_user_groups_group_id_e2ed4738_fk_auth_group_id]
GO
ALTER TABLE [dbo].[AppUser_user_groups]  WITH CHECK ADD  CONSTRAINT [AppUser_user_groups_user_id_83d94a1d_fk_AppUser_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[AppUser_user_groups] CHECK CONSTRAINT [AppUser_user_groups_user_id_83d94a1d_fk_AppUser_user_id]
GO
ALTER TABLE [dbo].[AppUser_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [AppUser_user_user_permissions_permission_id_c1d03c50_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[AppUser_user_user_permissions] CHECK CONSTRAINT [AppUser_user_user_permissions_permission_id_c1d03c50_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[AppUser_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [AppUser_user_user_permissions_user_id_a4819296_fk_AppUser_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[AppUser_user_user_permissions] CHECK CONSTRAINT [AppUser_user_user_permissions_user_id_a4819296_fk_AppUser_user_id]
GO
ALTER TABLE [dbo].[Asesoria]  WITH CHECK ADD  CONSTRAINT [Relationship49] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Asesoria] CHECK CONSTRAINT [Relationship49]
GO
ALTER TABLE [dbo].[AsesoriaTelefonica]  WITH CHECK ADD  CONSTRAINT [Relationship31] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[AsesoriaTelefonica] CHECK CONSTRAINT [Relationship31]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_permission]  WITH CHECK ADD  CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[auth_permission] CHECK CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[Capacitacion]  WITH CHECK ADD  CONSTRAINT [Relationship48] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Capacitacion] CHECK CONSTRAINT [Relationship48]
GO
ALTER TABLE [dbo].[Checklist]  WITH CHECK ADD  CONSTRAINT [Relationship24] FOREIGN KEY([VisitaID])
REFERENCES [dbo].[Visita] ([VisitaID])
GO
ALTER TABLE [dbo].[Checklist] CHECK CONSTRAINT [Relationship24]
GO
ALTER TABLE [dbo].[Cliente]  WITH CHECK ADD  CONSTRAINT [Relationship10] FOREIGN KEY([UsuarioID])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[Cliente] CHECK CONSTRAINT [Relationship10]
GO
ALTER TABLE [dbo].[Cliente]  WITH CHECK ADD  CONSTRAINT [Relationship47] FOREIGN KEY([RubroID])
REFERENCES [dbo].[RubroEmpresa] ([RubroID])
GO
ALTER TABLE [dbo].[Cliente] CHECK CONSTRAINT [Relationship47]
GO
ALTER TABLE [dbo].[Contrato]  WITH CHECK ADD  CONSTRAINT [Relationship13] FOREIGN KEY([RutCliente], [RubroID])
REFERENCES [dbo].[Cliente] ([RutCliente], [RubroID])
GO
ALTER TABLE [dbo].[Contrato] CHECK CONSTRAINT [Relationship13]
GO
ALTER TABLE [dbo].[Contrato]  WITH CHECK ADD  CONSTRAINT [Relationship16] FOREIGN KEY([RutEmpleado])
REFERENCES [dbo].[Empleado] ([RutEmpleado])
GO
ALTER TABLE [dbo].[Contrato] CHECK CONSTRAINT [Relationship16]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_user_id_c564eba6_fk_AppUser_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_user_id_c564eba6_fk_AppUser_user_id]
GO
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [Relationship4] FOREIGN KEY([UsuarioID])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [Relationship4]
GO
ALTER TABLE [dbo].[HistorialActividad]  WITH CHECK ADD  CONSTRAINT [Relationship50] FOREIGN KEY([RutEmpleado])
REFERENCES [dbo].[Empleado] ([RutEmpleado])
GO
ALTER TABLE [dbo].[HistorialActividad] CHECK CONSTRAINT [Relationship50]
GO
ALTER TABLE [dbo].[HistorialActividad]  WITH CHECK ADD  CONSTRAINT [Relationship53] FOREIGN KEY([AsesoriaID])
REFERENCES [dbo].[Asesoria] ([AsesoriaID])
GO
ALTER TABLE [dbo].[HistorialActividad] CHECK CONSTRAINT [Relationship53]
GO
ALTER TABLE [dbo].[HistorialActividad]  WITH CHECK ADD  CONSTRAINT [Relationship54] FOREIGN KEY([CapacitacionID])
REFERENCES [dbo].[Capacitacion] ([CapacitacionID])
GO
ALTER TABLE [dbo].[HistorialActividad] CHECK CONSTRAINT [Relationship54]
GO
ALTER TABLE [dbo].[HistorialActividad]  WITH CHECK ADD  CONSTRAINT [Relationship55] FOREIGN KEY([VisitaID])
REFERENCES [dbo].[Visita] ([VisitaID])
GO
ALTER TABLE [dbo].[HistorialActividad] CHECK CONSTRAINT [Relationship55]
GO
ALTER TABLE [dbo].[InformeVisita]  WITH CHECK ADD  CONSTRAINT [Relationship30] FOREIGN KEY([VisitaID])
REFERENCES [dbo].[Visita] ([VisitaID])
GO
ALTER TABLE [dbo].[InformeVisita] CHECK CONSTRAINT [Relationship30]
GO
ALTER TABLE [dbo].[InformeVisita]  WITH CHECK ADD  CONSTRAINT [Relationship44] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[InformeVisita] CHECK CONSTRAINT [Relationship44]
GO
ALTER TABLE [dbo].[ItemsChecklist]  WITH CHECK ADD  CONSTRAINT [Relationship28] FOREIGN KEY([ChecklistID], [VisitaID])
REFERENCES [dbo].[Checklist] ([ChecklistID], [VisitaID])
GO
ALTER TABLE [dbo].[ItemsChecklist] CHECK CONSTRAINT [Relationship28]
GO
ALTER TABLE [dbo].[Mejora]  WITH CHECK ADD  CONSTRAINT [Relationship45] FOREIGN KEY([InformeVisitaID], [VisitaID], [ContratoID])
REFERENCES [dbo].[InformeVisita] ([InformeVisitaID], [VisitaID], [ContratoID])
GO
ALTER TABLE [dbo].[Mejora] CHECK CONSTRAINT [Relationship45]
GO
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [Relationship12] FOREIGN KEY([TipoPagoID])
REFERENCES [dbo].[TipoPagos] ([TipoPagoID])
GO
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [Relationship12]
GO
ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [Relationship14] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [Relationship14]
GO
ALTER TABLE [dbo].[TasaAccidente]  WITH CHECK ADD  CONSTRAINT [FK_TasaAccidente_Contrato] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[TasaAccidente] CHECK CONSTRAINT [FK_TasaAccidente_Contrato]
GO
ALTER TABLE [dbo].[Visita]  WITH CHECK ADD  CONSTRAINT [Relationship51] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Visita] CHECK CONSTRAINT [Relationship51]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO]    Script Date: 27-11-2022 22:05:16 ******/
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
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente),
		RazonSocial
	FROM HistorialActividad JOIN Empleado ON (HistorialActividad.RutEmpleado = Empleado.RutEmpleado)
		JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN Asesoria ON (HistorialActividad.AsesoriaID = Asesoria.AsesoriaID)
	WHERE SUBSTRING(HistorialActividad.RutEmpleado, 0, len(HistorialActividad.RutEmpleado)-0) = @rut
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,FechaAsesoria)) * -1, 
		CONVERT(DATETIME, FechaAsesoria)) + 1, CONVERT(DATETIME, FechaAsesoria)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1 
		AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO_CAPACITACION]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ACTIVIDAD_EMPLEADO_CAPACITACION] (@rut NVARCHAR(12)) 
AS
BEGIN
	SELECT HistorialActividadID, TipoActividad, Capacitacion.FechaCapacitacion, 
		HistorialActividad.Estado, Empleado.RutEmpleado, HistorialActividad.CapacitacionID,
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente), Hora
	FROM HistorialActividad JOIN Empleado ON (HistorialActividad.RutEmpleado = Empleado.RutEmpleado)
		JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN Capacitacion ON (HistorialActividad.CapacitacionID = Capacitacion.CapacitacionID)
	WHERE SUBSTRING(HistorialActividad.RutEmpleado, 0, len(HistorialActividad.RutEmpleado)-0) = @rut
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Capacitacion.FechaCapacitacion)) * -1, 
		CONVERT(DATETIME, Capacitacion.FechaCapacitacion)) + 1, CONVERT(DATETIME, Capacitacion.FechaCapacitacion)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1
		AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ACTIVIDAD_EMPLEADO_VISITA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ACTIVIDAD_EMPLEADO_VISITA] (@rut NVARCHAR(12)) 
AS
BEGIN
	SELECT Visita.FechaVisita, ISNULL(CAST(CONVERT(NVARCHAR, FechaVisita, 110) AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(SUBSTRING(CAST(CONVERT(NVARCHAR, Hora, 8) AS NVARCHAR), 0, 6), 'SIN ASIGNAR'),
		Visita.Estado, Empleado.RutEmpleado, Visita.VisitaID,
		Empleado.Nombre + ' ' + Empleado.Apellido, Cliente.RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente)
	FROM Visita JOIN Contrato ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN Empleado ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE SUBSTRING(Contrato.RutEmpleado, 0, len(Contrato.RutEmpleado)-0) = @rut
		AND DATEDIFF(ww, DATEADD( dd, DAY(CONVERT(DATETIME,Visita.FechaVisita)) * -1, 
		CONVERT(DATETIME, Visita.FechaVisita)) + 1, CONVERT(DATETIME, Visita.FechaVisita)) + 1 = DATEDIFF(ww, DATEADD( dd, 
		DAY(GETDATE()) * -1, GETDATE()) + 1, GETDATE()) + 1
		AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_AGREGAR_ITEM_CHECKLIST]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_AGREGAR_ITEM_CHECKLIST] (@nombre NVARCHAR(50), @id INT)
AS
BEGIN
	DECLARE @checklist INT
	DECLARE @nom NVARCHAR(50)
	DECLARE Items CURSOR FOR SELECT Nombre FROM ItemsChecklist WHERE VisitaID = @id

	OPEN Items FETCH Items INTO @nom
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @nom = @nombre
		BEGIN
			DELETE ItemsChecklist
			WHERE Nombre = @nombre AND VisitaID = @id
		END
		FETCH Items INTO @nom
	END
	CLOSE Items
	DEALLOCATE Items 

	SELECT @checklist = ChecklistID FROM Checklist WHERE VisitaID = @id

	BEGIN TRY  
		INSERT INTO ItemsChecklist(Nombre, ChecklistID, VisitaID)
		VALUES(@nombre, @checklist, @id)
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_AGREGAR_ITEM_CHECKLIST' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ASESORIA_ESPECIAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ASESORIA_ESPECIAL] 
	(@fecha DATE, @desc NVARCHAR(500), @hora TIME, @rut NVARCHAR(12))
AS
BEGIN
	DECLARE @id INT

	SELECT @id = ContratoID 
	FROM Contrato 
	WHERE SUBSTRING(RutCliente, 0, len(RutCliente)-0) = @rut AND Estado = 1

	BEGIN TRY
		INSERT INTO Asesoria (FechaCreado, FechaAsesoria, DescripcionAsesoria, Estado, ContratoID, Hora, Extra)
		VALUES (GETDATE(), @fecha, @desc, 'SIN REALIZAR', @id, @hora, 1)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_ASESORIA_ESPECIAL' + GETDATE(), @mensaje)
	END CATCH 
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ASESORIAS_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
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
	ORDER BY FechaAsesoria ASC	
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ASESORIAS_CLIENTE_MES_ACTUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ASESORIAS_CLIENTE_MES_ACTUAL] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Asesoria.AsesoriaID, ISNULL(CAST(FechaAsesoria AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Asesoria.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Asesoria JOIN HistorialActividad ON (Asesoria.AsesoriaID = HistorialActividad.AsesoriaID)
		JOIN Empleado ON (Empleado.RutEmpleado = HistorialActividad.RutEmpleado)
	WHERE ContratoID =  dbo.FN_GET_ID(@rut) 
		AND CONVERT(NVARCHAR, FORMAT(FechaAsesoria, 'yyyy-MM')) = CONVERT(NVARCHAR, FORMAT(GETDATE(), 'yyyy-MM'))
	ORDER BY Extra ASC	
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ASORIAS_EXTRAS]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_ASORIAS_EXTRAS] (@id INT, @contrato INT)
AS
BEGIN
	SELECT 'Asesoria Extra', AsesoriaID, 'Asesoria solicitada en la fecha ' + CONVERT(nvarchar, FechaCreado, 23)
	+ ', para ser realizada el día ' + CONVERT(nvarchar, FechaAsesoria, 23)
	FROM Asesoria
	WHERE ContratoID = @contrato AND Extra = 1
	AND CONVERT(DATE, FechaAsesoria, 23) BETWEEN dbo.FN_INICIO_MES_PAGO(@id) AND dbo.FN_FINAL_MES_PAGO(@id)
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CAMBIAR_ESTADO_ASESORIA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[SP_CAMBIAR_ESTADO_ASESORIA] (@estado NVARCHAR(20), @id INT)
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
/****** Object:  StoredProcedure [dbo].[SP_CAMBIAR_ESTADO_VISITA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[SP_CAMBIAR_ESTADO_VISITA] (@estado NVARCHAR(20), @id INT)
AS
BEGIN
	BEGIN TRY
		UPDATE Visita 
		SET Estado = @estado
		WHERE VisitaID = @id
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()
		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CAMBIAR_ESTADO_ASESORIA' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CAPACITACION_EXTRAS]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CAPACITACION_EXTRAS] (@id INT, @contrato INT)
AS
BEGIN
	SELECT 'Visita Extra', CapacitacionID, 'Visita solicitada en la fecha ' + CONVERT(nvarchar, FechaCreacion, 23)
	+ ', para ser realizada el día ' + CONVERT(nvarchar, FechaCapacitacion, 23)
	FROM Capacitacion
	WHERE ContratoID = @contrato AND Extra = 1
	AND CONVERT(DATE, FechaCapacitacion, 23) BETWEEN dbo.FN_INICIO_MES_PAGO(@id) AND dbo.FN_FINAL_MES_PAGO(@id)
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CAPACITACIONES_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CAPACITACIONES_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Capacitacion.CapacitacionID, ISNULL(CAST(Capacitacion.FechaCapacitacion AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Capacitacion.Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Capacitacion.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Capacitacion JOIN Contrato ON (Capacitacion.ContratoID = Contrato.ContratoID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE Contrato.ContratoID = dbo.FN_GET_ID(@rut)
	ORDER BY Extra ASC	
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CAPACITACIONES_CLIENTE_MES_ACTUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SP_CAPACITACIONES_CLIENTE_MES_ACTUAL] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Capacitacion.CapacitacionID, ISNULL(CAST(FechaCapacitacion AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Capacitacion.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Capacitacion JOIN Contrato ON (Capacitacion.ContratoID = Contrato.ContratoID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE Contrato.ContratoID = dbo.FN_GET_ID(@rut)
	AND CONVERT(NVARCHAR, FORMAT(FechaCapacitacion, 'yyyy-MM')) = CONVERT(NVARCHAR, FORMAT(GETDATE(), 'yyyy-MM'))
	ORDER BY Extra ASC	
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CHECKLIST_ITEM]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SP_CHECKLIST_ITEM] (@id INT)
AS
BEGIN
	SELECT ItemCheclistID, Nombre, ChecklistID, VisitaID FROM ItemsChecklist WHERE VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CONTRACT_DETAIL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CONTRACT_DETAIL] (@id NVARCHAR(100))
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
/****** Object:  StoredProcedure [dbo].[SP_CONTRATO_ACTIVO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CONTRATO_ACTIVO] (@rut NVARCHAR(12))
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
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CONTRATO_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[SP_CONTRATO_CLIENTE]
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
/****** Object:  StoredProcedure [dbo].[SP_CREAR_CAPACITACION]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CREAR_CAPACITACION] 
	(@fecha DATE, @hora TIME(7), @asistente INT, @materiales NVARCHAR(200), @descripcion NVARCHAR(200), @rut NVARCHAR(12))
AS
BEGIN
	DECLARE @contrato INT 

	SELECT @contrato = ContratoID 
	FROM Contrato 
	WHERE SUBSTRING(RutCliente, 0, len(RutCliente)-0) = @rut AND Estado = 1
	
	BEGIN TRY	
		INSERT INTO Capacitacion (FechaCreacion, FechaCapacitacion, CantidadAsistentes, 
			Materiales, Descripcion, Estado, ContratoID, Extra, Hora)
		VALUES (GETDATE(), @fecha, @asistente, @materiales, @descripcion, 'SIN REALIZAR', @contrato, 0, @hora)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREAR_CAPACITACION' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREAR_PLAN_MEJORA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CREAR_PLAN_MEJORA] (@id INT, @plan NVARCHAR(500))
AS
BEGIN
	DECLARE @informe INT
	DECLARE @contrato INT

	SELECT @informe = InformeVisitaID FROM InformeVisita WHERE VisitaID = @id
	SELECT @contrato = ContratoID FROM InformeVisita WHERE VisitaID = @id

	BEGIN TRY
		INSERT INTO Mejora (PlanMejora, Fecha, AplicoMejora, InformeVisitaID, VisitaID, ContratoID)
		VALUES(@plan, CONVERT(DATE, GETDATE(), 23), 0, @informe, @id, @contrato)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_ACCIDENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_ACCIDENTE]
	(@fech DATETIME, @des NVARCHAR(500), @medidas NVARCHAR(500), @rut NVARCHAR(12))
AS
BEGIN
	DECLARE @id INT
	SELECT @id = ContratoID 
	FROM Contrato 
	WHERE SUBSTRING(RutCliente, 0, len(RutCliente)-0) = @rut AND Estado = 1
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
/****** Object:  StoredProcedure [dbo].[SP_CREATE_CHECKLIST]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_CHECKLIST] (@visita INT)
AS
BEGIN
	BEGIN TRY
		INSERT INTO Checklist (FechaChecklist, VisitaID)
		VALUES (GETDATE(), @visita)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_CLIENTE]
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
/****** Object:  StoredProcedure [dbo].[SP_CREATE_CONTRATO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_CONTRATO]
	(@asesorias INT, @capacitaciones INT, @fechaterm DATETIME, @fechapago DATE,
	@cuotas INT, @cliente NVARCHAR(12), @empleado NVARCHAR(12), @fecha DATETIME)
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Contrato(CantidadAsesorias,CantidadCapacitaciones,FechaCreacion,FechaTermino,FechaPago,
			CuotasContrato,ValorContrato,Pagado, Estado,RutCliente,RutEmpleado)
		VALUES (@asesorias,@capacitaciones,@fecha,@fechaterm,@fechapago, @cuotas,'12000000',0,1,@cliente,@empleado)
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_CONTRATO' + GETDATE(), @mensaje)

	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_EMPLEADO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[SP_CREATE_EMPLEADO]
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
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_ASESORIA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_DETALLE_ASESORIA] (@id INT)
AS
BEGIN
	SELECT AsesoriaID, ISNULL(CAST(FechaAsesoria AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		UPPER(DescripcionAsesoria), Asesoria.Estado, Extra,
		dbo.FN_FormatearRut(Cliente.RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono,
		UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Empleado.Apellido), dbo.FN_FormatearRut(Empleado.RutEmpleado),
		RubroEmpresa.Nombre, Representante, dbo.FN_FormatearRut(RutRepresentante)
	FROM Asesoria JOIN Contrato ON (Asesoria.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE AsesoriaID = @id AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_CAPACITACION]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   PROCEDURE [dbo].[SP_DETALLE_CAPACITACION] (@id INT)
AS
BEGIN
	SELECT CapacitacionID, ISNULL(CAST(FechaCapacitacion AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		UPPER(Descripcion), Capacitacion.Estado, Extra,
		dbo.FN_FormatearRut(Cliente.RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono,
		UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Empleado.Apellido), dbo.FN_FormatearRut(Empleado.RutEmpleado),
		RubroEmpresa.Nombre, Representante, dbo.FN_FormatearRut(RutRepresentante),
		Materiales, CantidadAsistentes
	FROM Capacitacion JOIN Contrato ON (Capacitacion.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE CapacitacionID = @id AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_CHECKLIST]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_CHECKLIST] (@id INT)
AS
BEGIN
	SELECT Nombre, Reprobado, SemiAprobado, Aprobado
	FROM ItemsChecklist
	WHERE VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT dbo.FN_FormatearRut(Cliente.RutCliente), RazonSocial, Direccion, Telefono, 
		Direccion, Representante, dbo.FN_FormatearRut(RutRepresentante), Cliente.Estado, RubroEmpresa.Nombre,
		RutCliente
	FROM Cliente JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_CUENTA_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_CUENTA_CLIENTE] (@rut NVARCHAR(50))
AS
BEGIN
	SELECT dbo.FN_FormatearRut(RutCliente), RazonSocial, Direccion, Telefono, Nombre,
		Representante, dbo.FN_FormatearRut(RutRepresentante), CantidadTrabajadores, 
		NombreUsuario, Last_login, FechaCreacion, AppUser_user.Estado
	FROM Cliente JOIN AppUser_user ON (Cliente.RutCliente = AppUser_user.NombreUsuario)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
	WHERE SUBSTRING(NombreUsuario, 0, len(NombreUsuario)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_CUENTA_EMPLEADO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_CUENTA_EMPLEADO] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT dbo.FN_FormatearRut(RutEmpleado), NombreUsuario, Nombre + ' ' + Apellido,
		Cargo, Last_login, FechaCreacion, AppUser_user.Estado, RutEmpleado
	FROM Empleado JOIN AppUser_user ON (Empleado.RutEmpleado = AppUser_user.NombreUsuario)
	WHERE SUBSTRING(NombreUsuario, 0, len(NombreUsuario)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_INFORME_VISITA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_INFORME_VISITA] (@id INT)
AS
BEGIN
	SELECT Empleado.Nombre + ' ' + Apellido, dbo.FN_FormatearRut(Empleado.RutEmpleado), FechaVisita,
		RazonSocial, dbo.FN_FormatearRut(Cliente.RutCliente), Direccion, 
		Contrato.RutCliente + '-' + CONVERT(nvarchar,YEAR(Contrato.FechaCreacion)) + '-' + CONVERT(nvarchar,Contrato.ContratoID),
		RubroEmpresa.Nombre
	FROM Empleado JOIN Contrato ON (Empleado.RutEmpleado = Contrato.RutEmpleado)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN Visita ON (Contrato.ContratoID = Visita.ContratoID)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
	WHERE VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_PAGO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_PAGO] (@id INT)
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), 
	CAST(Pagos.FechaPago AS DATE), 
	CAST(FechaVencimiento AS DATE), 
		 CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ValorContrato  AS MONEY), 1)) ValorContrato,
		 CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ValorCuota  AS MONEY), 1)) ValorCuota, Pagos.Estado,
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR), Contrato.RutCliente, CAST(Pagos.ContratoID AS nvarchar),
		 CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(MontoExtra  AS MONEY), 1)) MontoExtra,
		CuotasContrato, CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(ValorCuota + MontoExtra  AS MONEY), 1))
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE PagosID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_PLAN_MEJORA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_PLAN_MEJORA] (@id INT)
AS
BEGIN
	SELECT Situacion, PlanMejora, AplicoMejora
	FROM InformeVisita LEFT JOIN Mejora ON (InformeVisita.InformeVisitaID = Mejora.InformeVisitaID)
	WHERE InformeVisita.VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_PLAN_MEJORA_EMP]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_DETALLE_PLAN_MEJORA_EMP] (@id INT)
AS
BEGIN
	SELECT PlanMejora, Fecha, AplicoMejora FROM Mejora WHERE VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_DETALLE_VISITA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_DETALLE_VISITA] (@id INT)
AS
BEGIN
	SELECT VisitaID, ISNULL(CAST(FechaVisita AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), Visita.Estado, Extra,
		dbo.FN_FormatearRut(Cliente.RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono,
		UPPER(RubroEmpresa.Nombre), UPPER(Empleado.Nombre + ' ' + Empleado.Apellido), dbo.FN_FormatearRut(Empleado.RutEmpleado),
		Representante, dbo.FN_FormatearRut(RutRepresentante)
	FROM Visita JOIN Contrato ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE VisitaID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[SP_FECHA_PAGO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_FECHA_PAGO] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CONVERT(nvarchar, FechaPago, 23), CONVERT(nvarchar, FechaVencimiento, 23), MONTH(FechaPago), PagosID
	FROM [Pagos]
	WHERE [ContratoID] = [dbo].[FN_GET_ID](@rut) 
	AND MONTH(FechaPago) = MONTH(GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ID_CONTRATO_ACTIVO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_ID_CONTRATO_ACTIVO] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Contrato.RutCliente, YEAR(Contrato.FechaCreacion), ContratoID
	FROM Cliente JOIN Contrato ON (Cliente.RutCliente = Contrato.RutCliente)
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut
	AND Contrato.Estado = 1
END
GO
/****** Object:  StoredProcedure [dbo].[SP_INFORME_VISITA]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_INFORME_VISITA] (@situacion NVARCHAR(500), @visita INT)
AS
BEGIN
	DECLARE @contrato INT

	SELECT @contrato = ContratoID FROM Visita WHERE VisitaID = 35

	BEGIN TRY
		INSERT INTO InformeVisita (Situacion, Fecha, ContratoID, VisitaID)
		VALUES (@situacion, CONVERT(DATE, GETDATE(), 23), @contrato, @visita)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_INFORME_VISITA_CLI]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_INFORME_VISITA_CLI] (@id INT)
AS
BEGIN
	SELECT dbo.FN_FormatearRut(Empleado.RutEmpleado), Nombre + ' ' + Apellido, FechaVisita, Hora, Situacion
	FROM Empleado JOIN Contrato ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
		JOIN Visita ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN InformeVisita ON (Visita.VisitaID = InformeVisita.VisitaID)
	WHERE Visita.VisitaID = @id
END	
GO
/****** Object:  StoredProcedure [dbo].[SP_ITEM_CHECKLIST_ESTADO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[SP_ITEM_CHECKLIST_ESTADO] (@id INT, @a BIT, @r BIT, @sa BIT)
AS
BEGIN
	BEGIN TRY  
		UPDATE ItemsChecklist
		SET Aprobado = @a, Reprobado = @r, SemiAprobado = @sa
		WHERE ItemCheclistID = @id
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_ITEM_CHECKLIST_ESTADO' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CLIENTES]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[SP_LISTAR_CLIENTES]
AS
BEGIN
	SELECT dbo.Fn_FormatearRut(RutCliente), UPPER(RazonSocial), UPPER(Direccion), Telefono, 
		UPPER(Representante),UPPER(RubroEmpresa.Nombre), dbo.Fn_FormatearRut(RutRepresentante) 
	FROM Cliente JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CLIENTES_EMP]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_LISTAR_CLIENTES_EMP] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT dbo.FN_FormatearRut(Cliente.RutCliente), RazonSocial, Direccion, 
		Telefono, Representante, dbo.FN_FormatearRut(RutRepresentante), RubroEmpresa.Nombre, CantidadTrabajadores,
		Cliente.RutCliente
	FROM Cliente JOIN Contrato ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
	WHERE SUBSTRING(Contrato.RutEmpleado, 0, len(Contrato.RutEmpleado)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] (@rut NVARCHAR(12))
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
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut
	ORDER BY Contrato.FechaCreacion DESC
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_CLIENTE_INACTIVO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_LISTAR_CONTRATOS_CLIENTE_INACTIVO] (@rut NVARCHAR(12))
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
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut AND Contrato.Estado = 0
	ORDER BY Contrato.FechaCreacion DESC
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL] (@rut NVARCHAR(12))
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
	WHERE SUBSTRING(Contrato.RutEmpleado, 0, len(Contrato.RutEmpleado)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_EMPELADOS]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[SP_LISTAR_EMPELADOS]
AS
BEGIN
	SELECT * FROM Empleado
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_TASA_CONTRATO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_LISTAR_TASA_CONTRATO] (@id INT)
AS
BEGIN
	SELECT Tasa, TasaAccidente.Fecha, Periodo, CantidadTrabajadores, Contrato.ContratoID, CantidadAccidentes
	FROM TasaAccidente JOIN Contrato ON (TasaAccidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
	WHERE TasaAccidente.ContratoID = @id AND LEN(Periodo) = 7
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_TASA_CONTRATO_ANUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_LISTAR_TASA_CONTRATO_ANUAL] (@id INT)
AS
BEGIN
	SELECT Tasa, TasaAccidente.Fecha, Periodo, CantidadTrabajadores, Contrato.ContratoID, CantidadAccidentes
	FROM TasaAccidente JOIN Contrato ON (TasaAccidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
	WHERE TasaAccidente.ContratoID = @id AND LEN(Periodo) > 7
END
GO
/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE    PROCEDURE [dbo].[SP_PAGOS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), CAST(Pagos.FechaPago AS DATE), CAST(FechaVencimiento AS DATE), 
	CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato,
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorCuota  AS MONEY), 1))AS NVARCHAR) ValorCuota, Pagos.Estado
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE SUBSTRING(Cliente.RutCliente, 0, len(Cliente.RutCliente)-0) = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CONTRATO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE      PROCEDURE [dbo].[SP_PAGOS_CONTRATO] (@id NVARCHAR(100))
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
/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CONTRATO_MES_ACTUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_PAGOS_CONTRATO_MES_ACTUAL] (@id NVARCHAR(100))
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
	WHERE CAST(Contrato.ContratoID AS NVARCHAR) = @id AND MONTH(Pagos.FechaPago) = MONTH(GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[SP_PLAN_MEJORA_INFO]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_PLAN_MEJORA_INFO] (@id INT)
AS
BEGIN
	SELECT PlanMejora, Mejora.Fecha, AplicoMejora
	FROM Empleado JOIN Contrato ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
		JOIN Visita ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN InformeVisita ON (Visita.VisitaID = InformeVisita.VisitaID)
		JOIN Mejora ON (InformeVisita.InformeVisitaID = Mejora.InformeVisitaID)
	WHERE Visita.VisitaID = @id
END	
GO
/****** Object:  StoredProcedure [dbo].[SP_TASA_ACCIDENTABILIDAD_MENSUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_TASA_ACCIDENTABILIDAD_MENSUAL] (@id INT, @periodo NVARCHAR(12), @tasa DECIMAL(5,2) OUTPUT)
AS
BEGIN
	DECLARE @resultado INT
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)

	SELECT @tasa = COUNT(AccidenteID)*100/CantidadTrabajadores 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
	WHERE Contrato.ContratoID = @id 
		AND CONVERT(NVARCHAR, FORMAT(Accidente.Fecha, 'MM-yyyy')) = @periodo
	GROUP BY CantidadTrabajadores
	RETURN
END
GO
/****** Object:  StoredProcedure [dbo].[SP_TASA_ACCIDENTE]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_TASA_ACCIDENTE] (@contrato INT, @periodo NVARCHAR(12))
AS
BEGIN
	BEGIN TRY
		INSERT INTO TasaAccidente (Tasa, ContratoID, Fecha, Periodo)
		VALUES (dbo.FN_TASA_ACCIDENTABILIDAD_MENSUAL(@contrato, @periodo), @contrato, CONVERT(DATE, GETDATE(), 32), @periodo)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_TASA_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_TASA_ACCIDENTE_ANUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_TASA_ACCIDENTE_ANUAL] (@contrato INT)
AS
BEGIN
	DECLARE Periodos CURSOR FOR SELECT Periodo FROM TasaAccidente WHERE ContratoID = @contrato
	DECLARE @fecha NVARCHAR(30)
	DECLARE @cantidad INT
	DECLARE @final NVARCHAR(12)
	DECLARE @inicio NVARCHAR(12)

	SELECT @inicio = CONVERT(NVARCHAR, FechaCreacion, 23) FROM Contrato WHERE ContratoID = @contrato AND Estado = 1
	SELECT @final = CONVERT(NVARCHAR, FechaTermino, 23) FROM Contrato WHERE ContratoID = @contrato AND Estado = 1

	OPEN Periodos 
	FETCH Periodos INTO @fecha
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fecha = @inicio + ' - ' + @final
		BEGIN
			DELETE TasaAccidente
			WHERE Periodo = @inicio + ' - ' + @final AND ContratoID = @contrato
		END
		FETCH Periodos INTO @fecha
	END
	CLOSE Periodos
	DEALLOCATE Periodos

	SELECT @cantidad = COUNT(AccidenteID) 
	FROM Accidente JOIN Contrato ON (Accidente.ContratoID = Contrato.ContratoID)
	WHERE Accidente.ContratoID = @contrato 
		AND CONVERT(DATE, Fecha, 31) BETWEEN CONVERT(DATE, FechaCreacion, 31) AND CONVERT(DATE, FechaTermino, 31)

	BEGIN TRY
		INSERT INTO TasaAccidente (Tasa, ContratoID, Fecha, Periodo, CantidadAccidentes)
		VALUES (dbo.FN_TASA_ACCIDENTABILIDAD_ANUAL(@contrato), @contrato, 
			CONVERT(DATE, GETDATE(), 32), @inicio + ' - ' + @final, @cantidad)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_TASA_ACCIDENTE_ANUAL' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_TASA_ACCIDENTE_MENSUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_TASA_ACCIDENTE_MENSUAL] (@contrato INT, @periodo NVARCHAR(12))
AS
BEGIN
	DECLARE Periodos CURSOR FOR SELECT Periodo FROM TasaAccidente WHERE ContratoID = @contrato
	DECLARE @fecha NVARCHAR(12)
	DECLARE @cantidad INT

	OPEN Periodos 
	FETCH Periodos INTO @fecha
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @fecha = @periodo
		BEGIN
			DELETE TasaAccidente
			WHERE Periodo = @periodo AND ContratoID = @contrato
		END
		FETCH Periodos INTO @fecha
	END
	CLOSE Periodos
	DEALLOCATE Periodos

	SELECT @cantidad = COUNT(AccidenteID) 
	FROM Accidente 
	WHERE ContratoID = @contrato AND CONVERT(NVARCHAR, FORMAT(Fecha, 'yyyy-MM')) = @periodo

	BEGIN TRY
		INSERT INTO TasaAccidente (Tasa, ContratoID, Fecha, Periodo, CantidadAccidentes)
		VALUES (dbo.FN_TASA_ACCIDENTABILIDAD_MENSUAL(@contrato, @periodo), @contrato, CONVERT(DATE, GETDATE(), 32), @periodo, @cantidad)
	END TRY
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_TASA_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_VISITA_EXTRAS]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_VISITA_EXTRAS] (@id INT, @contrato INT)
AS
BEGIN
	SELECT 'Visita Extra', VisitaID, 'Visita solicitada en la fecha ' + CONVERT(nvarchar, FechaCreacion, 23)
	+ ', para ser realizada el día ' + CONVERT(nvarchar, FechaVisita, 23)
	FROM Visita
	WHERE ContratoID = @contrato AND Extra = 1
	AND CONVERT(DATE, FechaVisita, 23) BETWEEN dbo.FN_INICIO_MES_PAGO(@id) AND dbo.FN_FINAL_MES_PAGO(@id)
END
GO
/****** Object:  StoredProcedure [dbo].[SP_VISITAS_CLIENTE]    Script Date: 27-11-2022 22:05:16 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_VISITAS_CLIENTE_MES_ACTUAL]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_VISITAS_CLIENTE_MES_ACTUAL] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT Visita.VisitaID, ISNULL(CAST(Visita.FechaVisita AS NVARCHAR), 'SIN ASIGNAR'), 
		ISNULL(CAST(CONVERT(NVARCHAR, Visita.Hora, 108) AS NVARCHAR), 'SIN ASIGNAR'), 
		Visita.Estado, Extra, Empleado.RutEmpleado, Nombre + '' + Apellido
	FROM Visita JOIN Contrato ON (Visita.ContratoID = Contrato.ContratoID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
	WHERE Contrato.ContratoID = dbo.FN_GET_ID(@rut)
	AND CONVERT(NVARCHAR, FORMAT(FechaVisita, 'yyyy-MM')) = CONVERT(NVARCHAR, FORMAT(GETDATE(), 'yyyy-MM'))
	ORDER BY Extra ASC	
END
GO
/****** Object:  StoredProcedure [dbo].[SP_VISITAS_CLIENTE_REPORT]    Script Date: 27-11-2022 22:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_VISITAS_CLIENTE_REPORT] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT VisitaID, ISNULL(CAST(Visita.FechaVisita AS NVARCHAR), 'SIN ASIGNAR')
	FROM Visita
	WHERE ContratoID = dbo.FN_GET_ID(@rut)
END
GO
USE [master]
GO
ALTER DATABASE [AccidentesDB] SET  READ_WRITE 
GO
