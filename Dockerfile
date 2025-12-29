FROM python:3.9-slim

# Set working directory
WORKDIR /app

# System packages required for mysqlclient
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (cache layer)
COPY requirements.txt .

# Install Python deps
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Expose Django/Gunicorn port
EXPOSE 8000

# Run migrations automatically and start gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000"]


# @Library("Shared") _
# pipeline {
#     agent any

#     stages {

#         stage('Code') {
#             steps {
#                 scripts{
#                 echo "This is cloning the code"
#                 git url: "https://github.com/abdulmanan-ali/django-notes-app/", branch: 'main'
#                 echo "Code Cloning Successfully"                  
#                 }

#             }
#         }

#         stage('build') {
#             steps {
#                 echo "This is building the code"
#                 sh "docker build -t notes-app-jenkins:latest ."
#             }
#         }

#         stage('push to dockerhub') {
#             steps {
#                 echo "This is pushing the code to docker hub"
#             }
#         }

#         stage('deploy') {
#             steps {
#                 echo "This is deploying the code"
#                 sh "docker run --name=notes-app-jenkins -d -p 8000:8000 notes-app-jenkins:latest"
#             }
#         }
#     }
# }

