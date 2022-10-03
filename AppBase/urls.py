from django.urls import path
from AppBase.views import HomeView, CreateClient, CreateEmpleado, ListClienteView, CreateContractView, CreateAccidentView, ListContractView
from AppBase.views import ContractDetailView, ContractDetailPdf

app_name = 'base'

urlpatterns = [
    path('', HomeView, name='home'),
    path('ingresar-cliente', CreateClient, name='create-client'),
    path('ingresar-empleado', CreateEmpleado, name='create-emp'),
    path('clientes', ListClienteView, name='list-client'),
    path('ingresar-contrato', CreateContractView, name='create-contract'),
    path('ingresar-accidente', CreateAccidentView, name='create-accident'),
    path('contratos', ListContractView, name='list-contract'),
    path('contratos/detalle/<id>', ContractDetailView, name='contract-detail'),
    path('contratos/detalle/pdf/<pk>', ContractDetailPdf.as_view(), name='contract-pdf')
]