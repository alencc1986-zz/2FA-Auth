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

function DecryptToken () {
    $GPG --quiet --local-user $KeyID --recipient $UserID --decrypt $TokenFile
}

function EncryptToken () {
    $GPG --quiet --local-user $KeyID --recipient $UserID --yes --output $TokenFile --encrypt $TokenFileTXT
}

function TokenAdd () {
    function Add () {
        InputData "Insert (type or copy-paste) 2FA token for '$Service' (type 'C' to [C]ANCEL):"

        if [[ $( echo ${Input,,} ) = "c" ]]; then
            echo "Canceling..."
        else
            Token="$Input"

            [[ -f $TokenFile ]] && DecryptToken > $TempFile
            echo "$Service|$Token" >> $TempFile && \
            sort $TempFile > $TokenFileTXT

            EncryptToken && \
                echo "SUCCESS! '$Service' has been included using the token '$Token'" || \
                echo "ERROR! Something wrong happened while importing the '$Service' token!"

            rm -rf $TempFile $TokenFileTXT
        fi
    }

    clear
    echo "========================="
    echo "2FA-Auth // Add new token"
    echo "========================="
    echo
    echo "Dots, spaces and uppercase letters in the service name will"
    echo "to be replaced using underlines and lowercase letter. For"
    echo "example: '2FA.Auth Code' >>> '2fa_auth_code'"
    echo
    InputData "Type the service name you want to add (type 'C' to [C]ANCEL):"

    if [[ $( echo ${Input,,} ) = "c" ]]; then
        echo "Canceling..."
    else
        Service=$( echo ${Input,,} | sed "s| \+|_|g; s|\.\+|_|g" )

        if [[ ! -f $TokenFile ]]; then
            Add
        elif [[ $( DecryptToken | grep $Service ) ]]; then
            echo
            echo "ATTENTION! '$Service' was included already!"
            echo "[TIP] Try to use an alternative name for this service."
            echo "[RECOMMENDATION] You can use \"servicename_username\"."
        else
            Add
        fi
    fi
}

function TokenDel () {
    function Remove () {
        DecryptToken | sed "/$Service/d" > $TokenFileTXT && \
        { [[ $( cat $TokenFileTXT | wc -l ) > "0" ]] && EncryptToken || rm -rf $TokenFile ; } && \
        rm -rf $TokenFileTXT
    }

    clear
    echo "========================"
    echo "2FA-Auth // Delete token"
    echo "========================"
    echo

    if [[ ! -f $TokenFile ]]; then
        echo "ATTENTION! There are no services to be excluded!"
    else
        echo "Select a service to be deleted (type 'A' to delete [A]LL or 'C' to [C]ANCEL):"
        echo

        declare -a Array
        Array=( $( DecryptToken | cut -d"|" -f1 ) )
        Counter=
        Limit=$( DecryptToken | wc -l )

        for Number in $( seq 1 1 $Limit ); do
            let Index=$Number-1
            echo "[$Number] ${Array[$Index]}"
            [[ $Number = ${#Array[*]} ]] && Counter=$Counter$Number || Counter=$Counter$Number"|"
        done

        Counter="+($Counter)"

        echo
        read -p "Option: " -e -n$( echo ${#Array[*]} | wc -L ) CaseOption
        CaseOption=${CaseOption,,}

        shopt -s extglob
        case $CaseOption in
            $Counter) Index=$CaseOption-1
                      Service=${Array[$Index]}
                      ConfirmAction "Are you sure you want to delete '$Service' token?" \
                                    Remove \
                                    "'$Service' token deleted!" \
                                    "It wasn't possible to delete '$Service' token!" \
                                    "Keeping '$Service' token in your profile." ;;

                   a) ConfirmAction "Are you sure you want to delete ALL tokens?" \
                                    "rm -rf $TokenFile" \
                                    "All tokens were deleted!" \
                                    "It wasn't possible to delete your tokens!" \
                                    "Keeping all tokens in your profiles." ;;

                   c) echo "Canceling..." ;;
                   *) echo "Invalid option!" ;;
        esac
        shopt -u extglob
    fi
}

function TokenList () {
    clear
    echo "======================"
    echo "2FA-Auth // List token"
    echo "======================"
    echo

    if [[ ! -f $TokenFile ]]; then
        echo "ATTENTION! Nothing to be listed!"
    else
        echo "Listing all available services:"
        echo

        Counter=1
        DecryptToken | cut -d"|" -f1 | while read Line; do
            echo "[$Counter] $Line"
            let Counter+=1
        done
    fi
}

function TokenExport () {
    function ExportToFile () {
        cat /dev/null > $TempFile

        LineNumber=1

        DecryptToken | while read Line; do
            echo "[$LineNumber]|$Line" >> $TempFile
            let LineNumber+=1
        done && \
        column -t -s \| $TempFile > $HOME/$ExportFile
    }

    clear
    echo "========================"
    echo "2FA-Auth // Export token"
    echo "========================"
    echo

    if [[ ! -f $TokenFile ]]; then
        echo "ATTENTION! There's no token to export!"
    else
        echo "Exporting your tokens! Please, wait..."
        echo

        if [[ -f $HOME/$ExportFile ]]; then
            echo "A file with exported tokens was found at your HOME dir!"
            Overwrite "Would you like to overwrite it?" \
                      ExportToFile \
                      "Your tokens were exported to $ExportFile!" \
                      "It wasn't possible to export your tokens and overwrite $ExportFile!" \
                      "Keeping your file with 'old' tokens."
        else
            ConfirmAction "Do you want to proceed and export your tokens?" \
                          ExportToFile \
                          "Tokens exported to $ExportFile!" \
                          "It wasn't possible to export your tokens!" \
                          "Skipping this action!"
        fi

        [[ -f $TempFile ]] && rm -rf $TempFile
    fi
}

function TokenGenerate () {
    clear
    echo "=============================="
    echo "2FA-Auth // Generate 2FA codes"
    echo "=============================="
    echo

    if [[ ! -f $TokenFile ]]; then
        echo "ATTENTION! No tokens available!"
        echo "It's impossible to generate your 2FA codes!"
    else
        declare -a Array2FACode
        declare -a ArrayService

        KeyPressed=""
        Limit=$( DecryptToken | wc -l )
        SAVED_STTY="`stty --save`"

        let CursorEndPosition=$( DecryptToken | wc -l )+7

        echo "Generating 2FA codes for all available services! Please, wait..."
        echo "These codes are updated every 60 seconds."
        echo

        while [ "$KeyPressed" = "" ]; do
            tput civis

            Index=0
            DecryptToken | while read Line; do
                let Number=$Index+1

                ArrayService[$Index]=$( echo $Line | cut -d"|" -f1 )
                Token=$( echo $Line | cut -d"|" -f2 )
                Array2FACode[$Index]=$( $OATHTOOL --base32 --totp "$Token" )

                echo "[$Number]|${ArrayService[$Index]}|${Array2FACode[$Index]}"

                let Index+=1
            done | column -t -s \|

            echo
            read -p "Press 'S' to stop... " -s -n1 -t1 KeyPressed

            [[ ${KeyPressed,,} != "s" ]] && KeyPressed=

            tput cup 7 0
        done

        tput cup $CursorEndPosition 0
        tput cnorm
        tput ed

        stty $SAVED_STTY
    fi
}

function Token () {
    clear

    case $1 in
             Add) TokenAdd ;;
             Del) TokenDel ;;
            List) TokenList ;;
          Export) TokenExport ;;
        Generate) TokenGenerate ;;
    esac
}
