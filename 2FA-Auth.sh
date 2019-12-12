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

Version="v2.4-0"

ConfigDir=".config/2fa-auth"
InfoFile="$HOME/$ConfigDir/2fa-auth.info"

TempFile="$HOME/$ConfigDir/temp-tokens.txt"
TokenFile="$HOME/$ConfigDir/2fa-tokens.gpg"
TokenFileTXT="$HOME/$ConfigDir/2fa-tokens.txt"

BackupFile="2fa-config-backup.tar"
ExportFile="2fa-tokens.txt"

LibraryDir="$( dirname $0 )/library"
README="$( dirname $0 )/doc/README"

for Library in backup essential gnupg-encryption menu pkg-install system token; do
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
    function Usage () {
        echo "============="
        echo "2FA-Auth help"
        echo "============="
        echo
        echo "Hello! This menu can help you with 2FA-Auth additional parameters."
        echo "You don't need to use the main menu, just these 2 parameters."
        echo
        echo "2FA-Auth.sh changekey = Change GnuPG key/encryption"
        echo "2FA-Auth.sh gencode = Generate 2FA auth codes"
    }

    case ${1,,} in
        changekey) ChangeMenu ;;
          gencode) TokenGenerate ;;
                *) Usage ;;
    esac
fi
