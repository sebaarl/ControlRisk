from django.urls import path
from django.conf.urls import handler404, handler500


from AppBase.views import HomeView, CreateClient, CreateEmpleado, ListClienteView, CreateContractView, CreateAccidentView, ListContractView,ContractDetailView, ContractDetailPdf, ListPagosView, ContratoClientView, PagosContractView,ContratoEmpleadoView, PagosDetailView, AsesoriaClienteView, AsesoriaEspecialClienteView, AsesoriaClienteView, AsesoriasEmpleadoView, CapacitacioesEmpleadoView, VisitasEmpleadoView, DetalleAsesoriaView, VisitasClienteView, DetalleVisitaView, DetalleAsesoriaClienteView, DetalleVisitaEmpleadoView, ChecklistView, ClientesEmpleadoView, ClienteDetalle, PerfilUsuario, DetalleChecklist, TasaAccidentabildiadView, InformeVisitaEmp, InformeVisitaCliente, DetallePlanMejora, DetalleCapacitacionEmp, CrearCapacitacion, CapacitacionesView, DetalleCapacitacionView, Error404View, Error500View, ReporteAccidentabilidad, InformesClienteView, AccidentesPdf, ReporteVisita, VisitaPDF, ReporteVisitasGenerales,VisitaGeneralPDF, ModificarFechaVisitaView

app_name = 'base'

urlpatterns = [
    path('', HomeView, name='home'),

    path('profesional/ingresar/', CreateEmpleado, name='create-emp'),
    path('profesional/contratos/', ContratoEmpleadoView, name='contract-emp'),
    path('profesional/clientes/', ClientesEmpleadoView, name='client-emp'),

    path('actividades/asesorias/', AsesoriasEmpleadoView, name='asesorias-emp'),
    path('actividades/asesorias/detalle/<pk>/', DetalleAsesoriaView, name='asesorias-detalle-emp'),

    path('actividades/capacitaciones/', CapacitacioesEmpleadoView, name='capacitacion-emp'),
    path('actividades/capacitaciones/<pk>/detalle/', DetalleCapacitacionEmp, name='capacitacion-emp-detalle'),
    path('actividades/capacitaciones/ingresar', CrearCapacitacion, name='capacitacion-crear'),

    path('actividades/visitas/', VisitasEmpleadoView, name='visitas-emp'),
    path('actividades/visitas/detalle/<pk>/',  DetalleVisitaEmpleadoView, name='visitas-detalle-emp'),

    path('actividades/visitas/<pk>/checklist/',  ChecklistView, name='visita-checklist'),
    path('actividades/visitas/<pk>/informe/',  InformeVisitaEmp, name='visita-informe'),

    path('clientes/ingresar/', CreateClient, name='create-client'),

    path('cuenta/perfil/<pk>', PerfilUsuario, name='user-profile'),
    
    path('clientes/', ListClienteView, name='list-client'),
    path('clientes/contratos/', ContratoClientView, name='contract'),
    path('clientes/detalle/<pk>/', ClienteDetalle, name='client-detalle'),

    path('clientes/asesorias/', AsesoriaClienteView, name='asesoria-client'),
    path('clientes/asesorias/detalle/<pk>/', DetalleAsesoriaClienteView, name='asesoria-detalle'),
    path('clientes/asesorias/solicitud/', AsesoriaEspecialClienteView, name='asesoria-especial'),

    path('clientes/visitas/', VisitasClienteView, name='visita-client'),
    path('clientes/visitas/detalle/<pk>/', DetalleVisitaView, name='visita-detalle'),
    path('clientes/visitas/detalle/<pk>/asignar/fecha-hora/', ModificarFechaVisitaView, name='visita-update'),
    path('clientes/visitas/detalle/<pk>/checklist/', DetalleChecklist, name='visitadetalle-checklist'),
    path('clientes/visitas/detalle/<pk>/informe/', InformeVisitaCliente, name='visita-informe-cliente'),
    path('clientes/visitas/detalle/<pk>/plandemejora/', DetallePlanMejora, name='visita-mejora'),

    path('clientes/capacitaciones/', CapacitacionesView, name='capacitacion-client'),
    path('clientes/capacitaciones/detalle/<pk>/', DetalleCapacitacionView, name='capacitacion-detalle'),

    path('clientes/accidentes/ingresar/', CreateAccidentView, name='create-accident'),
    path('clientes/accidentes/tasa/<pk>', TasaAccidentabildiadView, name='tasa-accident'),

    path('contratos/', ListContractView, name='list-contract'),
    path('contratos/ingresar/', CreateContractView, name='create-contract'),
    path('contratos/detalle/<id>/', ContractDetailView, name='contract-detail'),
    path('contratos/detalle/pdf/<pk>/', ContractDetailPdf.as_view(), name='contract-pdf'),


    path('pagos/', ListPagosView, name='pagos'),
    path('pagos/contrato/<pk>/', PagosContractView, name='pago-contract'),
    path('pagos/detalle/<pk>/', PagosDetailView, name='pago-detail'),

    path('informes/', InformesClienteView, name='reportes'),
    
    path('informes/<pk>/accidentes', ReporteAccidentabilidad, name='reporte-tasa'),
    path('informes/<pk>/accidentes/pdf', AccidentesPdf.as_view(), name='tasa-pdf'),

    path('informes/visita/<pk>/', ReporteVisita, name='reporte-visita'),
    path('informes/visita/<pk>/pdf', VisitaPDF.as_view(), name='visita-pdf'),

    path('informes/<pk>/visitas/', ReporteVisitasGenerales, name='reporte-visita-general'),
    path('informes/<pk>/visitas/pdf', VisitaGeneralPDF.as_view(), name='visita-general-pdf'),
]

handler404 = Error404View.as_view()
handler500 = Error500View.as_view()