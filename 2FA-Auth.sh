#!/usr/bin/env bash

LibraryDir="$( dirname $0 )/library"

for Library in "backup" "essential" "gnupg-encryption" "menu" "system" "token"; do
    if [[ -f ${LibraryDir}/${Library}.sh ]]; then
        source ${LibraryDir}/${Library}.sh
    else
        echo "ERROR! The library '${Library}' is missing!"
        echo "Check what happened with it!"
        exit 1
    fi
done

ConfigDir=".config/2fa-auth"
BackupFile="2fa-config-backup.tar"
ExportFile="2fa-tokens.txt"

InfoFile="$HOME/${ConfigDir}/2fa-auth.info"
TempFile="$HOME/${ConfigDir}/temp-tokens.txt"
TokenFile="$HOME/${ConfigDir}/2fa-tokens.gpg"
TokenFileTXT="$HOME/${ConfigDir}/2fa-tokens.txt"

SystemCheck

if [[ -z $1 ]]; then
    MainMenu
else
    function Usage () {
        echo "=============="
        echo "2FA-Auth usage"
        echo "=============="
        echo
        echo "2FA-Auth changekey = Change GnuPG key/encryption"
        echo "2FA-Auth gencode = Generate 2FA auth codes"
    }

    case ${1,,} in
        changekey) ChangeMenu ;;
          gencode) TokenGenerate ;;
                *) Usage ;;
    esac
fi
