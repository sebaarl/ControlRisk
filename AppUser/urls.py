from django.urls import path
from AppUser.views import LoginView, LogoutView

app_name = 'users'

urlpatterns = [
    path('login/', LoginView, name='login'),
    path('logout/', LogoutView, name='logout'),
]