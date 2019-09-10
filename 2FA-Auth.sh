#!/usr/bin/env bash

################################################################################
#                                                                              #
#    2FA-Auth // Generating '2FA' codes in your terminal                       #
#    Copyright (C) 2019  Vinicius de Alencar                                   #
#                                                                              #
#    This program is free software: you can redistribute it and/or modify      #
#    it under the terms of the GNU General Public License as published by      #
#    the Free Software Foundation, either version 3 of the License, or         #
#    (at your option) any later version.                                       #
#                                                                              #
#    This program is distributed in the hope that it will be useful,           #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#    GNU General Public License for more details.                              #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.    #
#                                                                              #
################################################################################

ProjectDir=".config/2fa-auth"
TokenDir="$HOME/$ProjectDir/token"
InfoFile="$HOME/$ProjectDir/2fa-info"

BackupFile="2fa-config-backup.tar"
ExportFile="2fa-tokens.txt"

LibraryDir="$( dirname $0 )/library"

for Library in backup essential token; do
    if [[ -f $LibraryDir/$Library.sh ]]; then
        source $LibraryDir/$Library.sh
    else
        echo "ERROR! The library '$Library' is missing!"
        echo "Check what happened with it!"
        exit 1
    fi
done

SystemCheck

while true; do
    clear

    echo "====================="
    echo "2FA-Auth // Main menu"
    echo "====================="
    echo
    echo "[1] Add a new 2FA token in your profile"
    echo "[2] Delete one or all available tokens (be carreful!)"
    echo "[3] List all available 2FA tokens set in your profile"
    echo "[4] Export all 2FA tokens to use them in another app/program"
    echo "[5] Generate 2FA codes in order to login on a site/service"
    echo "[6] Save your configuration in a backup file"
    echo "[7] Restore your configuration from a backup file"
    echo
    echo "[I] Information about 2FA-Auth"
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
