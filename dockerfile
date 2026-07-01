FROM python:3.11-slim
RUN apt-get update && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*
RUN pip install aider-chat ruff

RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

RUN mv /root/.local/bin/rtk /usr/local/bin/rtk && chmod 755 /

ENV PATH="/tmp/.local/bin:${PATH}"

RUN mkdir -p /root/.claude && rtk init -g
WORKDIR /app
CMD ["tail", "-f", "/dev/null"]
