from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.views.decorators.http import require_http_methods
import json
from .models import UserNumber
from django.core.files.storage import default_storage
import stat

import os
from django.conf import settings

def ensure_directory_exists():
    folder_path = os.path.join(settings.MEDIA_ROOT, 'userfolder')
    os.makedirs(folder_path, exist_ok=True) 

def ensure_directory_permissions(directory):
    """ Ensure the directory exists and has correct permissions. """
    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)

    # Set read/write/execute permissions for all users (Windows/Linux)
    os.chmod(directory, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)  

UPLOAD_DIR = "./userfolder/" 
@csrf_exempt
@require_http_methods(["POST"])
def login(request):
    try:
        data = json.loads(request.body)
        username = data['username']
        password = data['password']

        # Authenticate user
        #user = authenticate(username=username, password=password)
        user, created = User.objects.get_or_create(username=username)
        if created:
            user.set_password(password)
            user.save()
            UserNumber.objects.create(user=user) 
        else:
            user = authenticate(username=username, password=password)
        if user is None:
            return JsonResponse({'error': 'Invalid credentials'}, status=401)
        else:
            return JsonResponse({'message': 'Login successful', 'username': username})
    except KeyError:
        return JsonResponse({'error': 'Invalid request data'}, status=400)

# View to fetch the accumulated total for a user
def get_total(request, username):
    try:
        user = User.objects.get(username=username)
        user_total = UserNumber.objects.get(user=user)
        return JsonResponse({'total': user_total.accumulated_number})
    except UserNumber.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

# View to add a number to the user's total
@csrf_exempt
@require_http_methods(["POST"])
def add_number(request, username):
    try:
        user = User.objects.get(username=username)
        user_total = UserNumber.objects.get(user=user)
        data = json.loads(request.body)
        number_to_add = data.get('number', 0)
        user_total.accumulated_number  += number_to_add
        user_total.save()
        return JsonResponse({'new_total': user_total.accumulated_number})
    except UserNumber.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

@csrf_exempt
def upload_files(request):
    if request.method == 'POST' and request.FILES:
        ensure_directory_exists()  # Ensure the directory exists
        username = request.POST.get('username')
        user = User.objects.get(username=username)

        #user, created = UserNumber.objects.get_or_create(username=username)

        # Save files to respective slots if they are uploaded
        if 'pdf1' in request.FILES:
            user.pdf1 = request.FILES['pdf1']
        if 'pdf2' in request.FILES:
            user.pdf2 = request.FILES['pdf2']
        if 'pdf3' in request.FILES:
            user.pdf3 = request.FILES['pdf3']

        user.save()
        return JsonResponse({'message': 'Files uploaded successfully'}, status=201)

    return JsonResponse({'error': 'Invalid request'}, status=400)

@csrf_exempt
def upload_file(request):
    if request.method == 'POST':
        username = request.POST.get('username', 'unknown_user')

        if 'file' in request.FILES:
            uploaded_file = request.FILES['file']
            #file_path = f'./userfolder/{username}/{uploaded_file.name}'
            
            user_folder = f'{UPLOAD_DIR}{username}'  # User-specific folder

             # Ensure user folder exists and has correct permissions
            ensure_directory_permissions(user_folder)
            file_path = f'{user_folder}/{uploaded_file.name}'
            with open(file_path, 'wb+') as destination:
                for chunk in uploaded_file.chunks():
                    destination.write(chunk)

            return JsonResponse({'message': 'File uploaded successfully'}, status=201)

        return JsonResponse({'error': 'No file found'}, status=400)

    return JsonResponse({'error': 'Invalid request'}, status=405)

def list_files(request, username):
    """ Returns a list of files in the user's folder. """
    user_folder = os.path.join(UPLOAD_DIR, username)

    if not os.path.exists(user_folder):
        return JsonResponse({"files": []})  # Return empty list if folder doesn't exist

    try:
        files = os.listdir(user_folder)  # Get file names
        return JsonResponse({"files": files})
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)