from django.shortcuts import render


def index(request):
    return render(request, 'channels_app/index.html')
