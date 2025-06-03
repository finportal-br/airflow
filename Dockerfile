FROM apache/airflow:2.7.3

USER root

# Instalar bibliotecas do sistema necessárias para o Chromium do Playwright
RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg2 ca-certificates \
    libglib2.0-0 libnss3 libgconf-2-4 libfontconfig1 libxss1 \
    libappindicator3-1 libasound2 libatk-bridge2.0-0 libgtk-3-0 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    fonts-liberation xdg-utils --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER airflow

# Instalar pacotes Python do projeto
COPY requirements.txt /requirements.txt
RUN pip install --user --no-cache-dir -r /requirements.txt
