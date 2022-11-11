from django import forms
from AppUser.models import User

class UserLoginForm(forms.Form):
    username = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'id': 'loginUsername',
                'type': 'text',
                'class': 'input',
                'placeholder': 'Nombre de usuario',
                'name': 'username'
            }
        )
    )
    password = forms.CharField(
        widget=forms.PasswordInput(
            attrs={
                'id': 'loginPassword',
                'type': 'password',
                'class': 'input',
                'placeholder': 'Contraseña',
                'name': 'password'
            }
        )
    )


class ResetPasswordForm(forms.Form):
    username = forms.CharField(widget=forms.TextInput(attrs={
        'placeholder': 'Ingrese un username',
        'class': 'form-control',
        'autocomplete': 'off'
    }))

    def clean(self):
        cleaned = super().clean()
        if not User.objects.filter(username=cleaned['username']).exists():
            #self._errors['error'] = self._errors.get('error', self.error_class())
            #self._errors['error'].append('El usuario no existe')
            raise forms.ValidationError('El usuario no existe')
        return cleaned

    def get_user(self):
        username = self.cleaned_data.get('username')
        return User.objects.get(username=username)
