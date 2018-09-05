#debian dist0ro
FROM debian

#add sources and update it
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"
RUN apt-get update
# install wget, less, compiler, nano
RUN apt-get install -y wget make less build-essential nano

#install bzip and git, zlib
RUN apt-get install -y bzip2 git zlib1g-dev
# install Fast from http://hannonlab.cshl.edu/fastx_toolkit/
RUN mkdir /root/programs
RUN cd /root/programs; wget -c http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
RUN cd /root/programs; tar -xjf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
RUN cp /root/programs/bin/* /usr/local/bin/
RUN apt-get install -y unzip
#install java
RUN apt-get update && \
    apt-get install --yes software-properties-common

# Add the JDK 8 and accept licenses (mandatory)
RUN add-apt-repository ppa:webupd8team/java && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections


RUN apt-get install --yes --no-install-recommends --allow-unauthenticated oracle-java8-installer
#install trimmomatic
RUN cd /root/programs; wget -c http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip
RUN cd /root/programs; unzip Trimmomatic-0.38.zip
RUN cp /root/programs/Trimmomatic-0.38/trimmomatic-0.38.jar /usr/local/bin/ ; cp -r /root/programs/Trimmomatic-0.38/adapters /usr/local/bin/

#install soapEc
RUN cd /root/programs; wget -c -O soapec.tar.gz https://downloads.sourceforge.net/project/soapdenovo2/ErrorCorrection/SOAPec_v2.01.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fsoapdenovo2%2Ffiles%2FErrorCorrection%2FSOAPec_v2.01.tar.gz%2Fdownload ; tar xvf /root/programs/soapec.tar.gz;  cp /root/programs/SOAPec_v2.01/bin/* /usr/local/bin/.

#install velvet
RUN cd /root/programs ; git clone https://github.com/dzerbino/velvet.git  ; cd velvet; make; cp velvet* /usr/local/bin/.

#install soapDenovo2
RUN cd /root/programs ; wget -c -O soapdenovo.tar.gz https://sourceforge.net/projects/soapdenovo2/files/SOAPdenovo2/bin/r240/SOAPdenovo2-bin-LINUX-generic-r240.tgz/download ; tar xvf soapdenovo.tar.gz ; cp SOAPdenovo2-bin-LINUX-generic-r240/SOAPdenovo* /usr/local/bin/.

# install abyss
RUN apt-get install -y abyss

#install platanus
RUN cd /root/programs ; wget -c -O platanus http://platanus.bio.titech.ac.jp/?ddownload=145 ; chmod a+x platanus; cp platanus /usr/local/bin/.

#install idba
RUN cd /root/programs ; git clone https://github.com/loneknightpy/idba.git; 
RUN apt-get install -y pkg-config zip g++ zlib1g-dev unzip bash-completion wget
RUN apt-get install -y gcc autoconf automake g++ make
RUN apt-get install -y vim
RUN cd /root/programs/idba ; ./build.sh ; cp bin/* /usr/local/bin/.

# install canu
RUN cd /root/programs ; git clone https://github.com/marbl/canu.git ; cd canu/src ; make  ; cp -r /root/programs/canu/Linux-amd64/* /usr/local/.


#install falcon in /FALCON-integrate
RUN apt-get install -y python python-pip virtualenv python-dev; pip install -U pip
RUN git clone git://github.com/PacificBiosciences/FALCON-integrate.git
WORKDIR /FALCON-integrate
ENV FC fc_env
RUN virtualenv --no-site-packages  --always-copy  $FC
RUN . $FC/bin/activate
RUN git submodule update --init
RUN make init
RUN cd pypeFLOW && python setup.py install
RUN cd FALCON && python setup.py install
RUN cd DAZZ_DB && make
RUN cd DAZZ_DB && cp DBrm DBshow DBsplit DBstats fasta2DB ../$FC/bin/
RUN cd DALIGNER && make
RUN cd DALIGNER && cp daligner daligner_p DB2Falcon HPC.daligner LA4Falcon LAmerge LAsort  ../$FC/bin
#RUN export GIT_SYM_CACHE_DIR=~/.git-sym-cache ; cd /root/programs/ ; git clone git://github.com/PacificBiosciences/FALCON-integrate.git ; cd FALCON-integrate ; git checkout develop  ; git submodule update --init --recursive ; make init ; source env.sh ; make config-edit-user ; make -j all ; make test  

#install spades
RUN cd /root/programs/ ; wget http://cab.spbu.ru/files/release3.12.0/SPAdes-3.12.0-Linux.tar.gz ; tar xvf SPAdes-3.12.0-Linux.tar.gz  ; cp -r /root/programs/SPAdes-3.12.0-Linux/* /usr/local/.


#install MaSurCA in /MaSuRCA-3.2.7
RUN apt-get install -y curl libghc-bzlib-dev swig
#RUN cd /root/programs/ ; git clone https://github.com/alekseyzimin/masurca ; cd masurca ; git submodule init ; git submodule update ; 
#RUN cd /root/programs/masurca ; automake --add-missing ; export BOOST_ROOT=install ; ./configure ; make

WORKDIR /
RUN wget -c https://github.com/alekseyzimin/masurca/releases/download/3.2.7/MaSuRCA-3.2.7.tar.gz ; tar xvf MaSuRCA-3.2.7.tar.gz ; rm MaSuRCA-3.2.7.tar.gz
RUN cd /MaSuRCA-3.2.7 ; export BOOST_ROOT=install; ./install.sh


#install gnx-tools. To use type: java -jar /usr/local/bin/gnx.jar
RUN apt-get install -y ant
RUN cd /root/programs ; git clone https://github.com/mh11/gnx-tools.git ; cd gnx-tools ; mkdir bin
RUN cd /root/programs/gnx-tools ;  javac -d bin/ src/uk/ac/ebi/gnx/* ; ant -f package.xml ; cp gnx.jar /usr/local/bin/.


#install KAT (documentation at: https://kat.readthedocs.io/en/latest/)
RUN apt-get install -y libtool python3-dev python3-pip
RUN python3.5 -m pip install numpy scipy matplotlib tabulate
RUN cd /root/programs ; git clone https://github.com/TGAC/KAT.git 
RUN cd /root/programs/KAT ; ./build_boost.sh ; ./autogen.sh ; ./configure ; make install
RUN cp -r /root/programs/KAT/deps/boost/build/lib/* /usr/local/lib/.
#RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
#install kmergenie
RUN apt-get install -y r-base
RUN cd /root/programs/ ; wget -c http://kmergenie.bx.psu.edu/kmergenie-1.7048.tar.gz ; tar xvf kmergenie-1.7048.tar.gz ; cd kmergenie-1.7048; make ; cp -r * /usr/local/bin/

##install quake
#RUN cd /root/programs; wget -c http://www.cbcb.umd.edu/software/quake/downloads/quake-0.3.5.tar.gz; tar -xvf quake-03.5.tar.gz; cd Quake; make; make install



#clean the space up
RUN rm -r /root/programs/
WORKDIR /DATA/

#NOTE: jellyfish is in: /MaSuRCA-3.2.7/global-1/jellyfish/bin/jellyfish
