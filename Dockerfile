FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the Django project
COPY . .

# Use virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Expose port
EXPOSE 8000

# Run migrations and start server
CMD python manage.py migrate && python manage.py collectstatic --noinput && gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000
