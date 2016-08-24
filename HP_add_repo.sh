#! /bin/sh

##
# NAME
#     bootstrap.sh - setup systems to access the HP Software Delivery Repository

# PURPOSE
#     - primarily, for the designated ProductBundleName
#	1) if available, display a EULA
#       2) determine the system's relevant distribution-version-architecture
#       3) deliver valid APT/YUM/ZUPP configurations pointing to the repository
#       4) if available, populate GPG keys for the respective content (TODO)

# SYNOPSIS
#    Prerequisites / Assumptions:
#       1) for maximum portability, this is written in shell, and tries
#          to only use essential FHS core commands
#       2) as invoked on the local system, it will check for any
#          further prerequisites, not only for it's runtime, but
#          for later, needed functionality

# USAGE
#    - intended to be downloaded and run manually on target system

# NOTES
#    - This may be run as any UID, however, that UID will need write
#      access to the default, or specified, APT/YUM/ZYPP configuration locations
##

# end of introduction^L

#------------------------------------------------------------------------------
#                               FUNCTIONS
#------------------------------------------------------------------------------


  # set expected globals
    set_defaults () {
      METHOD="http"
      WAYSTATION="downloads.linux.hpe.com"
      URLPREFIX="/SDR"
      EULA="EULA.txt"
      APTCONFDIR="/etc/apt/sources.list.d"
      ZYPPCONFDIR="/etc/zypp/repos.d"
      YUMCONFDIR="/etc/yum.repos.d"
    }

  # display usage message
    show_usage () {
      cat <<- EOU

  Usage: $0 <RepoName>

    eg: where <RepoName> might be "spp" (Support Pack for Proliant)
        or any directory found in ${METHOD}://${WAYSTATION}${URLPREFIX}/repo
   
    Normally the distribution, version, architecture and other information
    is auto-detected.  You made override these attributes with the following:

         [ -a <Architecture> ]     override to specified Linux architecture
         [ -d <Distribution> ]     override to specified Linux distribution
         [ -r <Release> ]          override to specified Linux release

         [ -R <Revision> ]         override to specified product revison

         [ -o <OutputDirectory> ]  override default output directory
         [ -s <APTConfigFile> ]    override default APT configuration file
         [ -y <YUMConfigFile> ]    override default YUM configuration file
         [ -z <ZYPPConfigFile> ]   override default ZYPP configuration file

         [ -m <TransportMethod> ]  override default transport protocol
                                   (ftp or http)
         [ -w <WaystationHost> ]   override default waystation host
         [ -u <URLPrefix> ]        override default URL prefix

    Additional options:

         [ -n ]                    preview actions only, make no changes
         [ -v ]                    increase verbosity

         [ -h ]                    show this help message

EOU
      exit 1
    }

  # set Architecture, if possible via uname
    get_architecture () {
      Architecture=""
      my_value=$(uname -m)
      case $my_value in
        hppa|parisc|parisc32|parisc64)
          MSG_TYPE="ERROR" && MSG="currently no repo for this architecture : $my_value"
          echo "$MSG_TYPE - $MSG !!" 1>&2
          exit 1
          ;;
        ppc|ppc64|s390|s390x)
          MSG_TYPE="ERROR" && MSG="not an HP supported architecture : $my_value"
          echo "$MSG_TYPE - $MSG !!" 1>&2
          exit 1
          ;;
        ia64)
          MSG_TYPE="note" && MSG="determined architecture : $my_value"
          [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
          Architecture="$my_value"
          ;;
        i386|i486|i586|i686)
          MSG_TYPE="note" && MSG="determined architecture : $my_value"
          [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
          #Architecture="i386"  # collapse to a single namespace
          Architecture="$my_value"
          ;;
        amd64|x86_64)
          MSG_TYPE="note" && MSG="determined architecture : $my_value"
          [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
          #Architecture="x86_64"  # collapse to a single namespace
          Architecture="$my_value"
          ;;
        *) 
          MSG_TYPE="ERROR" && MSG="unknown architecture : $my_value"
          echo "$MSG_TYPE - $MSG !!" 1>&2
          exit 1
          ;;
      esac

      return 0

    }

  # set Distribution, if possible via lsb_release
    get_distribution () {

      Distribution=""

      [ -x "$LSB" ] && Distribution=$($LSB -s -i)
      [ -x "$TR" ] && Distribution=$( echo $Distribution | $TR -s [:blank:] '_')

      # denote best guess
      [ -n "$Distribution" ] && {
        MSG_TYPE="note" && MSG="determined distribution : $Distribution"
        [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
      }

      return 0
         
    }

  # set Release, if possible via lsb_release
    get_release () {

      Release=""

      case $Distribution in

        Debian|Ubuntu) [ -x "$LSB" ] && Release=$($LSB -s -c) ;;

        *) [ -x "$LSB" ] && Release=$($LSB -s -r) ;;

      esac

      # denote best guess
      [ -n "$Release" ] && {
        MSG_TYPE="note" && MSG="determined release : $Release"        
        [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
      }

      return 0
         
    }

  # apt sources.list template
    apt_template () {

      [ -n "$APTGET" ] && {

        cat <<- EOU

# auto-generated by
#   ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/$0 ${Bundle}

# By including and using this configuration,
# you agree to the terms and conditions
# of the HP Software License Agreement at
# http://h20000.www2.hp.com/bizsupport/TechSupport/softwareLicense.jsp?lang=en&cc=us&prodTypeId=15351&prodSeriesId=1121516&prodNameId=3288134&taskId=135

# HP Software Delivery Repository for $Bundle
deb ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle} ${Release}/${my_Revision} non-free

EOU
      }

      return 0

    }

  # yum configuration template
    yum_template () {

      [ -n "$YUM" ] && {

        if [ -n "$my_Architecture" ] ; then
          my_arch="$my_Architecture"
        else
          my_arch="\$basearch"
        fi
        if [ -n "$my_Release" ] ; then
          my_rel="$my_Release"
        else
          my_rel="\$releasever"
        fi

        cat <<- EOU

# auto-generated by
#   ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/$0 ${Bundle}

# By including and using this configuration,
# you agree to the terms and conditions
# of the HP Software License Agreement at
# http://h20000.www2.hp.com/bizsupport/TechSupport/softwareLicense.jsp?lang=en&cc=us&prodTypeId=15351&prodSeriesId=1121516&prodNameId=3288134&taskId=135

[HP-${Bundle}]
name=HP Software Delivery Repository for ${Bundle}
baseurl=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${my_rel}/${my_arch}/${my_Revision}
enabled=1
gpgcheck=0
#gpgcheck=1
#gpgkey=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/GPG-KEY-${Bundle}

#[HP-${Bundle}-packages]
#name=HP Software Delivery Repository Repository for ${Bundle} Packages
#baseurl=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${my_rel}/packages/${my_arch}
#enabled=0
#gpgcheck=0
#gpgcheck=1
#gpgkey=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/GPG-KEY-${Bundle}

EOU

      }

      return 0

    }

  # zypp configuration template
    zypp_template () {

      [ -n "$ZYPPER" ] && {

        cat <<- EOU

# auto-generated by
#   ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/$0 ${Bundle}

# By including and using this configuration,
# you agree to the terms and conditions
# of the HP Software License Agreement at
# http://h20000.www2.hp.com/bizsupport/TechSupport/softwareLicense.jsp?lang=en&cc=us&prodTypeId=15351&prodSeriesId=1121516&prodNameId=3288134&taskId=135

[HP-${Bundle}]
name=HP Software Delivery Repository for ${Bundle}
enabled=1
autorefresh=1
baseurl=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${Release}/${Architecture}/${my_Revision}
path=/
type=YUM
priority=100
keeppackages=0

#[HP-${Bundle}-packages]
#name=HP Software Delivery Repository for ${Bundle} Packages
#enabled=0
#baseurl=${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${Release}/packages/${Architecture}
#path=/
#type=YUM
#priority=100
#keeppackages=0

EOU

      }

      return 0

    }

# end of functions

#------------------------------------------------------------------------------
#                               MAIN
#------------------------------------------------------------------------------

  # setup invocation environment
    set -e
    [ -n "$DEBUG" ] && set -x

  # establish default values
    set_defaults

  # set global umask for creations, ready for status messages
    umask 022

  # preset required variables, or which can be overridden from command-line
    my_Method="$METHOD"
    my_Waystation="$WAYSTATION"
    my_URLPrefix="$URLPREFIX"
    my_Revision="current"

  # check invocation
    my_opts=$(getopt a:d:hm:no:R:r:s:u:vw:y: "$@") || {
      show_usage
    }

    eval set -- "$my_opts"


    while [ "$1" != "--" ]; do
      case "$1" in
        -a) MSG_TYPE="note" && MSG="override Linux architecture : $2"        
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Architecture="$2"
            shift 2
            ;;
        -d) MSG_TYPE="note" && MSG="override Linux distribution : $2"        
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Distribution="$2"
            shift 2
            ;;
        -h) show_usage
            ;;
        -m) MSG_TYPE="note" && MSG="override transport protocol method : $2"
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            case "$2" in
              ftp|http) my_Method="$2"
                        ;;
              *) MSG_TYPE="ERROR" && MSG="not currently a supported transport protocol method : $my_value"
                 echo "$MSG_TYPE - $MSG !!" 1>&2
                 show_usage
                 ;;
            esac
            shift 2
            ;;
        -o) if [ -d "$2" ] ; then
              [ -w "$2" ] && my_OutputDirectory="$2"
              MSG_TYPE="note" && MSG="override output directory : $2"        
              [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            else
              MSG_TYPE="ERROR" && MSG="cannot write to output directory : $2"        
              echo "$MSG_TYPE : $MSG !!" 1>&2
              show_usage
            fi
            shift 2
            ;;
        -n) export PREVIEW=1
            MSG_TYPE="note" && MSG="enabled preview only mode"
            [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
            shift
            ;;
        -r) MSG_TYPE="note" && MSG="override Linux release : $2"        
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Release="$2"
            shift 2
            ;;
        -R) MSG_TYPE="note" && MSG="override product revision : $2"        
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Revision="$2"
            shift 2
            ;;
        -s) MSG_TYPE="note" && MSG="override APT configuration filename : $2"
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Aptconffile="$2"
            shift 2
            ;;
        -z) MSG_TYPE="note" && MSG="override ZYPP configuration filename : $2"
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Zyppconffile="$2"
            shift 2
            ;;
        -u) MSG_TYPE="note" && MSG="override URL prefix : $2"        
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_URLPrefix="$2"
            shift 2
            ;;
        -v) export VERBOSE=1  # DEBUG mode also, by environment variable
            MSG_TYPE="note" && MSG="enabled verbose output"
            echo "$MSG_TYPE : $MSG"
            shift
            ;;
        -w) MSG_TYPE="note" && MSG="override waystation host : $2"
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Waystation="$2"
            shift 2
            ;;
        -y) MSG_TYPE="note" && MSG="override YUM configuration filename : $2"
            [ -n "$DEBUG" ] && echo "$MSG_TYPE : $MSG"
            my_Yumconffile="$2"
            shift 2
            ;;
        --) shift
            ;;
      esac
    done

  # get rid of --, and grab the bundle name
    shift
    [ $# -eq 1 ] || show_usage
    Bundle=$1

  # check prerequisites (beyond FHS essential commands)

    # to map inputs
      if which tr >/dev/null 2>&1 ; then
          TR=$(which tr)
      fi

    # used for connectivity check, EULA pull
      if which wget >/dev/null 2>&1 ; then
          WGET=$(which wget)
      fi

    # determine which network-aware update mechanisms exist
    # and check resulting pathing configurations

      [ -z "$my_outdir" ] && {

        if which apt-get >/dev/null 2>&1 ; then

          # target Debian/Ubuntu based distros
          APTGET=$(which apt-get)

          my_outdir="$APTCONFDIR"
          [ -n "$my_OutputDirectory" ] && my_outdir="$my_OutputDirectory"
          my_outfile="HP-${Bundle}.list"
          [ -n "$my_Aptconffile" ] && my_outfile="$my_Aptconffile"


        fi

      }

      [ -n "$my_outdir" ] || {

        if which zypper >/dev/null 2>&1 ; then

          # target Novell/openSUSE based distros
          ZYPPER=$(which zypper)

          my_outdir="$ZYPPCONFDIR"
          [ -n "$my_OutputDirectory" ] && my_outdir="$my_OutputDirectory"
          my_outfile="HP-${Bundle}.repo"
          [ -n "$my_Zyppconffile" ] && my_outfile="$my_Zyppconffile"

        fi

      }

      [ -n "$my_outdir" ] || {

        if which yum >/dev/null 2>&1 ; then

          # target Asianux/CentOS/Fedora/RedHat based distros
          YUM=$(which yum)

          my_outdir="$YUMCONFDIR"
          [ -n "$my_OutputDirectory" ] && my_outdir="$my_OutputDirectory"
          my_outfile="HP-${Bundle}.repo"
          [ -n "$my_Yumconffile" ] && my_outfile="$my_Yumconffile"

        fi
      }

      [ -n "$my_outdir" ] || {
        MSG_TYPE="ERROR" && MSG="only supporting apt, yum, zypper currently"
        echo "$MSG_TYPE : $MSG !!" 1>&2
        [ -n "$PREVIEW" ] || exit 1
      }
      [ -d "$my_outdir" -a -w "$my_outdir" ] || {
        MSG_TYPE="ERROR" && MSG="missing or non-writable output directory : \"$my_outdir\""
        echo "$MSG_TYPE : $MSG !!" 1>&2
        [ -n "$PREVIEW" ] || exit 1
      }

      my_output="$my_outdir/$my_outfile"

    # key reading facilities

      my_cmd="apt-key"
      if which $my_cmd >/dev/null 2>&1 ; then
        APTKEY=$(which $my_cmd)
        KEYFILE="${Bundle}.asc"
      fi
      my_cmd=rpm
      if which $my_cmd >/dev/null 2>&1 ; then
        RPMKEY=$(which $my_cmd)
        KEYFILE="RPM-GPG-Key-${Bundle}"
      fi


    # LSB (available on most modern offerings)
      my_cmd=lsb_release
      if which $my_cmd >/dev/null 2>&1 ; then
        LSB=$(which $my_cmd)
      else
        MSG_TYPE="warn" && MSG="cannot find command : $my_cmd"
        echo "$MSG_TYPE : $MSG"
      fi

  # garner needed information

    [ -n "$LSB" ] && get_distribution
    if [ -n "$my_Distribution" ] ; then
      MSG_TYPE="note" && MSG="distribution overridden as : $my_Distribution"
      [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
      Distribution="$my_Distribution"
    else
      [ -z "$Distribution" ] && {
        MSG_TYPE="ERROR" && MSG="cannot determine distribution, please specify -d option"        
        echo "$MSG_TYPE $MSG !!" 1>&2
        show_usage
      }
    fi

    [ -n "$LSB" ] && get_release
    if [ -n "$my_Release" ] ; then
      MSG_TYPE="note" && MSG="release overridden as : $my_Release"
      [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
      Release=$my_Release
    else
      [ -n "$Release" ] || {
        MSG_TYPE="ERROR" && MSG="cannot determine release, please specify -r option"        
        echo "$MSG_TYPE $MSG !!" 1>&2
        show_usage
      }
    fi

    get_architecture
    if [ -n "$my_Architecture" ] ; then
      MSG_TYPE="note" && MSG="architecture overridden as : $my_Architecture"
      [ -n "$VERBOSE" ] && echo "$MSG_TYPE : $MSG"
      Architecture=$my_Architecture
    else
      [ -n "$Architecture" ] || {
        MSG_TYPE="ERROR" && MSG="cannot determine architecture, please specify -a option"        
        echo "$MSG_TYPE $MSG !!" 1>&2
        show_usage
      }
    fi

  # legal/licensing requirements

    [ -z "$PREVIEW" ] && [ -x $WGET ] && {

      # connectivity check
      if $WGET --quiet --server-response --spider --timeout=4 --tries=2 ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle} >/dev/null 2>&1 ; then
        TMPFILE=$(mktemp /tmp/EULA.XXXXXXXX) && {

          # EULA, if applicable
          if $WGET --quiet ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${EULA} --output-document=$TMPFILE 2>/dev/null; then
            [ -s $TMPFILE ] && {
              MSG_TYPE="note" && MSG="You must read and accept the License Agreement to continue."
              echo "$MSG_TYPE : $MSG"
              echo "Press enter to display it ... "
              read answer
              more $TMPFILE
              echo -n "Do you accept? (yes/no) "
              read answer
              case $answer in
                y|Y|yes|Yes|YES) ;;
                *) MSG_TYPE="warn" && MSG="Please try again when you are ready to accept."
                   echo "$MSG_TYPE : $MSG"
                   exit 1 ;;
              esac
            }
          fi
        }
      else
        MSG_TYPE="warn" && MSG="Please check your network settings. Had trouble accessing URL : "
        echo "$MSG_TYPE : $MSG"
        MSG_TYPE="warn" && MSG="${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}"
        echo "$MSG_TYPE : $MSG"
      fi
    }

  # configure that repository

    case $Distribution in

      Debian|Ubuntu)

        if $WGET --quiet --spider --timeout=4 --tries=2 ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/dists/${Release}/${my_Revision} >/dev/null 2>&1 ; then

          [ -n "$APTGET" ]  && {
            if [ -n "$PREVIEW" ] ; then
              MSG_TYPE="info" && MSG="would have delivered the following to : $my_output"
              echo "$MSG_TYPE : $MSG"
              apt_template
            else
              [ -s "$my_output" ] && {
                MSG_TYPE="warn" && MSG="about to overwrite configuration : $my_output"        
                echo "$MSG_TYPE : $MSG"
                echo -n "okay to overwrite? (yes/no) "
                read answer
                case $answer in
                  n|N|no|No|NO) exit 1 ;;
                esac
              }
              apt_template > $my_output || {
                MSG_TYPE="ERROR" && MSG="cannot create configuration : $my_output"        
                echo "$MSG_TYPE $MSG !!" 1>&2
                exit 1
              }
            fi
          }

        else
          MSG_TYPE="warn" && MSG="Unable to find relevant deliverables at URL : "
          echo "$MSG_TYPE : $MSG"
          MSG_TYPE="warn" && MSG="${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/dists/${Release}/${my_Revision}"
          echo "$MSG_TYPE : $MSG"
          MSG_TYPE="note" && MSG="For Debian users, might be worth trying \"-r stable\" invocation."
          echo "$MSG_TYPE : $MSG"
          MSG_TYPE="note" && MSG="No repository configurations added."
          echo "$MSG_TYPE : $MSG"
        fi
      ;;

      *)

        if $WGET --quiet --spider --timeout=4 --tries=2 ${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${Release}/${Architecture}/${my_Revision} >/dev/null 2>&1 ; then

          if [ -n "$ZYPPER" ] ; then
            if [ -n "$PREVIEW" ] ; then
              MSG_TYPE="info" && MSG="would have delivered the following to : $my_output"
              echo "$MSG_TYPE : $MSG"
              zypp_template
            else
              [ -s "$my_output" ] && {
                MSG_TYPE="warn" && MSG="about to overwrite configuration : $my_output"        
                echo "$MSG_TYPE : $MSG"
                echo -n "okay to overwrite? (yes/no) "
                read answer
                case $answer in
                  n|N|no|No|NO) exit 1 ;;
                esac
              }
              zypp_template > $my_output || {
                MSG_TYPE="ERROR" && MSG="cannot create configuration : $my_output"        
                echo "$MSG_TYPE $MSG !!" 1>&2
                exit 1
              }
            fi
          else [ -n "$YUM" ]  && {
            if [ -n "$PREVIEW" ] ; then
              MSG_TYPE="info" && MSG="would have delivered the following to : $my_output"
              echo "$MSG_TYPE : $MSG"
              yum_template
            else
              [ -s "$my_output" ] && {
                MSG_TYPE="warn" && MSG="about to overwrite configuration : $my_output"        
                echo "$MSG_TYPE : $MSG"
                echo -n "okay to overwrite? (yes/no) "
                read answer
                case $answer in
                  n|N|no|No|NO) exit 1 ;;
                esac
              }
              yum_template > $my_output || {
                MSG_TYPE="ERROR" && MSG="cannot create configuration : $my_output"        
                echo "$MSG_TYPE $MSG !!" 1>&2
                exit 1
              }
            fi
          }
          fi

        else
          MSG_TYPE="warn" && MSG="Unable to find relevant deliverables at URL : "
          echo "$MSG_TYPE : $MSG"
          MSG_TYPE="warn" && MSG="${my_Method}://${my_Waystation}${my_URLPrefix}/repo/${Bundle}/${Distribution}/${Release}/${Architecture}/${my_Revision}"
          echo "$MSG_TYPE : $MSG"
          MSG_TYPE="note" && MSG="No repository configurations added."
          echo "$MSG_TYPE : $MSG"
        fi
      ;;

    esac
    
  # TODO : add signing support, done via FAQ on site

  if [ -s "$my_output" ]; then
    MSG_TYPE="info" && MSG="Repo added to ${my_output}."
    echo "$MSG_TYPE : $MSG"
  fi
  exit 0
