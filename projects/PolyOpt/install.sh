#! /bin/sh

check_error()
{
    if [ $# -gt 2 ]; then
	echo "Error in check_error call";
	exit 1;
    fi;
    ERRCODE="$1";
    if [ "$ERRCODE" = "0" ]; then
	return 0;
    fi;
    if [ $# -eq 2 ]; then
	ERRMESSAGE="$2";
    else
	ERRMESSAGE="Error";
    fi;
    echo "[PolyOpt] $ERRMESSAGE";
    exit $ERRCODE;
}


if [ -z "${BOOST_ROOT}" ]; then
	BOOST_ROOT=/usr/local/boost
fi

if [ -z "${ROSE_ROOT}" ]; then
	ROSE_ROOT=/usr/local/rose-current
fi

if [ -n "${INSTALL_ROOT}" ]; then
	POCC_INSTALL_ROOT="${INSTALL_ROOT}/pocc"
	INSTALL_ROOT="--prefix=${INSTALL_ROOT}"
else
	POCC_INSTALL_ROOT="`pwd`/pocc"
fi

echo "*** Installation of PolyOpt ***"
echo "[PolyOpt] Install PoCC..."
POCC_INSTALL_PREFIX="$POCC_INSTALL_ROOT" ./pocc-installer.sh 
check_error "$?" "Installation of PoCC failed";
echo "[PolyOpt] Bootstrap..."
if ! [ -f configure ]; then
    ./bootstrap.sh
    check_error "$?" "Bootstrap failed";
fi;
echo "[PolyOpt] Configure..."
if ! [ -f Makefile ]; then
    ./configure --with-boost=${BOOST_ROOT} --with-rose=${ROSE_ROOT} ${INSTALL_ROOT} --with-pocc-prefix=$POCC_INSTALL_ROOT
    check_error "$?" "Configure failed";
fi;
echo "[PolyOpt] Make..."
make
check_error "$?" "Build failed";

if [ -n "${INSTALL_ROOT}" ]; then
	make install
	check_error "$?" "make install failed";
fi

echo "[PolyOpt] Installation complete."
echo "

* Usage
-------

$> src/PolyOpt <filename.c>

To use tiling with pluto:
$> src/PolyOpt --polyopt-pluto-tile <filename.c>

To get available options:
$> src/PolyOpt --polyopt-help



* Troubleshoot
--------------
For any error please email polyhedral@cse.ohio-state.edu
";
