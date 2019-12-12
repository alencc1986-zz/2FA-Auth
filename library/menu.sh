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
    echo "Version............: $Version"
    echo "Description........: Generating 2FA codes in your terminal"
    echo "Software license...: GNU GPL (General Public License) v3.0"
    echo "Created by.........: Vinicius de Alencar (alencc1986)"
    echo
    echo "GnuPG User ID......: $( grep UserID $InfoFile | cut -d' ' -f2- )"
    echo "GnuPG Key ID.......: $( grep KeyID $InfoFile | cut -d' ' -f2 )"
}

function MainMenu () {
    while true; do
        clear

        echo "====================="
        echo "2FA-Auth // Main menu"
        echo "====================="
        echo
        echo "------------------------------------------------"
        echo "| 2FA-Auth has 2 terminal parameters           |"
        echo "|                                              |"
        echo "| 'changekey' -- change GnuPG key/encryption   |"
        echo "|                                              |"
        echo "| 'gencode'   -- generate auth codes in a fast |"
        echo "|                way without use the main menu |"
        echo "------------------------------------------------"
        echo
        echo "[1] Add new 2FA auth tokens"
        echo "[2] Delete 2FA auth tokens"
        echo "[3] List all 2FA auth tokens"
        echo "[4] Rename 2FA auth tokens"
        echo "[5] Export all 2FA auth tokens"
        echo "[6] Generate 2FA auth codes"
        echo "[7] Backup your tokens/config"
        echo "[8] Restore your tokens/config"
        echo
        echo "[C] Change GnuPG encryption key"
        echo "[I] Information"
        echo "[R] Show README file"
        echo "[Q] Quit"
        echo
        read -p "Option: " -e -n1 Option

        Option=${Option^^}

        case $Option in
            1) Token Add ;;
            2) Token Del ;;
            3) Token List ;;
            4) Token Rename ;;
            5) Token Export ;;
            6) Token Generate ;;
            7) Backup Create ;;
            8) Backup Restore ;;
            C) ChangeMenu ;;
            I) Information ;;
            R) clear ; less $README ; echo "End-of-file ($README)!" ;;
            Q) break ;;
            *) echo "Invalid option!" ;;
        esac

        PressAnyKey
    done
}
