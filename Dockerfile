FROM continuumio/miniconda3

LABEL author="Remi-Andre Olsen" \
      description="merged_nodups2bed" \
      maintainer="remi-andre.olsen@scilifelab.se"

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

# Add source files to the container
COPY merged_nodups2bed.sh /opt/conda/envs/merged_nodups2bed/bin/
ENV PATH /opt/conda/envs/merged_nodups2bed/bin:$PATH