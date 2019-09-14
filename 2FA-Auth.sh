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

Version="v1.2-1"

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

if [[ -z $1 ]]; then
    MainMenu
else
    case ${1,,} in
           help) Usage ;;
           info) Information ;;
        gencode) TokenGenerate ;;
              *) Usage ;;
    esac
fi
