FROM ubuntu:latest

RUN apt update && apt install -y python3 python3-pip nano imagemagick

WORKDIR /app

COPY plant_extra.py /app/plant_extra.py
COPY requirements.txt /app/requirements.txt

RUN pip3 install --break-system-packages -r requirements.txt

ENTRYPOINT ["python3", "plant_extra.py"]

