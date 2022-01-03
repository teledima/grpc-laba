FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 5001

ENV GOOGLE_APPLICATION_CREDENTIALS=application_default_credentials.json
ENV GOOGLE_CLOUD_PROJECT=eng-empire-336419
ENV INSTANCE_CONNECTION_STRING=eng-empire-336419:us-central1:games
ENV DRIVER=pg8000
ENV USER=postgres
ENV PASSWORD=postgres
ENV DB_NAME=postgres

CMD ["python", "async_greeter_server.py"]
