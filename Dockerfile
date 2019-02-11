FROM debian:stretch
LABEL maintainer="Tatsuki Sugiura <sugi@nemui.org>"
RUN DEBIAN_FRONTEND=noninteractive apt update && apt -y upgrade \
	&& apt install -y build-essential libperl-dev unidic-mecab mecab default-jre-headless \
	  patch file wget libdbi-perl libdbd-sqlite3-perl libpar-packer-perl locales-all time \
	&& apt clean
ADD *.list /etc/apt/sources.list.d/
RUN apt update && apt install -t experimental -y tinysvm yamcha && apt clean
ADD comainu /usr/local/bin/
RUN exec bash -exc ' \
	mkdir -p /var/tmp/build; \
	cd /var/tmp/build; \
	wget -nv https://osdn.net/projects/comainu/downloads/63950/Comainu-0.72-src.tgz \
	  https://osdn.net/projects/comainu/downloads/63950/Comainu-0.72-model.tgz \
	  https://osdn.net/projects/comainu/downloads/63044/Comainu-unidic2-0.10.tgz; \
	wget -nv "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" -O CRF++-0.58.tar.gz; \
	for f in *.tar* *.tgz; do tar xf $f; done; \
	mv /var/tmp/build/unidic2 /usr/local/share/; \
	cd /var/tmp/build/CRF++-0.58; \
	./configure && make && make install; \
	cd /var/tmp/build/Comainu-0.72; \
	./configure \
	  --svm-tool-dir /usr/bin \
	  --yamcha-dir /usr/bin \
	  --crf-dir /usr/local/bin \
	  --mecab-dir /usr/bin \
	  --mecab-dic-dir /var/lib/mecab/dic \
	  --unidic-db /usr/local/share/unidic2/unidic.db \
	  --pp /usr/bin/pp; \
	echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local-lib.conf; \
	ldconfig; \
	mkdir -p /usr/libexec/yamcha; \
	ln -s /usr/bin/yamcha /usr/libexec/yamcha/yamcha; \
	mv /var/tmp/build/Comainu-0.72 /opt/Comainu; \
	adduser comainu --gecos="Comainu" --disabled-password; \
	cd /; \
	rm -rf /var/tmp/build; \
	rmdir /opt/Comainu/tmp; \
	ln -s /tmp /opt/Comainu/tmp; \
	chmod 755 /usr/local/bin/comainu; \
'
ADD --chown=comainu:comainu .inputrc /home/comainu
USER comainu
