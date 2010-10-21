dnl
dnl @synopsis LLNL_CONFIRM_BABEL_JAVA_SUPPORT
dnl
dnl  This is a meta-command that orchestrates a bunch of sub-checks.
dnl  I made it a separate M4 Macro to make synchronization between 
dnl  the main configure script and the runtime configure script easier.
dnl
dnl  If Babel support for JAVA is enabled:
dnl     the cpp macro JAVA_DISABLED is undefined
dnl     the automake conditional SUPPORT_JAVA is true
dnl
dnl  If Babel support for JAVA is disabled:
dnl     the cpp macro JAVA_DISABLED is defined as true
dnl     the automake conditional SUPPORT_JAVA is false
dnl
dnl  @author Gary Kumfert

AC_DEFUN([LLNL_CONFIRM_BABEL_JAVA_SUPPORT], [
  AC_ARG_VAR([JAVAPREFIX],[Directory where Java is installed has subdirectories bin and include ( @<:@e.g. $JAVAPREFIX/bin/java@:>@])
  AC_ARG_VAR([JAVAC],[Absolute path to Java Compiler])
  AC_ARG_VAR([JAVACFLAGS],[Flags for Java Compiler])
  AC_ARG_VAR([JAVA],[Absolute path to Java Runtime])
  AC_ARG_VAR([JAVAFLAGS],[Flags for Java Runtime])
  AC_ARG_VAR([JAVAH],[Absolute path to javah, the JNI C stub and header generator])
  AC_ARG_VAR([JAR],[Absolute path to the Java Archive Tool (jar)])
  AC_ARG_VAR([JNI_INCLUDES],[Preprocessor flags used @<:@e.g., -I$JAVAPREFIX/include@:>@ to #include <jni.h>])

  # First determine enable_java == true or false, and value of $JAVA (before testing JAVAPREFIX)
  AC_ARG_ENABLE([java],
	AS_HELP_STRING(--enable-java@<:@=JAVAPREFIX@:>@,java language bindings @<:@default=yes@:>@. If a directory value is given it overrides JAVAPREFIX.),
	[enable_java="$enableval"],
	[enable_java="yes"])
  test -z "$enable_java" && enable_java="yes" #zero length is yes

  if test "x$enable_java" = "xno"; then
    # --enable-java=no is equiv to --disable-java
    AC_MSG_WARN([Cannot disable Java entirely, only Java support in Babel.])
    AC_MSG_WARN([The Babel code generator itself still needs a working Java.])
  elif test "x$enable_java" != "xyes"; then
    if test -n "$JAVAPREFIX"; then 
      if test "$JAVAPREFIX" != "$enable_java"; then 
        AC_MSG_WARN([--enable-java=]"$enable_java"[, and JAVAPREFIX=]"$JAVAPREFIX"[, using former])
      fi
    fi
    JAVAPREFIX="$enable_java"
    enable_java=yes
  fi;

  AC_SUBST(JAVAPREFIX)dnl 


  LLNL_CHECK_CLASSPATH
  AC_PROG_JAVAC
  if test "X$ac_cv_prog_javac_works" != "Xyes"; then
    AC_MSG_ERROR([Babel development kit requires working java compiler.])
  fi
  LLNL_PROG_JAVA
  LLNL_CHECK_JAVA_ADDCLASSPATH_FLAG

  LLNL_PROG_JAR
  
  AC_TRY_COMPILE_JAVA
  if test "X$enable_java" != "Xno"; then
    AC_PROG_JAVADOC
    LLNL_PROG_JAVAH
    if test "X$llnl_cv_header_jni_h" = "Xno"; then
      AC_MSG_WARN([Cannot find jni.h, Java support will be disabled])
      AC_MSG_WARN([Try setting JNI_INCLUDES and rerunning configure])
      enable_java=no
      msgs="$msgs
  	  Java support disabled against request (no jni.h found!)"
    fi
    if test -z "$llnl_cv_lib_jvm"; then
      AC_MSG_WARN([Cannot find JVM shared library, Java support will be disabled])
      enable_java=no
      msgs="$msgs
  	  Java support disabled against request 
              (no jvm.dll/libjvm.so/libjvm.a found!)"
    fi
  else
      msgs="$msgs
  	  Java support disabled by request"
  fi 
  AM_CONDITIONAL(SUPPORT_JAVA, test "X$enable_java" != "Xno")
  if test "X$enable_java" = "Xno"; then
    AC_DEFINE(JAVA_DISABLED, 1, [If defined, Java support was disabled at configure time])
  else
    msgs="$msgs
  	  Java enabled.";
  fi 
if test "$llnl_cv_jni_includes" = "none needed"; then
  JNI_INCLUDES=""
else
  JNI_INCLUDES="$llnl_cv_jni_includes"
fi
AC_SUBST(JNI_INCLUDES)
JNI_LDFLAGS="$llnl_cv_jni_linker_flags"
AC_SUBST(JNI_LDFLAGS)

AC_SUBST(JAVAC)dnl
AC_SUBST(JAVACFLAGS)dnl
AC_SUBST(JAVA)dnl
AC_SUBST(JAVAFLAGS)dnl
])
