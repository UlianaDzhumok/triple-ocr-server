FROM nvidia/cuda:11.2.2-cudnn8-runtime-ubuntu20.04

# Установим переменную окружения для автоматической установки
ENV DEBIAN_FRONTEND=noninteractive

# Установка Python и pip
RUN apt-get update && apt-get install -y \
    python3.8 python3-pip libssl1.1 libglib2.0-0 libsm6 libxext6 libxrender-dev libtesseract-dev \
    libgl1-mesa-glx \
    && apt-get clean

# Установка Tesseract-OCR
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:alex-p/tesseract-ocr
RUN apt-get update && apt-get install -y tesseract-ocr-rus

# Создание рабочей директории
WORKDIR /app

# Копирование приложения
COPY app /app

# Обновление pip
RUN python3 -m pip install --upgrade pip

# Установка PyTorch, EasyOCR, FastAPI и Uvicorn
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Устанавливаем переменную окружения LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.2/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

ENV HOST=0.0.0.0
ENV PORT=8000

EXPOSE ${PORT}

CMD ["sh", "-c", "uvicorn main:app --host ${HOST} --port ${PORT}"]