FROM ubuntu:20.04

RUN set -e \
	&& apt-get update \
	&& apt-get -y upgrade 

RUN apt-get install -y --no-install-recommends git \
	&& apt-get clean

EXPOSE 8787
CMD ["/init"]
