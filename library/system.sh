#!/usr/bin/env bash

function InstallPackages () {
    function ErrorMsg () {
        echo "ATTENTION! It wasn't possible to determine your system's package manager!"
        echo
        echo "It wasn't possible to automatically install GnuPG or OAth Toolkit in"
        echo "your system! Please, install these programs and run 2FA-Auth again."
        echo "Exiting..."
        exit 1
    }

    if [[ ! $( command -v gpg ) || ! $( command -v oathtool ) ]]; then
        echo "ATTENTION! GnuPG and/or OATH Toolkit is/are NOT installed in your system!"
        echo "Checking which package manager your system is using. Please, wait!"

        for PkgMan in "apt" "apt-get" "dnf" "emerge" "equo" "pacman" "urpmi" "yum" "zypper" "NONE"; do
            [[ $( command -v ${PkgMan} ) ]] && break
        done

        echo
        echo "Checking if you're online. Please, wait!"
        if [[ ! $( ping -c 4 www.google.com ) ]]; then
            echo "ATTENTION! It seems you're offline!"
            echo "Check your network settings and your Internet connection."
            exi 1
        else
            echo
            echo "Installing GnuPG and/or OATH Toolkit. Please, wait!"

            case ${PkgMan} in
                apt|apt-get) sudo ${PkgMan} update ; sudo ${PkgMan} install -y gnupg2 oathtool ;;
                    dnf|yum) sudo ${PkgMan} check-update ; sudo ${PkgMan} install -y gnupg2 oathtool ;;
                     emerge) sudo emerge --sync ; sudo emerge gnupg oath-toolkit ;;
                       equo) sudo equo update ; sudo equo install gnupg oathtool ;;
                     pacman) sudo pacman -Sy ; sudo pacman -Sy --noconfirm gnupg oathtool ;;
                      urpmi) sudo urpmi.update -a ; yes | sudo urpmi gnupg2 oath-toolkit ;;
                     zypper) sudo zypper refresh ; sudo zypper -n install gnupg oath-toolkit ;;
                       NONE) ErrorMsg ;;
            esac

            if [[ $? = "0" ]]; then
                echo "Installation completed with success!"
            else
                echo "Something wrong happened while installing GnuPG and/or OAth Toolkit!"
                exit 1
            fi

            PressAnyKey
        fi
    fi
}

function SystemCheck () {
    InstallPackages

    GPG=$( command -v gpg )
    OATHTOOL=$( command -v oathtool )

    if [[ $( ${GPG} --list-keys | wc -l ) = "0" ]]; then
        echo "ERROR! No GnuPG key(s) found in your profile!"
        exit 1
    fi

    [[ ! -d $HOME/${ConfigDir} ]] && mkdir -p $HOME/${ConfigDir}
    [[ -f $HOME/${ConfigDir}/2fa-info ]] && mv $HOME/${ConfigDir}/2fa-info ${InfoFile}

    cd $HOME

    if [[ ! -f ${InfoFile} ]]; then
        while true; do
            clear

            echo "================================="
            echo "2FA-Auth // Initial configuration"
            echo "================================="
            echo
            echo "It's mandatory to inform your GnuPG ID (User ID). This ID is"
            echo "essential to encrypt/decrypt your 2FA tokens. User ID is your"
            echo "email address which is registered in your GnuPG key."
            echo "If you have 2 or more keys/subkeys, choose 1 of them and input"
            echo "ID when prompted. About subkeys, it's possible to have many en-"
            echo "cryption subkeys included/associated with your main key."
            echo
            echo "Listing your available key(s):"
            echo
            echo "-------------------------------------------------"
            ListGPGkeys
            echo "-------------------------------------------------"
            echo

            read -p "Type/copy-paste your User ID (e-mail address): " -e UserID 
            UserID=$( echo ${UserID,,} | sed 's| \+||g' ) 


            if [[ $( ${GPG} --list-keys ${UserID} ) ]]; then
                echo "UserID ${UserID}" > ${InfoFile}
                break
            else
                echo "ERROR! You typed/included an invalid User ID!"
                PressAnyKey
            fi
        done
    else
        UserID=$( grep "UserID" ${InfoFile} | cut -d' ' -f2- )
    fi

    Token Unify
}
