#!/usr/bin/env bash

#  2FA-Auth // Generating '2FA' codes in your terminal
#  Copyright (C) 2019  Vinicius de Alencar
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

function ErrorMsg () {
    echo "ATTENTION! It wasn't possible to determine your system's package manager!"
    echo
    echo "It wasn't possible to automatically install GnuPG or OAth Toolkit in"
    echo "your system! Please, install these programs and run 2FA-Auth again."
    echo "Exiting..."
    exit 1
}

function InstallPackages () {
    if [[ ! $( which gpg ) || ! $( which oathtool ) ]]; then
        echo "ATTENTION! GnuPG and/or OATH Toolkit is/are NOT installed in your system!"
        echo "Checking which package manager your system is using. Please, wait!"
        for PKGMAN in apt apt-get dnf emerge equo pacman urpmi yum zypper; do
            [[ $( which $PKGMAN ) ]] && break || ErrorMsg
        done

        echo
        echo "Checking if you're online. Please, wait!"
        if [[ ! $( ping -c 4 www.google.com ) ]]; then
            echo "ATTENTION! It seems you're offline!"
            echo "Check your network settings and your Internet connection."
        else
            echo
            echo "Installing GnuPG and/or OATH Toolkit. Please, wait!"
            case $PKGMAN in
                apt|apt-get) sudo $PKGMAN update && sudo $PKGMAN install -y gnupg2 oathtool ;;
                    dnf|yum) sudo $PKGMAN check-update && sudo $PKGMAN install -y gnupg2 oathtool ;;
                     emerge) sudo emerge --sync && sudo emerge gnupg oath-toolkit ;;
                       equo) sudo equo update && sudo equo install gnupg oathtool ;;
                     pacman) sudo pacman -Sy && sudo pacman -Sy --noconfirm gnupg oathtool ;;
                      urpmi) sudo urpmi.update -a && yes | sudo urpmi gnupg2 oath-toolkit ;;
                     zypper) sudo zypper refresh && sudo zypper -n install gnupg oath-toolkit ;;
            esac

            [[ $( which gpg ) && $( which oathtool ) ]] && InstallationMsg success || InstallationMsg fail
        fi
    fi
}
