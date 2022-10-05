from pyexpat import model
from django.db import models
from django.forms import model_to_dict
from AppUser.models import User
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from AppBase.validators import validate_length
import time
import datetime
from datetime import date


class RubroEmpresa(models.Model):
    rubroid = models.AutoField(db_column='RubroID', primary_key=True)
    nombre = models.CharField(db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'RubroEmpresa'
    
    def __str__(self):
        return self.nombre


class Accidente(models.Model):
    accidenteid = models.AutoField(
        db_column='AccidenteID', primary_key=True)
    fecha = models.DateTimeField(db_column='Fecha')
    descripcion = models.CharField(
        db_column='Descripcion', max_length=500, db_collation='Modern_Spanish_CI_AS')
    medidas = models.CharField(
        db_column='Medidas', max_length=500, db_collation='Modern_Spanish_CI_AS')
    contratoid = models.ForeignKey(
        'Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True, related_name='contrato_contrato')

    class Meta:
        managed = False
        db_table = 'Accidente'


class Actividad(models.Model):
    actividadid = models.AutoField(
        db_column='ActividadID', primary_key=True)
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')
    estadoactividad = models.SmallIntegerField(db_column='EstadoActividad')
    actividadextra = models.SmallIntegerField(db_column='ActividadExtra')
    contratoid = models.ForeignKey('Contrato', models.DO_NOTHING,
                                   db_column='ContratoID', blank=True, null=True, related_name='contrato_contrato_actividad')
    rutempleado = models.ForeignKey(
        'Empleado', models.DO_NOTHING, db_column='RutEmpleado', related_name="empleado_empleado")
    asesoriaid = models.ForeignKey(
        'Asesoria', models.DO_NOTHING, db_column='AsesoriaID', blank=True, null=True, related_name="asesoria_asesoria")
    capacitacionid = models.ForeignKey(
        'Capacitacion', models.DO_NOTHING, db_column='CapacitacionID', blank=True, null=True, related_name="asesoria_capacitacion")
    visitaid = models.ForeignKey(
        'Visita', models.DO_NOTHING, db_column='VisitaID', blank=True, null=True, related_name="asesoria_visita")

    class Meta:
        managed = False
        db_table = 'Actividad'
        unique_together = (('actividadid', 'rutempleado', 'contratoid'),)


class Asesoria(models.Model):
    asesoriaid = models.AutoField(db_column='AsesoriaID', primary_key=True)
    estado = models.SmallIntegerField(
        db_column='Estado', blank=True, null=True)
    fechaasesoria = models.DateTimeField(db_column='FechaAsesoria')
    descripcionasesoria = models.CharField(
        db_column='DescripcionAsesoria', max_length=500, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'Asesoria'


class Asesoriatelefonica(models.Model):
    asesoriatelefonicaid = models.AutoField(
        db_column='AsesoriaTelefonicaID', primary_key=True)
    dudacliente = models.CharField(
        db_column='DudaCliente', max_length=250, db_collation='Modern_Spanish_CI_AS')
    respuestaempleado = models.CharField(
        db_column='RespuestaEmpleado', max_length=250, db_collation='Modern_Spanish_CI_AS')
    fechahora = models.DateTimeField(db_column='FechaHora')
    contratoid = models.ForeignKey(
        'Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'AsesoriaTelefonica'


class Capacitacion(models.Model):
    capacitacionid = models.AutoField(
        db_column='CapacitacionID', primary_key=True)
    fecha = models.DateTimeField(db_column='Fecha')
    cantidadasistentes = models.IntegerField(db_column='CantidadAsistentes')
    materiales = models.CharField(db_column='Materiales', max_length=200,
                                  db_collation='Modern_Spanish_CI_AS', blank=True, null=True)
    descripcion = models.CharField(db_column='Descripcion', max_length=200,
                                   db_collation='Modern_Spanish_CI_AS', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Capacitacion'


class Checklist(models.Model):
    checklistid = models.AutoField(
        db_column='ChecklistID', primary_key=True)
    fechachecklist = models.DateField(db_column='FechaChecklist')
    visitaid = models.ForeignKey(
        'Visita', models.DO_NOTHING, db_column='VisitaID')

    class Meta:
        managed = False
        db_table = 'Checklist'
        unique_together = (('checklistid', 'visitaid'),)


class Cliente(models.Model):
    rutcliente = models.CharField(db_column='RutCliente', max_length=12, unique=True,
                                  db_collation='Modern_Spanish_CI_AS', primary_key=True)
    razonsocial = models.CharField(
        db_column='RazonSocial', max_length=50, db_collation='Modern_Spanish_CI_AS')
    direccion = models.CharField(
        db_column='Direccion', max_length=100, db_collation='Modern_Spanish_CI_AS')
    telefono = models.PositiveIntegerField(db_column='Telefono', validators=[validate_length])
    representante = models.CharField(
        db_column='Representante', max_length=50, db_collation='Modern_Spanish_CI_AS')
    rutrepresentante = models.CharField(db_column='RutRepresentante', max_length=12, db_collation='Modern_Spanish_CI_AS')
    # usuarioid = models.ForeignKey(
    #     settings.AUTH_USER_MODEL, models.DO_NOTHING, db_column='UsuarioID', null=True, blank=True)
    rubroid = models.ForeignKey('RubroEmpresa', models.DO_NOTHING, db_column='RubroID')

    class Meta:
        managed = False
        db_table = 'Cliente'
    
    def __str__(self):
        return self.rutcliente

    def formatRut(self):
        if len(self.rutcliente) == 8:                
            formato = self.rutcliente[0:1] + '.' + self.rutcliente[1:4] + '.' + self.rutcliente[4:7] + '-' + self.rutcliente[-1]
        else:
            formato = self.rutcliente[0:2] + '.' + self.rutcliente[2:5] + '.' + self.rutcliente[5:8] + '-' + self.rutcliente[-1]
        return formato

    def toJSON(self):
        item = model_to_dict(self)
        item['rubroid'] = [i.toJSON() for i in self.rubroempresa_set.all()]


class Contrato(models.Model):
    contratoid = models.AutoField(db_column='ContratoID', primary_key=True)
    cantidadasesorias = models.IntegerField(db_column='CantidadAsesorias')
    cantidadcapacitaciones = models.IntegerField(
        db_column='CantidadCapacitaciones')
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')
    fechatermino = models.DateTimeField(db_column='FechaTermino')
    fechapago = models.DateField(db_column='FechaPago')
    cuotascontrato = models.IntegerField(db_column='CuotasContrato')
    valorcontrato = models.IntegerField(
        db_column='ValorContrato')
    estado = models.BooleanField(db_column='Estado')
    pagado = models.BooleanField(db_column='Pagado', default=False)
    rutcliente = models.OneToOneField(Cliente, models.DO_NOTHING, db_column='RutCliente', blank=True, null=True)
    rutempleado = models.OneToOneField('Empleado', models.DO_NOTHING, db_column='RutEmpleado')

    class Meta:
        managed = False
        db_table = 'Contrato'

    def __str__(self):
        rut = str(self.rutcliente)
        return rut

    def year(self):
        annio = self.fechacreacion.year()
        return annio

    def toJSON(self):
        item = model_to_dict(self)
        item['cliente'] = [i.toJSON() for i in self.cliente_set.all()]
        item['empelado'] = [i.toJSON() for i in self.empelado_set.all()]


class Empleado(models.Model):
    rutempleado = models.CharField(db_column='RutEmpleado', max_length=12,
                           db_collation='Modern_Spanish_CI_AS', primary_key=True)
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')
    apellido = models.CharField(
        db_column='Apellido', max_length=50, db_collation='Modern_Spanish_CI_AS')
    cargo = models.CharField(
        db_column='Cargo', max_length=50, db_collation='Modern_Spanish_CI_AS')
    usuarioid = models.ForeignKey(
        settings.AUTH_USER_MODEL, models.DO_NOTHING, db_column='UsuarioID', null=True, blank=True)
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Empleado'

    def __str__(self):
        return self.rutempleado


class Informevisita(models.Model):
    informevisitaid = models.AutoField(
        db_column='InformeVisitaID', primary_key=True)
    situacion = models.CharField(
        db_column='Situacion', max_length=500, db_collation='Modern_Spanish_CI_AS')
    fecha = models.DateField(db_column='Fecha')
    contratoid = models.ForeignKey(
        Contrato, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)
    visitaid = models.ForeignKey(
        'Visita', models.DO_NOTHING, db_column='VisitaID')

    class Meta:
        managed = False
        db_table = 'InformeVisita'
        unique_together = (('informevisitaid', 'visitaid', 'contratoid'),)


class Itemschecklist(models.Model):
    itemcheclistid = models.AutoField(
        db_column='ItemCheclistID', primary_key=True)
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')
    aprobado = models.SmallIntegerField(
        db_column='Aprobado', blank=True, null=True)
    reprobado = models.SmallIntegerField(
        db_column='Reprobado', blank=True, null=True)
    semiaprobado = models.SmallIntegerField(
        db_column='SemiAprobado', blank=True, null=True)
    checklistid = models.ForeignKey(
        Checklist, models.DO_NOTHING, db_column='ChecklistID',  related_name='check_check')
    visitaid = models.ForeignKey(
        Checklist, models.DO_NOTHING, db_column='VisitaID', related_name='check_visita')

    class Meta:
        managed = False
        db_table = 'ItemsChecklist'
        unique_together = (('itemcheclistid', 'checklistid', 'visitaid'),)


class Mejora(models.Model):
    mejoraid = models.AutoField(db_column='MejoraID', primary_key=True)
    planmejora = models.CharField(
        db_column='PlanMejora', max_length=500, db_collation='Modern_Spanish_CI_AS')
    fecha = models.DateField(db_column='Fecha')
    aplicomejora = models.SmallIntegerField(db_column='AplicoMejora')
    informevisitaid = models.ForeignKey(
        Informevisita, models.DO_NOTHING, db_column='InformeVisitaID', blank=True, null=True, related_name="informe_informe")
    visitaid = models.ForeignKey(
        Informevisita, models.DO_NOTHING, db_column='VisitaID', blank=True, null=True, related_name="informe_visita")
    contratoid = models.ForeignKey(
        Informevisita, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True, related_name="informe_contrato")

    class Meta:
        managed = False
        db_table = 'Mejora'


class Pagos(models.Model):
    pagosid = models.AutoField(db_column='PagosID', primary_key=True)
    fechapago = models.DateTimeField(db_column='FechaPago')
    fechavencimiento = models.DateTimeField(db_column='FechaVencimiento')
    valorcuota = models.DecimalField(
        db_column='ValorCuota', max_digits=19, decimal_places=4)
    montoextra = models.DecimalField(
        db_column='MontoExtra', max_digits=19, decimal_places=4)
    valorpago = models.DecimalField(
        db_column='ValorPago', max_digits=19, decimal_places=4)
    tipopagoid = models.ForeignKey(
        'Tipopagos', models.DO_NOTHING, db_column='TipoPagoID', blank=True, null=True)
    contratoid = models.ForeignKey(
        Contrato, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Pagos'


class Tipopagos(models.Model):
    tipopagoid = models.AutoField(db_column='TipoPagoID', primary_key=True)
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'TipoPagos'


class Visita(models.Model):
    visitaid = models.AutoField(db_column='VisitaID', primary_key=True)
    fechavisita = models.DateTimeField(db_column='FechaVisita')
    estado = models.SmallIntegerField(db_column='Estado')

    class Meta:
        managed = False
        db_table = 'Visita'
