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

function ErrorMsg () {
    echo "ATTENTION! It wasn't possible to discovery your system's package manager!"
    echo
    echo "It wasn't possible to automatically install GnuPG and/or OAth Toolkit"
    echo "in your system! Please, install these programs and run 2FA-Auth again."
    echo "Exiting..."

    exit 2
}

function InstallationMsg () {
    case STATUS in
        success) echo "SUCCESS! Packages installed with success!" ;;

           fail) echo "FAIL! Something wrong happened while installing GnuPG and OAth Toolkit!"
                 echo "Please, check what happened! Exiting..."

                 exit 2 ;;
    esac
}

function InstallPackages () {
    if [[ ! $( which gpg ) || ! $( which oathtool ) ]]; then
        for PKGMAN in apt apt-get dnf emerge equo pacman urpmi yum zypper; do
            [[ $( which $PKGMAN ) ]] && break || ErrorMsg
        done

        case $PKGMAN in
            apt|apt-get) sudo $PKGMAN update && sudo $PKGMAN install -y gnupg2 oathtool ;;
                dnf|yum) sudo $PKGMAN check-update && sudo $PKGMAN install -y gnupg2 oathtool ;;
                 emerge) sudo emerge --sync && sudo emerge gnupg oath-toolkit ;;
                   equo) sudo equo update && sudo equo install gnupg oathtool ;;
                 pacman) sudo pacman -Sy && sudo pacman -Sy --noconfirm gnupg oathtool ;;
                  urpmi) sudo urpmi.update -a && yes | sudo urpmi gnupg2 oath-toolkit ;;
                 zypper) sudo zypper refresh && sudo zypper -n install gnupg oath-toolkit ;;
        esac

        [[ $( which gpg ) && $( which oathtool ) ]] && InstallationMsg success || InstallationMsg fail
    fi
}

function UnifyTokens () {
    if [[ -d $ProjectDir/token ]]; then
        if [[ $( find $ProjectDir/token -type f -name *.token | wc -l ) > "0" ]]; then
            echo "Gathering all 2FA tokens into one single file. Please, wait!"
            echo

            cat /dev/null > $TempFile

            AmountOfTokens=$( find $ProjectDir/token -type f -name *.token | wc -l )
            Counter=1

            for Service in $( basename -a -s .token $( find $ProjectDir/token -type f -name *.token | sort ) ); do
                echo -n "Processing file $Counter of $AmountOfTokens (service: $Service)... "

                Token=$( $GPG --quiet --local-user $KeyID --recipient $UserID --decrypt $ProjectDir/token/$Service.token )
                if [[ $? != "0" ]]; then
                    echo "FAIL"
                    echo
                    echo "Something wrong happened!"
                    echo "Did you type your GnuPG password correctly?"

                    exit 4
                else
                    echo "$Service|$Token" >> $TempFile
                    let Counter+=1
                    echo "done!"
                fi
            done

            $GPG --local-user $KeyID --recipient $UserID --yes --output $TokenFile --encrypt $TempFile
            rm -rf $TempFile $ProjectDir/token

            echo
            echo "Tokens were unified with success!"
            echo "New token file is: $TokenFile"

            PressAnyKey
        fi
    fi
}

function SystemCheck () {
    InstallPackages

    GPG=$( which gpg )
    OATHTOOL=$( which oathtool )

    [[ $( $GPG --fingerprint | wc -l ) = "0" ]] && { echo "ERROR! No GnuPG key(s) found in your profile!" ; exit 3 ; }

    cd $HOME ; [[ -f $ProjectDir/2fa-info ]] && mv $ProjectDir/2fa-info $InfoFile

    if [[ ! -f $InfoFile ]]; then
        clear

        echo "================================="
        echo "2FA-Auth // Initial configuration"
        echo "================================="
        echo
        echo "2FA-Auth needs to know your GnuPG IDs (UserID & KeyID), once they are"
        echo "essential to encrypt/decrypt your 2FA tokens. UserID is your email which"
        echo "is registered in your GnuPG key, while KeyID is part of your fingerprint"
        echo "(KeyID numbers are the last 16 digits/4 blocks of your fingerprint)."
        echo "If you have 2 or more keys/subkeys, choose one of them and input your IDs"
        echo "when prompted. About subkeys, it's possible to have a encryption subkey that"
        echo "can be included/assossiated with your main key."
        echo "Remmember: both IDs (UserID and KeyID) *MUST* belong to the same GnuPG Key!"
        echo
        echo "Listing your available key(s):"
        echo
        echo "-------------------------------------------------"
        $GPG --fingerprint | grep -v "pub\|sub\|-----" | sed 's/uid//g; s/ \+/ /g; s/^ //g; $ d'
        echo "-------------------------------------------------"
        echo

        read -p "Type/copy-paste your UserID (e-mail).......: " -e UserID
        read -p "Type/copy-paste your KeyID (fingerprint)...: " -e KeyID

        UserID=$( echo $UserID | sed 's| \+||g' ) ; echo "UserID $UserID" > $InfoFile
        KeyID=$( echo ${KeyID^^} | sed 's| \+||g' ) ; echo "KeyID $KeyID" >> $InfoFile
    else
        UserID=$( grep "UserID" $InfoFile | cut -d' ' -f2- )
        KeyID=$( grep "KeyID" $InfoFile | cut -d' ' -f2 )
    fi

    UnifyTokens
}
