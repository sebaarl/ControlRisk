from django.forms import ValidationError
from django.utils.translation import gettext_lazy as _

def validate_length(value):
    an_integer = value
    a_string = str(an_integer)
    length = len(a_string)
    if length != 6 and length !=7:
        raise ValidationError(
            _('%(value)s Telefono debe ser de 6 o 7 digitos')
        )