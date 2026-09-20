# Versions come from .env via docker-compose build args.
ARG CUDA_VERSION
ARG UBUNTU_VERSION
FROM nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu${UBUNTU_VERSION}
ARG EMPY_VERSION
RUN apt-get update && apt-get upgrade -y
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
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8


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
# User ubuntu with the host UID and GID. Root work ends here.
# --------------------
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN apt-get update && apt-get install -y --no-install-recommends sudo && rm -rf /var/lib/apt/lists/*
RUN if id ubuntu >/dev/null 2>&1; then \
      groupmod -g ${HOST_GID} ubuntu && usermod -u ${HOST_UID} -g ${HOST_GID} ubuntu; \
    else \
      groupadd -g ${HOST_GID} ubuntu && \
      useradd -m -s /bin/bash -u ${HOST_UID} -g ${HOST_GID} ubuntu; \
    fi && \
    mkdir -p /home/ubuntu && chown -R ubuntu:ubuntu /home/ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# --------------------
# Miniconda, installed and initialized as ubuntu
# --------------------
ENV CONDA_DIR=/miniconda
ENV PATH=${CONDA_DIR}/bin:${PATH}
RUN mkdir -p ${CONDA_DIR} && chown ubuntu:ubuntu ${CONDA_DIR}

USER ubuntu
WORKDIR /home/ubuntu

# Installer is pinned in .env: Miniconda3-latest floats to a new Python and breaks wheels.
ARG MINICONDA_INSTALLER
RUN curl -fsSL "https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}" -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda config --system --set always_yes yes && \
    conda config --system --set changeps1 true && \
    conda init bash && \
    conda clean -afy

# --------------------
# Python Dependencies via Miniconda Pip
# --------------------
COPY --chown=ubuntu:ubuntu common/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
rm /tmp/requirements.txt
RUN pip install --no-cache-dir "empy==${EMPY_VERSION}"

RUN echo "alias python=python3" >> /home/ubuntu/.bashrc
CMD ["/bin/bash"]
