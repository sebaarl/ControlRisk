from multiprocessing import connection, context
from django.shortcuts import render
from django.contrib.auth import authenticate, get_user_model, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.http.response import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.http import Http404
from django.db import connection
from django.contrib.auth import authenticate, login
from django.core.paginator import Paginator
from django.contrib import messages

from AppBase.forms import CreateClienteForm, CreateEmpleadoForm, CreateContratoForm
from AppBase.models import Cliente, Empleado, Contrato
from AppUser.models import User


@login_required
def HomeView(request):
    return render(request, 'home.html')


@login_required
def CreateClient(request):
    data = {
        'cliente': CreateClienteForm()
    }

    if request.method == "POST":
        if request.POST.get('rut') and request.POST.get('razon') and request.POST.get('rubro') and request.POST.get('direccion') and request.POST.get('telefono') and request.POST.get('representante'):
            clientesave = Cliente()
            clientesave.rutcliente = request.POST.get('rut')
            clientesave.razonsocial = request.POST.get('razon')
            clientesave.direccion = request.POST.get('direccion')
            clientesave.telefono = request.POST.get('telefono')
            clientesave.representante = request.POST.get('representante')
            clientesave.rubro = request.POST.get('rubro')

            if request.method == "POST":
                username = request.POST.get('rut')
                password = request.POST.get('rut')[4:]

                user = get_user_model().objects.create(
                    username=username,
                    password=make_password(password),
                    is_active=True,
                    is_profesional=False
                )

            from django.db import connection
            with connection.cursor() as cursor:

                cursor.execute('EXEC [dbo].[SP_CREATE_CLIENTE] %s, %s, %s, %s, %s, %s', (clientesave.rutcliente,
                               clientesave.razonsocial, clientesave.rubro,  clientesave.direccion, clientesave.telefono, clientesave.representante))

                messages.success(request, "Cliente " +
                                 clientesave.rutcliente+" registrado correctamente ")

            return render(request, 'create_cliente.html', data)

    return render(request, 'create_cliente.html', data)


@login_required
def CreateEmpleado(request):
    data = {
        'emp': CreateEmpleadoForm()
    }
    if request.method == "POST":
        if request.POST.get('rut') and request.POST.get('nombre') and request.POST.get('apellido') and request.POST.get('cargo'):
            empsave = Empleado()
            empsave.rut = request.POST.get('rut')
            empsave.nombre = request.POST.get('nombre')
            empsave.apellido = request.POST.get('apellido')
            empsave.cargo = request.POST.get('cargo')

            if request.method == "POST":
                username = request.POST.get('rut')
                password = request.POST.get('rut')[4:]

                user = get_user_model().objects.create(
                    username=username,
                    password=make_password(password),
                    is_active=True,
                    is_profesional=True
                )

            from django.db import connection
            with connection.cursor() as cursor:

                cursor.execute('EXEC [dbo].[SP_CREATE_EMPLEADO] %s, %s, %s, %s', (
                    empsave.rut, empsave.nombre, empsave.apellido, empsave.cargo))

                messages.success(request, "Empleado " +
                                 empsave.rut+" registrado correctamente ")

            return render(request, 'create_empleado.html', data)

    return render(request, 'create_empleado.html', data)


@login_required
def ListClienteView(request):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_LISTAR_CLIENTES]')
    results = cursor.fetchall()
    page = request.GET.get('page', 1)

    try:
        paginator = Paginator(results, 8)
        results = paginator.page(page)
    except:
        raise Http404

    data = {
        "entity": results,
        "paginator": paginator
    }

    return render(request, 'listar_clientes.html', data)


def CreateAccidentView(request):
    return render(request, 'create_accident.html')


@login_required
def CreateContractView(request):
    data = {
        'contract': CreateContratoForm()
    }
    if request.method == "POST":
        if request.POST.get('asesoria') and request.POST.get('capa') and request.POST.get('termino') and request.POST.get(
            'pago') and request.POST.get('cuota') and request.POST.get('valor') and request.POST.get('cliente') and request.POST.get('emp'):
            contratosave = Contrato()
            contratosave.cantidadasesorias = request.POST.get('asesoria')
            contratosave.cantidadcapacitaciones = request.POST.get('capa')
            contratosave.fechatermino = request.POST.get('termino')
            contratosave.fechapago = request.POST.get('pago')
            contratosave.cuotascontrato = request.POST.get('cuota')
            contratosave.valorcontrato = request.POST.get('valor')
            contratosave.rutcliente = request.POST.get('cliente')
            contratosave.rut = request.POST.get('empleado')

            from django.db import connection
            with connection.cursor() as cursor:

                cursor.execute('EXEC [dbo].[SP_CREATE_CONTRATO] %s, %s, %s, %s, %s, %s, %s, %s', (contratosave.cantidadasesorias,
                                contratosave.cantidadcapacitaciones,contratosave.fechatermino,contratosave.fechapago,contratosave.cuotascontrato,contratosave.valorcontrato, contratosave.rutcliente, contratosave.rut))

                messages.success(request, "Contrato " +
                                 "registrado correctamente ")

            return render(request, 'create_contract.html', data)

    return render(request, 'create_contract.html', data)


@login_required
def ListContractView(request):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_LISTAR_CONTRATO]')
    results = cursor.fetchall()
    page = request.GET.get('page', 1)

    try:
        paginator = Paginator(results, 8)
        results = paginator.page(page)
    except:
        raise Http404

    data = {
        "entity": results,
        "paginator": paginator
    }

    return render(request, 'listar_contratos.html', data)