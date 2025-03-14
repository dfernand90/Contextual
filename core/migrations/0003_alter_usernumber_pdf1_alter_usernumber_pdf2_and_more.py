# Generated by Django 5.1.5 on 2025-02-13 23:32

import core.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0002_usernumber_pdf1_usernumber_pdf2_usernumber_pdf3'),
    ]

    operations = [
        migrations.AlterField(
            model_name='usernumber',
            name='pdf1',
            field=models.FileField(blank=True, null=True, upload_to=core.models.user_directory_path),
        ),
        migrations.AlterField(
            model_name='usernumber',
            name='pdf2',
            field=models.FileField(blank=True, null=True, upload_to=core.models.user_directory_path),
        ),
        migrations.AlterField(
            model_name='usernumber',
            name='pdf3',
            field=models.FileField(blank=True, null=True, upload_to=core.models.user_directory_path),
        ),
    ]
