from django.contrib import messages
from django.shortcuts import render
from django.contrib.auth import authenticate, get_user_model, login, logout
from django.shortcuts import redirect, render
from django.contrib.auth import authenticate, login
from django.contrib.auth import views as auth_views
from django.views.generic import TemplateView
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from django.template.loader import render_to_string

from AppUser.forms import UserLoginForm
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from django.contrib.auth import login, logout
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.views import LoginView
from django.http import HttpResponseRedirect, JsonResponse
from django.shortcuts import redirect
from django.template.loader import render_to_string
from django.urls import reverse_lazy
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from django.views.generic import FormView, RedirectView


from core import settings
import smtplib
from django.contrib.auth import REDIRECT_FIELD_NAME, get_user_model
from django.contrib.auth.forms import (
    AuthenticationForm,
    PasswordChangeForm,
    PasswordResetForm,
    SetPasswordForm,
)

from django.utils.decorators import method_decorator
from django.utils.translation import gettext_lazy as _
from django.views.decorators.csrf import csrf_protect, csrf_exempt
from django.views.generic.base import TemplateView
from AppUser.forms import ResetPasswordForm


# Create your views here.
def LoginView(request):
    login_form = UserLoginForm(request.POST or None)

    if login_form.is_valid():
        username = login_form.cleaned_data.get('username')
        password = login_form.cleaned_data.get('password')
        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            messages.success(request, 'Has iniciado sesión correctamente!')
            return redirect('base:home')
        else:
            messages.warning(
                request, 'Nombre de usuario o contraseña incorrecta!!')
            return redirect('base:home')

    messages.error(request, 'Formulario invalido')
    return render(request, 'registration/login.html')


user = get_user_model()


def LogoutView(request):
    logout(request)
    return redirect('user:login')


class PasswordChangeView(FormView):
    form_class = ResetPasswordForm
    template_name = "registration/password_change_form.html"

    @method_decorator(csrf_exempt)
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)

    def send_email_reset_pwd(self, user):
        data = {}
        try:
            mailServer = smtplib.SMTP(settings.EMAIL_HOST, settings.EMAIL_PORT)
            mailServer.starttls()
            mailServer.login(settings.EMAIL_HOST_USER,
                             settings.EMAIL_HOST_PASSWORD)

            email_to = user.email
            mensaje = MIMEMultipart()
            mensaje['From'] = settings.EMAIL_HOST_USER
            mensaje['To'] = email_to
            mensaje['Subject'] = 'Reseteo de contraseña'

            content = render_to_string('login/send_email.html', {
                'user': user,
                'link_resetpwd': '',
                'link_home': ''
            })
            mensaje.attach(MIMEText(content, 'html'))

            mailServer.sendmail(settings.EMAIL_HOST_USER,
                                email_to,
                                mensaje.as_string())
        except Exception as e:
            data['error'] = str(e)
        return data

    def post(self, request, *args, **kwargs):
        data = {}
        try:
            form = ResetPasswordForm(request.POST)  # self.get_form()
            if form.is_valid():
                user = form.get_user()
                data = self.send_email_reset_pwd(user)
            else:
                data['error'] = form.errors
        except Exception as e:
            data['error'] = str(e)
        return JsonResponse(data, safe=False)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['title'] = 'Reseteo de Contraseña'
        return context
