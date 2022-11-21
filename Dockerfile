FROM debian:bullseye as build-base
RUN apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y build-essential patch file wget curl time \
	&& apt clean

FROM build-base as build-neologd
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends sudo libmecab-dev git mecab \
	&& apt clean
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
RUN cd mecab-ipadic-neologd && bin/install-mecab-ipadic-neologd -n -a -y -p /var/lib/mecab/dic/ipadic-neologd

FROM build-base as build-comainu
RUN exec bash -exc ' \
	mkdir -p /var/tmp/build; \
	cd /var/tmp/build; \
	wget -nv https://osdn.net/dl/comainu/Comainu-0.80-src.tgz \
	  https://osdn.net/dl/comainu/Comainu-0.80-model.tgz \
	  https://osdn.net/dl/comainu/Comainu-unidic2-0.10.tgz; \
	wget -nv "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" -O CRF++-0.58.tar.gz; \
	for f in *.tar* *.tgz; do tar xf $f; done; \
'
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y  build-essential \
	&& apt clean
RUN exec bash -exc ' \
	cd /var/tmp/build/CRF++-0.58; \
	./configure && make && make install; \
	cd /var/tmp/build/Comainu-0.80; \
	./configure \
	  --comainu-home=/opt/Comainu \
	  --comainu-appdata-dir=/opt/Comainu \
	  --svm-tool-dir /usr/bin \
	  --yamcha-dir /usr/bin \
	  --crf-dir /usr/local/bin \
	  --mecab-dir /usr/bin \
	  --mecab-dic-dir /var/lib/mecab/dic \
	  --unidic-db /usr/local/share/unidic2/unidic.db \
	  --pp /usr/bin/pp; \
	rm -rf tmp; \
'

FROM debian:bullseye AS main
LABEL maintainer="Tatsuki Sugiura <sugi@nemui.org>"
ADD *.list /etc/apt/sources.list.d/
ADD comainu /usr/bin/
RUN apt update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
	  mecab unidic-mecab \
	  default-jre-headless locales \
	  perl libdbi-perl libdbd-sqlite3-perl libpar-packer-perl \
	&& DEBIAN_FRONTEND=noninteractive apt install -y -t experimental yamcha tinysvm \
	&& apt clean && rm -rf /var/lib/apt/lists/* /var/lib/mecab/dic/juman-utf8
COPY --from=build-neologd /var/lib/mecab/dic/ipadic-neologd /var/lib/mecab/dic/ipadic-neologd
COPY --from=build-comainu /usr/local/lib/* /usr/local/lib/
COPY --from=build-comainu /usr/local/bin/* /usr/local/bin/
COPY --from=build-comainu /var/tmp/build/Comainu-0.80 /opt/Comainu
COPY --from=build-comainu /var/tmp/build/unidic2 /usr/local/share/unidic2
RUN bash -exc '\
	echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local-lib.conf && \
	ldconfig && \
	mkdir -p /usr/libexec/yamcha && \
	ln -s /usr/bin/yamcha /usr/libexec/yamcha/yamcha && \
	adduser comainu --gecos="Comainu" --disabled-password && \
	update-alternatives --install /var/lib/mecab/dic/debian  mecab-dictionary /var/lib/mecab/dic/ipadic-neologd 500 && \
	chmod 555 /usr/bin/comainu && \
	ln -sf /tmp /opt/Comainu/tmp && \
	echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && update-locale LANG=ja_JP.UTF-8 \
'
ADD --chown=comainu:comainu .inputrc /home/comainu
USER comainu
