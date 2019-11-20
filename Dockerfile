FROM python:3.7.5-slim-stretch AS builder

MAINTAINER m.vandenbeek@gmail.com

ARG galaxy_branch=master

ENV PLANEMO_VENV=/planemo_venv
ENV GALAXY_VENV=/venv
ENV GALAXY_ROOT=/galaxy
ENV GALAXY_VIRTUAL_ENV=/venv

RUN apt-get update && apt-get install -y --no-install-recommends wget git build-essential
RUN pip install virtualenv && \
    virtualenv $GALAXY_VENV
RUN mkdir /galaxy && wget -q https://codeload.github.com/galaxyproject/galaxy/tar.gz/${galaxy_branch} -O - | tar -C '/galaxy' --strip-components=1 -xvz
RUN cd /galaxy && GALAXY_VIRTUAL_ENV=$GALAXY_VENV DEV_WHEELS=1 GALAXY_SKIP_CLIENT_BUILD=1 sh scripts/common_startup.sh
RUN virtualenv $PLANEMO_VENV && \
     cd /root && \
     git clone --recurse-submodules https://github.com/galaxyproject/planemo && \
    . $PLANEMO_VENV/bin/activate && pip install planemo/

FROM python:3.7.5-slim-stretch
COPY --from=builder $GALAXY_VENV $GALAXY_VENV
COPY --from=builder $PLANEMO_ENV $PLANEMO_ENV
COPY --from=builder $GALAXY_ROOT $GALAXY_ROOT

ENV GALAXY_VIRTUAL_ENV=/venv
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
