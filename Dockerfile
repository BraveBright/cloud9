#ARG user="cloud9"

FROM ubuntu:18.04 as builder
RUN apt-get update -qq \
 && apt-get install -qq -y build-essential curl wget git nodejs npm python tmux \
 && useradd -u 1000 -m cloud9
USER cloud9
RUN git clone https://github.com/c9/core.git /home/cloud9/c9 --depth=1
WORKDIR /home/cloud9/c9/
RUN npm install --silent optimist async pty.js tmux \
 && npm update --silent
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8
RUN sh scripts/install-sdk.sh
RUN touch /home/cloud9/.c9/user.settings /home/cloud9/.c9/project.settings

FROM ubuntu:18.04
RUN apt-get update -qq \
 && apt-get upgrade -qq -y \
 && apt-get install -qq -y nodejs tmux openssh-client bash-completion git \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -u 1000 -m cloud9
COPY --from=builder --chown=1000:1000 /home/cloud9/c9 /home/cloud9/c9
COPY --from=builder --chown=1000:1000 /home/cloud9/.c9 /home/cloud9/.c9
USER cloud9
WORKDIR /home/cloud9/c9
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8
ENTRYPOINT ["node","server.js"]
