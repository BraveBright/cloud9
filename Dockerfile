FROM ubuntu:18.04 as builder
WORKDIR /root
RUN apt-get update \
 && apt-get install -y build-essential curl wget git nodejs npm python tmux \
 && git clone https://github.com/c9/core.git c9 --depth=1
WORKDIR /root/c9
RUN npm install optimist async pty.js tmux \
 && npm update
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8
RUN sh scripts/install-sdk.sh

FROM ubuntu:18.04
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y nodejs tmux openssh-client bash-completion git \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /root/c9 /root/c9
COPY --from=builder /root/.c9 /root/.c9
WORKDIR /root/c9
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8
ENTRYPOINT ["node","server.js"]
