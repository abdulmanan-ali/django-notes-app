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

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

ENV PATH="/opt/venv/bin"

EXPOSE 8000

USER nonroot

# Run the Django app using gunicorn
CMD ["/opt/venv/bin/gunicorn", "notesapp.wsgi:application", "--bind", "0.0.0.0:8000"]
