#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

set -o verbose

echo Installing prereqs...
aptitude update
aptitude -VR install texlive-base texlive-binaries  texlive-extra-utils texlive-font-utils texlive-fonts-recommended  texlive-fonts-recommended-doc texlive-generic-recommended texlive-latex-base texlive-latex-base-doc texlive-latex-extra texlive-latex-extra-doc texlive-latex-recommended texlive-latex-recommended-doc texlive-luatex texlive-pictures texlive-pictures-doc texlive-pstricks texlive-pstricks-doc
