#! /bin/sh

machine=`hostname`;

case $machine in 
  up*)
       export PATH=/usr/apps/babel/dev_2008/bin:${PATH}
       AUTOHEADER=autoheader
       ACLOCAL=aclocal
       AUTOMAKE=automake
       AUTOCONF=autoconf
       ;;
  lemur.*) 
	AUTOHEADER=/opt/local/bin/autoheader
	ACLOCAL=/opt/local/bin/aclocal
	AUTOMAKE=/opt/local/bin/automake
	AUTOCONF=/opt/local/bin/autoconf
	;;
  ingot*)
	AUTOHEADER=/usr/apps/babel/dev_tools/bin/autoheader
	ACLOCAL=/usr/apps/babel/dev_tools/bin/aclocal
	AUTOMAKE=/usr/apps/babel/dev_tools/bin/automake
	AUTOCONF=/usr/apps/babel/dev_tools/bin/autoconf
	;;
  tux*)
        export PATH=/usr/casc/babel/apps/autotools_2009/bin:${PATH}
	AUTOHEADER=/usr/casc/babel/apps/autotools_2009/bin/autoheader
	ACLOCAL=/usr/casc/babel/apps/autotools_2009/bin/aclocal
	AUTOMAKE=/usr/casc/babel/apps/autotools_2009/bin/automake
	AUTOCONF=/usr/casc/babel/apps/autotools_2009/bin/autoconf
	;;
  driftcreek*)
	AUTOHEADER=autoheader
	ACLOCAL=aclocal-1.10
	AUTOMAKE=automake-1.10
	AUTOCONF=autoconf
	;;
  *)
	AUTOHEADER=autoheader
	ACLOCAL=aclocal
	AUTOMAKE=automake
	AUTOCONF=autoconf
	;;
esac

#echo "**** $AUTOHEADER ****"
#$AUTOHEADER

echo "**** $ACLOCAL ****" && \
$ACLOCAL && \
echo "**** $AUTOMAKE ****" && \
$AUTOMAKE --add-missing && \
echo "**** $AUTOCONF ****" && \
$AUTOCONF # && \
# echo "**** cd runtime ****" && \
# cd runtime && \
# echo "**** $ACLOCAL (in runtime) ****" && \
# $ACLOCAL && \
# echo "**** $AUTOMAKE (in runtime) ****" && \
# $AUTOMAKE && \
# echo "**** $AUTOCONF (in runtime) ****" && \
# $AUTOCONF && \
# echo "**** $AUTOHEADER (in runtime) ****" && \
# $AUTOHEADER && \
# (cd sidl ; mv -f babel_internal.h.in babel_internal.h.in.bak ; awk -f changeundef.awk babel_internal.h.in.bak > babel_internal.h.in && rm -f babel_internal.h.in.bak )
