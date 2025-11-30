FROM docker.io/ubuntu:25.10

RUN apt-get --yes update && apt-get --yes install git parallel

ENV LANG=C LC_ALL=C LC_CTYPE=C

RUN echo '#!/bin/bash\nexport LANG=C\nsource "${HOME}/.config/bash/90-hermes.sh"' >'/home/ubuntu/.bashrc'
