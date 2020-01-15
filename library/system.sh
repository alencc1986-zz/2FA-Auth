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

function UnifyTokens () {
    if [[ -d $HOME/$ConfigDir/token ]]; then
        if [[ $( find $HOME/$ConfigDir/token -type f -name *.token | wc -l ) > "0" ]]; then
            echo "Gathering all 2FA tokens into one single file. Please, wait!"
            echo

            cat /dev/null > $TempFile

            AmountOfTokens=$( find $HOME/$ConfigDir/token -type f -name *.token | wc -l )
            Counter=1

            for Service in $( basename -a -s .token $( find $HOME/$ConfigDir/token -type f -name *.token | sort ) ); do
                echo -n "Processing file $Counter of $AmountOfTokens (service: $Service)... "

                Token=$( $GPG --quiet --local-user $KeyID --recipient $UserID --decrypt $HOME/$ConfigDir/token/$Service.token )
                if [[ $? != "0" ]]; then
                    echo "FAIL"
                    echo
                    echo "Something wrong happened!"
                    echo "Did you type your GnuPG password correctly?"

                    exit 1
                else
                    echo "$Service|$Token" >> $TempFile
                    let Counter+=1
                    echo "done!"
                fi
            done

            $GPG --local-user $KeyID --recipient $UserID --yes --output $TokenFile --encrypt $TempFile
            rm -rf $TempFile $HOME/$ConfigDir/token

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

    [[ $( $GPG --fingerprint | wc -l ) = "0" ]] && { echo "ERROR! No GnuPG key(s) found in your profile!" ; exit 1 ; }

    [[ ! -d $HOME/$ConfigDir ]] && mkdir -p $HOME/$ConfigDir
    cd $HOME
    [[ -f $HOME/$ConfigDir/2fa-info ]] && mv $HOME/$ConfigDir/2fa-info $InfoFile

    if [[ ! -f $InfoFile ]]; then
        while true; do
            clear

            echo "================================="
            echo "2FA-Auth // Initial configuration"
            echo "================================="
            echo
            echo "It's mandatory to inform your GnuPG IDs (User ID and Key ID)."
            echo "These IDs are essential to encrypt/decrypt your 2FA tokens."
            echo "User ID is your email address which is registered in your GnuPG"
            echo "key, while Key ID is part of your fingerprint (you may look for"
            echo "the last 16 digits or last 4 blocks of number in your GnuPG key"
            echo "fingerprint)."
            echo "If you have 2 or more keys/subkeys, choose 1 of them and input"
            echo "IDs when prompted. About subkeys, it's possible to have many en-"
            echo "cryption subkeys included/associated with your main key."
            echo "ATTENTION: both IDs *MUST* belong to the same GnuPG Key!"
            echo
            echo "Listing your available key(s):"
            echo
            echo "-------------------------------------------------"
            $GPG --fingerprint | grep -v "pub\|sub\|-----" | sed 's/uid//g; s/ \+/ /g; s/^ //g; $ d'
            echo "-------------------------------------------------"
            echo

            read -p "Type/copy-paste your User ID (e-mail address): " -e UserID ; UserID=$( echo ${UserID,,} | sed 's| \+||g' ) 
            read -p "Type/copy-paste your Key ID (fingerprint)....: " -e KeyID ; KeyID=$( echo ${KeyID^^} | sed 's| \+||g' )


            if [[ $( $GPG --list-keys $UserID | grep $KeyID ) ]]; then
                echo "UserID $UserID" > $InfoFile
                echo "KeyID $KeyID" >> $InfoFile
                break
            else
                echo "ERROR! You typed/included IDs that belong to different GnuPG keys!"
                PressAnyKey
            fi
        done
    else
        UserID=$( grep "UserID" $InfoFile | cut -d' ' -f2- )
        KeyID=$( grep "KeyID" $InfoFile | cut -d' ' -f2 )
    fi

    UnifyTokens
}
