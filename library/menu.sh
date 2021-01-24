#!/usr/bin/env bash

function Information () {
    clear

    echo "=============================="
    echo "2FA-Auth ${VERSION} // Information"
    echo "=============================="
    echo
    echo "Description...: Generating 2FA codes in your terminal"
    echo "Created by....: Vinicius de Alencar (alencc1986)"
    echo
    echo "Your GnuPG User ID is \"$( awk '{ print $2 }' ${InfoFile} )\""
}

function MainMenu () {
    while true; do
        clear

        echo "============================"
        echo "2FA-Auth ${VERSION} // Main menu"
        echo "============================"
        echo
        echo "[1] Add 2FA token"
        echo "[2] Delete 2FA token"
        echo "[3] List available 2FA tokens"
        echo "[4] Rename 2FA token"
        echo "[5] Export 2FA tokens"
        echo "[6] Generate authentication codes"
        echo "[7] Backup tokens and configuration"
        echo "[8] Restore tokens and configuration"
        echo
        echo "[C] Change your GnuPG key"
        echo "[I] Information about 2FA-Auth"
        echo "[U] Usage"
        echo "[Q] Quit"
        echo

        read -p "Option: " -e -n1 Option

        Option=${Option^^}

        case ${Option} in
            1) Token Add ;;
            2) Token Del ;;
            3) Token List ;;
            4) Token Rename ;;
            5) Token Export ;;
            6) Token Generate ;;
            7) Backup Create ;;
            8) Backup Restore ;;
            C) ChangeMenu ;;
            I) Information ;;
            U) Usage ;;
            Q) break ;;
            *) echo "Invalid option!" ;;
        esac

        PressAnyKey
    done
}
