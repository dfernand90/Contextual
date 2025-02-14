from django.db import models
from django.contrib.auth.models import User

def user_directory_path(instance, filename):
    return f"userfolder/{instance.username}/{filename}"

class UserNumber(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    accumulated_number = models.IntegerField(default=0)
    pdf1 = models.FileField(upload_to=user_directory_path, blank=True, null=True)
    pdf2 = models.FileField(upload_to=user_directory_path, blank=True, null=True)
    pdf3 = models.FileField(upload_to=user_directory_path, blank=True, null=True)


    def __str__(self):
        return f"{self.user.username} - {self.accumulated_number}"
