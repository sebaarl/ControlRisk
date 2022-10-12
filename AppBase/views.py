from multiprocessing import connection, context
from unittest import result
from django.shortcuts import render
from django.contrib.auth import authenticate, get_user_model, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.http.response import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.http import Http404, HttpResponseRedirect
from django.db import connection
from django.contrib.auth import authenticate, login
from django.core.paginator import Paginator
from django.contrib import messages
from django.urls import reverse_lazy

from AppBase.forms import CreateAsesoriaEspecial, CreateClienteForm, CreateEmpleadoForm, CreateContratoForm
from AppBase.models import Asesoria, Cliente, Empleado, Contrato
from AppUser.models import User

from datetime import date
from datetime import datetime
from datetime import timedelta
from dateutil.relativedelta import *
from dateutil.easter import *
from dateutil.rrule import *
from dateutil.parser import *
from django.views import View

import os
from django.conf import settings
from django.http import HttpResponse
from django.template.loader import get_template
from xhtml2pdf import pisa
from django.contrib.staticfiles import finders
from rut_chile import rut_chile
from unidecode import unidecode


def rut(rut):
    puntos = rut.replace('.', '')
    guion = puntos.replace('-', '')
    rut_final = guion

    return rut_final


def formatRut(rut):
    if len(rut) == 8:
        formato = rut[0:1] + '.' + rut[1:4] + '.' + rut[4:7] + '-' + rut[-1]
    else:
        formato = rut[0:2] + '.' + rut[2:5] + '.' + rut[5:8] + '-' + rut[-1]

    return formato


@login_required
def HomeView(request):
    datos = request.user

    # from django.db import connection
    # with connection.cursor() as cursor:

    #     data_emp = cursor.execute(
    #         'SELECT * FROM [dbo].[Empleado] WHERE [RutEmpleado] = {}'.format(datos.username))
    #     profesional = data_emp.fetchone()
    #     data_cli = cursor.execute(
    #         'SELECT RazonSocial FROM [dbo].[Cliente] WHERE [RutCliente] = {}'.format(datos.username))
    #     cliente = data_cli.fetchone()

    data = {
        'user': datos,
    }

    return render(request, 'home.html', data)


@login_required
def CreateClient(request):
    data = {
        'form': CreateClienteForm()
    }

    if request.method == "POST":
        formulario = CreateClienteForm(request.POST)
        if formulario.is_valid():
            # if request.POST.get('rut') and request.POST.get('razon') and request.POST.get('rubro') and request.POST.get('direccion') and request.POST.get('telefono') and request.POST.get('representante') and request.POST.get('rutrepre'):
            clientesave = Cliente()
            clientesave.rutcliente = request.POST.get('rut')
            clientesave.razonsocial = request.POST.get('razon')
            clientesave.direccion = request.POST.get('direccion')
            clientesave.telefono = request.POST.get('telefono')
            clientesave.representante = request.POST.get('representante')
            clientesave.rutrepresentante = request.POST.get('rutrepre')
            clientesave.rubro = request.POST.get('rubro')

            rut_cli = rut(clientesave.rutcliente)
            rut_repre = rut(clientesave.rutrepresentante)

            existe = Cliente.objects.filter(rutcliente=rut_cli).exists()
            user_exist = User.objects.filter(username=rut_cli).exists()

            if rut_chile.is_valid_rut(clientesave.rutcliente) and rut_chile.is_valid_rut(clientesave.rutrepresentante):
                if existe or user_exist:
                    messages.error(request, "El rut " +
                                       formatRut(rut_cli) + " ya está registrado en el sistema!")
                else:
                    username = rut_cli
                    password = rut_cli[4:]

                    user = get_user_model().objects.create(
                        username=username,
                        password=make_password(password),
                        is_active=True,
                        is_profesional=False
                    )

                    from django.db import connection
                    with connection.cursor() as cursor:

                        cursor.execute('EXEC [dbo].[SP_CREATE_CLIENTE] %s, %s, %s, %s, %s, %s, %s', (rut_cli,
                                    clientesave.razonsocial, clientesave.rubro,  clientesave.direccion, clientesave.telefono, clientesave.representante, rut_repre))

                        messages.success(request, "Cliente " + formatRut(rut_cli) + " registrado correctamente ")

                        return render(request, 'cliente/create_cliente.html', data)
            else:
                messages.error(request, "RUT invalido!!")

    return render(request, 'cliente/create_cliente.html', data)


@login_required
def CreateEmpleado(request):
    data = {
        'emp': CreateEmpleadoForm()
    }

    if request.method == "POST":
        formulario = CreateEmpleadoForm(request.POST)
        if formulario.is_valid():
            # if request.POST.get('rut') and request.POST.get('nombre') and request.POST.get('apellido') and request.POST.get('cargo'):
            empsave = Empleado()
            empsave.rutempleado = request.POST.get('rut')
            empsave.nombre = request.POST.get('nombre')
            empsave.apellido = request.POST.get('apellido')
            empsave.cargo = request.POST.get('cargo')

            if empsave.cargo == 'Profesional':
                profesional = True
                staff = False
            else:
                profesional = False
                staff = True

            rut_emp = rut(empsave.rutempleado)

            existe = Empleado.objects.filter(rutempleado=rut_emp).exists()
            user_exist = User.objects.filter(username=rut_emp).exists()

            if rut_chile.is_valid_rut(empsave.rutempleado):
                if existe or user_exist:
                    messages.error(
                        request, "El rut " + formatRut(rut_emp) + " ya está registrado en el sistema!")
                else:
                    username = rut_emp
                    password = rut_emp[4:]

                    user = get_user_model().objects.create(
                        username=username,
                        password=make_password(password),
                        is_active=True,
                        is_profesional=profesional,
                        is_staff=staff
                    )

                    from django.db import connection
                    with connection.cursor() as cursor:

                        cursor.execute('EXEC [dbo].[SP_CREATE_EMPLEADO] %s, %s, %s, %s', (
                            rut_emp, empsave.nombre, empsave.apellido, empsave.cargo))

                        messages.success(
                            request, "Empleado " + formatRut(rut_emp) + " registrado correctamente ")

                        return render(request, 'empleados/create_empleado.html', data)
            else:
                messages.error(request, "Cliente " +
                               formatRut(rut_emp) + " invalido ")

    return render(request, 'empleados/create_empleado.html', data)


@login_required
def ListClienteView(request):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_LISTAR_CLIENTES]')
    results = cursor.fetchall()
    page = request.GET.get('page', 1)

    try:
        paginator = Paginator(results, 10)
        results = paginator.page(page)
    except:
        raise Http404

    data = {
        "entity": results,
        "paginator": paginator,
    }

    return render(request, 'cliente/listar_clientes.html', data)


@login_required
def CreateAccidentView(request):
    return render(request, 'accidentes/create_accident.html')


# Vistas Contrato
# Creación de contrato
@login_required
def CreateContractView(request):
    data = {
        'contract': CreateContratoForm()
    }

    if request.method == "POST":
        if request.POST.get('asesoria') and request.POST.get('capa') and request.POST.get('cuota') and request.POST.get('valor') and request.POST.get('cliente') and request.POST.get('empleado'):
            contratosave = Contrato()
            contratosave.cantidadasesorias = request.POST.get('asesoria')
            contratosave.cantidadcapacitaciones = request.POST.get('capa')
            contratosave.cuotascontrato = request.POST.get('cuota')
            contratosave.valorcontrato = request.POST.get('valor')

            cliente = Cliente.objects.get(
                rutcliente=request.POST.get('cliente'))
            empleado = Empleado.objects.get(
                rutempleado=request.POST.get('empleado'))

            contratosave.rutcliente = cliente
            contratosave.rutempleado = empleado

            now = datetime.now()
            termino = now + relativedelta(months=12)
            pago = now + relativedelta(months=1)

            from django.db import connection
            with connection.cursor() as cursor:

                filterRut = Contrato.objects.filter(
                    rutcliente=contratosave.rutcliente)
                estado = filterRut.filter(estado=1)
                cantidad = estado.count()

                if cantidad >= 1:
                    messages.error(request, 'La empresa {0} presenta un contracto activo'.format(
                        formatRut(str(contratosave.rutcliente))))
                else:
                    cursor.execute('EXEC [dbo].[SP_CREATE_CONTRATO]  %s, %s, %s, %s, %s, %s, %s, %s, %s', (
                        int(contratosave.cantidadasesorias), int(
                            contratosave.cantidadcapacitaciones), termino, pago,
                        int(contratosave.cuotascontrato), int(
                            contratosave.valorcontrato),
                        str(contratosave.rutcliente), str(contratosave.rutempleado), now))

                    messages.success(
                        request, "Contrato registrado correctamente")

            return render(request, 'contrato/create_contract.html', data)

    return render(request, 'contrato/create_contract.html', data)


# Listar todos los contratos del sistema
@login_required
def ListContractView(request):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_CONTRATO_CLIENTE]')
    results = cursor.fetchall()
    page = request.GET.get('page', 1)

    try:
        paginator = Paginator(results, 10)
        results = paginator.page(page)
    except:
        raise Http404

    data = {
        "entity": results,
        "paginator": paginator
    }

    return render(request, 'contrato/listar_contratos.html', data)


# Mostrar detalle del contrato
@login_required
def ContractDetailView(request, id):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_CONTRACT_DETAIL] {}'.format(str(id)))
    results = cursor.fetchone()

    try:
        results
    except:
        raise Http404

    data = {
        "contrato": results,
    }

    return render(request, 'contrato/contract.html', data)


# Listar contratos del cliente
@login_required
def ContratoClientView(request):
    datos = request.user

    cursor = connection.cursor()
    cursor.execute(
        'EXEC [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] [{}]'.format(str(datos.username)))
    results = cursor.fetchall()

    cantidad = Contrato.objects.filter(rutcliente=datos.username).count()

    data = {
        # 'user': formatRut(str(datos.username)),
        'entity': results,
        'cantidad': cantidad
    }

    return render(request, 'contrato/contratos_client.html', data)


@login_required
def ContratoEmpleadoView(request):
    datos = request.user

    cantidad = Contrato.objects.filter(rutempleado=datos.username).count()
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL] [{}]'.format(
        str(datos.username)))
    results = cursor.fetchall()

    data = {
        # 'user': formatRut(str(datos.username)),
        'entity': results,
        'cantidad': cantidad
    }

    return render(request, 'contrato/contratos_emp.html', data)


# Pagos
@login_required
def ListPagosView(request):
    datos = request.user

    cantidad = Contrato.objects.all().filter(rutcliente=datos.username).count()
    cursor = connection.cursor()
    cursor.execute(
        'EXEC [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] [{}]'.format(str(datos.username)))
    results = cursor.fetchall()

    data = {
        # 'user': formatRut(datos.username),
        'entity': results,
        'c': cantidad
    }

    return render(request, 'pagos/pagos.html', data)


@login_required
def PagosContractView(request, pk):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_PAGOS_CONTRATO] {}'.format(str(pk)))
    results = cursor.fetchall()

    try:
        results
    except:
        raise Http404

    data = {
        "entity": results,
        'c': pk,
    }

    return render(request, 'pagos/tabla_pagos.html', data)


@login_required
def PagosDetailView(request, pk):
    cursor = connection.cursor()
    cursor.execute('EXEC [dbo].[SP_PAGOS_CONTRATO] {}'.format(str(pk)))
    results = cursor.fetchall()

    try:
        results
    except:
        raise Http404

    data = {
        "entity": results,
        'c': pk,
    }

    return render(request, 'pagos/detalle_pago.html', data)


# PDF Contrato
class ContractDetailPdf(View):
    def get(self, request, *args, **kwargs):
        pk = self.kwargs['pk']
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_CONTRACT_DETAIL] {}'.format(str(pk)))
        results = cursor.fetchone()

        template = get_template('pdf.html')
        response = HttpResponse(content_type='application/pdf')
        # response['Content-Disposition'] = 'attachment; filename="detalle_contrato.pdf"'
        context = {
            'comp': {'name': 'ControlRisk', 'rut': '99.999.999-k', 'direccion': 'Avenida Siempreviva 742'},
            'contrato': results
        }
        html = template.render(context)
        pisa_status = pisa.CreatePDF(html, dest=response)

        return response


# Actividades
# Asesorias ciente
@login_required
def AsesoriaClienteView(request):

    return render(request, 'asesorias/asesorias_cliente.html')


@login_required
def AsesoriaEspecialClienteView(request):
    usuario = request.user
    data = {
        'form': CreateAsesoriaEspecial()
    }

    if request.method == "POST":
        formulario = CreateAsesoriaEspecial(request.POST)
        if formulario.is_valid():
            asesoria = Asesoria()
            asesoria.fechaasesoria = request.POST.get('fecha')
            asesoria.hora = request.POST.get('hora')
            asesoria.descripcionasesoria = request.POST.get('descripcion')

            # fHora = datetime.strptime(hora, '%H:%M').time()
            # fFecha = datetime.strptime(
            #     asesoria.fechaasesoria, '%Y-%m-%d').date()

            from django.db import connection
            with connection.cursor() as cursor:

                cursor = connection.cursor()
                cursor.execute('EXEC [dbo].[SP_ASESORIA_ESPECIAL] %s, %s, %s, %s',
                               (asesoria.fechaasesoria, asesoria.descripcionasesoria, asesoria.hora, usuario.username))

                messages.success(
                    request, "Solicitud de asesoria ingresada correctamente")

            return render(request, 'asesorias/asesoria_especial.html', data)
        else:
            messages.error(
                request, "Error al ingresar solicitud")

    return render(request, 'asesorias/asesoria_especial.html', data)
