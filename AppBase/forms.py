from django import forms
from AppBase.models import Cliente, Empleado, RubroEmpresa
from django.forms import ValidationError


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

    def clean_rut(self):
        rut = self.cleaned_data["rut"]
        existe = Cliente.objects.filter(rutcliente=rut).exists()

        if existe:
            raise ValidationError("Rut ya registrado!")
            
        return rut


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
    cliente = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'contratCliente',
                'type': 'text',
                'class': '',
                'placeholder': '',
                'name': 'cliente',
            }
        )
    )
    emp = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'contratEmp',
                'type': 'text',
                'class': '',
                'placeholder': '',
                'name': 'empleado',
            }
        )
    )


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