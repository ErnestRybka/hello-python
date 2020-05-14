FROM python:3.6-slim

WORKDIR /app

ADD ./app /app/

RUN pip install -r /app/requirements.txt

EXPOSE 5000
CMD ["python", "/app/main.py"]
