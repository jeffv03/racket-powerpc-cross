#!/bin/sh

# From: http://www.wedesoft.de/racket-on-android.html

ARCHIVE=$HOME/AppDownloads/racket-lang.org/racket-5.3.3-src-unix.tgz
HOST=powerpc-e500v2-linux-gnuspe

#CROSS_COMPILE=../../../build/target/${TARGET_HOST}/${TARGET_HOST}/bin/
#CROSS_COMPILE=../../../build/target/${TARGET_HOST}/bin/${TARGET_HOST}
CROSS_COMPILE=${HOST}-
export PATH=$PATH:`pwd`/../../../build/target/${HOST}/bin

if [[ ! -d host ]]
then
  echo host doesn\'t exist
  mkdir -p host
  cd host
  tar xzf $ARCHIVE
  cd -
  cd host/racket*/src
  ./configure --disable-docs
  make
  make install
  cd -
fi

BUILD_HOST=`pwd`/host/racket*
echo BUILD_HOST is: $BUILD_HOST

rm -rf cross
mkdir -p cross
cd cross
tar xzf $ARCHIVE
cd -

BUILD_CROSS=`pwd`/cross/racket*

cd $BUILD_CROSS/src
echo "BUILD_CROSS is $BUILD_CROSS, in `pwd`"

./configure --disable-docs --host=$HOST
echo $PATH

make \
  RUN_THIS_RACKET_CGC=$BUILD_HOST/src/racket/racketcgc \
  RUN_THIS_RACKET_MMM=$BUILD_HOST/src/racket/racket3m \
  RUN_THIS_RACKET_MAIN_VARIANT=$BUILD_HOST/src/racket/racket3m \
  HOSTCC=/usr/bin/gcc \
  HOSTCFLAGS="-g -O2 -Wall -pthread -I./include" \
  STRIP_DEBUG="${CROSS_COMPILE}strip -S" 

make \
  RUN_THIS_RACKET_CGC=$BUILD_HOST/src/racket/racketcgc \
  RUN_THIS_RACKET_MMM=$BUILD_HOST/src/racket/racket3m \
  RUN_THIS_RACKET_MAIN_VARIANT=$BUILD_HOST/src/racket/racket3m \
  HOSTCC=/usr/bin/gcc \
  HOSTCFLAGS="-g -O2 -Wall -pthread -I./include" \
  STRIP_DEBUG="${CROSS_COMPILE}strip -S" \
  install

echo "pre cd - : in `pwd`"
cd -
echo "post cd - : in `pwd`"
cd $BUILD_CROSS/src/racket
${CROSS_COMPILE}gcc -static -o racket3m  gc2/main.o libracket3m.a  -ldl -lm  -ldl -lm -rdynamic
