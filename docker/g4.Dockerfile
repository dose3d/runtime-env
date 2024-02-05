#
# DockerHub: brachwal/ubuntu-g4:22.04-11.1.3-1.0
#
# From scratch:
# docker build --tag 'ubuntu-g4:22.04-11.2' . -f docker/g4.Dockerfile
#
# RunInteractively and Remove it Once the Process is Complete
# docker run -it --rm ubuntu-g4:22.04-11.2 /bin/bash

FROM ubuntu:22.04
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y gpg && \
  apt-get install -y cmake && \
  apt-get install -y make && \
  apt-get install -y git && \
  apt-get install -y wget && \
  apt-get install -y curl && \
  apt-get install -y zlib1g-dev && \
  apt-get install -y ca-certificates && \
  wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-py310_23.9.0-0-Linux-x86_64.sh -O /opt/miniconda.sh && \
  /bin/bash /opt/miniconda.sh -b -p /opt/conda && \
  rm /opt/miniconda.sh
 
ENV CONDA_DIR /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda init && \
    /bin/bash && \
    conda create --name geant4 -y -c conda-forge conda-libmamba-solver python=3.11.7 make=4.2.1 gxx=11.2.0 hdf5=1.14.3 anaconda::xerces-c=3.2.4

# Build Geant4 from source:
# https://geant4-userdoc.web.cern.ch/UsersGuides/InstallationGuide/html/installguide.html
RUN mkdir /opt/geant4; mkdir /opt/geant4-data
RUN cd; git clone https://gitlab.cern.ch/geant4/geant4.git
RUN cd ~/geant4; git checkout geant4-11.2-release; mkdir build
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate geant4 && \
    cd ~/geant4/build; cmake -DGEANT4_INSTALL_DATA=OFF \
    -DGEANT4_INSTALL_DATADIR=/opt/geant4-data \ 
    -DCMAKE_INSTALL_PREFIX=/opt/geant4 \
    -DGEANT4_USE_GDML=ON \
    -DGEANT4_INSTALL_EXAMPLES=OFF \
    -DGEANT4_USE_HDF5=ON \
    -DGEANT4_USE_SYSTEM_EXPAT=OFF ../

RUN cd ~/geant4/build; make -j2
RUN cd ~/geant4/build; make install

# clean-up
RUN rm -rf ~/geant4; rm -rf /opt/conda