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

function ConfirmAction () {
    Message="$1"
    Action="$2"
    Success="SUCCESS! $3"
    Fail="FAIL! $4"
    Keep="$5"

    read -p "$Message [y/N] " -e -n1 Confirm
    [[ -z "$Confirm" ]] && Confirm="n" || Confirm=${Confirm,,}

    case $Confirm in
        y) $Action && echo "$Success" || echo "$Fail" ;;
        n) echo "$Keep" ;;
        *) echo "Invalid option!" ;;
    esac
}

function Information () {
    clear

    echo "======================="
    echo "2FA-Auth // Information"
    echo "======================="
    echo
    echo "Version.............: v1.0-1"
    echo "Description.........: Generate '2FA' codes in your terminal"
    echo "Software license....: GNU GPL (General Public License) v3.0"
    echo "Created by..........: Vinicius de Alencar (alencc1986)"
    echo
    echo "Your GnuPG UserID...: $( grep UserID $InfoFile | cut -d' ' -f2- )"
    echo "Your GnuPG KeyID....: $( grep KeyID $InfoFile | cut -d' ' -f2 )"
}

function InputData () {
    Message="$1"
    Input=

    read -p "$Message " -e Input
    if [[ -z $Input ]]; then
        echo "ATTENTION!!! You *MUST* type something!!!"
        InputData "$Message"
    fi
}

function Overwrite () {
    Message="$1"
    Action="$2"
    MsgSuccess="SUCCESS! $3"
    MsgFail="FAIL! $4"
    MsgKeep="$5"

    read -p "$Message [y/N] " -e -n1 OverwriteAnswer
    [[ -z "$OverwriteAnswer" ]] && OverwriteAnswer="n" || OverwriteAnswer=${OverwriteAnswer,,}

    case $OverwriteAnswer in
        y) $Action && echo "$MsgSuccess" || echo "$MsgFail" ;;
        n) echo "$MsgKeep" ;;
        *) echo "Invalid option!" ;;
    esac
}

function PressAnyKey () {
    echo
    read -p "Press any key to continue... " -e -n1
}

function SystemCheck () {
    [[ ! $( which gpg2 ) ]] && { echo "ERROR! 'GnuPG' isn't installed in your system!" ; exit 2 ; } || GPG=$( which gpg2 )
    [[ ! $( which oathtool ) ]] && { echo "ERROR! 'OAth Toolkit' isn't installed in your system!" ; exit 2 ; } || OATHTOOL=$( which oathtool )
    [[ $( $GPG --fingerprint | wc -l ) = "0" ]] && { echo "ERROR! No GnuPG key(s) found in your profile!" ; exit 3 ; }

    [[ ! -d $TokenDir ]] && mkdir -p $TokenDir

    if [[ ! -f $InfoFile ]]; then
        clear

        echo "================================="
        echo "2FA-Auth // Initial configuration"
        echo "================================="
        echo
        echo "2FA-Auth needs to know your GnuPG IDs (UserID & KeyID), once they are"
        echo "essential to encrypt/decrypt your 2FA tokens. UserID is your email which"
        echo "is registered in your GnuPG key, while KeyID is part of your fingerprint."
        echo
        echo "Listing your available key(s):"
        echo
        echo "FINGERPRINT-------------------[Here's your KeyID]"
        $GPG --fingerprint | grep -v "pub\|sub\|-----" | sed 's/uid//g; s/ \+/ /g; s/^ //g; $ d'
        echo "-------------------------------------------------"
        echo
        echo "If you have 2 or more keys, choose one key and input its IDs when prompted."
        echo "Both IDs (UserID and KeyID) *MUST* belong to the same GnuPG Key!"
        echo

        read -p "Type/copy-paste your UserID (e-mail).......: " -e UserID
        read -p "Type/copy-paste your KeyID (fingerprint)...: " -e KeyID

        UserID=$( echo $UserID | sed 's| \+||g' ) ; echo "UserID $UserID" > $InfoFile
        KeyID=$( echo ${KeyID^^} | sed 's| \+||g' ) ; echo "KeyID $KeyID" >> $InfoFile
    else
        UserID=$( grep "UserID" $InfoFile | cut -d' ' -f2- )
        KeyID=$( grep "KeyID" $InfoFile | cut -d' ' -f2 )
    fi
}

function TokenCount () {
    return $( find $ProjectDir -type f -name *.token | wc -l )
}
