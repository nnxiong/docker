# # 使用官方的 Miniconda3 镜像作为基础镜像
# FROM continuumio/miniconda3:latest

# # 设置工作目录
# WORKDIR /app

# # 复制 Conda 环境文件到容器中
# COPY ./envs/environment_linux.yaml /app/environment_linux.yaml

# # 复制 setup.py 文件到容器中
# COPY setup.py /app/setup.py

# # 创建 Conda 环境
# RUN conda env create -f /app/environment_linux.yaml

# # 激活 Conda 环境并安装 Python 包
# RUN echo "conda activate RhoFold" > ~/.bashrc \
#     && python setup.py install


# 使用一个轻量级的基础镜像
FROM ubuntu

# 设置环境变量
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV MINICONDA_VERSION=py39_23.1.0-1
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh \
    && mkdir -p /opt \
    && bash Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh -b -p $CONDA_DIR \
    && rm Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh

# 更新 Conda
RUN conda update -y conda

# 设置默认的 Conda 环境
RUN conda init bash

# 设置工作目录
WORKDIR /app

# # 默认启动命令
# CMD ["/bin/bash"]
