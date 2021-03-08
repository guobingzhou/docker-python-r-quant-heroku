FROM python:3.8.2-slim

# Copy a script that we will use to correct permissions after running certain commands
# COPY fix-permissions /usr/local/bin/fix-permissions
# RUN chmod a+rx /usr/local/bin/fix-permissions
RUN echo \
   'deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free\n \
    deb http://security.debian.org/debian-security stretch/updates main\n \
    deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free\n' \
    > /etc/apt/sources.list && \
     apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        libopencv-dev \ 
        build-essential \
        libssl-dev \
        libpq-dev \
        libcurl4-gnutls-dev \
        libexpat1-dev \
        gettext \
        unzip \
        supervisor \
        git  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
#安装conda
COPY miniconda.sh /root/miniconda.sh
RUN echo 'export PATH=/opt/conda/bin:$PATH' >> /root/.bashrc && \
    # wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH
#p安装r
RUN apt-get update && apt-get install -y --no-install-recommends \
        fonts-dejavu \
        gfortran \
        gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# R
#RUN conda install -c r ipython-notebook r-irkernel
RUN apt-get update && \
    apt-get install -y r-base && \
    conda install -c r r-irkernel r-essentials   -c conda-forge && \
    rm -rf /var/lib/apt/lists/*
# USER $NB_UID
# RUN conda install --quiet --yes \
#     # 'notebook=6.2.0' \
#     # 'jupyterhub=1.3.0' \
#     'jupyterlab=*' \
#     'r-base=*'  \
#     'r-ggplot2=*' \
#     'r-irkernel=*'  && \
#     conda config --system --set auto_update_conda false && \
#     conda config --system --set show_channel_urls true && \
#     conda update -n base conda --quiet --yes && \
#     conda update --all --quiet --yes && \
#     conda config --add channels conda-forge && \
#     conda config --set channel_priority flexible && \
#     conda clean --all -f -y && \
#     # npm cache clean --force && \
#     # jupyter notebook --generate-config && \
#     # jupyter lab clean && \
#     # rm -rf /home/$NB_USER/.cache/yarn && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"


RUN R --quiet -e "install.packages(c('ggplot2','png', 'reticulate','fAsset','fArma','fGarch','fOpions','fCopulae','PerformanceAnalytics','PortfolioAnalytics','fUnitRoots','ftrading','quantstart','blotter'), repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/')" &&\
    rm -rf /tmp/*
# COPY packages.r /root/packages.r
#安装py库
RUN apt-get update -y && \
    apt-get upgrade -y && \apt-get install -y --no-install-recommends \
        python3-setuptools \
        python3-pip \
        python3-dev \
        python3-venv \
        python3-urllib3  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Upgrade PIP

ENV APP_HOME /app
WORKDIR ${APP_HOME}
COPY . ./
RUN pip install pip pipenv --upgrade
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir \
        jupyter_nbextensions_configurator 


# RUN jupyter labextension install jupyterlab-python-file 
#sklearn matplootlib, numpy, and pandas
RUN pip install pandas numpy matplotlib scikit-learn
RUN pip install tushare fooltrader zvt backtrader 

RUN pipenv install --skip-lock --system --dev 
CMD ["./scripts/entrypoint.sh"]
