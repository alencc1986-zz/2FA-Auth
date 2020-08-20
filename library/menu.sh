#!/usr/bin/env bash

function Information () {
    clear

    echo "======================="
    echo "2FA-Auth // Information"
    echo "======================="
    echo
    echo "Version............: 3.0-0"
    echo "Description........: Generating 2FA codes in your terminal"
    echo "Created by.........: Vinicius de Alencar (alencc1986)"
    echo
    echo "GnuPG User ID......: $( awk '{ print $2 }' ${InfoFile} )"
}

function MainMenu () {
    while true; do
        clear

        echo "====================="
        echo "2FA-Auth // Main menu"
        echo "====================="
        echo
        echo "----------------------------------------------"
        echo "| 2FA-Auth has 2 terminal parameters         |"
        echo "|                                            |"
        echo "| 'changekey' -- change GnuPG key/encryption |"
        echo "|                                            |"
        echo "| 'gencode'   -- generate auth codes without |"
        echo "|                use the main menu           |"
        echo "----------------------------------------------"
        echo
        echo "[1] Add new 2FA auth tokens"
        echo "[2] Delete 2FA auth tokens"
        echo "[3] List all 2FA auth tokens"
        echo "[4] Rename 2FA auth tokens"
        echo "[5] Export all 2FA auth tokens"
        echo "[6] Generate 2FA auth codes"
        echo "[7] Backup your tokens/config"
        echo "[8] Restore your tokens/config"
        echo
        echo "[C] Change GnuPG encryption key"
        echo "[I] Information"
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
            Q) break ;;
            *) echo "Invalid option!" ;;
        esac

        PressAnyKey
    done
}
