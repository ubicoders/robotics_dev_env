FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
RUN apt-get update && apt-get upgrade -y
RUN echo "alias python=python3" >> /root/.bashrc
# --------------------
# Locale / base setup
# --------------------
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone
# --------------------
# Install locales
# --------------------
RUN apt-get update && apt-get install -y \
    locales \
    lsb-release \
    gnupg2 \
    curl \
    software-properties-common \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US./robot_ws/srcUTF-8


# --------------------
# System packages
# --------------------
RUN apt-get update && apt-get -y --quiet --no-install-recommends install \
  apt-utils \
  autoconf \
  automake \
  bison \
  bzip2 \
  build-essential \
  ca-certificates \
  ccache \
  cmake \
  cppcheck \
  curl \
  dmidecode \
  dirmngr \
  doxygen \
  file \
  flex \
  g++ \
  genromfs \
  gcc \
  gdb \
  git \
  gnupg2 \
  gosu \
  gperf \
  lcov \
  libncurses-dev \
  libcunit1-dev \
  libfreetype6-dev \
  libgtest-dev \
  libpng-dev \
  libssl-dev \
  libasio-dev \
  libtinyxml2-dev \
  libtool \
  lsb-release \
  net-tools \
  make \
  nano \
  ninja-build \
  openjdk-8-jdk \
  openjdk-8-jre \
  openssh-client \
  picocom \
  minicom \
  screen \
  pkg-config \
  python3-dev \
  python3-pip \
  python3-tk \
  rsync \
  software-properties-common \
  shellcheck \
  tzdata \
  tree \
  uncrustify \
  unzip \
  valgrind \
  vim-common \
  wget \
  xsltproc \
  zip \
  && apt-get -y autoremove \
  && apt-get clean autoclean \
  && rm -rf /var/lib/apt/lists/*

# If you actually need Java, pick a supported version:
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-17-jdk-headless && rm -rf /var/lib/apt/lists/*

# --------------------
# Miniconda (non-interactive)
# --------------------
ENV CONDA_DIR=/miniconda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

RUN conda --version && \
    conda config --set always_yes yes --set changeps1 no && \
    conda clean -afy || true

RUN conda config --set changeps1 True
RUN /miniconda/bin/conda init bash

# --------------------
# Python Dependencies via Miniconda Pip
# --------------------
COPY requirements.txt /tmp/requirements.txt
RUN pip uninstall empy -y
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
rm /tmp/requirements.txt


# --------------------
# Default workspace
# --------------------
RUN rm -rf /home/ubuntu/user
RUN mkdir -p /home/ubuntu
WORKDIR /home/ubuntu/


