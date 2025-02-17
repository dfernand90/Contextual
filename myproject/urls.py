"""
URL configuration for myproject project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
import core.views as views
from core.views import upload_files
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/total/<str:username>/', views.get_total, name='get_total'),
    path('api/add/<str:username>/', views.add_number, name='add_number'),
    path('api/login/', views.login, name='login'),
    path('api/signup/', views.signup, name='signup'),
    path('api/upload/', views.upload_file, name='upload_files'),
    path('api/files/<str:username>/', views.list_files, name='list_files'),
    path('api/query_llm/', views.query_llm, name='query_llm'),
]
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# (Invoke-WebRequest -Uri "https://1db7-85-252-83-74.ngrok-free.app/api/total/er" -Method Get).Content
# (Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/total/er" -Method Get).Content
# curl -I "https://1db7-85-252-83-74.ngrok-free.app/api/total/er"
