from django.contrib import admin
from AppBase.models import Cliente, Empleado, Contrato, Accidente, Historialactividad, Pagos, RubroEmpresa, Visita, Asesoria, Informevisita, Mejora

# # Register your models here.
admin.site.register(Cliente)
admin.site.register(Empleado)
admin.site.register(Contrato)
admin.site.register(Accidente)
admin.site.register(RubroEmpresa)
admin.site.register(Asesoria)
admin.site.register(Visita)
admin.site.register(Historialactividad)
admin.site.register(Pagos)
admin.site.register(Informevisita)
admin.site.register(Mejora)