from .utils import get_graph, get_barplot, get_pieplot, get_groupedbar
from multiprocessing import connection, context
from re import I

from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.http.response import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.http import Http404, HttpResponseRedirect
from django.db import connection
from django.contrib.auth import authenticate, login, get_user_model
from django.contrib.auth.models import Group
from django.core.paginator import Paginator
from django.contrib import messages
from django.urls import reverse_lazy
from django.views.generic import TemplateView
from django.db.models.functions import Coalesce
from django.db.models import Count, Sum

from django.core.mail import EmailMessage
from django.template import RequestContext, context

from AppBase.forms import CreateAsesoriaEspecial, CreateClienteForm, CreateEmpleadoForm, CreateContratoForm, CreateAccidenteForm, EstadoAsesoria, EstadoVisita, ChecklistItem, ChecklistForm
from AppBase.models import Asesoria, Capacitacion, Cliente, Empleado, Contrato, Accidente, Historialactividad, Itemschecklist, Mejora, Valorextra, Pagos, Visita
from AppUser.models import User

from datetime import datetime, timedelta, date
from dateutil.relativedelta import *
from dateutil.easter import *
from dateutil.rrule import *
from dateutil.parser import *
from django.views import View

from django.http import HttpResponse
from django.template.loader import get_template
from xhtml2pdf import pisa
from rut_chile import rut_chile
from collections import OrderedDict

import base64
from io import BytesIO
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')


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
    user = request.user

    data = {
        'user': user,
    }

    if user.is_profesional == 0 and user.is_staff == 0:
        activo = Contrato.objects.filter(
            rutcliente=user.username).filter(estado=1).count()

        try:
            activo
        except:
            raise Http404

        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute('SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(str(user.username)[:-1]))

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(str(user.username)[:-1]))

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            try:
                pagoActual,
                pago
            except:
                raise Http404

            data = {
                'user': user,
                'pago': estadoPago,
                'fechaPago': fechaPago,
                'fechaVenc': fechaVenc,
                'mes': mesPago,
                'id': pagoId,
                'activo': activo
            }

            if estadoPago == False:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                return render(request, 'home.html', data)

    return render(request, 'home.html', data)


@login_required
def CreateClient(request):
    datos = request.user
    data = {
        'form': CreateClienteForm()
    }
    if datos.is_profesional == 1 or datos.is_staff == 1:
        if request.method == "POST":
            formulario = CreateClienteForm(request.POST)
            if formulario.is_valid():
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

                if rut_chile.is_valid_rut(clientesave.rutcliente) == True:
                    if rut_chile.is_valid_rut(clientesave.rutrepresentante) == True:
                        if existe or user_exist:
                            messages.error(
                                request, "El rut " + formatRut(rut_cli) + " ya está registrado en el sistema!")

                        else:
                            username = rut_cli
                            password = rut_cli[4:]
                            group = Group.objects.get(name='Cliente')
                            user = get_user_model().objects.create(
                                username=username,
                                password=make_password(password),
                                is_active=True,
                                is_profesional=False
                            )

                            user.groups.add(group)

                            from django.db import connection
                            with connection.cursor() as cursor:

                                cursor.execute('EXEC [dbo].[SP_CREATE_CLIENTE] %s, %s, %s, %s, %s, %s, %s', (rut_cli,
                                                                                                             clientesave.razonsocial, clientesave.rubro,  clientesave.direccion, clientesave.telefono, clientesave.representante, rut_repre))

                                messages.success(
                                    request, "Cliente " + formatRut(rut_cli) + " registrado correctamente ")
                                return render(request, 'cliente/create_cliente.html', data)
                    else:
                        messages.warning(request, "RUT: " +
                                         formatRut(rut_repre) + " es invalido")
                else:
                    messages.warning(request, "RUT: " +
                                     formatRut(rut_cli) + " es invalido")

        return render(request, 'cliente/create_cliente.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def CreateEmpleado(request):
    datos = request.user

    if datos.is_staff == 1:
        data = {
            'emp': CreateEmpleadoForm()
        }

        if request.method == "POST":
            formulario = CreateEmpleadoForm(request.POST)
            if formulario.is_valid():
                empsave = Empleado()
                empsave.rutempleado = request.POST.get('rut')
                empsave.nombre = request.POST.get('nombre')
                empsave.apellido = request.POST.get('apellido')
                empsave.cargo = request.POST.get('cargo')

                if empsave.cargo == 'Profesional':
                    profesional = True
                    staff = False
                    group = Group.objects.get(name='Profesional')
                else:
                    profesional = False
                    staff = True
                    group = Group.objects.get(name='Administrador')

                rut_emp = rut(empsave.rutempleado)

                existe = Empleado.objects.filter(rutempleado=rut_emp).exists()
                user_exist = User.objects.filter(username=rut_emp).exists()

                if rut_chile.is_valid_rut(empsave.rutempleado) == True:
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
                            is_staff=staff,
                        )

                        user.groups.add(group)

                        from django.db import connection
                        with connection.cursor() as cursor:

                            cursor.execute('EXEC [dbo].[SP_CREATE_EMPLEADO] %s, %s, %s, %s', (
                                rut_emp, empsave.nombre, empsave.apellido, empsave.cargo))

                            messages.success(
                                request, "Empleado " + formatRut(rut_emp) + " registrado correctamente ")
                            return render(request, 'empleados/create_empleado.html', data)
                else:
                    messages.warning(request, "RUT: " +
                                     formatRut(rut_emp) + " es invalido")

        return render(request, 'empleados/create_empleado.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def ListClienteView(request):
    datos = request.user

    if datos.is_staff == 1 or datos.is_profesional == 1:
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
    else:
        return render(request, 'error/auth.html')


@login_required
def CreateAccidentView(request):
    datos = request.user

    if datos.is_staff == 0 and datos.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago,
                'fechaVenc': fechaVenc,
                'mes': mesPago,
                'id': pagoId
            }

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                if request.method == "POST":
                    formulario = CreateAccidenteForm(request.POST)
                    if formulario.is_valid():
                        accidentesave = Accidente()
                        accidentesave.fecha = request.POST['fecha']
                        accidentesave.descripcion = request.POST['descripcion']
                        accidentesave.medidas = request.POST['medidas']

                        cursor.execute('EXEC [dbo].[SP_CREATE_ACCIDENTE]  %s, %s, %s, %s', (accidentesave.fecha,
                                                                                            accidentesave.descripcion,
                                                                                            accidentesave.medidas,
                                                                                            str(datos.username)))

                        messages.success(
                            request, "Accidente registrado correctamente")

                        return render(request, 'accidentes/create_accident.html', data)
                    else:
                        messages.error(request, "Formulario no valido")
                return render(request, 'accidentes/create_accident.html', data)
    else:
        return render(request, 'error/auth.html')


# Vistas Contrato
# Creación de contrato
@login_required
def CreateContractView(request):
    datos = request.user

    data = {
        'contract': CreateContratoForm()
    }

    if datos.is_staff == 1 or datos.is_profesional == 1:
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
    else:
        return render(request, 'error/auth.html')


# Listar todos los contratos del sistema
@login_required
def ListContractView(request):
    datos = request.user

    if datos.is_staff == 1:
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
    else:
        return render(request, 'error/auth.html')


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

    if datos.is_staff == 0 and datos.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                cursor = connection.cursor()
                cursor.execute(
                    'EXEC [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] [{}]'.format(datos.username))
                results = cursor.fetchall()

                cantidad = Contrato.objects.filter(
                    rutcliente=datos.username).count()

                try:
                    cantidad,
                    results
                except:
                    raise Http404

                data = {'entity': results, 'cantidad': cantidad}

                return render(request, 'contrato/contratos_client.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def ContratoEmpleadoView(request):
    datos = request.user

    if datos.is_profesional == 1:
        cantidad = Contrato.objects.filter(rutempleado=datos.username).count()
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_LISTAR_CONTRATOS_PROFESIONAL] [{}]'.format(
            str(datos.username)[:-1]))
        results = cursor.fetchall()

        try:
            results, cantidad
        except:
            raise Http404

        data = {
            'rut': formatRut(str(datos.username)),
            'entity': results,
            'cantidad': cantidad
        }

        return render(request, 'contrato/contratos_emp.html', data)
    else:
        return render(request, 'error/auth.html')


# Pagos
@login_required
def ListPagosView(request):
    datos = request.user

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cantidad = Contrato.objects.all().filter(rutcliente=datos.username).count()
        cursor = connection.cursor()

        cursor.execute(
            'EXEC [dbo].[SP_CONTRATO_ACTIVO] [{}]'.format(str(datos.username)[:-1]))
        results = cursor.fetchall()

        cursor.execute(
            'EXEC [dbo].[SP_LISTAR_CONTRATOS_CLIENTE] [{}]'.format(str(datos.username)[:-1]))
        contratos = cursor.fetchall()

        try:
            cantidad, results, contratos
        except:
            raise Http404

        data = {
            # 'user': formatRut(datos.username),
            'entity': results,
            'contratos': contratos,
            'c': cantidad
        }

        return render(request, 'pagos/pagos.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def PagosContractView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato WHERE ContratoID = {} '.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            cursor.execute('EXEC [dbo].[SP_PAGOS_CONTRATO] {}'.format(str(pk)))
            results = cursor.fetchall()

            cursor.execute(
                'EXEC [dbo].[SP_PAGOS_CONTRATO_MES_ACTUAL] {}'.format(str(pk)))
            pagosMesActual = cursor.fetchall()

            try:
                results, pagosMesActual
            except:
                raise Http404

            data = {
                "entity": results,
                'c': pk,
                'pagosMes': pagosMesActual
            }

            return render(request, 'pagos/tabla_pagos.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


@login_required
def PagosDetailView(request, pk):
    datos = request.user

    if datos.is_staff == 0 and datos.is_profesional == 0:
        cursor = connection.cursor()
        cursor.execute(
            'SELECT RutCliente, Contrato.ContratoID FROM Contrato JOIN Pagos ON (Contrato.ContratoID = Pagos.ContratoID) WHERE PagosID = {} '.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]
            cid = i[1]

        if datos.username == cliente:
            cursor.execute('EXEC [dbo].[SP_DETALLE_PAGO] {}'.format(str(pk)))
            results = cursor.fetchall()

            cursor.execute('EXEC SP_ASORIAS_EXTRAS {}, {}'.format(pk, cid))
            asesoriaExtras = cursor.fetchall()
            valorAsesoria = Valorextra.objects.filter(nombre='Asesoria').get()

            cursor.execute(
                'EXEC SP_CAPACITACION_EXTRAS {}, {}'.format(pk, cid))
            capacitacionExtras = cursor.fetchall()
            valorCapacitacion = Valorextra.objects.filter(
                nombre='Capacitacion').get()

            cursor.execute('EXEC SP_VISITA_EXTRAS {}, {}'.format(pk, cid))
            visitaExtras = cursor.fetchall()
            valorVisita = Valorextra.objects.filter(nombre='Visita').get()

            try:
                results, asesoriaExtras, valorAsesoria, capacitacionExtras, valorCapacitacion, visitaExtras, valorVisita
            except:
                raise Http404

            data = {
                'asesoriaExtras': asesoriaExtras,
                'cantidadAsesorias': len(asesoriaExtras),
                'valorAsesoria': valorAsesoria,
                'capacitacionExtras': capacitacionExtras,
                'cantidadCapacitaciones': len(capacitacionExtras),
                'valorCapacitacion': valorCapacitacion,
                'visitaExtras': visitaExtras,
                'valorVisita': valorVisita,
                'cantidadVisita': len(visitaExtras),
                'entity': results,
                'c': pk,
                'a': cid
            }

            return render(request, 'pagos/detalle_pago.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


# PDF Contrato
class ContractDetailPdf(View):
    def get(self, request, *args, **kwargs):
        pk = self.kwargs['pk']
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_CONTRACT_DETAIL] {}'.format(str(pk)))
        results = cursor.fetchone()

        try:
            results
        except:
            raise Http404

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


# Asesorias especial
@login_required
def AsesoriaEspecialClienteView(request):
    usuario = request.user

    data = {
        'form': CreateAsesoriaEspecial()
    }

    if usuario.is_staff == 0 and usuario.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=usuario.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(usuario.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(usuario.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                if request.method == "POST":
                    formulario = CreateAsesoriaEspecial(request.POST)
                    if formulario.is_valid():
                        asesoria = Asesoria()
                        asesoria.fechaasesoria = request.POST.get('fecha')
                        asesoria.hora = request.POST.get('hora')
                        asesoria.descripcionasesoria = request.POST.get(
                            'descripcion')

                        cursor = connection.cursor()
                        cursor.execute('EXEC [dbo].[SP_ASESORIA_ESPECIAL] %s, %s, %s, %s',
                                       (asesoria.fechaasesoria, asesoria.descripcionasesoria, asesoria.hora, usuario.username))

                        messages.success(
                            request, "Solicitud de asesoria ingresada correctamente")
                        return render(request, 'asesorias/asesoria_especial.html', data)
                    else:
                        messages.error(request, "Error al ingresar solicitud")

        return render(request, 'asesorias/asesoria_especial.html', data)
    else:
        return render(request, 'error/auth.html')


# Asesorias ciente
@login_required
def AsesoriaClienteView(request):
    usuario = request.user
    cursor = connection.cursor()

    if usuario.is_staff == 0 and usuario.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=usuario.username).filter(estado=1).count()
        cursor.execute('SELECT dbo.FN_GET_ID({})'.format(usuario.username[:-1]))
        contrato = cursor.fetchall()

        try:
            activo, contrato
        except:
            raise Http404

        for i in contrato:
            cid = i[0]

        cursor.execute(
            'SELECT RutCliente FROM Contrato WHERE ContratoID = {} '.format(cid))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if usuario.username == cliente:
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                cursor = connection.cursor()
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(usuario.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(usuario.username[:-1]))

                try:
                    pago
                except:
                    raise Http404

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    activo = Contrato.objects.filter(
                        rutcliente=usuario.username).filter(estado=1).count()
                    cursor = connection.cursor()
                    mesActual = cursor.execute(
                        'EXEC [dbo].[SP_ASESORIAS_CLIENTE_MES_ACTUAL] [{}]'.format(str(usuario.username)[:-1]))
                    asesoriasMesuales = mesActual.fetchall()

                    cursor.execute('EXEC [dbo].[SP_ASESORIAS_CLIENTE] [{}]'.format(
                        str(usuario.username)[:-1]))
                    result = cursor.fetchall()

                    try:
                        activo, mesActual, asesoriasMesuales, result
                    except:
                        raise Http404

                    data = {
                        'entity': result,
                        'rut': formatRut(usuario.username),
                        'mesuales': asesoriasMesuales,
                        'c': len(asesoriasMesuales),
                        'activo': activo}

            return render(request, 'asesorias/asesorias_cliente.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleAsesoriaClienteView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Asesoria ON (Contrato.ContratoID = Asesoria.ContratoID) WHERE AsesoriaID = {}'.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                try:
                    pago
                except:
                    raise Http404

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_DETALLE_ASESORIA] {}'.format(pk))
                    results = cursor.fetchall()

                    try:
                        results
                    except:
                        raise Http404

                    data = {
                        'entity': results,
                        'id': pk,
                        'rut': formatRut(datos.username)
                    }

                    return render(request, 'asesorias/detalle_asesoria_cliente.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


# Capacitaciones ciente
@login_required
def CapacitacionesView(request):
    usuario = request.user

    if usuario.is_staff == 0 and usuario.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=usuario.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(usuario.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(usuario.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                activo = Contrato.objects.filter(
                    rutcliente=usuario.username).filter(estado=1).count()

                cursor = connection.cursor()
                mesActual = cursor.execute(
                    'EXEC [dbo].[SP_CAPACITACIONES_CLIENTE_MES_ACTUAL] [{}]'.format(str(usuario.username)[:-1]))
                capacitacionesMensuales = mesActual.fetchall()

                cursor.execute('EXEC [dbo].[SP_CAPACITACIONES_CLIENTE] [{}]'.format(
                    str(usuario.username)[:-1]))
                result = cursor.fetchall()

                try:
                    result, mesActual, capacitacionesMensuales
                except:
                    raise Http404

                data = {
                    'entity': result,
                    'cp': len(result),
                    'rut': formatRut(usuario.username),
                    'mensual': capacitacionesMensuales,
                    'c': len(capacitacionesMensuales),
                    'activo': activo
                }

                return render(request, 'capacitaciones/capacitaciones_cliente.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleCapacitacionView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Capacitacion ON (Contrato.ContratoID = Capacitacion.ContratoID) WHERE CapacitacionID = {}'.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                try:
                    pago
                except:
                    raise Http404

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_DETALLE_CAPACITACION] {}'.format(pk))
                    results = cursor.fetchall()

                    try:
                        results
                    except:
                        raise Http404

                    data = {
                        'entity': results,
                        'id': pk,
                        'rut': formatRut(datos.username)
                    }

                    return render(request, 'capacitaciones/detalle_capacitacion.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


# Visitas ciente
@login_required
def VisitasClienteView(request):
    usuario = request.user

    if usuario.is_staff == 0 and usuario.is_profesional == 0:
        activo = Contrato.objects.filter(
            rutcliente=usuario.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(usuario.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(usuario.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                activo = Contrato.objects.filter(
                    rutcliente=usuario.username).filter(estado=1).count()

                cursor = connection.cursor()
                mesActual = cursor.execute(
                    'EXEC [dbo].[SP_VISITAS_CLIENTE_MES_ACTUAL] [{}]'.format(str(usuario.username)[:-1]))
                visitasMesuales = mesActual.fetchall()

                cursor = connection.cursor()
                cursor.execute('EXEC [dbo].[SP_VISITAS_CLIENTE] [{}]'.format(
                    str(usuario.username)[:-1]))
                result = cursor.fetchall()

                try:
                    mesActual, visitasMesuales, result
                except:
                    raise Http404

                data = {
                    'entity': result,
                    'rut': formatRut(usuario.username),
                    'mensual': visitasMesuales,
                    'c': len(visitasMesuales),
                    'activo': activo
                }

                return render(request, 'visitas/visitas_cliente.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleVisitaView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Visita ON (Contrato.ContratoID = Visita.ContratoID) WHERE VisitaID = {}'.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                try:
                    pago
                except:
                    raise Http404

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_DETALLE_VISITA] {}'.format(pk))
                    results = cursor.fetchall()

                    try:
                        results
                    except:
                        raise Http404

                    data = {
                        'entity': results,
                        'id': pk,
                        'rut': formatRut(datos.username)
                    }

                    return render(request, 'visitas/detalle_visita.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')



@login_required
def ModificarFechaVisitaView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Visita ON (Contrato.ContratoID = Visita.ContratoID) WHERE VisitaID = {}'.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                try:
                    pago
                except:
                    raise Http404

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_DETALLE_VISITA] {}'.format(pk))
                    results = cursor.fetchall()

                    try:
                        results
                    except:
                        raise Http404

                    for i in results:
                        empleado = i[11]

                    if request.method == 'POST':
                        fecha = request.POST.get('fecha')
                        hora = request.POST.get('hora')

                        fechaOcupada = Visita.objects.filter(contratoid__rutempleado=rut(empleado), fechavisita=fecha).exists()

                        data = {
                            'entity': results,
                            'id': pk,
                            'rut': formatRut(datos.username)
                        }

                        if fechaOcupada:
                            messages.warning(request, 'El profesional ' + empleado + ' posee una visita agendada en la fecha ingresada. Por favor ingrese una nueva')
                            return render(request, 'visitas/modificar_visita.html', data)
                        else:
                            Visita.objects.filter(visitaid=int(pk)).update(fechavisita=fecha, hora=hora)
                            messages.success(request, 'Fecha y Hora asignadas correctamente')
                            return render(request, 'visitas/modificar_visita.html', data)

                    data = {
                        'entity': results,
                        'id': pk,
                        'rut': formatRut(datos.username)
                    }
                    
                    return render(request, 'visitas/modificar_visita.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


# Actividades empleado
@login_required
def AsesoriasEmpleadoView(request):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_ACTIVIDAD_EMPLEADO] [{}]'.format(str(datos.username)[:-1]))
        results = cursor.fetchall()

        try:
            results
        except:
            raise Http404

        data = {
            'entity': results,
            'rut': formatRut(datos.username),
            'c': len(results)
        }

        return render(request, 'actividades/asesorias_emp.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleAsesoriaView(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 1:
        cursor.execute('EXEC [dbo].[SP_DETALLE_ASESORIA] {}'.format(pk))
        results = cursor.fetchall()

        try:
            results
        except:
            raise Http404

        data = {
            'entity': results,
            'id': pk
        }

        if request.method == "POST":
            formulario = EstadoAsesoria(request.POST)
            if formulario.is_valid():
                estado = request.POST.get('estado')

                cursor.execute(
                    'EXEC [dbo].[SP_CAMBIAR_ESTADO_ASESORIA] %s, %s', (estado, pk))
                messages.success(
                    request, "Se ha modificado el estado correctamente")

                return render(request, 'actividades/asesoria_detalle.html', data)
            else:
                messages.error(
                    request, "Error al modificar estado")

        return render(request, 'actividades/asesoria_detalle.html', data)
    else:
        return render(request, 'error/auth.html')


# Capacitaciones empleado por semana
@login_required
def CapacitacioesEmpleadoView(request):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_ACTIVIDAD_EMPLEADO_CAPACITACION] [{}]'.format(
            str(datos.username)[:-1]))
        results = cursor.fetchall()

        try:
            results
        except:
            raise Http404

        data = {
            'entity': results,
            'rut': formatRut(datos.username),
            'c': len(results)
        }

        return render(request, 'actividades/capacitacion_emp.html', data)
    else:
        return render(request, 'error/auth.html')


# Visitas empleado por semana
@login_required
def VisitasEmpleadoView(request):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_ACTIVIDAD_EMPLEADO_VISITA] [{}]'.format(str(datos.username)[:-1]))
        results = cursor.fetchall()

        try:
            results
        except:
            raise Http404

        data = {
            'entity': results,
            'rut': formatRut(datos.username),
            'c': len(results)
        }

        return render(request, 'actividades/visitas_emp.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleVisitaEmpleadoView(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_DETALLE_VISITA] {}'.format(pk))
        results = cursor.fetchall()

        try:
            results
        except:
            raise Http404

        data = {
            'entity': results,
            'id': pk
        }

        if request.method == "POST":
            formulario = EstadoVisita(request.POST)
            if formulario.is_valid():
                estado = request.POST.get('estado')

                cursor.execute(
                    'EXEC [dbo].[SP_CAMBIAR_ESTADO_VISITA] %s, %s', (estado, pk))
                messages.success(
                    request, "Se ha modificado el estado correctamente")

                return render(request, 'actividades/visita_detalle_empleado.html', data)
            else:
                messages.error(
                    request, "Error al modificar estado")

        return render(request, 'actividades/visita_detalle_empleado.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def ChecklistView(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        items = Itemschecklist.objects.all().filter(visitaid=pk)
        results = items
        c = items.count()

        data = {
            'id': pk,
            'entity': results,
            'form': ChecklistItem(),
            'c': c
        }

        if 'btnitem' in request.POST:
            nombre = request.POST.get('nombre')
            check = Itemschecklist.objects.filter(itemcheclistid=pk)
            if check.filter(nombre=nombre).exists():
                messages.error(request, "Ya está ingresado")
            else:
                cursor = connection.cursor()
                cursor.execute(
                    'EXEC [dbo].[SP_AGREGAR_ITEM_CHECKLIST] %s, %s', (nombre, pk))

                messages.success(request, "Item agregado correctamente")

                return render(request, 'checklist/checklist.html', data)

        if 'btn' in request.POST:
            id_list_a = request.POST.getlist('boxesa')
            id_list_sa = request.POST.getlist('boxessa')
            id_list_r = request.POST.getlist('boxesr')

            for x in id_list_a:
                Itemschecklist.objects.filter(pk=int(x)).update(aprobado=True)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(semiaprobado=False)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(reprobado=False)

            for x in id_list_sa:
                Itemschecklist.objects.filter(pk=int(x)).update(aprobado=False)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(semiaprobado=True)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(reprobado=False)

            for x in id_list_r:
                Itemschecklist.objects.filter(pk=int(x)).update(aprobado=False)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(semiaprobado=False)
                Itemschecklist.objects.filter(
                    pk=int(x)).update(reprobado=True)

            messages.success(request, "Checklist guardada correctamente")

            return render(request, 'checklist/checklist.html', data)
        else:
            return render(request, 'checklist/checklist.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def ClientesEmpleadoView(request):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_LISTAR_CLIENTES_EMP] {}'.format(str(datos.username)[:-1]))
        result = cursor.fetchall()

        try:
            result
        except:
            raise Http404

        data = {
            'clientes': result,
            'rut': formatRut(datos.username)
        }

        return render(request, 'cliente/listar_clientes_emp.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def ClienteDetalle(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_DETALLE_CLIENTE] {}'.format(str(pk)))
        result = cursor.fetchall()

        contrato = Contrato.objects.filter(rutcliente=str(pk)).filter(estado=1)

        cursor.execute('EXEC [dbo].[SP_ID_CONTRATO_ACTIVO] {}'.format(str(pk)))
        activo = cursor.fetchall()

        try:
            result, contrato, activo
        except:
            raise Http404

        data = {
            'rut': formatRut(pk),
            'entity': result,
            'activo': contrato.count(),
            'contrato': activo
        }

        return render(request, 'cliente/detalle_cliente.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def PerfilUsuario(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_DETALLE_CUENTA_EMPLEADO] {0}'.format(datos.username[:-1]))
        result = cursor.fetchall()

        try:
            result
        except:
            raise Http404

        data = {
            'entity': result,
            'rut': formatRut(datos.username)
        }

    if datos.is_profesional == 0 and datos.is_staff == 0 and datos.is_superuser == 0:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                cursor = connection.cursor()
                cursor.execute(
                    'EXEC [dbo].[SP_DETALLE_CUENTA_CLIENTE] {0}'.format(datos.username[:-1]))
                result = cursor.fetchall()

                try:
                    result
                except:
                    raise Http404

                data = {
                    'entity': result,
                    'rut': formatRut(datos.username)
                }

    return render(request, 'perfil/perfil.html', data)


@login_required
def DetalleChecklist(request, pk):
    datos = request.user
    cursor = connection.cursor()

    if datos.is_profesional == 0 and datos.is_staff == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Visita ON (Contrato.ContratoID = Visita.ContratoID) WHERE VisitaID = {} '.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                try:
                    pago
                except:
                    raise Http404

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_DETALLE_CHECKLIST] {}'.format(pk))
                    result = cursor.fetchall()

                    try:
                        result
                    except:
                        raise Http404

                    data = {
                        'entity': result,
                        'id': pk
                    }

                    return render(request, 'checklist/detalle_checklist.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


@login_required
def TasaAccidentabildiadView(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        contrato = Contrato.objects.filter(contratoid=int(pk)).filter(estado=1)
        cursor = connection.cursor()
        cursor.execute(
            'SELECT YEAR([FechaCreacion]) FROM [Contrato] WHERE [ContratoID] = {}'.format(pk))
        annio = cursor.fetchall()

        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_LISTAR_TASA_CONTRATO] {}'.format(pk))
        result = cursor.fetchall()

        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_LISTAR_TASA_CONTRATO_ANUAL] {}'.format(pk))
        anual = cursor.fetchall()

        date = datetime.now()
        periodo = date.strftime('%Y-%m')

        cursor.execute(
            'SELECT [dbo].[FN_ACCIDENTES_PERIODO](%s, %s)', (pk, periodo))
        accidentes = cursor.fetchall()

        try:
            contrato, annio, result, anual, accidentes
        except:
            raise Http404

        data = {
            'id': pk,
            'contrato': contrato,
            'annio': annio,
            'entity': result,
            'accidente': accidentes,
            'anual': anual,
        }

        if 'btnmensual' in request.POST:
            cursor = connection.cursor()
            cursor.execute(
                'EXEC [dbo].[SP_TASA_ACCIDENTE_MENSUAL] %s, %s', (pk, periodo))

            return render(request, 'accidentes/tasa_accidentabilidad.html', data)

        if 'btnanual' in request.POST:
            cursor = connection.cursor()
            cursor.execute(
                'EXEC [dbo].[SP_TASA_ACCIDENTE_ANUAL] {}'.format(pk))

            return render(request, 'accidentes/tasa_accidentabilidad.html', data)

        return render(request, 'accidentes/tasa_accidentabilidad.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def InformeVisitaEmp(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        fecha = datetime.now()
        cursor = connection.cursor()
        cursor.execute(
            'SELECT [RazonSocial], [Cliente].[RutCliente], [FechaVisita] FROM [Cliente] JOIN [Contrato] ON (Cliente.RutCliente = Contrato.RutCliente) JOIN [Visita] ON (Contrato.ContratoID = Visita.ContratoID) WHERE [Visita].[VisitaID] = {}'.format(pk))
        visita = cursor.fetchall()

        try:
            visita
        except:
            raise Http404

        data = {
            'id': pk,
            'fecha': fecha,
            'visita': visita
        }

        if 'btninforme' in request.POST:
            situacion = request.POST.get('situacion')
            rut = request.POST.get('rut')
            empresa = request.POST.get('empresa')
            fechavisita = request.POST.get('fecha')

            cursor.execute(
                'EXEC [dbo].[SP_INFORME_VISITA] %s, %s', (situacion, pk))

            messages.success(request, 'Informe guardardo correctamente')

            return render(request, 'informes/informe_visita.html', data)

        if 'btnmejora' in request.POST:
            plan = request.POST.get('mejora')

            cursor.execute(
                'EXEC [dbo].[SP_CREAR_PLAN_MEJORA] %s, %s', (pk, plan))

            messages.success(request, 'Plan generado Correctamente')

            return render(request, 'informes/informe_visita.html', data)

        return render(request, 'informes/informe_visita.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def InformeVisitaCliente(request, pk):
    datos = request.user

    if datos.is_profesional == 0 and datos.is_staff == 0 and datos.is_superuser == 0:
        cursor.execute(
            'SELECT RutCliente FROM Contrato JOIN Visita ON (Contrato.ContratoID = Visita.ContratoID) WHERE VisitaID = {} '.format(pk))
        rutcli = cursor.fetchall()

        try:
            rutcli
        except:
            raise Http404

        for i in rutcli:
            cliente = i[0]

        if datos.username == cliente:
            activo = Contrato.objects.filter(
                rutcliente=datos.username).filter(estado=1).count()
            if activo == 0:
                return render(request, 'contrato/contrato_inactivo.html')
            else:
                cursor = connection.cursor()
                pagoActual = cursor.execute(
                    'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

                try:
                    pagoActual
                except:
                    raise Http404

                for i in pagoActual:
                    estadoPago = i[0]

                pago = cursor.execute(
                    'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

                try:
                    pago
                except:
                    raise Http404

                for a in pago:
                    fechaPago = a[0]
                    fechaVenc = a[1]
                    mesPago = a[2]
                    pagoId = a[3]

                data = {
                    'pago': estadoPago,
                    'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                    'mes': mesPago, 'id': pagoId}

                if estadoPago == 0:
                    return render(request, 'pagos/pago_venc.html', data)
                else:
                    cursor = connection.cursor()
                    cursor.execute(
                        'EXEC [dbo].[SP_INFORME_VISITA_CLI] {}'.format(pk))
                    result = cursor.fetchall()

                    plan = cursor.execute(
                        'EXEC [dbo].[SP_PLAN_MEJORA_INFO] {}'.format(pk))
                    mejora = plan.fetchall()

                    try:
                        result, mejora, plan
                    except:
                        raise Http404

                    data = {
                        'id': pk,
                        'entity': result,
                        'mejora': mejora,
                        'c': len(mejora)
                    }

                    return render(request, 'informes/informe_visita_cliente.html', data)
        else:
            return render(request, 'error/auth.html')
    else:
        return render(request, 'error/auth.html')


@login_required
def DetallePlanMejora(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_DETALLE_PLAN_MEJORA_EMP] {}'.format(pk))
        result = cursor.fetchall()

        try:
            result
        except:
            raise Http404

        data = {
            'id': pk,
            'entity': result,
        }

        if request.method == 'POST':
            estado = request.POST.get('estado')

            if estado == 'si':
                mejora = 1
            else:
                mejora = 0

            Mejora.objects.filter(visitaid=pk).update(aplicomejora=mejora)

            messages.success(request, 'Estado modificado correctamente')
            return render(request, 'mejoras/detalle_mejora.html', data)

        return render(request, 'mejoras/detalle_mejora.html', data)
    else:
        return render(request, 'error/auth.html')


@login_required
def DetalleCapacitacionEmp(request, pk):
    datos = request.user

    if datos.is_profesional == 1:
        cursor = connection.cursor()
        cursor.execute('EXEC [dbo].[SP_DETALLE_CAPACITACION] {}'.format(pk))
        result = cursor.fetchall()

        try:
            result
        except:
            raise Http404

        data = {
            'id': pk,
            'entity': result
        }

        if request.method == 'POST':
            estado = request.POST.get('estado')
            Capacitacion.objects.filter(
                capacitacionid=pk).update(estado=estado)

            messages.success(request, 'Estado modificado correctamente')
            return render(request, 'actividades/detalle_capacitacion.html', data)

        return render(request, 'actividades/detalle_capacitacion.html', data)

    else:
        return render(request, 'error/auth.html')


@login_required
def CrearCapacitacion(request):
    datos = request.user

    if datos.is_profesional == 1:
        if request.method == 'POST':
            rutcliente = request.POST.get('rut')
            fecha = request.POST.get('fecha')
            hora = request.POST.get('hora')
            asistentes = request.POST.get('asistentes')
            materiales = request.POST.get('materiales')
            desc = request.POST.get('desc')

            cursor = connection.cursor()
            cursor.execute('EXEC [dbo].[SP_CREAR_CAPACITACION] %s, %s, %s, %s, %s, %s', (
                fecha, hora, asistentes, materiales, desc, rut(rutcliente)))

            messages.success(request, 'Capacitación ingresada correctamente')

            return render(request, 'actividades/crear_capacitacion.html')

        return render(request, 'actividades/crear_capacitacion.html')

    else:
        return render(request, 'error/auth.html')


class Error404View(TemplateView):
    template_name = 'error/404.html'


class Error500View(TemplateView):
    template_name = 'error/500.html'

    @classmethod
    def as_error_view(cls):
        v = cls.as_view()

        def view(request):
            r = v(request)
            r.render()

            return r

        return view


# Informes Cliente
@login_required
def InformesClienteView(request):
    datos = request.user

    if datos.is_profesional == 1 and datos.is_staff == 1 and datos.is_superuser == 1:
        return render(request, 'error/auth.html')
    else:
        cantidad = Contrato.objects.all().filter(rutcliente=datos.username).count()
        cursor = connection.cursor()
        cursor.execute(
            'EXEC [dbo].[SP_CONTRATO_ACTIVO] [{}]'.format(str(datos.username)[:-1]))
        results = cursor.fetchall()

        cursor.execute(
            'EXEC SP_VISITAS_CLIENTE_REPORT [{}]'.format(datos.username[:-1]))
        visitas = cursor.fetchall()

        cursor.execute(
            'EXEC SP_LISTAR_CONTRATOS_CLIENTE_INACTIVO [{}]'.format(datos.username[:-1]))
        inactivo = cursor.fetchall()

        try:
            results, visitas, inactivo
        except:
            raise Http404

        data = {
            'entity': results,
            'contratos': inactivo,
            'c': cantidad,
            'visitas': visitas
        }

        return render(request, 'informes/informes.html', data)


# Graficos :D
@login_required
def ReporteAccidentabilidad(request, pk):
    datos = request.user

    if datos.is_profesional == 1 and datos.is_staff == 1 and datos.is_superuser == 1:
        return render(request, 'error/auth.html')
    else:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                cursor = connection.cursor()
                cursor.execute(
                    'SELECT dbo.FN_GET_ID({})'.format(datos.username[:-1]))
                contrato = cursor.fetchall()

                for i in contrato:
                    cid = i[0]

                cursor.execute(
                    'SELECT RutCliente FROM Contrato WHERE ContratoID = {} '.format(pk))
                rutcli = cursor.fetchall()

                try:
                    rutcli, contrato
                except:
                    raise Http404

                for i in rutcli:
                    cliente = i[0]

                if datos.username == cliente:
                    cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino), RazonSocial, Nombre, DATEADD(MONTH, -1, FechaCreacion), FechaTermino FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID) WHERE ContratoID = {}'.format(pk))
                    contrato = cursor.fetchall()

                    for i in contrato:
                        rut = i[0]
                        yearInicio = i[1]
                        contratoid = i[2]
                        monthInicio = i[3]
                        yearFinal = i[4]
                        monthFinal = i[5]
                        razonSocial = i[6]
                        rubro = i[7]
                        inicio = i[8]
                        final = i[9]

                    try:
                        contrato
                    except:
                        raise Http404

                    date1 = inicio
                    date2 = final
                    month_list = np.array([i.strftime("%b-%y") for i in pd.date_range(start=date1, end=date2, freq='MS')])

                    valores = []

                    for month in np.array([i.strftime("%m-%y") for i in pd.date_range(start=date1, end=date2, freq='MS')]):
                        cursor.execute("SELECT COUNT(AccidenteID) FROM Accidente WHERE FORMAT(Fecha, '%M-%y') = '{0}' AND ContratoID = {1}".format(month, pk))
                        cantidad = cursor.fetchall()
                        for i in cantidad:
                            valores.append(i)

                    cantidadAccidentes = Accidente.objects.filter(contratoid=pk).count()

                    x = month_list
                    a = np.array([])
                    new_a = np.append(a, valores)
                    vector = np.vectorize(np.int_)
                    y = np.array(new_a)
                    new_y = vector(y)

                    periodo = str(monthInicio) + '/' + str(yearInicio) + ' - ' + str(monthFinal) + '/' + str(yearFinal)
                    chart = get_barplot(x, new_y, 'Cantidad de Accidentes Sufridos por la Empresa ' + razonSocial + ' en el periodo ' + periodo, 'Meses del año de contrato', 'Cantidad de Accidentes')

                    data = {
                        'c': cid,
                        'id': contratoid,
                        'year': yearInicio,
                        'rut': rut,
                        'formatRut': formatRut(rut),
                        'inicio': str(monthInicio) + '/' + str(yearInicio),
                        'final': str(monthFinal) + '/' + str(yearFinal),
                        'empresa': razonSocial,
                        'graph_accident_month': valores,
                        'rubro': rubro,
                        'chart': chart,
                        'fecha': new_y,
                        'cantidadAccidentes': cantidadAccidentes
                    }

                    return render(request, 'informes/accidentes.html', data)
                else:
                    return render(request, 'error/auth.html')


@login_required
def ReporteVisita(request, pk):
    datos = request.user

    if datos.is_profesional == 1 and datos.is_staff == 1 and datos.is_superuser == 1:
        return render(request, 'error/auth.html')
    else:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            try:
                pagoActual
            except:
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))

            try:
                pago
            except:
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                cursor.execute(
                    'SELECT dbo.FN_GET_ID({})'.format(datos.username[:-1]))
                contrato = cursor.fetchall()

                try:
                    contrato
                except:
                    raise Http404

                for i in contrato:
                    cid = i[0]

                cursor.execute(
                    'SELECT RutCliente FROM Contrato WHERE ContratoID = {} '.format(cid))
                rutcli = cursor.fetchall()

                try:
                    rutcli
                except:
                    raise Http404

                for i in rutcli:
                    cliente = i[0]

                if datos.username == cliente:
                    aprobado = Itemschecklist.objects.filter(visitaid=pk, aprobado=1, semiaprobado=0, reprobado=0).aggregate(
                        r=Coalesce(Count('aprobado'), 0)).get('r')
                    reprobado = Itemschecklist.objects.filter(visitaid=pk, aprobado=0, semiaprobado=0, reprobado=1).aggregate(
                        r=Coalesce(Count('reprobado'), 0)).get('r')
                    semiaprobado = Itemschecklist.objects.filter(visitaid=pk, aprobado=0, semiaprobado=1, reprobado=0).aggregate(
                        r=Coalesce(Count('semiaprobado'), 0)).get('r')

                    total = Itemschecklist.objects.filter(visitaid=pk).aggregate(
                        r=Coalesce(Count('itemcheclistid'), 0)).get('r')

                    aprob = aprobado*100/total
                    semi = semiaprobado*100/total
                    repro = reprobado*100/total

                    cursor.execute('EXEC [SP_DETALLE_VISITA] {}'.format(pk))
                    visita = cursor.fetchall()

                    cursor.execute('EXEC [SP_DETALLE_CHECKLIST] {}'.format(pk))
                    checkList = cursor.fetchall()

                    try:
                        visita, checkList
                    except:
                        raise Http404

                    for i in visita:
                        fechaVisita = i[1]

                    cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino),RazonSocial FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) WHERE ContratoID = {}'.format(cid))
                    contrato = cursor.fetchall()

                    cursor.execute(
                        'EXEC SP_DETALLE_INFORME_VISITA {}'.format(pk))
                    detalle = cursor.fetchall()

                    cursor.execute('EXEC SP_DETALLE_PLAN_MEJORA {}'.format(pk))
                    plan = cursor.fetchall()

                    try:
                        contrato, detalle, plan
                    except:
                        raise Http404

                    for i in contrato:
                        rut = i[0]
                        yearInicio = i[1]
                        contratoid = i[2]
                        monthInicio = i[3]
                        yearFinal = i[4]
                        monthFinal = i[5]
                        razonSocial = i[6]

                    data = {
                        'c': cid,
                        'fechaVisita': fechaVisita,
                        'itemAprob': aprobado,
                        'itemSemi': semiaprobado,
                        'itemRepro': reprobado,
                        'checkList': checkList,
                        'rut': formatRut(rut),
                        'empresa': razonSocial,
                        'total': total,
                        'id': pk,
                        'detalle': detalle,
                        'plan': plan,
                        'aprobado': aprobado,
                        'semi': semiaprobado,
                        'reprobado': reprobado,
                        'aprob': round(aprob, 1),
                        'semiapro': round(semi,1),
                        'repro': round(repro,1)
                    }

                    if 'email' in request.POST:
                        asunto = 'Invitacion a contestar Encuesta'
                        metodo = request.POST.get("sendEmail")
                        messege = """
                            Ingrese a este link
                            """
                        mail = EmailMessage(
                            asunto, messege, metodo, to=[datos.email])
                        mail.send()

                        return render(request, 'informes/visita.html', data)

                    return render(request, 'informes/visita.html', data)
                else:
                    return render(request, 'error/auth.html')


@login_required
def ReporteVisitasGenerales(request, pk):
    datos = request.user

    if datos.is_profesional == 1 and datos.is_staff == 1 and datos.is_superuser == 1:
        return render(request, 'error/auth.html')
    else:
        activo = Contrato.objects.filter(
            rutcliente=datos.username).filter(estado=1).count()
        if activo == 0:
            return render(request, 'contrato/contrato_inactivo.html')
        else:
            cursor = connection.cursor()
            pagoActual = cursor.execute(
                'SELECT [dbo].[FN_GET_PAGO_ATRASADO]({})'.format(datos.username[:-1]))

            try:
                pagoActual
            except:                
                raise Http404

            for i in pagoActual:
                estadoPago = i[0]

            pago = cursor.execute(
                'EXEC [dbo].[SP_FECHA_PAGO] {}'.format(datos.username[:-1]))
            
            try:
                pago
            except:                
                raise Http404

            for a in pago:
                fechaPago = a[0]
                fechaVenc = a[1]
                mesPago = a[2]
                pagoId = a[3]

            data = {
                'pago': estadoPago,
                'fechaPago': fechaPago, 'fechaVenc': fechaVenc,
                'mes': mesPago, 'id': pagoId}

            if estadoPago == 0:
                return render(request, 'pagos/pago_venc.html', data)
            else:
                cursor.execute('SELECT RutCliente FROM Contrato WHERE ContratoID = {} '.format(pk))
                rutcli = cursor.fetchall()

                try:
                    rutcli
                except:                
                    raise Http404

                for i in rutcli:
                    cliente = i[0]

                if datos.username == cliente:
                    fechas = Visita.objects.filter(contratoid=pk).values_list('fechavisita')
                    valoresFecha = []
                    a = np.array([])
                    new_a = np.append(a, fechas)
                    vector = np.vectorize(np.str_)
                    x = vector(new_a)
                    repro = []
                    semi = []
                    aprob = []

                    for i in x:
                        reprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk, checklistid__visitaid__fechavisita=i).filter(aprobado=0,semiaprobado=0,reprobado=1).aggregate(r=Coalesce(Count('reprobado'), 0)).get('r')
                        repro.append(reprobado)
                        semiaprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk, checklistid__visitaid__fechavisita=i).filter(aprobado=0,semiaprobado=1,reprobado=0).aggregate(r=Coalesce(Count('semiaprobado'), 0)).get('r')
                        semi.append(semiaprobado)
                        aprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk, checklistid__visitaid__fechavisita=i).filter(aprobado=1,semiaprobado=0,reprobado=0).aggregate(r=Coalesce(Count('aprobado'), 0)).get('r')
                        aprob.append(aprobado)

                    total = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).aggregate(r=Coalesce(Count('itemcheclistid'), 0)).get('r')
                    
                    cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino),RazonSocial FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) WHERE ContratoID = {}'.format(pk))
                    contrato = cursor.fetchall()

                    try:
                        contrato
                    except:                
                        raise Http404

                    for i in contrato:
                        rut = i[0]
                        yearInicio = i[1]
                        contratoid = i[2]
                        monthInicio = i[3]
                        yearFinal = i[4]
                        monthFinal = i[5]
                        razonSocial = i[6]

                    re = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=0,semiaprobado=0,reprobado=1).aggregate(r=Coalesce(Count('reprobado'), 0)).get('r')
                    ap = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=1,semiaprobado=0,reprobado=0).aggregate(r=Coalesce(Count('aprobado'), 0)).get('r')
                    sa = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=0,semiaprobado=1,reprobado=0).aggregate(r=Coalesce(Count('semiaprobado'), 0)).get('r')

                    porc_aprobado = ap*100/total
                    porc_semi = sa*100/total
                    porc_reprobado = re*100/total

                    chart = get_groupedbar(repro, semi, aprob, x, str(monthInicio) + '/' + str(yearInicio) + ' - ' + str(monthFinal) + '/' + str(yearFinal),)

                    cursor.execute('SELECT YEAR(FechaCreacion) FROM Contrato GROUP BY YEAR(FechaCreacion)')
                    annios = cursor.fetchall()

                    data = {
                        'x': new_a,
                        'id': pk,
                        'cid': contratoid,
                        'rut': rut,
                        'formatRut': formatRut(rut),
                        'annio': yearInicio,
                        'empresa': razonSocial,
                        'total': total,
                        'valoresFecha': valoresFecha,
                        'aprobado': aprob,
                        'semi': semi,
                        'reprobado': repro,
                        'inicio': str(monthInicio) + '/' + str(yearInicio),
                        'final': str(monthFinal) + '/' + str(yearFinal),
                        'chart': chart,
                        'porc_aprobado': round(porc_aprobado,1),
                        'porc_semi': round(porc_semi,1),
                        'porc_reprobado': round(porc_reprobado,1),
                        're': re,
                        'sa': sa,
                        'ap': ap,
                        'annios': annios
                    }

                    if 'email' in request.POST:
                        asunto='Invitacion a contestar Encuesta'
                        metodo= request.POST.get("sendEmail")
                        messege = """
                            Ingrese a este link
                            """
                        mail= EmailMessage(asunto,messege,metodo,to=[datos.email])
                        mail.send()

                        return render(request, 'informes/visitas_generales.html', data)

                    return render(request, 'informes/visitas_generales.html', data)
                else:
                    return render(request, 'error/auth.html')


# PDF Reporte Accidentes
class AccidentesPdf(View):
    def get(self, request, *args, **kwargs):
        pk = self.kwargs['pk']
        cursor = connection.cursor()

        cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino), RazonSocial, Nombre, DATEADD(MONTH, -1, FechaCreacion), FechaTermino FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) JOIN RubroEmpresa ON (Cliente.RubroID = RubroEmpresa.RubroID) WHERE ContratoID = {}'.format(pk))
        contrato = cursor.fetchall()

        for i in contrato:
            rut = i[0]
            yearInicio = i[1]
            contratoid = i[2]
            monthInicio = i[3]
            yearFinal = i[4]
            monthFinal = i[5]
            razonSocial = i[6]
            rubro = i[7]
            inicio = i[8]
            final = i[9]

        try:
            contrato
        except:
            raise Http404

        
        date1 = inicio
        date2 = final
        month_list = np.array([i.strftime("%b-%y") for i in pd.date_range(start=date1, end=date2, freq='MS')])

        valores = []

        for month in np.array([i.strftime("%m-%y") for i in pd.date_range(start=date1, end=date2, freq='MS')]):
            cursor.execute("SELECT COUNT(AccidenteID) FROM Accidente WHERE FORMAT(Fecha, '%M-%y') = '{0}' AND ContratoID = {1}".format(month, pk))
            cantidad = cursor.fetchall()
            for i in cantidad:
                valores.append(i)

        x = month_list
        a = np.array([])
        new_a = np.append(a, valores)
        vector = np.vectorize(np.int_)
        y = np.array(new_a)
        new_y = vector(y)

        periodo = str(monthInicio) + '/' + str(yearInicio) + ' - ' + str(monthFinal) + '/' + str(yearFinal)
        chart = get_barplot(x, new_y, 'Cantidad de Accidentes Sufridos por la Empresa ' + razonSocial + ' en el periodo ' + periodo, 'Meses del año de contrato', 'Cantidad de Accidentes')

        template = get_template('pdf_accidente.html')
        response = HttpResponse(content_type='application/pdf')
        # response['Content-Disposition'] = 'attachment; filename="infome_accidentes.pdf"'
        context = {
            'comp': {'name': 'ControlRisk', 'rut': '99.999.999-k', 'direccion': 'Avenida Siempreviva 742'},
            'empresa': razonSocial,
            'graph_accident_month': valores,
            'chart': chart,
            'c': pk,
            'id': contratoid,
            'year': yearInicio,
            'rut': rut,
            'formatRut': formatRut(rut),
            'inicio': str(monthInicio) + '/' + str(yearInicio),
            'final': str(monthFinal) + '/' + str(yearFinal),
            'rubro': rubro,
            'fechaActual': datetime.today().strftime("%d-%m-%Y"),
        }
        html = template.render(context)
        pisa_status = pisa.CreatePDF(html, dest=response)

        return response

    
# PDF Reporte Visita
class VisitaPDF(View):
    def get(self, request, *args, **kwargs):
        pk = self.kwargs['pk']
        cursor = connection.cursor()

        cursor.execute('SELECT ContratoID FROM Visita WHERE VisitaID = {}'.format(pk))
        contrato = cursor.fetchall()

        for i in contrato:
            cid = i[0]

        aprobado = Itemschecklist.objects.filter(visitaid=pk,aprobado=1,semiaprobado=0,reprobado=0).aggregate(r=Coalesce(Count('aprobado'), 0)).get('r')
        reprobado = Itemschecklist.objects.filter(visitaid=pk,aprobado=0,semiaprobado=0,reprobado=1).aggregate(r=Coalesce(Count('reprobado'), 0)).get('r')
        semiaprobado = Itemschecklist.objects.filter(visitaid=pk,aprobado=0,semiaprobado=1,reprobado=0).aggregate(r=Coalesce(Count('semiaprobado'), 0)).get('r')

        total = Itemschecklist.objects.filter(visitaid=pk).aggregate(r=Coalesce(Count('itemcheclistid'), 0)).get('r')

        aprob = aprobado*100/total
        semi = semiaprobado*100/total
        repro = reprobado*100/total

        valores = []
        valores.append(reprobado)
        valores.append(semiaprobado)
        valores.append(aprobado)

        cursor.execute('EXEC [SP_DETALLE_VISITA] {}'.format(pk))
        visita = cursor.fetchall()

        cursor.execute('EXEC [SP_DETALLE_CHECKLIST] {}'.format(pk))
        checkList = cursor.fetchall()

        for i in visita:
            fechaVisita = i[1]
                    
        cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino),RazonSocial FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) WHERE ContratoID = {}'.format(cid))
        contrato = cursor.fetchall()

        for i in contrato:
            rut = i[0]
            yearInicio = i[1]
            contratoid = i[2]
            monthInicio = i[3]
            yearFinal = i[4]
            monthFinal = i[5]
            razonSocial = i[6]

        x = ['Reprobado', 'Semi Aprobado', 'Aprobado']
        y = valores
        bar_chart = get_barplot(x, y, 'Items CheckList Visita :  ' + fechaVisita, 'Estado de Item', 'Cantidad de Items')

        pie_x = reprobado
        pie_y = semiaprobado
        pie_z = aprobado
        pie_chart = get_pieplot(pie_x, pie_y, pie_z, 'Porcentaje de Items Visita ' + fechaVisita, 'Reprobado', 'Semi Aprobado', 'Aprobado')

        cursor.execute('EXEC SP_DETALLE_INFORME_VISITA {}'.format(pk))
        detalle = cursor.fetchall()

        cursor.execute('EXEC SP_DETALLE_PLAN_MEJORA {}'.format(pk))
        plan = cursor.fetchall()

        template = get_template('pdf_visita.html')
        response = HttpResponse(content_type='application/pdf')
        # response['Content-Disposition'] = 'attachment; filename="infome_accidentes.pdf"'
        context = {
            'comp': {'name': 'ControlRisk', 'rut': '99.999.999-k', 'direccion': 'Avenida Siempreviva 742'},
            'id': contratoid,
            'year': yearInicio,
            'rut': rut,
            'inicio': str(monthInicio) + '/' + str(yearInicio),
            'final': str(monthFinal) + '/' + str(yearFinal),
            'empresa': razonSocial,
            'checkList': checkList,
            'fechaVisita': fechaVisita,
            'chart_bar': bar_chart,
            'chart_pie': pie_chart,
            'detalle': detalle,
            'plan': plan,
            'total': total,
            'aprobado': aprobado,
            'semi': semiaprobado,
            'reprobado': reprobado,
            'aprob': aprob,
            'semiapro': semi,
            'repro': repro
        }
        html = template.render(context)
        pisa_status = pisa.CreatePDF(html, dest=response)

        return response


# PDF Reporte Visitas Generales
class VisitaGeneralPDF(View):
    def get(self, request, *args, **kwargs):
        pk = self.kwargs['pk']
        cursor = connection.cursor()

        fechas = Visita.objects.filter(contratoid=pk).values_list('fechavisita')
        valoresFecha = []
        a = np.array([])
        new_a = np.append(a, fechas)
        vector = np.vectorize(np.str_)
        x = vector(new_a)
        repro = []
        semi = []
        aprob = []

        for i in x:
            reprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk,checklistid__visitaid__fechavisita=i).filter(aprobado=0,semiaprobado=0,reprobado=1).aggregate(r=Coalesce(Count('reprobado'), 0)).get('r')
            repro.append(reprobado)
            semiaprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk,checklistid__visitaid__fechavisita=i).filter(aprobado=0,semiaprobado=1,reprobado=0).aggregate(r=Coalesce(Count('semiaprobado'), 0)).get('r')
            semi.append(semiaprobado)
            aprobado = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk,checklistid__visitaid__fechavisita=i).filter(aprobado=1,semiaprobado=0,reprobado=0).aggregate(r=Coalesce(Count('aprobado'), 0)).get('r')
            aprob.append(aprobado)

        total = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).aggregate(r=Coalesce(Count('itemcheclistid'), 0)).get('r')
                    
        cursor.execute('SELECT Contrato.RutCliente,YEAR(FechaCreacion),ContratoID,MONTH(FechaCreacion),YEAR(FechaTermino),MONTH(FechaTermino),RazonSocial FROM Contrato JOIN Cliente ON (Contrato.RutCliente = CLiente.RutCliente) WHERE ContratoID = {}'.format(pk))
        contrato = cursor.fetchall()

        for i in contrato:
            rut = i[0]
            yearInicio = i[1]
            contratoid = i[2]
            monthInicio = i[3]
            yearFinal = i[4]
            monthFinal = i[5]
            razonSocial = i[6]

        re = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=0,semiaprobado=0,reprobado=1).aggregate(r=Coalesce(Count('reprobado'), 0)).get('r')
        ap = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=1,semiaprobado=0,reprobado=0).aggregate(r=Coalesce(Count('aprobado'), 0)).get('r')
        sa = Itemschecklist.objects.filter(checklistid__visitaid__contratoid=pk).filter(aprobado=0,semiaprobado=1,reprobado=0).aggregate(r=Coalesce(Count('semiaprobado'), 0)).get('r')

        porc_aprobado = ap*100/total
        porc_semi = sa*100/total
        porc_reprobado = re*100/total

        chart = get_groupedbar(repro, semi, aprob, x, str(monthInicio) + '/' + str(yearInicio) + ' - ' + str(monthFinal) + '/' + str(yearFinal),)
        pie_chart = get_pieplot(round(porc_aprobado,1), round(porc_semi,1), round(porc_reprobado,1), 'Resultado general de Check List en porcentajes ' + razonSocial ,'Aprobados', 'Semi Aprobados', 'Reprobados')

        template = get_template('pdf_visitas_generales.html')
        response = HttpResponse(content_type='application/pdf')
        # response['Content-Disposition'] = 'attachment; filename="infome_accidentes.pdf"'
        context = {
            'comp': {'name': 'ControlRisk', 'rut': '99.999.999-k', 'direccion': 'Avenida Siempreviva 742'},
            'x': new_a,
            'id': pk,
            'cid': contratoid,
            'rut': rut,
            'formatRut': formatRut(rut),
            'annio': yearInicio,
            'empresa': razonSocial,
            'total': total,
            'valoresFecha': valoresFecha,
            'aprobado': aprob,
            'semi': semi,
            'reprobado': repro,
            'inicio': str(monthInicio) + '/' + str(yearInicio),
            'final': str(monthFinal) + '/' + str(yearFinal),
            'chart': chart,
            'pie_chart': pie_chart,
            'porc_aprobado': round(porc_aprobado,1),
            'porc_semi': round(porc_semi,1),
            'porc_reprobado': round(porc_reprobado,1),
            're': re,
            'sa': sa,
            'ap': ap
        }
        html = template.render(context)
        pisa_status = pisa.CreatePDF(html, dest=response)

        return response