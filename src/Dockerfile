
FROM python:3.8-slim

ADD requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

ADD app/ /app/

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
