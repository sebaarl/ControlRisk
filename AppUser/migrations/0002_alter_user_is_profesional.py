# Generated by Django 4.0.7 on 2022-09-12 20:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('AppUser', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='is_profesional',
            field=models.BooleanField(db_column='Is_Profesional', default=False),
        ),
    ]
