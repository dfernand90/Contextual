from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.views.decorators.http import require_http_methods
import json
from .models import UserNumber
from django.core.files.storage import default_storage
import stat
from rest_framework.decorators import api_view
from rest_framework.response import Response
import os
from django.conf import settings
from LLM_model import create_a_query_engine, model_response
import time

#UPLOAD_DIR = "C:\\django_test\\userfolder" 
UPLOAD_DIR = "C:\\Contextual\\Contextual\\userfolder" 
trusted_list = ["Xd8s4RVJwrLZMOmo",
    "qOpLSqsp1DRL1uHE",
    "rWEZyEiwHuPHpfmm",
    "JwNspsCBWJrOJXQp",]

# Dictionary to store user models
user_models = {}

# Dictionary to store last accessed timestamps
user_last_access = {}

# Model timeout in seconds (e.g., 10 minutes)
MODEL_TIMEOUT = 120  

def remove_inactive_models():
    """Removes models that haven't been used in MODEL_TIMEOUT seconds."""
    while True:
        time.sleep(60)  # Check every minute
        now = time.time()
        for user_id in list(user_models.keys()):
            if now - user_last_access[user_id] > MODEL_TIMEOUT:
                del user_models[user_id]  # Remove model from memory
                del user_last_access[user_id]  # Remove timestamp
                print(f"Model for {user_id} removed due to inactivity.")

def create_mode_for_user(username, model ="deepseek-r1:latest", temperature = 0.75):
    document_path =  os.path.join(UPLOAD_DIR, username)
    if not os.path.exists(document_path) or not os.listdir(document_path):  # Checks if the directory is empty
       document_path = "C:\\Contextual\\Contextual\\userfolder\\welcome"
    query_engine = create_a_query_engine(model = model, temperature = temperature, document_path = document_path)
    user_models[username] = query_engine
    user_last_access[username] = time.time()
    return query_engine

def get_model_for_user(username, model ="deepseek-r1:latest", temperature = 0.75):
    """Returns the model for a user, loading it if necessary."""
    if username not in user_models:
        print(f"Loading model for user {username}...")
        #document_path =  os.path.join(UPLOAD_DIR, username)        
        try:
            create_mode_for_user(username, model = model, temperature = temperature)       
        except:
            create_mode_for_user(username, model = "llama3.2:1b", temperature = temperature)
    user_last_access[username] = time.time()  # Update last access time
    return user_models[username]

def ensure_directory_exists():
    folder_path = os.path.join(settings.MEDIA_ROOT, 'userfolder')
    os.makedirs(folder_path, exist_ok=True) 

def ensure_directory_permissions(directory):
    """ Ensure the directory exists and has correct permissions. """
    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)

    # Set read/write/execute permissions for all users (Windows/Linux)
    os.chmod(directory, stat.S_IRWXU | stat.S_IRWXG | stat.S_IRWXO)  



@csrf_exempt
@require_http_methods(["POST"])
def signup(request):
    print("enter in signup")
    try:
        data = json.loads(request.body)
        username = data['username']
        password = data['password']
        #nordic_code = data['code']
        #print("code:",nordic_code)
        if username in trusted_list:
            nordic_code ="nordic-ai.no"
        # Authenticate user
        #user = authenticate(username=username, password=password)
        if nordic_code == "nordic-ai.no":
            print("code verified")
            user, created = User.objects.get_or_create(username=username)
            if created:
                print("user created")
                user.set_password(password)
                user.save()
                UserNumber.objects.create(user=user)
                return JsonResponse({'message': 'Sign successful', 'username': username}) 
            else:
                print("user not created")
                return JsonResponse({'error': 'User already registered'}, status=401)
        else:
            print("code not verified")
            return JsonResponse({'error': 'Fail confirmation code'}, status=401)
           
    except KeyError:
        return JsonResponse({'error': 'Invalid request data'}, status=400)

@csrf_exempt
@require_http_methods(["POST"])
def login(request):
    try:
        data = json.loads(request.body)
        username = data['username']
        password = data['password']
        
        # Authenticate user
        user = authenticate(username=username, password=password)
        """
        user, created = User.objects.get_or_create(username=username)
        if created:
            user.set_password(password)
            user.save()
            UserNumber.objects.create(user=user) 
        else:
            user = authenticate(username=username, password=password)
        """
        if user is None:
            return JsonResponse({'error': 'Invalid credentials'}, status=401)
        else:
            create_mode_for_user(username, model ="llama3.2:1b", temperature = 0.75)
            return JsonResponse({'message': 'Login successful', 'username': username})
    except KeyError:
        return JsonResponse({'error': 'Invalid request data'}, status=400)

# View to fetch the accumulated total for a user
@csrf_exempt
@require_http_methods(["POST"])
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
# DELETE THIS METHOD
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
            
            user_folder = os.path.join(UPLOAD_DIR, username)  # User-specific folder

             # Ensure user folder exists and has correct permissions
            ensure_directory_permissions(user_folder)
            file_path = f'{user_folder}/{uploaded_file.name}'
            with open(file_path, 'wb+') as destination:
                for chunk in uploaded_file.chunks():
                    destination.write(chunk)
            try:
                data = request.body
                model = data['model']
                temperature = data['temperature']
                create_mode_for_user(username, model = model, temperature = temperature)
            except:
                create_mode_for_user(username, model ="llama3.2:1b", temperature = 0.75)
            return JsonResponse({'message': 'File uploaded successfully'}, status=201)

        return JsonResponse({'error': 'No file found'}, status=400)

    return JsonResponse({'error': 'Invalid request'}, status=405)

@csrf_exempt
@require_http_methods(["POST"])
def clear_files(request, username):
    """ Deletes all files in the user's folder. """
    user_folder = os.path.join(UPLOAD_DIR, username)

    if not os.path.exists(user_folder):
        return JsonResponse({"message": "Folder does not exist."})

    try:
        # Remove all files in the folder
        for filename in os.listdir(user_folder):
            file_path = os.path.join(user_folder, filename)
            if os.path.isfile(file_path):
                os.remove(file_path)

        return JsonResponse({"files": []})
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def list_files(request, username):
    print("enter list files")
    """ Returns a list of files in the user's folder. """
    user_folder = os.path.join(UPLOAD_DIR, username)
    print("accessing list files")
    if not os.path.exists(user_folder):
        return JsonResponse({"files": []})  # Return empty list if folder doesn't exist

    try:
        files = os.listdir(user_folder)  # Get file names
        print(files)
        return JsonResponse({"files": files})
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
    
@csrf_exempt
@require_http_methods(["POST"])
def query_llm(request, username):
    
    try:
        user = User.objects.get(username=username)
        #user_total = UserNumber.objects.get(user=user)
        
        data = json.loads(request.body)
        model = data.get('model', 0)
        temperature = data.get('temperature', 0)
        query = data.get('query', 0)
        #document_path =  os.path.join(UPLOAD_DIR, username)
        #query_engine = create_a_query_engine(model = model, temperature = temperature, document_path = document_path)
        query_engine = get_model_for_user(username, model = model, temperature = temperature)
        response = model_response(query_engine, query = query )

        return JsonResponse({'response': response})
    except UserNumber.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)

@csrf_exempt
@require_http_methods(["POST"])
def reload_llm(request, username):
    
    try:
        user = User.objects.get(username=username)
        #user_total = UserNumber.objects.get(user=user)
        
        data = json.loads(request.body)
        model = data.get('model', 0)
        temperature = data.get('temperature', 0)
        #query = data.get('query', 0)
        #document_path =  os.path.join(UPLOAD_DIR, username)
        #query_engine = create_a_query_engine(model = model, temperature = temperature, document_path = document_path)
        _ = get_model_for_user(username, model = model, temperature = temperature)
        #response = model_response(query_engine, query = query )

        return JsonResponse({'response': "model reloaded"})
    except UserNumber.DoesNotExist:
        return JsonResponse({'error': 'User not found'}, status=404)