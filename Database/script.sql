USE [master]
GO
/****** Object:  Database [ControlRiskDB]    Script Date: 05-10-2022 15:32:39 ******/
CREATE DATABASE [ControlRiskDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ControlRiskDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ControlRiskDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ControlRiskDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ControlRiskDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ControlRiskDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ControlRiskDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ControlRiskDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ControlRiskDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ControlRiskDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ControlRiskDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ControlRiskDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [ControlRiskDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ControlRiskDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ControlRiskDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ControlRiskDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ControlRiskDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ControlRiskDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ControlRiskDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ControlRiskDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ControlRiskDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ControlRiskDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ControlRiskDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ControlRiskDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ControlRiskDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ControlRiskDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ControlRiskDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ControlRiskDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ControlRiskDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ControlRiskDB] SET RECOVERY FULL 
GO
ALTER DATABASE [ControlRiskDB] SET  MULTI_USER 
GO
ALTER DATABASE [ControlRiskDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ControlRiskDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ControlRiskDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ControlRiskDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ControlRiskDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ControlRiskDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ControlRiskDB', N'ON'
GO
ALTER DATABASE [ControlRiskDB] SET QUERY_STORE = OFF
GO
USE [ControlRiskDB]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_FormatearRut]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       FUNCTION [dbo].[Fn_FormatearRut] (@Rut VARCHAR(12))
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
/****** Object:  Table [dbo].[Accidente]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Actividad]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actividad](
	[ActividadID] [int] IDENTITY(1,1) NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[EstadoActividad] [bit] NOT NULL,
	[ActividadExtra] [bit] NOT NULL,
	[ContratoID] [int] NOT NULL,
	[AsesoriaID] [int] NULL,
	[CapacitacionID] [int] NULL,
	[VisitaID] [int] NULL,
	[RutEmpleado] [nvarchar](12) NOT NULL,
 CONSTRAINT [PK_Actividad] PRIMARY KEY CLUSTERED 
(
	[ActividadID] ASC,
	[ContratoID] ASC,
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AppUser_user]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[AppUser_user_groups]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[AppUser_user_user_permissions]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Asesoria]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Asesoria](
	[AsesoriaID] [int] IDENTITY(1,1) NOT NULL,
	[FechaAsesoria] [datetime] NOT NULL,
	[DescripcionAsesoria] [nvarchar](500) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Asesoria] PRIMARY KEY CLUSTERED 
(
	[AsesoriaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AsesoriaTelefonica]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[auth_group]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[auth_permission]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Capacitacion]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Capacitacion](
	[CapacitacionID] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NULL,
	[CantidadAsistentes] [int] NOT NULL,
	[Materiales] [nvarchar](200) NULL,
	[Descripcion] [nvarchar](200) NULL,
 CONSTRAINT [PK_Capacitacion] PRIMARY KEY CLUSTERED 
(
	[CapacitacionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Checklist]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Cliente]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cliente](
	[RutCliente] [nvarchar](12) NOT NULL,
	[RazonSocial] [nvarchar](50) NOT NULL,
	[Direccion] [nvarchar](100) NOT NULL,
	[Telefono] [int] NOT NULL,
	[Representante] [nvarchar](50) NOT NULL,
	[RutRepresentante] [nvarchar](12) NOT NULL,
	[Estado] [bit] NOT NULL,
	[UsuarioID] [bigint] NULL,
	[RubroID] [int] NOT NULL,
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
/****** Object:  Table [dbo].[Contrato]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[django_content_type]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[django_migrations]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[django_session]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Empleado]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Error]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[InformeVisita]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[ItemsChecklist]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Mejora]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Pagos]    Script Date: 05-10-2022 15:32:39 ******/
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
	[Pagado] [bit] NULL,
 CONSTRAINT [PK_Pagos] PRIMARY KEY CLUSTERED 
(
	[PagosID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RubroEmpresa]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[TipoPagos]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  Table [dbo].[Visita]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Visita](
	[VisitaID] [int] IDENTITY(1,1) NOT NULL,
	[FechaVisita] [datetime] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Visita] PRIMARY KEY CLUSTERED 
(
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship37]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship37] ON [dbo].[Accidente]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship33]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship33] ON [dbo].[Actividad]
(
	[AsesoriaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship34]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship34] ON [dbo].[Actividad]
(
	[CapacitacionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship35]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship35] ON [dbo].[Actividad]
(
	[VisitaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_group_id_e2ed4738]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_groups_group_id_e2ed4738] ON [dbo].[AppUser_user_groups]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_user_id_83d94a1d]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_groups_user_id_83d94a1d] ON [dbo].[AppUser_user_groups]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_groups_user_id_group_id_e1f5f27d_uniq]    Script Date: 05-10-2022 15:32:39 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AppUser_user_groups_user_id_group_id_e1f5f27d_uniq] ON [dbo].[AppUser_user_groups]
(
	[user_id] ASC,
	[group_id] ASC
)
WHERE ([user_id] IS NOT NULL AND [group_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_permission_id_c1d03c50]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_user_permissions_permission_id_c1d03c50] ON [dbo].[AppUser_user_user_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_user_id_a4819296]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [AppUser_user_user_permissions_user_id_a4819296] ON [dbo].[AppUser_user_user_permissions]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AppUser_user_user_permissions_user_id_permission_id_bde4c76d_uniq]    Script Date: 05-10-2022 15:32:39 ******/
CREATE UNIQUE NONCLUSTERED INDEX [AppUser_user_user_permissions_user_id_permission_id_bde4c76d_uniq] ON [dbo].[AppUser_user_user_permissions]
(
	[user_id] ASC,
	[permission_id] ASC
)
WHERE ([user_id] IS NOT NULL AND [permission_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship31]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship31] ON [dbo].[AsesoriaTelefonica]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_group_id_b120cbf9]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_group_id_b120cbf9] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_group_id_permission_id_0cd325b0_uniq]    Script Date: 05-10-2022 15:32:39 ******/
CREATE UNIQUE NONCLUSTERED INDEX [auth_group_permissions_group_id_permission_id_0cd325b0_uniq] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC,
	[permission_id] ASC
)
WHERE ([group_id] IS NOT NULL AND [permission_id] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_permission_id_84c5c92e]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_permission_id_84c5c92e] ON [dbo].[auth_group_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [auth_permission_content_type_id_2f476e4b]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [auth_permission_content_type_id_2f476e4b] ON [dbo].[auth_permission]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [auth_permission_content_type_id_codename_01ab375a_uniq]    Script Date: 05-10-2022 15:32:39 ******/
CREATE UNIQUE NONCLUSTERED INDEX [auth_permission_content_type_id_codename_01ab375a_uniq] ON [dbo].[auth_permission]
(
	[content_type_id] ASC,
	[codename] ASC
)
WHERE ([content_type_id] IS NOT NULL AND [codename] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship10]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship10] ON [dbo].[Cliente]
(
	[UsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Relationship13]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship13] ON [dbo].[Contrato]
(
	[RutCliente] ASC,
	[RubroID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Relationship16]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship16] ON [dbo].[Contrato]
(
	[RutEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_content_type_id_c4bce8eb]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_content_type_id_c4bce8eb] ON [dbo].[django_admin_log]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_user_id_c564eba6]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [django_admin_log_user_id_c564eba6] ON [dbo].[django_admin_log]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [django_content_type_app_label_model_76bd3d3b_uniq]    Script Date: 05-10-2022 15:32:39 ******/
CREATE UNIQUE NONCLUSTERED INDEX [django_content_type_app_label_model_76bd3d3b_uniq] ON [dbo].[django_content_type]
(
	[app_label] ASC,
	[model] ASC
)
WHERE ([app_label] IS NOT NULL AND [model] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [django_session_expire_date_a5c62663]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [django_session_expire_date_a5c62663] ON [dbo].[django_session]
(
	[expire_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship4]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship4] ON [dbo].[Empleado]
(
	[UsuarioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship45]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship45] ON [dbo].[Mejora]
(
	[InformeVisitaID] ASC,
	[VisitaID] ASC,
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship12]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship12] ON [dbo].[Pagos]
(
	[TipoPagoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Relationship14]    Script Date: 05-10-2022 15:32:39 ******/
CREATE NONCLUSTERED INDEX [IX_Relationship14] ON [dbo].[Pagos]
(
	[ContratoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Accidente]  WITH CHECK ADD  CONSTRAINT [Relationship37] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Accidente] CHECK CONSTRAINT [Relationship37]
GO
ALTER TABLE [dbo].[Actividad]  WITH CHECK ADD  CONSTRAINT [Relationship17] FOREIGN KEY([RutEmpleado])
REFERENCES [dbo].[Empleado] ([RutEmpleado])
GO
ALTER TABLE [dbo].[Actividad] CHECK CONSTRAINT [Relationship17]
GO
ALTER TABLE [dbo].[Actividad]  WITH CHECK ADD  CONSTRAINT [Relationship33] FOREIGN KEY([AsesoriaID])
REFERENCES [dbo].[Asesoria] ([AsesoriaID])
GO
ALTER TABLE [dbo].[Actividad] CHECK CONSTRAINT [Relationship33]
GO
ALTER TABLE [dbo].[Actividad]  WITH CHECK ADD  CONSTRAINT [Relationship34] FOREIGN KEY([CapacitacionID])
REFERENCES [dbo].[Capacitacion] ([CapacitacionID])
GO
ALTER TABLE [dbo].[Actividad] CHECK CONSTRAINT [Relationship34]
GO
ALTER TABLE [dbo].[Actividad]  WITH CHECK ADD  CONSTRAINT [Relationship35] FOREIGN KEY([VisitaID])
REFERENCES [dbo].[Visita] ([VisitaID])
GO
ALTER TABLE [dbo].[Actividad] CHECK CONSTRAINT [Relationship35]
GO
ALTER TABLE [dbo].[Actividad]  WITH CHECK ADD  CONSTRAINT [Relationship36] FOREIGN KEY([ContratoID])
REFERENCES [dbo].[Contrato] ([ContratoID])
GO
ALTER TABLE [dbo].[Actividad] CHECK CONSTRAINT [Relationship36]
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
ALTER TABLE [dbo].[Empleado]  WITH CHECK ADD  CONSTRAINT [Relationship88] FOREIGN KEY([UsuarioID])
REFERENCES [dbo].[AppUser_user] ([id])
GO
ALTER TABLE [dbo].[Empleado] CHECK CONSTRAINT [Relationship88]
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
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
/****** Object:  StoredProcedure [dbo].[SP_CONTRACT_DETAIL]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CONTRACT_DETAIL] (@id NVARCHAR(100))
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
/****** Object:  StoredProcedure [dbo].[SP_CONTRATO_CLIENTE]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CONTRATO_CLIENTE]
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
/****** Object:  StoredProcedure [dbo].[SP_CREATE_ACCIDENTE]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_ACCIDENTE]
	(@fech DATETIME, @des NVARCHAR(500), @medidas NVARCHAR(500), @contrato INT)
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Accidente(Fecha,Descripcion,Medidas,ContratoID)
		VALUES(@fech, @des, @medidas, @contrato)	
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_ACCIDENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_CLIENTE]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_CREATE_CLIENTE]
	(@rut NVARCHAR(12), @razon NVARCHAR(50), @rubro INT, @direccion NVARCHAR(100),
	@telefono INT, @representante NVARCHAR(50), @rutrepre NVARCHAR(12))
AS
BEGIN
	BEGIN TRY  
		INSERT INTO Cliente(RutCliente,RazonSocial,direccion,telefono,Representante, RutRepresentante,RubroID, Estado)
		VALUES(@rut,@razon,@direccion,@telefono,@representante, @rutrepre,@rubro, 1)	
	END TRY  
	BEGIN CATCH
		DECLARE @mensaje NVARCHAR(500) = ERROR_MESSAGE()

		INSERT INTO Error (MensajeError, Descripcion)
		VALUES ('Error en el procedimiento SP_CREATE_CLIENTE' + GETDATE(), @mensaje)
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[SP_CREATE_CONTRATO]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[SP_CREATE_CONTRATO]
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
/****** Object:  StoredProcedure [dbo].[SP_CREATE_EMPLEADO]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CLIENTES]    Script Date: 05-10-2022 15:32:39 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_CONTRATOS_CLIENTE]    Script Date: 05-10-2022 15:32:39 ******/
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
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR)
	FROM Contrato JOIN Cliente ON (Contrato.RutCliente = Cliente.RutCliente)
		JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID)
		JOIN Empleado ON (Contrato.RutEmpleado = Empleado.RutEmpleado)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE Cliente.RutCliente = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_EMPELADOS]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LISTAR_EMPELADOS]
AS
BEGIN
	SELECT * FROM Empleado
END
GO
/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CLIENTE]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_PAGOS_CLIENTE] (@rut NVARCHAR(12))
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), CAST(Pagos.FechaPago AS DATE), CAST(FechaVencimiento AS DATE), 
	CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato,
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorCuota  AS MONEY), 1))AS NVARCHAR) ValorCuota, Pagos.Pagado
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE Cliente.RutCliente = @rut
END
GO
/****** Object:  StoredProcedure [dbo].[SP_PAGOS_CONTRATO]    Script Date: 05-10-2022 15:32:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_PAGOS_CONTRATO] (@id NVARCHAR(100))
AS
BEGIN
	SELECT CAST(PagosID AS NVARCHAR), CAST(Pagos.FechaPago AS DATE), CAST(FechaVencimiento AS DATE), 
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorContrato  AS MONEY), 1))AS NVARCHAR) ValorContrato,
		CAST('$' + CONVERT(NVARCHAR, CONVERT(NVARCHAR, CAST(ValorCuota  AS MONEY), 1))AS NVARCHAR) ValorCuota, Pagos.Pagado,
		CAST(YEAR(Contrato.FechaCreacion) AS NVARCHAR), Contrato.RutCliente, CAST(Pagos.ContratoID AS nvarchar)
	FROM Pagos JOIN Contrato ON (Pagos.ContratoID = Contrato.ContratoID)
		JOIN Cliente ON (Cliente.RutCliente = Contrato.RutCliente)
		JOIN AppUser_user ON (AppUser_user.NombreUsuario = Cliente.RutCliente)
	WHERE CAST(Contrato.ContratoID AS NVARCHAR) = @id
END
GO
USE [master]
GO
ALTER DATABASE [ControlRiskDB] SET  READ_WRITE 
GO
