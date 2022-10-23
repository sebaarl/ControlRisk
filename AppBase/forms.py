from multiprocessing.connection import Client
from pyexpat import model
from turtle import title
from wsgiref.validate import validator
from django import forms
from AppBase.models import Cliente, Empleado, RubroEmpresa
from django.forms import ValidationError
from django.utils.translation import gettext_lazy as _
from django.core.validators import MaxValueValidator, MaxLengthValidator, MinLengthValidator
from AppBase.validators import validate_length
from django.forms import ModelForm
from django.forms import fields


class CreateClienteForm(forms.Form):
    rut = forms.CharField(
        max_length=12,
        min_length=8,
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRut',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese RUT',
                'name': 'rut',
                # 'pattern': '^\d{1,2}\.\d{3}\.\d{3}[-][0-9kK]{1}$',
                # 'title': 'Ingrese RUT en formato correcto XX.XXX.XXX-X',
            }
        )
    )
    razon = forms.CharField(
        min_length=1,
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRazon',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese Razón Social',
                'name': 'razon',
                'title': 'Ingrese la Razón Social',
            }
        )
    )
    direccion = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'clienteDireccion',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese dirección',
                'name': 'direccion',
            }
        )
    )
    telefono = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'clienteTelefono',
                'type': 'number',
                'class': '',
                'placeholder': 'Ingrese telefono',
                'name': 'telefono',
            }
        )
    )
    representante = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRepresentante',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese representante legal',
                'name': 'representante',
                # 'pattern': '^([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\']+[\s])+([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])+[\s]?([A-Za-zÁÉÍÓÚñáéíóúÑ]{0}?[A-Za-zÁÉÍÓÚñáéíóúÑ\'])?$',
                # 'title': 'Ingrese nombre de Representante Legal correctamente'
            }
        )
    )
    rutrepre = forms.CharField(
        max_length=12,
        min_length=8,
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRutRepre',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese RUT',
                'name': 'rut',
                'pattern': '^\d{1,2}\.\d{3}\.\d{3}[-][0-9kK]{1}$',
                'title': 'Ingrese RUT en formato correcto XX.XXX.XXX-X',
            }
        )
    )
    rubro = forms.ModelChoiceField(
        queryset=RubroEmpresa.objects.all(),
        initial=0,
        widget=forms.Select(
            attrs={
                'id': 'clienteRubro',
                'type': 'select',
                'class': '',
                'placeholder': 'Ingrese rubro de la empresa',
                'name': 'rubro',
            }
        )
    )

    def clean_rut(self):
        rut = self.cleaned_data["rut"]
        existe = Cliente.objects.filter(rutcliente=rut).exists()
        if existe:
            raise ValidationError("Rut ya registrado!")
        return rut


class CreateEmpleadoForm(forms.Form):
    CARGO_CHOICES = [
        ('Profesional', 'Profesional'),
        ('Administrador', 'Administrador'),
    ]

    rut = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'empRut',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese rut del empleado',
                'name': 'rut',
            }
        )
    )
    nombre = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'empRut',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese nombres del empleado',
                'name': 'nombre',
            }
        )
    )
    apellido = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'empApellido',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese apellidos del empleado',
                'name': 'apellido',
            }
        )
    )
    cargo = forms.ChoiceField(
        widget=forms.Select(
            attrs={
                'id': 'empCargo',
                'type': 'text',
                'class': '',
                'placeholder': 'Ingrese cargo del empleado',
                'name': 'cargo',
            }
        ),
        choices=CARGO_CHOICES
    )


class CreateContratoForm(forms.Form):
    asesoria = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoAsesoria',
                'type': 'number',
                'class': '',
                'placeholder': 'Ingrese n° de asesorias',
                'name': 'asesoria',
                'pattern': '[0-9]',
                'title': 'Ingrese un nro. telefonico correcto',
            }
        )
    )
    capa = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoCapa',
                'type': 'number',
                'class': '',
                'placeholder': 'Ingrese n° de capacitaciones',
                'name': 'capa',
            }
        )
    )
    termino = forms.DateTimeField(
        widget=forms.DateTimeInput(
            attrs={
                'id': 'contratoTermino',
                'type': 'date',
                'class': '',
                'placeholder': '',
                'name': 'termino',
            }
        )
    )
    pago = forms.DateField(
        widget=forms.DateInput(
            attrs={
                'id': 'contratoPago',
                'type': 'date',
                'class': '',
                'placeholder': '',
                'name': 'pago',
            }
        )
    )
    cuota = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoCuota',
                'type': 'number',
                'class': '',
                'placeholder': 'Ingrese n° de cuotas del contrato',
                'name': 'cuota',
            }
        )
    )
    valor = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoValor',
                'type': 'number',
                'class': '',
                'placeholder': 'Ingrese el valor total',
                'name': 'valor',
            }
        )
    )
    cliente = forms.ModelChoiceField(
        queryset=Cliente.objects.all(),
        initial=0,
        widget=forms.Select(
            attrs={
                'id': 'clienteCli',
                'type': 'select',
                'class': '',
                'placeholder': 'Ingrese RUT',
                'name': 'empleado',
            }
        )
    )
    empleado = forms.ModelChoiceField(
        queryset=Empleado.objects.all(),
        initial=0,
        widget=forms.Select(
            attrs={
                'id': 'clienteRut',
                'type': 'select',
                'class': '',
                'placeholder': 'Ingrese RUT',
                'name': 'empleado',
            }
        )
    )


class CreateAccidenteForm(forms.Form):
    fecha = forms.DateTimeField(
        widget=forms.DateTimeInput(
            attrs={
                'id': 'accidenteFecha',
                'type': 'date',
                'class': '',
                'placeholder': '',
                'name': 'fecha',
            }
        )
    )
    descripcion = forms.CharField(
        widget=forms.Textarea(
        )
    )
    medidas = forms.CharField(
        widget=forms.Textarea(
        )
    )


class CreateAsesoriaEspecial(forms.Form):
    fecha = forms.DateField(
        widget=forms.DateInput(
            attrs={
                'id': 'especialFecha',
                'type': 'date',
                'class': '',
                'placeholder': '',
                'name': 'fecha',
            }
        )
    )
    hora = forms.TimeField(
        widget=forms.TimeInput(
            attrs={
                'id': 'especialHora',
                'type': 'time',
                'class': '',
                'placeholder': '',
                'name': 'fecha',
            }
        )
    )
    descripcion = forms.CharField(
        widget=forms.Textarea(
        )
    )


class EstadoAsesoria(forms.Form):
    ESTADO_CHOICES = [
        ('FINALIZADA', 'FINALIZADA'),
        ('EN PROGRESO', 'EN PROGRESO'),
    ]

    estado = forms.ChoiceField(
        widget=forms.Select(
            attrs={
                'id': 'asesoriaEstado',
                'type': 'text',
                'class': '',
                'name': 'estado',
            }
        ),
        choices=ESTADO_CHOICES
    )


class EstadoVisita(forms.Form):
    ESTADO_CHOICES = [
        ('FINALIZADA', 'FINALIZADA'),
        ('EN PROGRESO', 'EN PROGRESO'),
    ]

    estado = forms.ChoiceField(
        widget=forms.Select(
            attrs={
                'id': 'visitaEstado',
                'type': 'text',
                'class': '',
                'name': 'estado',
            }
        ),
        choices=ESTADO_CHOICES
    )


class ChecklistForm(forms.Form):
    ESTADO_CHOICES = [
        ('NO CUMPLE', 'NO CUMPLE'),
        ('MEDIANAMENTE CUMPLIDO', 'MEDIANAMENTE CUMPLIDO'),
        ('CUMPLE', 'CUMPLE'),
    ]
    estado = forms.ChoiceField(
        widget=forms.Select(
            attrs={
                'class': 'estado-radio'
            }
        ), 
        choices=ESTADO_CHOICES
    )


class ChecklistItem(forms.Form):
    nombre = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'nombre',
                'type': 'text',
                'class': 'itemform',
                'placeholder': 'Ingrese item que desea agregar',
                'name': 'nombre',
            }
        )
    )

    ap = forms.BooleanField()

    sa = forms.BooleanField()

    r = forms.BooleanField()
