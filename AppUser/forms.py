from django import forms


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