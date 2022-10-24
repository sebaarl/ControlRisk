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
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')

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


class Asesoria(models.Model):
    # Field name made lowercase.
    asesoriaid = models.AutoField(db_column='AsesoriaID', primary_key=True)
    # Field name made lowercase.
    fechacreado = models.DateTimeField(db_column='FechaCreado')
    # Field name made lowercase.
    fechaasesoria = models.DateField(
        db_column='FechaAsesoria', blank=True, null=True)
    # Field name made lowercase.
    descripcionasesoria = models.CharField(
        db_column='DescripcionAsesoria', max_length=500, db_collation='Modern_Spanish_CI_AS')
    # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=20)
    contratoid = models.ForeignKey(
        'Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)
    # Field name made lowercase.
    hora = models.TimeField(db_column='Hora', blank=True, null=True)
    # Field name made lowercase.
    extra = models.BooleanField(db_column='Extra')

    class Meta:
        managed = False
        db_table = 'Asesoria'

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato


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

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato


class Capacitacion(models.Model):
    capacitacionid = models.AutoField(
        db_column='CapacitacionID', primary_key=True)
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')
    fechacapacitacion = models.DateTimeField(
        db_column='FechaCapacitacion', blank=True, null=True)
    cantidadasistentes = models.IntegerField(db_column='CantidadAsistentes')
    materiales = models.CharField(db_column='Materiales', max_length=200,
                                  db_collation='Modern_Spanish_CI_AS', blank=True, null=True)
    descripcion = models.CharField(db_column='Descripcion', max_length=200,
                                   db_collation='Modern_Spanish_CI_AS', blank=True, null=True)
    estado = models.CharField(db_column='Estado', max_length=20, db_collation='Modern_Spanish_CI_AS')
    contratoid = models.ForeignKey(
        'Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)

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
    telefono = models.CharField(db_column='Telefono', max_length=12)
    representante = models.CharField(
        db_column='Representante', max_length=50, db_collation='Modern_Spanish_CI_AS')
    rutrepresentante = models.CharField(
        db_column='RutRepresentante', max_length=12, db_collation='Modern_Spanish_CI_AS')
    # usuarioid = models.ForeignKey(
    #     settings.AUTH_USER_MODEL, models.DO_NOTHING, db_column='UsuarioID', null=True, blank=True)
    rubroid = models.ForeignKey(
        'RubroEmpresa', models.DO_NOTHING, db_column='RubroID')

    class Meta:
        managed = False
        db_table = 'Cliente'

    def __str__(self):
        return self.rutcliente

    def formatRut(self):
        if len(self.rutcliente) == 8:
            formato = self.rutcliente[0:1] + '.' + self.rutcliente[1:4] + \
                '.' + self.rutcliente[4:7] + '-' + self.rutcliente[-1]
        else:
            formato = self.rutcliente[0:2] + '.' + self.rutcliente[2:5] + \
                '.' + self.rutcliente[5:8] + '-' + self.rutcliente[-1]
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
    rutcliente = models.OneToOneField(
        Cliente, models.DO_NOTHING, db_column='RutCliente', blank=True, null=True)
    rutempleado = models.OneToOneField(
        'Empleado', models.DO_NOTHING, db_column='RutEmpleado')

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
    # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')

    class Meta:
        managed = False
        db_table = 'Empleado'

    def __str__(self):
        return self.rutempleado


class Historialactividad(models.Model):
    # Field name made lowercase.
    historialactividadid = models.AutoField(
        db_column='HistorialActividadID', primary_key=True)
    # Field name made lowercase.
    tipoactividad = models.CharField(
        db_column='TipoActividad', max_length=50, db_collation='Modern_Spanish_CI_AS')
    # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')
    # Field name made lowercase.
    fecharealizada = models.DateTimeField(db_column='FechaRealizada')
    # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')
    # Field name made lowercase.
    rutempleado = models.ForeignKey(
        Empleado, models.DO_NOTHING, db_column='RutEmpleado')
    # Field name made lowercase.
    asesoriaid = models.ForeignKey(
        Asesoria, models.DO_NOTHING, db_column='AsesoriaID', blank=True, null=True)
    # Field name made lowercase.
    capacitacionid = models.ForeignKey(
        Capacitacion, models.DO_NOTHING, db_column='CapacitacionID', blank=True, null=True)
    # Field name made lowercase.
    visitaid = models.ForeignKey(
        'Visita', models.DO_NOTHING, db_column='VisitaID', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'HistorialActividad'

    def __str__(self):
        emp = str(self.rutempleado)
        return emp


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

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato


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

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato


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

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato


class Tipopagos(models.Model):
    tipopagoid = models.AutoField(db_column='TipoPagoID', primary_key=True)
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'TipoPagos'


class Valorextra(models.Model):
    # Field name made lowercase.
    valorid = models.AutoField(db_column='ValorID', primary_key=True)
    # Field name made lowercase.
    nombre = models.CharField(
        db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')
    # Field name made lowercase.
    valor = models.DecimalField(
        db_column='Valor', max_digits=19, decimal_places=4)

    class Meta:
        managed = False
        db_table = 'ValorExtra'


class Visita(models.Model):
    visitaid = models.AutoField(db_column='VisitaID', primary_key=True)  # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')  # Field name made lowercase.
    fechavisita = models.DateField(db_column='FechaVisita', blank=True, null=True)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=20, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    contratoid = models.ForeignKey(Contrato, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.
    extra = models.BooleanField(db_column='Extra')  # Field name made lowercase.
    hora = models.TimeField(db_column='Hora', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Visita'

    def __str__(self):
        contrato = str(self.contratoid)
        return contrato
