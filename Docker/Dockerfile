FROM nvidia/cuda:12.1.0-base-ubuntu22.04 as base
LABEL maintainer "Matthew Ishahak <ishahakm@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH $PATH:/opt/conda/bin/:/opt/scripts
ENV PATH $PATH:/opt/julia-1.7.3/bin
ENV NVIDIA_DISABLE_REQUIRE=true

COPY pkgs.txt pkgs.txt

RUN  apt-get update \
    && xargs apt-get install -y --no-install-recommends < pkgs.txt \
    && echo "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" | tee -a /etc/apt/sources.list \
    && curl -sL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x51716619E084DAB9" | apt-key add \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base r-base-core r-recommended r-base-dev  \
    && apt-get upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python 3.10
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py310_23.11.0-2-Linux-x86_64.sh -O ~/miniconda.sh \
    && bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && ln -s -f /opt/conda/bin/python /usr/bin/python

RUN conda update conda \
    && conda install -y numpy scipy matplotlib pandas seaborn scikit-learn scikit-learn-intelex \
    dash plotly black bokeh h5py click jupyter jupyterlab pytables setuptools \
    sphinx sphinx_rtd_theme fastcluster numba \
    && conda install -y -c conda-forge sphinx-autobuild nbsphinx python-igraph jupyterthemes umap-learn ncurses \
    && pip install --upgrade tables scanpy==1.10.1 "jax[cuda12]" \
    && pip install --no-cache-dir Cython MACS2 notebook==6.5.6 sphinxcontrib.exceltable jupyter_contrib_nbextensions session_info tqdm \
    && conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia \
    && pip install pyro-ppl==1.8.6 scvi-tools==0.20.3 tangram-sc \
    && pip install cellcharter 

# Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.3-linux-x86_64.tar.gz \
    && tar -xvzf julia-1.7.3-linux-x86_64.tar.gz \
    && rm julia-1.7.3-linux-x86_64.tar.gz \
    && cp -r julia-1.7.3 /opt/ \
    && ln -s /opt/julia-1.7.3/bin/julia /usr/local/bin/julia

RUN julia -e 'using Pkg; Pkg.add("IJulia")' \
    && julia -e 'using Pkg; Pkg.add(url="https://github.com/bicycle1885/Leiden.jl")' \
    && julia -e 'using Pkg; Pkg.add(url="https://github.com/TheHumphreysLab/CellScopes.jl")' \
    && julia -e 'using Pkg; Pkg.precompile()'

# R Packages
RUN R -e "install.packages(c('BiocManager'))" \
    && R -e "BiocManager::install(ask = FALSE)" \
    && R CMD javareconf \
    && R -e "install.packages(c('repr','IRdisplay','evaluate','crayon','pbdZMQ','devtools','uuid','digest','Rcpp','sf','tidyverse','xlsx','hdf5r','Rfast2','ape','igraph','VennDiagram','usethis','graph','rJava','plotly','KernSmooth','msigdbr'))" \
    && R -e "BiocManager::install(c('multtest','rhdf5','SingleR','EnhancedVolcano','fgsea','AUCell', 'RcisTarget','GENIE3','DT', 'NMF', 'ComplexHeatmap', 'R2HTML', 'Rtsne', 'infercnv'))" \
    && R -e "devtools::install_github('IRkernel/IRkernel')" \
    && R -e "install.packages(c('Seurat','BPCells','glmGamPoi', 'harmony'))" \
    && R -e "remotes::install_github('satijalab/seurat-wrappers', quiet = TRUE)" \
    && R -e "remotes::install_github('mojaveazure/seurat-disk')" \
    && R -e "devtools::install_github('immunogenomics/presto')" \
    && R -e "devtools::install_github('quadbiolab/voxhunt')" \
    && R -e "devtools::install_github('aertslab/SCopeLoomR')" \
    && R -e "devtools::install_github('aertslab/SCENIC')"

# Jupyter Config
COPY conf conf
RUN jupyter notebook --generate-config \
    && cat ./conf >> ~/.jupyter/jupyter_notebook_config.py \
    && rm ./conf
RUN R -e "IRkernel::installspec(user = FALSE)" \
    && julia -e 'using Pkg; Pkg.build("IJulia")' 

### Final setting
RUN conda clean --all -y && pip cache purge
 
