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

function Information () {
    clear

    echo "======================="
    echo "2FA-Auth // Information"
    echo "======================="
    echo
    echo "Version.............: $Version"
    echo "Description.........: Generating 2FA auth codes in your terminal"
    echo "Software license....: GNU GPL (General Public License) v3.0"
    echo "Created by..........: Vinicius de Alencar (alencc1986)"
    echo
    echo "Your GnuPG UserID...: $( grep UserID $InfoFile | cut -d' ' -f2- )"
    echo "Your GnuPG KeyID....: $( grep KeyID $InfoFile | cut -d' ' -f2 )"
}

function MainMenu () {
    while true; do
        clear

        echo "====================="
        echo "2FA-Auth // Main menu"
        echo "====================="
        echo
        echo "----------------------------------------------"
        echo "| 2FA-Auth has 1 terminal parameter          |"
        echo "| 'gencode' -- generate auth codes in a fast |"
        echo "|              way without use the main menu |"
        echo "----------------------------------------------"
        echo
        echo "[1] Add new 2FA auth tokens"
        echo "[2] Delete 2FA auth tokens"
        echo "[3] List all 2FA auth tokens"
        echo "[4] Export all 2FA auth tokens"
        echo "[5] Generate 2FA auth codes"
        echo "[6] Backup your tokens/config"
        echo "[7] Restore your tokens/config"
        echo
        echo "[I] Information"
        echo "[Q] Quit"
        echo
        read -p "Option: " -e -n1 Option

        Option=${Option^^}

        case $Option in
            1) Token Add ;;
            2) Token Del ;;
            3) Token List ;;
            4) Token Export ;;
            5) Token Generate ;;
            6) Backup Create ;;
            7) Backup Restore ;;
            I) Information ;;
            Q) break ;;
            *) echo "Invalid option!" ;;
        esac

        PressAnyKey
    done
}

function Usage () {
    echo "============="
    echo "2FA-Auth help"
    echo "============="
    echo
    echo "Hello, user! This menu can help you with 2FA-Auth additional parameter."
    echo "2FA-Auth.sh gencode = Generate 2FA auth codes without use main menu."
}
