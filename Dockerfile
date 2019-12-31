FROM helmuthva/jetson-nano-ml-base

ARG NB_GID="100"
ARG NB_UID="1000"
ARG NB_USER="stephan"

ARG CONDA_VERSION=4.7.7
ARG HOME=/home/$NB_USER
ARG IJAVA_VERSION=1.3.0
ARG MINICONDA_VERSION=4.6.14
ARG TINI_VERSION=0.18.0
ARG WORK_DIR=${HOME}/work

ENV DEBIAN_FRONTEND noninteractive

ENV CONDA_DIR=/opt/conda \
  LANG=de_DE.UTF-8 \
  LANGUAGE=de_DE.UTF-8 \
  LC_ALL=de_DE.UTF-8 \
  NB_GID=${NB_GID} \
  NB_UID=${NB_UID} \
  NB_USER=${NB_USER} \
  SHELL=/bin/bash \
  XDG_CACHE_HOME=${HOME}/.cache/

ENV PATH=$CONDA_DIR/bin:$PATH

RUN useradd -ms /bin/bash stephan

USER root

RUN apt update && apt install -y python3-scipy python3-pip

RUN pip3 install --user keras
RUN conda update --all

RUN conda install --quiet --yes \
  'conda-forge::blas=*=openblas' \
  beautifulsoup4 \
  tini \
  cython \
  ipysheet \
  ipywidgets \
  jupyterlab \
  lxml \
  nltk \
  nltk_data \
  nodejs \
  notebook \
  pandas \
  pandas-datareader \
  pandas-profiling \
  protobuf \
  psutil \
  pyyaml 

#RUN jupyter labextension install --no-build \
#  @agoose77/jupyterlab-markup \
# @jpmorganchase/perspective-jupyterlab \
#  @jupyter-widgets/jupyterlab-manager \ 
#  @jupyterlab/celltags \ 
#  @jupyterlab/geojson-extension \
 # @jupyterlab/git 
 # @jupyterlab/toc \
 # @krassowski/jupyterlab_go_to_definition \
 # @mflevine/jupyterlab_html \
 # @parente/jupyterlab-quickopen \
 # bqplot \
 # ipysheet \
 # jupyter-leaflet \
#  jupyter-matplotlib \
#  jupyterlab-chart-editor \
#  jupyterlab-drawio \
#  jupyterlab-plotly \
#  jupyterlab-spreadsheet \
#  jupyterlab_bokeh \ 
#  jupyterlab_vim \
#  jupyterlab_filetree \
#  lineup_widget 
#  plotlywidget 
#  qgrid

RUN jupyter lab build --dev-build=False

#RUN jupyter serverextension enable --py \
 # jupyterlab_quickopen \
  #jupyterlab_git

ADD fix-permissions /usr/local/bin/fix-permissions

RUN mkdir ${WORK_DIR} && \
  fix-permissions ${HOME}

EXPOSE 8888
WORKDIR ${WORK_DIR}

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/

COPY jupyter_notebook_config.py /etc/jupyter/

RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start-notebook.sh
RUN chmod +x /usr/local/bin/start-singleuser.sh
RUN chown -R ${NB_USER} ${HOME}
ADD fix-permissions /usr/local/bin/fix-permissions
RUN fix-permissions /etc/jupyter/
RUN fix-permissions /home/stephan
RUN conda install --quiet --yes scipy
# Switch back to stephan to avoid accidental container runs as root
USER ${NB_UID}
