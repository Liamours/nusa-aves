# Build from the repo root so both server/ and model/ land in the image:
#   docker build -f server/Dockerfile -t nusa-aves .
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY server/requirements.txt server/
RUN pip install --no-cache-dir -r server/requirements.txt

COPY model/ model/
COPY server/ server/
WORKDIR /app/server

ENTRYPOINT ["python", "cli.py"]
