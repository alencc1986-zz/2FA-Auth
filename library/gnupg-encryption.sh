#!/usr/bin/env bash

#  2FA-Auth // Generating '2FA' codes in your terminal
#  Copyright (C) 2020  Vinicius de Alencar
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

function ReplaceInfoFile () {
    UserID=$1
    KeyID=$2

    echo "UserID $UserID" > $InfoFile
    echo "KeyID $KeyID" >> $InfoFile
}

function RestoreGPG () {
    UserID=$1
    KeyID=$2
    NewUserID=$3
    NewKeyID=$4

    echo "UserID $UserID" > $InfoFile
    echo "KeyID $KeyID" >> $InfoFile

    if [[ $ENCRYPTSTATUS = "OK" ]]; then
        $GPG --quiet --local-user $NewUserID --recipient $NewKeyID --yes --output $TokenFileTXT --decrypt $TokenFile 2> /dev/null && \
        $GPG --quiet --local-user $UserID --recipient $KeyID --yes --output $TokenFile --encrypt $TokenFileTXT 2> /dev/null && \
        echo "Old encryption was used to re-encrypt your tokens!" || echo "It wasn't possible to re-encrypt your tokens using your old encryption!"
    fi
}

function ChangeGPG () {
    echo "Changing your GPG key. Please, wait..."

    $GPG --quiet --local-user $UserID --recipient $KeyID --yes --output $TokenFileTXT --decrypt $TokenFile 2> /dev/null && DECRYPTSTATUS="OK" && \
    $GPG --quiet --local-user $NewUserID --recipient $NewKeyID --yes --output $TokenFile --encrypt $TokenFileTXT 2> /dev/null && ENCRYPTSTATUS="OK" && \
    rm -rf "$TokenFileTXT" 2> /dev/null

    if [[ $DECRYPTSTATUS = "OK" ]]&&[[ $ENCRYPTSTATUS = "OK" ]]; then
        echo "SUCCESS! Your GnuPG key has been changed!"
        ReplaceInfoFile $NewUserID $NewKeyID
    else
        echo "FAIL! Something wrong happened while changing you GnuPG key!"
        RestoreGPG $UserID $KeyID $NewUserID $NewKeyID
    fi
}

function ChangeMenu () {
    clear
    echo "==================================="
    echo "2FA-Auth // Change GnuPG encryption"
    echo "==================================="
    echo
    echo "Current User ID in use is \"$UserID\"."
    echo "Current Key ID in use is \"$KeyID\"."
    echo
    echo "Changing your GnuPG key, allows you to update/change"
    echo "the encryption in your 2FA-Auth tokens file. This is"
    echo "helpful when you want to change your GPG key in your"
    echo "profile."
    echo
    echo "Listing all available keys:"
    echo
    echo "-------------------------------------------------"
    $GPG --fingerprint | grep -v "pub\|sub\|-----" | sed 's/uid//g; s/ \+/ /g; s/^ //g; $ d'
    echo "-------------------------------------------------"
    echo

    InputData "Type/copy-paste your new UserID (e-mail address) (press [C] to CANCEL):"
    NewUserID=$( echo ${Input,,} | sed 's| \+||g' )

    if [[ $( echo ${Input,,} ) = "c" ]]; then
        echo "Cancelling..."
    else
        InputData "Type/copy-paste your new KeyID (fingerprint) (press [C] to CANCEL):"
        NewKeyID=$( echo ${Input^^} | sed 's| \+||g' )

        if [[ $( echo ${Input,,} ) = "c" ]]; then
            echo "Cancelling..."
        else
            if [[ $( $GPG --list-keys $NewUserID | grep $NewKeyID ) ]]; then
                while true; do
                    echo
                    read -p "Are you sure that you want to change your GnuPG encryption? [y/N] " -e -n1 ANSWER
                    echo

                    [[ -z $ANSWER ]] && ANSWER="n" || ANSWER=${ANSWER,,}

                    case $ANSWER in
                        y) ChangeGPG ; break ;;
                        n) echo "Keeping your 'old' GPG key!" ; break ;;
                        *) echo "ERROR: Invalid option!" ;;
                    esac
                done
            else
                echo "ERROR! You typed (or copy-pasted) IDs that belong to different GnuPG keys!"
                echo "Please, type/copy-paste IDs from the same key!"
                PressAnyKey
                ChangeMenu
            fi
        fi
    fi
}
