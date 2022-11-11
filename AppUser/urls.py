from django.urls import path
from AppUser import views
from django.contrib.auth import views as auth_views

app_name = 'users'

urlpatterns = [
    path('login/', views.LoginView, name='login'),
    path('logout/', views.LogoutView, name='logout'),

    path('password-reset/', auth_views.PasswordResetView.as_view(), name='password_reset'),
    path('password-reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('done/', auth_views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),
]