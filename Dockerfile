FROM python:3.8.0

MAINTAINER m.vandenbeek@gmail.com

RUN python -m pip install ruamel.yaml==0.16.5 planemo
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
