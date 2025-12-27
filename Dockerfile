# ---------- Stage 1: Build ----------
FROM python:3.9-slim as builder

WORKDIR /app

# System deps for building mysqlclient and others
RUN apt-get update \
    && apt-get install -y build-essential default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Create virtualenv to freeze deps cleanly
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy Django project
COPY . .

# ---------- Stage 2: Runtime ----------
FROM gcr.io/distroless/python3-debian11

WORKDIR /app

# Copy venv and application from builder image
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

# Use virtual env
ENV PATH="/opt/venv/bin:$PATH"

# Django will listen on 8000
EXPOSE 8000

# Non-root user for security
USER nonroot

# Run migrations and start gunicorn
CMD ["python", "-c", "import os; os.system('python manage.py migrate && python manage.py collectstatic --noinput && gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000')"]
