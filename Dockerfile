FROM python:3.11-slim

# Installeer compilers, git, cmake en graphviz
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    git \
    make \
    cmake \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Maak een vaste niet-root gebruiker aan (UID 1000)
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# 1. Clone de officiële FlexFringe repository, wissel naar de juiste branch en compileer
RUN git clone https://github.com/tudelft-cda-lab/FlexFringe.git /opt/FlexFringe && \
    cd /opt/FlexFringe && \
    git checkout fixed_sat_solver_and_json_parsing && \
    mkdir -p build && cd build && \
    cmake .. && make && \
    cp /opt/FlexFringe/flexfringe /usr/local/bin/flexfringe && \
    chmod +x /usr/local/bin/flexfringe

# 2. Installeer de Python bindings
RUN pip install --no-cache-dir git+https://github.com/tudelft-cda-lab/FlexFringe-python.git

WORKDIR /app

# 3. Installeer overige Python packages
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Schakel over naar de vaste gebruiker
USER appuser

# Kopieer de lab-bestanden
COPY --chown=appuser:appuser . .

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]