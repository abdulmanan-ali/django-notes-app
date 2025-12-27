# ---------- Stage 1: Build ----------
FROM python:3.9-slim AS builder

WORKDIR /app

RUN apt-get update \
    && apt-get install -y build-essential default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

COPY . .

# ---------- Stage 2: Runtime ----------
FROM gcr.io/distroless/python3-debian11

WORKDIR /app

# Copy venv and app
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

# Use virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Expose port
EXPOSE 8000

# Use non-root user
USER nonroot

# Run Gunicorn directly
CMD ["gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]

