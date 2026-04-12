FROM docker.io/ubuntu:25.10

# We accept the following hadolint issues because
# this is a Development Container.
#
# hadolint global ignore=DL3008,DL3009,DL3015

RUN apt-get --yes update && apt-get --yes install git parallel

ENV LANG=C LC_ALL=C LC_CTYPE=C

# hadolint ignore=SC2016
RUN printf '#!/bin/bash\nexport LANG=C\nsource "${HOME}/.config/bash/90-hermes.sh"\n' >'/home/ubuntu/.bashrc'
