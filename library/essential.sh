#!/usr/bin/env bash

function ConfirmAction () {
    Message="$1"
    Action="$2"
    MsgSuccess="SUCCESS! $3"
    MsgFail="FAIL! $4"
    MsgNoChange="$5"

    read -p "${Message} [y/N] " -e -n1 Confirm

    [[ -z "${Confirm}" ]] && Confirm="n" || Confirm=${Confirm,,}

    case ${Confirm} in
        y) ${Action} && echo "${MsgSuccess}" || echo "${MsgFail}" ;;
        n) echo "${MsgNoChange}" ;;
        *) echo "Invalid option!" ;;
    esac
}

function InputData () {
    Message="$1"

    read -p "${Message} " -e Input

    if [[ -z ${Input} ]]; then
        echo "ATTENTION!!! Empty input isn't valid!"
        echo "You must type something!"
        echo

        InputData "${Message}"
    fi
}

function ListGPGkeys () {
    ${GPG} --list-keys | grep -i "uid" | sed 's/ \+/ /g; s/uid //g' | sort
}

function Overwrite () {
    Message="$1"
    Action="$2"
    MsgSuccess="SUCCESS! $3"
    MsgFail="FAIL! $4"
    MsgKeep="$5"

    read -p "${Message} [y/N] " -e -n1 OverwriteAnswer

    [[ -z "${OverwriteAnswer}" ]] && OverwriteAnswer="n" || OverwriteAnswer=${OverwriteAnswer,,}

    case ${OverwriteAnswer} in
        y) ${Action} && echo "${MsgSuccess}" || echo "${MsgFail}" ;;
        n) echo "${MsgKeep}" ;;
        *) echo "Invalid option!" ;;
    esac
}

function PressAnyKey () {
    echo
    read -p "Press any key to continue... " -e -n1
}

function Usage () {
    clear

    echo "========================"
    echo "2FA-Auth ${VERSION} // Usage"
    echo "========================"
    echo
    echo "You can (optionally) use one of these options:"
    echo
    echo "2FA-Auth changekey = Change GnuPG key/encryption"
    echo "2FA-Auth gencode = Generate 2FA auth codes"
}
