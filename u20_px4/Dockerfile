FROM px4io/px4-dev-nuttx-focal
RUN apt-get update && apt upgrade -y
# System packages 
RUN apt-get -y --quiet --no-install-recommends install \
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
  make \
  nano \
  net-tools \
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

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda
RUN conda install -c anaconda -y python=3.11.0
RUN conda install -c anaconda  conda-build
RUN conda init bash
COPY ./requirements.txt /home/ubuntu/requirements.txt
RUN pip install -r /home/ubuntu/requirements.txt
RUN pip3 install -r /home/ubuntu/requirements.txt
RUN rm -r /home/ubuntu/requirements.txt

COPY ./download_px4_autopilot.bash /home/ubuntu/download_px4_autopilot.bash

RUN rm -rf /home/ubuntu/user
WORKDIR /home/ubuntu


## zsh
COPY .p10k.zsh /root/.p10k.zsh
COPY installzsh.bash /root/installzsh.bash
RUN bash /root/installzsh.bash