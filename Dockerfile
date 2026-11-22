FROM python:3.11-slim

# Installeer compilers, git en cmake
RUN apt-get update && apt-get install -y \
    git \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Maak non-root gebruiker aan met UID 1000
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Installeer Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]