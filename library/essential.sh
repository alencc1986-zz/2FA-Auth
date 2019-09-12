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
    NoChange="$5"

    read -p "$Message [y/N] " -e -n1 Confirm
    [[ -z "$Confirm" ]] && Confirm="n" || Confirm=${Confirm,,}

    case $Confirm in
        y) $Action && echo "$Success" || echo "$Fail" ;;
        n) echo "$NoChange" ;;
        *) echo "Invalid option!" ;;
    esac
}

function Information () {
    echo "======================="
    echo "2FA-Auth // Information"
    echo "======================="
    echo
    echo "Version.............: $Version"
    echo "Description.........: Generating 2FA codes in your terminal"
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

function MainMenu () {
    while true; do
        clear

        echo "====================="
        echo "2FA-Auth // Main menu"
        echo "====================="
        echo
        echo "Current version: $Version"
        echo
        echo "[1] Add a new 2FA token in your profile"
        echo "[2] Delete one or all available tokens (be carreful!)"
        echo "[3] List all available 2FA tokens set in your profile"
        echo "[4] Export all 2FA tokens to use them in another app/program"
        echo "[5] Generate 2FA codes in order to login on a site/service"
        echo "[6] Save your configuration in a backup file"
        echo "[7] Restore your configuration from a backup file"
        echo
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
            Q) break ;;
            *) echo "Invalid option!" ;;
        esac

        PressAnyKey
    done
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

function Usage () {
    echo "============="
    echo "2FA-Auth help"
    echo "============="
    echo
    echo "Hello, user \"$USER\"! Here's a help menu about 2FA-Auth parameters!"
    echo "You can use them instead of access 2FA-Auth's main menu."
    echo
    echo "$ ./2FA-Auth.sh [parameter]"
    echo
    echo "                help    = Show this message and quit"
    echo "                info    = Show 2FA-Auth information and your GPG IDs"
    echo "                gencode = Generate 2FA codes without use main menu"
}
