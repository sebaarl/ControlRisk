from django.contrib import messages
from django.shortcuts import render
from django.views.generic import View
from django.contrib.auth import authenticate, get_user_model, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.hashers import make_password
from django.http.response import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.contrib.auth import authenticate, login

from AppUser.forms import UserLoginForm
from AppUser.models import User


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

user=get_user_model()


def LogoutView(request):    
    logout(request)
    return redirect('user:login')