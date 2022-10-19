# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Accidente(models.Model):
    accidenteid = models.AutoField(db_column='AccidenteID', primary_key=True)  # Field name made lowercase.
    fecha = models.DateTimeField(db_column='Fecha')  # Field name made lowercase.
    descripcion = models.CharField(db_column='Descripcion', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    medidas = models.CharField(db_column='Medidas', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    contratoid = models.ForeignKey('Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Accidente'


class AppuserUser(models.Model):
    id = models.BigAutoField(primary_key=True)
    password = models.CharField(max_length=128, db_collation='Modern_Spanish_CI_AS')
    is_superuser = models.BooleanField()
    nombreusuario = models.CharField(db_column='NombreUsuario', unique=True, max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')  # Field name made lowercase.
    last_login = models.DateTimeField(db_column='Last_login')  # Field name made lowercase.
    is_staff = models.BooleanField(db_column='Is_staff')  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.
    is_profesional = models.BooleanField(db_column='Is_Profesional')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'AppUser_user'


class AppuserUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AppuserUser, models.DO_NOTHING)
    group = models.ForeignKey('AuthGroup', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'AppUser_user_groups'
        unique_together = (('user', 'group'),)


class AppuserUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AppuserUser, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'AppUser_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Asesoria(models.Model):
    asesoriaid = models.AutoField(db_column='AsesoriaID', primary_key=True)  # Field name made lowercase.
    fechacreado = models.DateTimeField(db_column='FechaCreado')  # Field name made lowercase.
    fechaasesoria = models.DateField(db_column='FechaAsesoria', blank=True, null=True)  # Field name made lowercase.
    descripcionasesoria = models.CharField(db_column='DescripcionAsesoria', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=20, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    contratoid = models.ForeignKey('Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.
    hora = models.TimeField(db_column='Hora', blank=True, null=True)  # Field name made lowercase.
    extra = models.BooleanField(db_column='Extra')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Asesoria'


class Asesoriatelefonica(models.Model):
    asesoriatelefonicaid = models.AutoField(db_column='AsesoriaTelefonicaID', primary_key=True)  # Field name made lowercase.
    dudacliente = models.CharField(db_column='DudaCliente', max_length=250, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    respuestaempleado = models.CharField(db_column='RespuestaEmpleado', max_length=250, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    fechahora = models.DateTimeField(db_column='FechaHora')  # Field name made lowercase.
    contratoid = models.ForeignKey('Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'AsesoriaTelefonica'


class Capacitacion(models.Model):
    capacitacionid = models.AutoField(db_column='CapacitacionID', primary_key=True)  # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')  # Field name made lowercase.
    fechacapacitacion = models.DateTimeField(db_column='FechaCapacitacion', blank=True, null=True)  # Field name made lowercase.
    cantidadasistentes = models.IntegerField(db_column='CantidadAsistentes')  # Field name made lowercase.
    materiales = models.CharField(db_column='Materiales', max_length=200, db_collation='Modern_Spanish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    descripcion = models.CharField(db_column='Descripcion', max_length=200, db_collation='Modern_Spanish_CI_AS', blank=True, null=True)  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.
    contratoid = models.ForeignKey('Contrato', models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.
    extra = models.BooleanField(db_column='Extra')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Capacitacion'


class Checklist(models.Model):
    checklistid = models.AutoField(db_column='ChecklistID', primary_key=True)  # Field name made lowercase.
    fechachecklist = models.DateField(db_column='FechaChecklist')  # Field name made lowercase.
    visitaid = models.ForeignKey('Visita', models.DO_NOTHING, db_column='VisitaID')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Checklist'
        unique_together = (('checklistid', 'visitaid'),)


class Cliente(models.Model):
    rutcliente = models.CharField(db_column='RutCliente', primary_key=True, max_length=12, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    razonsocial = models.CharField(db_column='RazonSocial', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    direccion = models.CharField(db_column='Direccion', max_length=100, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    telefono = models.CharField(db_column='Telefono', max_length=12, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    representante = models.CharField(db_column='Representante', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    rutrepresentante = models.CharField(db_column='RutRepresentante', max_length=12, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.
    usuarioid = models.ForeignKey(AppuserUser, models.DO_NOTHING, db_column='UsuarioID', blank=True, null=True)  # Field name made lowercase.
    rubroid = models.ForeignKey('Rubroempresa', models.DO_NOTHING, db_column='RubroID')  # Field name made lowercase.
    cantidadtrabajadores = models.IntegerField(db_column='CantidadTrabajadores', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Cliente'
        unique_together = (('rutcliente', 'rubroid'),)


class Contrato(models.Model):
    contratoid = models.AutoField(db_column='ContratoID', primary_key=True)  # Field name made lowercase.
    cantidadasesorias = models.IntegerField(db_column='CantidadAsesorias')  # Field name made lowercase.
    cantidadcapacitaciones = models.IntegerField(db_column='CantidadCapacitaciones')  # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')  # Field name made lowercase.
    fechatermino = models.DateTimeField(db_column='FechaTermino')  # Field name made lowercase.
    fechapago = models.DateField(db_column='FechaPago')  # Field name made lowercase.
    cuotascontrato = models.IntegerField(db_column='CuotasContrato')  # Field name made lowercase.
    valorcontrato = models.DecimalField(db_column='ValorContrato', max_digits=19, decimal_places=4)  # Field name made lowercase.
    pagado = models.BooleanField(db_column='Pagado')  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.
    rutempleado = models.ForeignKey('Empleado', models.DO_NOTHING, db_column='RutEmpleado', blank=True, null=True)  # Field name made lowercase.
    rutcliente = models.ForeignKey(Cliente, models.DO_NOTHING, db_column='RutCliente', blank=True, null=True)  # Field name made lowercase.
    rubroid = models.ForeignKey(Cliente, models.DO_NOTHING, db_column='RubroID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Contrato'


class Empleado(models.Model):
    rutempleado = models.CharField(db_column='RutEmpleado', primary_key=True, max_length=12, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    nombre = models.CharField(db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    apellido = models.CharField(db_column='Apellido', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    cargo = models.CharField(db_column='Cargo', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.
    usuarioid = models.ForeignKey(AppuserUser, models.DO_NOTHING, db_column='UsuarioID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Empleado'


class Error(models.Model):
    errorid = models.AutoField(db_column='ErrorID', primary_key=True)  # Field name made lowercase.
    mensajeerror = models.CharField(db_column='MensajeError', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    descripcion = models.CharField(db_column='Descripcion', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Error'


class Historialactividad(models.Model):
    historialactividadid = models.AutoField(db_column='HistorialActividadID', primary_key=True)  # Field name made lowercase.
    tipoactividad = models.CharField(db_column='TipoActividad', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    fechacreacion = models.DateTimeField(db_column='FechaCreacion')  # Field name made lowercase.
    fecharealizada = models.DateTimeField(db_column='FechaRealizada', blank=True, null=True)  # Field name made lowercase.
    estado = models.CharField(db_column='Estado', max_length=20, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    rutempleado = models.ForeignKey(Empleado, models.DO_NOTHING, db_column='RutEmpleado')  # Field name made lowercase.
    asesoriaid = models.ForeignKey(Asesoria, models.DO_NOTHING, db_column='AsesoriaID', blank=True, null=True)  # Field name made lowercase.
    capacitacionid = models.ForeignKey(Capacitacion, models.DO_NOTHING, db_column='CapacitacionID', blank=True, null=True)  # Field name made lowercase.
    visitaid = models.ForeignKey('Visita', models.DO_NOTHING, db_column='VisitaID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'HistorialActividad'


class Informevisita(models.Model):
    informevisitaid = models.AutoField(db_column='InformeVisitaID', primary_key=True)  # Field name made lowercase.
    situacion = models.CharField(db_column='Situacion', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    fecha = models.DateField(db_column='Fecha')  # Field name made lowercase.
    contratoid = models.ForeignKey(Contrato, models.DO_NOTHING, db_column='ContratoID')  # Field name made lowercase.
    visitaid = models.ForeignKey('Visita', models.DO_NOTHING, db_column='VisitaID')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'InformeVisita'
        unique_together = (('informevisitaid', 'visitaid', 'contratoid'),)


class Itemschecklist(models.Model):
    itemcheclistid = models.AutoField(db_column='ItemCheclistID', primary_key=True)  # Field name made lowercase.
    nombre = models.CharField(db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    aprobado = models.BooleanField(db_column='Aprobado', blank=True, null=True)  # Field name made lowercase.
    reprobado = models.BooleanField(db_column='Reprobado', blank=True, null=True)  # Field name made lowercase.
    semiaprobado = models.BooleanField(db_column='SemiAprobado', blank=True, null=True)  # Field name made lowercase.
    checklistid = models.ForeignKey(Checklist, models.DO_NOTHING, db_column='ChecklistID')  # Field name made lowercase.
    visitaid = models.ForeignKey(Checklist, models.DO_NOTHING, db_column='VisitaID')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ItemsChecklist'
        unique_together = (('itemcheclistid', 'checklistid', 'visitaid'),)


class Mejora(models.Model):
    mejoraid = models.AutoField(db_column='MejoraID', primary_key=True)  # Field name made lowercase.
    planmejora = models.CharField(db_column='PlanMejora', max_length=500, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    fecha = models.DateField(db_column='Fecha')  # Field name made lowercase.
    aplicomejora = models.BooleanField(db_column='AplicoMejora')  # Field name made lowercase.
    informevisitaid = models.ForeignKey(Informevisita, models.DO_NOTHING, db_column='InformeVisitaID', blank=True, null=True)  # Field name made lowercase.
    visitaid = models.ForeignKey(Informevisita, models.DO_NOTHING, db_column='VisitaID', blank=True, null=True)  # Field name made lowercase.
    contratoid = models.ForeignKey(Informevisita, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Mejora'


class Pagos(models.Model):
    pagosid = models.AutoField(db_column='PagosID', primary_key=True)  # Field name made lowercase.
    fechapago = models.DateTimeField(db_column='FechaPago')  # Field name made lowercase.
    fechavencimiento = models.DateTimeField(db_column='FechaVencimiento')  # Field name made lowercase.
    valorcuota = models.DecimalField(db_column='ValorCuota', max_digits=19, decimal_places=4)  # Field name made lowercase.
    montoextra = models.DecimalField(db_column='MontoExtra', max_digits=19, decimal_places=4)  # Field name made lowercase.
    valorpago = models.DecimalField(db_column='ValorPago', max_digits=19, decimal_places=4)  # Field name made lowercase.
    tipopagoid = models.ForeignKey('Tipopagos', models.DO_NOTHING, db_column='TipoPagoID', blank=True, null=True)  # Field name made lowercase.
    contratoid = models.ForeignKey(Contrato, models.DO_NOTHING, db_column='ContratoID', blank=True, null=True)  # Field name made lowercase.
    estado = models.BooleanField(db_column='Estado')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Pagos'


class Rubroempresa(models.Model):
    rubroid = models.AutoField(db_column='RubroID', primary_key=True)  # Field name made lowercase.
    nombre = models.CharField(db_column='Nombre', max_length=250, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'RubroEmpresa'


class Tipopagos(models.Model):
    tipopagoid = models.IntegerField(db_column='TipoPagoID', primary_key=True)  # Field name made lowercase.
    nombre = models.CharField(db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'TipoPagos'


class Valorextra(models.Model):
    valorid = models.AutoField(db_column='ValorID', primary_key=True)  # Field name made lowercase.
    nombre = models.CharField(db_column='Nombre', max_length=50, db_collation='Modern_Spanish_CI_AS')  # Field name made lowercase.
    valor = models.DecimalField(db_column='Valor', max_digits=19, decimal_places=4)  # Field name made lowercase.

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


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255, db_collation='Modern_Spanish_CI_AS')
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(db_collation='Modern_Spanish_CI_AS', blank=True, null=True)
    object_repr = models.CharField(max_length=200, db_collation='Modern_Spanish_CI_AS')
    action_flag = models.SmallIntegerField()
    change_message = models.TextField(db_collation='Modern_Spanish_CI_AS')
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AppuserUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100, db_collation='Modern_Spanish_CI_AS')
    model = models.CharField(max_length=100, db_collation='Modern_Spanish_CI_AS')

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255, db_collation='Modern_Spanish_CI_AS')
    name = models.CharField(max_length=255, db_collation='Modern_Spanish_CI_AS')
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40, db_collation='Modern_Spanish_CI_AS')
    session_data = models.TextField(db_collation='Modern_Spanish_CI_AS')
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
