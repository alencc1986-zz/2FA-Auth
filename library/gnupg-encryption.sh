#!/usr/bin/env bash

function ReplaceInfoFile () {
    UserID=$1
    echo "UserID ${UserID}" > ${InfoFile}
}

function RestoreGPG () {
    UserID=$1
    NewUserID=$2

    echo "UserID ${UserID}" > ${InfoFile}

    if [[ ${EncryptStatus} = "OK" ]]; then
        ${GPG} --quiet --yes --output ${TokenFileTXT} --decrypt ${TokenFile} 2> /dev/null && \
            ${GPG} --quiet --recipient ${UserID} --yes --output ${TokenFile} --encrypt ${TokenFileTXT} 2> /dev/null && \
            echo "Old encryption was used to re-encrypt your tokens!" || echo "It wasn't possible to re-encrypt your tokens using your old encryption!"
    fi
}

function ChangeGPG () {
    echo "Changing your GPG key. Please, wait..."

    ${GPG} --quiet --output ${TokenFileTXT} --decrypt ${TokenFile} 2> /dev/null && DecryptStatus="OK" && \
        ${GPG} --quiet --recipient ${NewUserID} --yes --output ${TokenFile} --encrypt ${TokenFileTXT} 2> /dev/null && EncryptStatus="OK" && \
        rm -rf "${TokenFileTXT}" 2> /dev/null

    if [[ ${DecryptStatus} = "OK" ]]&&[[ ${EncryptStatus} = "OK" ]]; then
        echo "SUCCESS! Your GnuPG key has been changed!"
        ReplaceInfoFile ${NewUserID} ${NewKeyID}
    else
        echo "FAIL! Something wrong happened while changing you GnuPG key!"
        RestoreGPG ${UserID} ${NewUserID}
    fi
}

function ChangeMenu () {
    clear
    echo "=========================================="
    echo "2FA-Auth ${VERSION} // Change GnuPG encryption"
    echo "=========================================="
    echo
    echo "Current User ID in use is \"${UserID}\"."
    echo
    echo "Changing your GnuPG key, allows you to update/change"
    echo "the encryption in your 2FA-Auth tokens file. This is"
    echo "helpful when you want to change your GPG key in your"
    echo "profile."
    echo
    echo "Listing all available keys:"
    echo
    echo "-------------------------------------------------"
    ListGPGkeys
    echo "-------------------------------------------------"
    echo

    InputData "Type your new UserID (e-mail address) (press [C] to CANCEL):"

    NewUserID=$( echo ${Input,,} | sed 's| \+||g' )

    if [[ $( echo ${Input,,} ) = "c" ]]; then
        echo "Cancelling..."
    else
        while true; do
            echo
            read -p "Are you sure that you want to change your GnuPG encryption? [y/N] " -e -n1 Answer
            echo

            [[ -z ${Answer} ]] && Answer="n" || Answer=${Answer,,}

            case ${Answer} in
                y) ChangeGPG ; break ;;
                n) echo "Keeping your previous GPG key!" ; break ;;
                *) echo "ERROR: Invalid option!" ;;
            esac
        done
    fi
}
