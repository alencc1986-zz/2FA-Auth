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
    echo "It wasn't possible to automatically install GnuPG and/or OAth Toolkit"
    echo "in your system! Please, manually install these programs and run 2FA-Auth"
    echo "again. Exiting..."

    exit 2
}

function InstallationMsg () {
    case STATUS in
        success) echo "SUCCESS! Packages installed with success!" ;;

           fail) echo "FAIL! Something wrong happened while installing GnuPG and OAth Toolkit!"
                 echo "Please, check what happened! Exiting..."
                 exit 2 ;;
    esac
}

function InstallPackages () {
    if [[ ! $( which gpg ) || ! $( which oathtool ) ]]; then
        for PKGMAN in apt apt-get dnf emerge equo pacman urpmi yum zypper; do
            [[ $( which $PKGMAN ) ]] && break || ErrorMsg
        done

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
}
