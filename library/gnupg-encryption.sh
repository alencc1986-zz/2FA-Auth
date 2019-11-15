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

function ChangeGPG () {
    $GPG --quiet --local-user $UserID --recipient $KeyID --yes --output $TokenFileTXT --decrypt $TokenFile && \
    $GPG --quiet --local-user $NewUserID --recipient $NewKeyID --yes --output $TokenFile --encrypt $TokenFileTXT && \
    mv "$InfoFile" "$InfoFile"-old && \
    { echo "UserID $NewUserID" > $InfoFile && echo "KeyID $NewKeyID" >> $InfoFile ; }
    rm -rf "$TokenFileTXT" "$InfoFile"-old
}

function ChangeMenu () {
    clear
    echo "==================================="
    echo "2FA-Auth // Change GnuPG encryption"
    echo "==================================="
    echo
    echo "Your current UserID is \"$UserID\"."
    echo "Your current KeyID is \"$KeyID\"."
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

    InputData "Type/copy-paste your new UserID (press [C] to CANCEL):" ; NewUserID=$( echo ${Input,,} | sed 's| \+||g' )
    if [[ $( echo ${Input,,} ) = "c" ]]; then
        echo "Cancelling..."
    else
        InputData "Type/copy-paste your new KeyID (press [C] to CANCEL):" ; NewKeyID=$( echo ${Input^^} | sed 's| \+||g' )
        if [[ $( echo ${Input,,} ) = "c" ]]; then
            echo "Cancelling..."
        else
            echo
            if [[ $( $GPG --list-keys $NewUserID | grep $NewKeyID ) ]]; then
                ConfirmAction "Are you sure that you want to change your GnuPG encryption?" \
                    ChangeGPG \
                    "GnuPG encryption changed!" \
                    "Something wrong happened while changing your encryption!" \
                    "Keeping your 'old' GnuPG encryption!"
            else
                echo "ERROR! You typed (or copy-pasted) IDs that belong to different GnuPG keys!"
                echo "Please, type/copy-paste IDs from the same key!"
                ChangeMenu
            fi
        fi
    fi
}
