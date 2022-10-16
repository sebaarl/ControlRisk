from django.urls import path
from AppBase.views import HomeView, CreateClient, CreateEmpleado, ListClienteView, CreateContractView, CreateAccidentView, ListContractView,ContractDetailView, ContractDetailPdf, ListPagosView, ContratoClientView, PagosContractView,ContratoEmpleadoView, PagosDetailView, AsesoriaClienteView, AsesoriaEspecialClienteView, AsesoriaClienteView, AsesoriasEmpleadoView, CapacitacioesEmpleadoView, VisitasEmpleadoView, DetalleAsesoriaView

app_name = 'base'

urlpatterns = [
    path('', HomeView, name='home'),

    path('profesional/ingresar/', CreateEmpleado, name='create-emp'),
    path('profesional/contratos/', ContratoEmpleadoView, name='contract-emp'),
    path('profesional/actividades/asesorias/', AsesoriasEmpleadoView, name='asesorias-emp'),
    path('profesional/actividades/asesorias/detalle/<pk>', DetalleAsesoriaView, name='asesorias-detalle-emp'),
    path('profesional/actividades/capacitaciones/', CapacitacioesEmpleadoView, name='capacitacion-emp'),
    path('profesional/actividades/visitas/', VisitasEmpleadoView, name='visitas-emp'),

    path('clientes/ingresar/', CreateClient, name='create-client'),
    
    path('clientes/', ListClienteView, name='list-client'),
    path('clientes/contratos/', ContratoClientView, name='contract'),
    path('clientes/asesorias/', AsesoriaClienteView, name='asesoria-client'),
    path('clientes/asesorias/solicitud/', AsesoriaEspecialClienteView, name='asesoria-especial'),
    path('clientes/accidentes/ingresar/', CreateAccidentView, name='create-accident'),

    path('contratos/', ListContractView, name='list-contract'),
    path('contratos/ingresar/', CreateContractView, name='create-contract'),
    path('contratos/detalle/<id>/', ContractDetailView, name='contract-detail'),
    path('contratos/detalle/pdf/<pk>/', ContractDetailPdf.as_view(), name='contract-pdf'),


    path('pagos/', ListPagosView, name='pagos'),
    path('pagos/contrato/<pk>/', PagosContractView, name='pago-contract'),
    path('pagos/detalle/<pk>/', PagosDetailView, name='pago-detail'),
]