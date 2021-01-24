#!/usr/bin/env bash

function TokenDecrypt () {
    ${GPG} --quiet --recipient ${UserID} --decrypt ${TokenFile}
}

function TokenEncrypt () {
    ${GPG} --quiet --recipient ${UserID} --yes --output ${TokenFile} --encrypt ${TokenFileTXT}
}

function TokenAdd () {
    function Add () {
        InputData "Insert 2FA token for '${Service}' (press 'C' to [C]ANCEL):"

        if [[ $( echo ${Input,,} ) = "c" ]]; then
            echo "Canceling..."
        else
            Token="${Input}"

            [[ -f ${TokenFile} ]] && TokenDecrypt > ${TempFile}

            echo "${Service}|${Token}" >> ${TempFile} && \
            sort ${TempFile} > ${TokenFileTXT}

            TokenEncrypt && \
                echo "SUCCESS! '${Service}' has been included using the token '${Token}'" || \
                echo "ERROR! Something wrong happened while importing the '${Service}' token!"

            rm -rf ${TempFile} ${TokenFileTXT}
        fi
    }

    clear
    echo "================================"
    echo "2FA-Auth ${VERSION} // Add new token"
    echo "================================"
    echo
    echo "Dots, spaces and uppercase letters in the service name will be"
    echo "replaced by underlines and lowercase letter."
    echo "For example: '2FA.Auth Code' >>> '2fa_auth_code'"
    echo

    InputData "Type the service name you want to add (press 'C' to [C]ANCEL):"

    if [[ $( echo ${Input,,} ) = "c" ]]; then
        echo "Canceling..."
    else
        Service=$( echo ${Input,,} | sed "s| \+|_|g; s|\.\+|_|g" )

        if [[ ! -f ${TokenFile} ]]; then
            Add
        elif [[ $( TokenDecrypt | grep ${Service} ) ]]; then
            echo
            echo "ATTENTION! '${Service}' was included already!"
            echo "[TIP] Try to use an alternative name for this service."
            echo "[RECOMMENDATION] You can use \"servicename_username\"."
        else
            Add
        fi
    fi
}

function TokenDel () {
    function Remove () {
        TokenDecrypt | sed "/${Service}/d" > ${TokenFileTXT} && \
            { [[ $( cat ${TokenFileTXT} | wc -l ) > "0" ]] && TokenEncrypt || rm -rf ${TokenFile} ; }

        rm -rf ${TokenFileTXT}
    }

    clear
    echo "==============================="
    echo "2FA-Auth ${VERSION} // Delete token"
    echo "==============================="
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! There are no services to be excluded!"
    else
        echo "Select a service to be deleted (press 'A' to delete [A]LL or 'C' to [C]ANCEL):"
        echo

        declare -a Array
        Array=( $( TokenDecrypt | cut -d"|" -f1 ) )
        Counter=
        Limit=$( TokenDecrypt | wc -l )

        for Number in $( seq 1 1 ${Limit} ); do
            let Index=${Number}-1
            echo "[${Number}] ${Array[${Index}]}"
            [[ ${Number} = ${#Array[*]} ]] && Counter=${Counter}${Number} || Counter=${Counter}${Number}"|"
        done

        Counter="+(${Counter})"

        echo
        read -p "Option: " -e -n$( echo ${#Array[*]} | wc -L ) CaseOption
        CaseOption=${CaseOption,,}

        shopt -s extglob
        case ${CaseOption} in
            ${Counter}) Index=${CaseOption}-1
                        Service=${Array[${Index}]}
                        ConfirmAction "Are you sure you want to delete '${Service}' token?" \
                                      Remove \
                                      "'${Service}' token deleted!" \
                                      "It wasn't possible to delete '${Service}' token!" \
                                      "Keeping '${Service}' token in your profile." ;;

                     a) ConfirmAction "Are you sure you want to delete ALL tokens?" \
                                      "rm -rf ${TokenFile}" \
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
    echo "============================="
    echo "2FA-Auth ${VERSION} // List token"
    echo "============================="
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! Nothing to be listed!"
    else
        echo "Listing services:"
        echo

        Counter=1
        TokenDecrypt | cut -d"|" -f1 | while read Line; do
            echo "[$Counter] ${Line}"
            let Counter+=1
        done
    fi
}

function TokenRename () {
    clear
    echo "==============================="
    echo "2FA-Auth ${VERSION} // Rename token"
    echo "==============================="
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! There is nothing to be renamed!"
    else
        echo "Listing services:"
        echo

        declare -a Array
        Array=( $( TokenDecrypt | cut -d"|" -f1 ) )
        Counter=
        Limit=$( TokenDecrypt | wc -l )

        for Number in $( seq 1 1 ${Limit} ); do
            let Index=${Number}-1
            echo "[${Number}] ${Array[${Index}]}"
            [[ ${Number} = ${#Array[*]} ]] && Counter=${Counter}${Number} || Counter=${Counter}${Number}"|"
        done

        Counter="+(${Counter})"

        echo
        read -p "Which service do you want to rename? (press 'C' to [C]ANCEL) " -e -n$( echo ${#Array[*]} | wc -L ) CaseOption
        CaseOption=${CaseOption,,}

        shopt -s extglob
        case ${CaseOption} in
            ${Counter}) Index=${CaseOption}-1
                        Service=${Array[${Index}]}

                        echo "You selected: ${Service}"
                        echo

                        InputData "Type the new name for this service (press 'C' to [C]ANCEL):"

                        case ${Input,,} in
                            c|cancel) echo "Canceling..." ;;

                                   *) echo "Renaming \"${Service}\"..."
                                      NewService=$( echo ${Input,,} | sed "s| \+|_|g; s|\.\+|_|g" )

                                      TokenDecrypt > ${TokenFileTXT} && \
                                      grep -v "${Service}" ${TokenFileTXT} > ${TempFile} && \
                                      grep -i "${Service}" ${TokenFileTXT} | sed "s|^${Service}\||${NewService}\||g" >> ${TempFile} && \
                                      sort ${TempFile} > ${TokenFileTXT} &&\
                                      TokenEncrypt && \
                                      echo "Service \"${Service}\" was renamed as \"${NewService}\"!" || echo "ERROR! Something wrong happened while renaming \"${Service}\"!"

                                      rm -rf ${TokenFileTXT} ${TempFile} ;;
                        esac ;;

                     c) echo "Canceling..." ;;

                     *) echo "Invalid option..." ;;
        esac
        shopt -u extglob
    fi
}

function TokenExport () {
    function ExportToFile () {
        cat /dev/null > ${TempFile}

        LineNumber=1

        TokenDecrypt | while read Line; do
            echo "[${LineNumber}]|${Line}" >> ${TempFile}
            let LineNumber+=1
        done && \
        column -t -s \| ${TempFile} > $HOME/${ExportFile}
    }

    clear
    echo "==============================="
    echo "2FA-Auth ${VERSION} // Export token"
    echo "==============================="
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! There's no token to export!"
    else
        echo "Exporting your tokens! Please, wait..."
        echo

        if [[ -f $HOME/${ExportFile} ]]; then
            echo "A file with exported tokens was found at your HOME dir!"
            Overwrite "Would you like to overwrite it?" \
                      ExportToFile \
                      "Your tokens were exported to ${ExportFile}!" \
                      "It wasn't possible to export your tokens and overwrite ${ExportFile}!" \
                      "Keeping your file with 'old' tokens."
        else
            ConfirmAction "Do you want to proceed and export your tokens?" \
                          ExportToFile \
                          "Tokens exported to ${ExportFile}!" \
                          "It wasn't possible to export your tokens!" \
                          "Skipping this action!"
        fi

        [[ -f ${TempFile} ]] && rm -rf ${TempFile}
    fi
}

function TokenGenerate () {
    clear
    echo "====================================="
    echo "2FA-Auth ${VERSION} // Generate 2FA codes"
    echo "====================================="
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! No tokens available!"
        echo "It's impossible to generate your 2FA codes!"
    else
        declare -a Array2FACode
        declare -a ArrayService

        KeyPressed=""
        Limit=$( TokenDecrypt | wc -l )
        SAVED_STTY="`stty --save`"

        let CursorEndPosition=$( TokenDecrypt | wc -l )+7

        echo "Generating 2FA codes for all available services..."
        echo "(( These codes are updated every 60 seconds. ))"
        echo

        while [ "${KeyPressed}" = "" ]; do
            tput civis

            Index=0
            TokenDecrypt | while read Line; do
                let Number=${Index}+1

                ArrayService[${Index}]=$( echo ${Line} | cut -d"|" -f1 )
                Token=$( echo ${Line} | cut -d"|" -f2 )
                Array2FACode[${Index}]=$( ${OATHTOOL} --base32 --totp "${Token}" )

                echo "[${Number}]|${ArrayService[${Index}]}|${Array2FACode[${Index}]}"

                let Index+=1
            done | column -t -s \|

            echo
            read -p "Press 'S' to stop... " -s -n1 -t1 KeyPressed

            [[ ${KeyPressed,,} != "s" ]] && KeyPressed=

            tput cup 7 0
        done

        tput cup ${CursorEndPosition} 0
        tput cnorm
        tput ed

        stty ${SAVED_STTY}
    fi
}

function Token () {
    clear

    case $1 in
             Add) TokenAdd ;;
             Del) TokenDel ;;
          Export) TokenExport ;;
        Generate) TokenGenerate ;;
            List) TokenList ;;
          Rename) TokenRename ;;
    esac
}
