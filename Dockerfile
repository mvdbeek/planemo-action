FROM python:3.7.5-slim-buster AS builder

MAINTAINER m.vandenbeek@gmail.com

# RUN apk update && apt add linux-headers build-base libxml2-dev libxslt-dev bzip2-dev
# RUN apk add xz-dev
RUN apt-get update && apt-get install -y --no-install-recommends wget git build-essential
RUN pip install virtualenv && \
    virtualenv /venv
RUN mkdir /galaxy && wget -q https://codeload.github.com/galaxyproject/galaxy/tar.gz/release_19.09 -O - | tar -C '/galaxy' --strip-components=1 -xvz
RUN cd /galaxy && GALAXY_VIRTUAL_ENV=/venv DEV_WHEELS=1 GALAXY_SKIP_CLIENT_BUILD=1 sh scripts/common_startup.sh
RUN virtualenv /planemo_venv && \
     cd /root && \
     git clone --recurse-submodules https://github.com/galaxyproject/planemo && \
    . /planemo_venv/bin/activate && pip install planemo/

FROM python:3.7.5-slim-buster
# RUN apk update && apk --no-cache add libxml2-utils
COPY --from=builder /venv /venv
COPY --from=builder /planemo_venv /planemo_venv
COPY --from=builder /galaxy /galaxy

ENV GALAXY_VIRTUAL_ENV=/venv
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
