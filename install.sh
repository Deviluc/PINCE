#!/bin/bash
: '
Copyright (C) 2016-2017 Korcan Karaokçu <korcankaraokcu@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'

install_gdb () {
	if ! sudo sh install_gdb.sh ; then
		echo "Failed to install PINCE"
		exit 1
	fi
}


PKG_NAMES_ALL="python3-setuptools python3-pip python3-dev gcc g++"
PKG_NAMES_PIP="psutil pexpect distorm3 pygdbmi"

declare -A packages
packages=( ["deb"]="$PKG_NAMES_ALL python3-pyqt5" ["suse"]="$PKG_NAMES_ALL python3-qt5" ["arch"]="base-devel gcc python-setuptools python-pip python-pyqt5")

declare -A install_command
install_command=( ["deb"]="apt-get install" ["suse"]="zypper install" ["arch"]="pacman -S --needed")

OS_NAME="deb"

LSB_RELEASE="`which lsb_release`"
if [ -n "$LSB_RELEASE" ] ; then
	OS_NAME="`$LSB_RELEASE -d -s`"
fi


echo "Detected os name: $OS_NAME"

case "$OS_NAME" in
*buntu*)
	OS_NAME="deb"
	;;
*ebian*)
	OS_NAME="deb"
	;;
*SUSE*)
	OS_NAME="suse"
	;;
*Arch*)
	OS_NAME="arch"
	;;
Manjaro*)
	OS_NAME="arch"
	;;
esac

echo "Detected os code-name: $OS_NAME"

sudo ${install_command["$OS_NAME"]} ${packages["$OS_NAME"]}

if [ $? -gt 0 ]; then
	if [ "$OS_NAME" = "deb" ]; then
		sudo apt-get install software-properties-common
		sudo add-apt-repository ppa:ubuntu-toolchain-r/test
		sudo apt-get update
		sudo ${install_command["$OS_NAME"]} ${packages["$OS_NAME"]}
		if [ $? -gt 0 ]; then
			echo "Failed to install dependencies for Debian/Ubuntu, aborting..."
			exit 1
		fi
	else
		echo "Failed to install dependencies for `lsb_release -d -s`, aborting..."
		exit 1
	fi
fi

sudo pip3 install $PKG_NAMES_PIP
if [ $? -gt 0 ]; then
	echo "Failed to install dependencies for `lsb_release -d -s`, aborting..."
	exit 1
fi


if [ -e libPINCE/gdb_pince/gdb-8.2/bin/gdb ] ; then
	echo "GDB has been already compiled&installed, recompile&install? (y/n)"
	read answer
	if echo "$answer" | grep -iq "^[Yy]" ;then
		install_gdb
	fi
else
	install_gdb
fi

echo "PINCE has been installed successfully!"
echo "Now, just run 'sh PINCE.sh' from terminal"
