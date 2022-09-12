from django.contrib.auth.models import BaseUserManager
from django.utils.translation import gettext_lazy as _
import uuid

class CustomUserManager(BaseUserManager):
    def create_user(self, username, password, **other_fields):
        if not username:
            raise ValueError('Users must have a username')

        user = self.model(
            username = username,
            **other_fields
        )
        user.is_active  = True

        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, username, password, **other_fields):

        other_fields.setdefault('is_staff', True)
        other_fields.setdefault('is_superuser', True)
        other_fields.setdefault('is_active', True)

        return self.create_user(username, password, **other_fields)