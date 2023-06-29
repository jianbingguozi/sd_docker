FROM python:3.10-slim

RUN echo 'deb https://mirrors.aliyun.com/debian/ bullseye main non-free contrib' > /etc/apt/sources.list \
  && echo 'deb-src https://mirrors.aliyun.com/debian/ bullseye main non-free contrib' >> /etc/apt/sources.list \
  && echo 'deb https://mirrors.aliyun.com/debian-security/ bullseye-security main' >> /etc/apt/sources.list \
  && echo 'deb-src https://mirrors.aliyun.com/debian-security/ bullseye-security main' >> /etc/apt/sources.list \
  && echo 'deb https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib' >> /etc/apt/sources.list \
  && echo 'deb-src https://mirrors.aliyun.com/debian/ bullseye-updates main non-free contrib' >> /etc/apt/sources.list \
  && echo 'deb https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib' >> /etc/apt/sources.list \
  && echo 'deb-src https://mirrors.aliyun.com/debian/ bullseye-backports main non-free contrib' >> /etc/apt/sources.list 

RUN apt update -y \
  && apt install -y wget git python3 python3-venv libglvnd-dev libglib2.0-dev libcairo2-dev xdg-utils \
  && apt install -y libgoogle-perftools4 libtcmalloc-minimal4 git \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

RUN pip config set global.index-url http://10.8.2.148:3141/root/pypi/ \
  && pip config set global.trusted-host 10.8.2.148 \
  && pip config set global.no-cache-dir true
RUN pip install --upgrade pip

RUN pip install torch==2.0.1 torchvision==0.15.2 --extra-index-url https://download.pytorch.org/whl/cu118 

WORKDIR /app

RUN git clone --branch v1.3.2 https://ghproxy.com/https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /app

RUN git clone https://ghproxy.com/https://github.com/Stability-AI/stablediffusion.git /app/repositories/stable-diffusion-stability-ai
RUN git -C /app/repositories/stable-diffusion-stability-ai checkout cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf

RUN git clone https://ghproxy.com/https://github.com/CompVis/taming-transformers.git /app/repositories/taming-transformers
RUN git -C /app/repositories/taming-transformers checkout 24268930bf1dce879235a7fddd0b2355b84d7ea6

RUN git clone https://ghproxy.com/https://github.com/crowsonkb/k-diffusion.git /app/repositories/k-diffusion
RUN git -C /app/repositories/k-diffusion checkout c9fe758757e022f05ca5a53fa8fac28889e4f1cf

RUN git clone https://ghproxy.com/https://github.com/sczhou/CodeFormer.git /app/repositories/CodeFormer
RUN git -C /app/repositories/CodeFormer checkout c5b4593074ba6214284d6acd5f1719b6c5d739af

RUN git clone https://ghproxy.com/https://github.com/salesforce/BLIP.git /app/repositories/BLIP
RUN git -C /app/repositories/BLIP checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9

RUN pip install -r "/app/repositories/CodeFormer/requirements.txt"
RUN pip install -r requirements_versions.txt

RUN pip install https://ghproxy.com/https://github.com/TencentARC/GFPGAN/archive/8d2447a2d918f8eba5a4a01463fd48e45126a379.zip
RUN pip install https://ghproxy.com/https://github.com/openai/CLIP/archive/d50d76daa670286dd6cacf3bcd80b5e4823fc8e1.zip
RUN pip install https://ghproxy.com/https://github.com/mlfoundations/open_clip/archive/bb6e834e9c70d9c27d0dc3ecedeebeaeb1ffad6b.zip
RUN pip install -U -I --no-deps xformers==0.0.17
RUN pip install install ngrok

RUN pip install mediapipe
RUN pip install svglib
RUN pip install fvcore
RUN pip install python-dotenv
RUN pip install Pillow

COPY sd_cache /root/.cache
COPY webui.sh webui.sh

# 忽略git权限校验
RUN git config --global --add safe.directory '*'

EXPOSE 7860

# sudo docker run -it --rm --gpus all -p 7860:7860 -v /home/dell/liweixiang/stable-diffusion-webui/webui.sh:/app/webui.sh -v /home/dell/liweixiang/stable-diffusion-webui/models/:/app/models jianbing/sd:dev1 bash
