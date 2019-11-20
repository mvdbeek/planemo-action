FROM python:3.7.5-slim-buster AS builder

MAINTAINER m.vandenbeek@gmail.com

ARG galaxy_branch=master

RUN apt-get update && apt-get install -y --no-install-recommends wget git build-essential
RUN pip install virtualenv && \
    virtualenv /venv
RUN mkdir /galaxy && wget -q https://codeload.github.com/galaxyproject/galaxy/tar.gz/${galaxy_branch} -O - | tar -C '/galaxy' --strip-components=1 -xvz
RUN cd /galaxy && GALAXY_VIRTUAL_ENV=/venv DEV_WHEELS=1 GALAXY_SKIP_CLIENT_BUILD=1 sh scripts/common_startup.sh
RUN virtualenv /planemo_venv && \
     cd /root && \
     git clone --recurse-submodules https://github.com/galaxyproject/planemo && \
    . /planemo_venv/bin/activate && pip install planemo/

FROM python:3.7.5-slim-buster
COPY --from=builder /venv /venv
COPY --from=builder /planemo_venv /planemo_venv
COPY --from=builder /galaxy /galaxy

ENV GALAXY_VIRTUAL_ENV=/venv
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
