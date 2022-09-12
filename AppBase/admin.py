from django.contrib import admin
from AppBase.models import Cliente, Empleado, Contrato, Accidente, RubroEmpresa

# # Register your models here.
admin.site.register(Cliente)
admin.site.register(Empleado)
admin.site.register(Contrato)
admin.site.register(Accidente)
admin.site.register(RubroEmpresa)