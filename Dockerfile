FROM python:3.6-slim

WORKDIR /app

COPY app .

RUN pip install -r /app/requirements.txt

EXPOSE 5000
CMD ["python", "/app/main.py"]
