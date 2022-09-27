from enum import unique
from multiprocessing.connection import Client
from django import forms
from .models import Cliente, Empleado, RubroEmpresa
from django.forms import ValidationError
from datetime import date
from datetime import datetime

from AppBase import models


class CreateClienteForm(forms.Form):
    rut = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRut',
                'type': 'text',
                'class': '',
                'placeholder': '',
                'name': 'rut',
            }
        )
    )      
    razon = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'clienteRazon',
                'type': 'text',
                'class': '',
                'placeholder': '',
                'name': 'razon',
            }
        )
    )
    direccion = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'clienteDireccion',
                'type': 'text',
                'class': '',
                'placeholder': '',
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
                'placeholder': '',
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
                'placeholder': '',
                'name': 'representante',
            }
        )
    )
    rubro = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'clienteRubro',
                'type': 'number',
                'class': '',
                'placeholder': '',
                'name': 'rubro',
            }
        )
    )    
        
    rut=forms.CharField(min_length=8, max_length=12)
    razon=forms.CharField(min_length=3, max_length=50, required=True,
    widget=forms.TextInput(attrs={'class':'form-control' , 'autocomplete': 'off',
    'pattern':'[A-Za-z]+', 'title':'No puede contener numeros ni cracteres especiales '}))
    direccion=forms.CharField(min_length=3, max_length=100)
    telefono=forms.IntegerField()
    representante=forms.CharField(min_length=3, max_length=50, required=True,
    widget=forms.TextInput(attrs={'class':'form-control' , 'autocomplete': 'off',
    'pattern':'[A-Za-z]+', 'title':'No puede contener numeros ni cracteres especiales '}))
    rubro=forms.IntegerField(max_value=4)

    def clean_rut(self):
        rut = self.cleaned_data["rut"]
        existe = Cliente.objects.filter(RutCliente=rut).exists()

        if existe:
            raise ValidationError("Rut ya registrado!")
            
        return rut
    
    def validarRazon(self):
        razon = self.cleaned_data["razon"]
        if razon.isalpha():
            raise ValidationError("Solo ingresar texto")
        return razon


class CreateEmpleadoForm(forms.Form):
    rut = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'empRut',
                'type': 'text',
                'class': '',
                'placeholder': '',
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
                'placeholder': '',
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
                'placeholder': '',
                'name': 'apellido',
            }
        )
    )
    cargo = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'empCargo',
                'type': 'text',
                'class': '',
                'placeholder': '',
                'name': 'cargo',
            }
        )
    )


class CreateContratoForm(forms.Form):
    asesoria = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoAsesoria',
                'type': 'number',
                'class': '',
                'placeholder': '',
                'name': 'asesoria',
            }
        )
    )
    capa = forms.IntegerField(
        widget=forms.NumberInput(
            attrs={
                'id': 'contratoCapa',
                'type': 'number',
                'class': '',
                'placeholder': '',
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
                'placeholder': '',
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
                'placeholder': '',
                'name': 'valor',
            }
        )
    )
    cliente = forms.ModelChoiceField(
            queryset=Cliente.objects.all(),
            initial=0 
    )
    empleado = forms.ModelChoiceField(
        queryset=Empleado.objects.all(),
        initial=0 
    )

    def clean_fecha(self):
        fecha = self.cleaned_data["termino"]
        now = datetime.now()
        
        if fecha < now:
            raise ValidationError("Ingrese una fecha valida")
            
        return fecha    

class CreateAccidenteForm(forms.Form):
    fecha = forms.DateTimeField(
        widget=forms.DateTimeInput(
            attrs={
                'id': 'accidenteTermino',
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

    
    