FROM ubuntu:20.04

LABEL maintainer="abocci <andrea.bocci@telefonica.com>"

SHELL [ "/bin/bash", "--login", "-c" ]

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG username=al-khawarizmi
ARG uid=1000
ARG gid=100
ENV USER $username
ENV UID $uid
ENV GID $gid
ENV HOME /home/$USER

RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

## Maybe combine these steps in one layer
## recent version of Docker may allow COPY as non-user, so things below may be redundant (but more portable)
## can be improved adding chown at the COPY level
COPY environment.yml requirements.txt /tmp/
RUN chown $UID:$GID /tmp/environment.yml /tmp/requirements.txt

COPY postBuild /usr/local/bin/postBuild.sh
RUN chown $UID:$GID /usr/local/bin/postBuild.sh && \
    chmod u+x /usr/local/bin/postBuild.sh

COPY docker/entrypoint.sh /usr/local/bin/
RUN chown $UID:$GID /usr/local/bin/entrypoint.sh && \
    chmod u+x /usr/local/bin/entrypoint.sh

USER $USER

# install miniconda
ENV MINICONDA_VERSION 4.8.2
ENV CONDA_DIR $HOME/miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py38_$MINICONDA_VERSION-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# make non-activate conda commands available (ENV can use = or not, just differ for multiple assignment in the same line)
ENV PATH=$CONDA_DIR/bin:$PATH

# make `conda activate` command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile

# make `conda activate` command available from /bin/bash --interative shells
RUN conda init bash

# create a project directory inside user home
ENV PROJECT_DIR $HOME/app
## the WORKDIR is created automatically if does not exist BUT not with the correct user. Need explicit mkdir
RUN mkdir $PROJECT_DIR  
WORKDIR $PROJECT_DIR

#RUN echo 'Current dir' && pwd 
#RUN echo 'permissions...' && ls -Al ..
#RUN echo 'who...' && whoami

# build the conda environment (for reproducibility avoid non-tagged version/update/etc..)
ENV ENV_PREFIX $PROJECT_DIR/env
RUN conda update --name base --channel defaults conda && \
    conda env create --prefix $ENV_PREFIX --file /tmp/environment.yml --force && \
    conda clean --all --yes

# run the postBuild script to install the JupyterLab extensions
#RUN conda activate $ENV_PREFIX && \
#    /usr/local/bin/postBuild.sh && \
#    conda deactivate

## activate the env when using bash interactively 
RUN echo "conda activate $ENV_PREFIX" >> ~/.bashrc

# use an entrypoint script to insure conda environment is properly activated at runtime
# any further arguments from command line is appended (exec "$@")
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# default command will be to launch JupyterLab server for development
#CMD [ "jupyter", "lab", "--no-browser", "--ip", "0.0.0.0" ]

##ab: volume, Port are not set. Directory structure is not set
