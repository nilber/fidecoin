FROM ubuntu:18.04

#shared libraries and dependencies
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt install build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git -y 
RUN apt-get install libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:bitcoin/bitcoin -y
RUN apt-get update -y
RUN apt-get install libdb4.8-dev libdb4.8++-dev -y
RUN apt-get install libminiupnpc-dev -y
RUN apt-get install libzmq3-dev -y
RUN apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler -y
RUN apt install nsis -y


RUN apt install mingw-w64 mingw-w64-tools -y
RUN update-alternatives --config x86_64-w64-mingw32-g++

COPY ./fidecoin.conf /root/.fidecoin/fidecoin.conf
COPY . /fidecoin
WORKDIR /fidecoin


RUN echo -e "$BGreen select (1) Posix "
RUN echo -e $Color_Off
# RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu zesty universe"
# RUN apt update -y
# RUN chmod -R 777 /fidecoin
RUN cd /fidecoin/depends
		# -i or it will stop compiling
# RUN make clean
# RUN make HOST=x86_64-w64-mingw32 -i
RUN make HOST=x86_64-w64-mingw32 -j4
RUN cd /fidecoin
RUN mkdir /fidecoin/deploy
RUN mkdir /fidecoin/deploy/docs
RUN mkdir /fidecoin/deploy/exe

#build fidecoin source
RUN ./autogen.sh
# RUN ./configure --disable-tests --disable-bench --disable-gui-tests 
RUN CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --prefix=/ --disable-tests --disable-bench --disable-gui-tests "/fidecoin/deploy/docs" "/fidecoin/deploy/exe"
# --disable-wallet
RUN make -j 4 -i
# RUN make install
#open service port
EXPOSE 3031 13031 3032
CMD ["fidecoind", "--printtoconsole"]