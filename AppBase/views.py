from multiprocessing import connection, context
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

from AppBase.forms import CreateClienteForm, CreateEmpleadoForm, CreateContratoForm
from AppBase.models import Cliente, Empleado, Contrato
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
    return render(request, 'home.html')


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

            if request.method == "POST":
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
                                                                                                         clientesave.razonsocial, clientesave.rubro,  clientesave.direccion, clientesave.telefono, clientesave.representante,
                                                                                                         rut_repre))

                            messages.success(request, "Cliente " +
                                             formatRut(rut_cli) + " registrado correctamente ")

                            return render(request, 'create_cliente.html', data)
                else:
                    messages.error(request, "Cliente " +
                                   formatRut(rut_cli) + " invalido ")

    return render(request, 'cliente/create_cliente.html', data)


@login_required
def CreateEmpleado(request):
    data = {
        'emp': CreateEmpleadoForm()
    }
    if request.method == "POST":
        if request.POST.get('rut') and request.POST.get('nombre') and request.POST.get('apellido') and request.POST.get('cargo'):
            empsave = Empleado()
            empsave.rutempleado = request.POST.get('rut')
            empsave.nombre = request.POST.get('nombre')
            empsave.apellido = request.POST.get('apellido')
            empsave.cargo = request.POST.get('cargo')

            rut_emp = rut(empsave.rutempleado)

            if request.method == "POST":
                existe = Empleado.objects.filter(rutempleado=rut_emp).exists()
                user_exist = User.objects.filter(username=rut_emp).exists()

                if rut_chile.is_valid_rut(empsave.rutempleado):
                    if existe and user_exist:
                        messages.error(request, "El rut " +
                                    formatRut(rut_emp) + " ya está registrado en el sistema!")
                    else:
                        if request.method == "POST":
                            username = rut_emp
                            password = rut_emp[4:]
                            
                            if empsave.cargo == 'Profesional':
                                user = get_user_model().objects.create(
                                    username=username,
                                    password=make_password(password),
                                    is_active=True,
                                    is_profesional=True
                                )
                            else:
                                user = get_user_model().objects.create(
                                    username=username,
                                    password=make_password(password),
                                    is_active=True,
                                    is_profesional=False
                                )

                            from django.db import connection
                            with connection.cursor() as cursor:

                                cursor.execute('EXEC [dbo].[SP_CREATE_EMPLEADO] %s, %s, %s, %s', (
                                    empsave.rut, empsave.nombre, empsave.apellido, empsave.cargo))

                                messages.success(request, "Empleado " +
                                                empsave.rut+" registrado correctamente ")

                            return render(request, 'empleados/create_empleado.html', data)
                else:
                    messages.error(request, "Cliente " + formatRut(rut_emp) + " invalido ")

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

    filtro = Contrato.objects.filter(rutcliente=datos.username)
    cantidad = filtro.count()

    data = {
        'user': formatRut(str(datos.username)),
        'entity': results,
        'cantidad': cantidad
    }

    return render(request, 'contrato/contratos_client.html', data)


# Pagos
@login_required
def ListPagosView(request):
    datos = request.user
    filtro = Contrato.objects.all().filter(rutcliente=datos.username)

    cursor = connection.cursor()
    cursor.execute(
        'EXEC [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] [{}]'.format(str(datos.username)))
    results = cursor.fetchall()
    cantidad = filtro.count()

    data = {
        'user': formatRut(str(datos.username)),
        'entity': results,
        'c': cantidad,
        'u': datos,
        'contratos': filtro,
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
