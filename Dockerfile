FROM ubuntu:16.04
LABEL maintainer="David Sn <divad.nnamtdeis@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV USER jenkins
ENV HOSTNAME buildbot
ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache

# Install required dependencies 
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        bc bison build-essential sudo ccache curl flex g++-multilib gcc-multilib git-core python gnupg gperf imagemagick openjdk-8-jre openjdk-8-jdk \
        lib32ncurses5-dev lib32readline-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libc6-dev libc6-dev-i386 libgl1-mesa-dev \
        libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip unzip zlib1g-dev libx11-dev x11proto-core-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install repo binary (thanks akheel)
RUN curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo && \
    chmod a+x /usr/local/bin/repo

# Create seperate user for building
RUN groupadd -g 1000 -r ${USER} && \
    useradd -u 1000 --create-home -r -g ${USER} ${USER} && \
    mkdir -p /tmp/ccache /repo && \
    chown -R ${USER}: /tmp/ccache /repo && \
    usermod -aG sudo ${USER}

# Setup volumes for persistent data
USER ${USER}
VOLUME ["/tmp/ccache", "/repo"]

# Create gitconfig for build user
RUN git config --global user.name ${USER} && git config --global user.email ${USER}@${HOSTNAME}.local && \
    git config --global ui.color auto

# Work in the build directory, repo is expected to be init'd here
WORKDIR /repo

# This is where the magic happens~
ENTRYPOINT ["/bin/bash"]