from turtle import mode
from urllib.request import AbstractBasicAuthHandler
from xml.parsers.expat import model
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
import uuid
from .managers import CustomUserManager


class User(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(
        db_column='NombreUsuario', max_length=50, db_collation='Modern_Spanish_CI_AS', unique=True)
    date_joined = models.DateTimeField(
        auto_now_add=True, db_column='FechaCreacion')
    last_login = models.DateTimeField(
        auto_now=True, db_column='Last_login')
    email = models.EmailField(max_length=254, null=True, db_column="CorreoElectronico")
    is_staff = models.BooleanField(default=False, db_column="Is_staff")
    is_active = models.BooleanField(default=True, db_column='Estado')
    is_profesional = models.BooleanField(default=False, db_column="Is_Profesional")

    objects = CustomUserManager()

    USERNAME_FIELD = 'username'     
    REQUIRED_FIELDS = []
        
    def __str__(self):
        return self.username