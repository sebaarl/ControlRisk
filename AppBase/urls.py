from django.urls import path
from AppBase.views import HomeView, CreateClient, CreateEmpleado, ListClienteView, CreateContractView, CreateAccidentView, ListContractView,ContractDetailView, ContractDetailPdf, ListPagosView, ContratoClientView, PagosContractView,ContratoEmpleadoView, PagosDetailView, AsesoriaClienteView, AsesoriaEspecialClienteView, AsesoriaClienteView, AsesoriasEmpleadoView, CapacitacioesEmpleadoView, VisitasEmpleadoView, DetalleAsesoriaView, VisitasClienteView, DetalleVisitaView, DetalleAsesoriaClienteView, DetalleVisitaEmpleadoView, ChecklistView

app_name = 'base'

urlpatterns = [
    path('', HomeView, name='home'),

    path('profesional/ingresar/', CreateEmpleado, name='create-emp'),
    path('profesional/contratos/', ContratoEmpleadoView, name='contract-emp'),
    path('actividades/asesorias/', AsesoriasEmpleadoView, name='asesorias-emp'),
    path('actividades/asesorias/detalle/<pk>/', DetalleAsesoriaView, name='asesorias-detalle-emp'),
    path('actividades/capacitaciones/', CapacitacioesEmpleadoView, name='capacitacion-emp'),
    path('actividades/visitas/', VisitasEmpleadoView, name='visitas-emp'),
    path('actividades/visitas/detalle/<pk>/',  DetalleVisitaEmpleadoView, name='visitas-detalle-emp'),

    path('actividades/visitas/<pk>/checklist/',  ChecklistView, name='visita-checklist'),

    path('clientes/ingresar/', CreateClient, name='create-client'),
    
    path('clientes/', ListClienteView, name='list-client'),
    path('clientes/contratos/', ContratoClientView, name='contract'),

    path('clientes/asesorias/', AsesoriaClienteView, name='asesoria-client'),
    path('clientes/asesorias/detalle/<pk>/', DetalleAsesoriaClienteView, name='asesoria-detalle'),
    path('clientes/asesorias/solicitud/', AsesoriaEspecialClienteView, name='asesoria-especial'),

    path('clientes/visitas/', VisitasClienteView, name='visita-client'),
    path('clientes/visitas/detalle/<pk>/', DetalleVisitaView, name='visita-detalle'),

    path('clientes/accidentes/ingresar/', CreateAccidentView, name='create-accident'),

    path('contratos/', ListContractView, name='list-contract'),
    path('contratos/ingresar/', CreateContractView, name='create-contract'),
    path('contratos/detalle/<id>/', ContractDetailView, name='contract-detail'),
    path('contratos/detalle/pdf/<pk>/', ContractDetailPdf.as_view(), name='contract-pdf'),


    path('pagos/', ListPagosView, name='pagos'),
    path('pagos/contrato/<pk>/', PagosContractView, name='pago-contract'),
    path('pagos/detalle/<pk>/', PagosDetailView, name='pago-detail'),
]

