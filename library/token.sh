#!/usr/bin/env bash

function TokenDecrypt () {
    ${GPG} --quiet --recipient ${UserID} --decrypt ${TokenFile}
}

function TokenEncrypt () {
    ${GPG} --quiet --recipient ${UserID} --yes --output ${TokenFile} --encrypt ${TokenFileTXT}
}

function TokenAdd () {
    function Add () {
        InputData "Insert (type or copy-paste) 2FA token for '${Service}' (type 'C' to [C]ANCEL):"

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
    echo "========================="
    echo "2FA-Auth // Add new token"
    echo "========================="
    echo
    echo "Dots, spaces and uppercase letters in the service name will be"
    echo "replaced using underlines and lowercase letter. For example:"
    echo "'2FA.Auth Code' >>> '2fa_auth_code'"
    echo

    InputData "Type the service name you want to add (type 'C' to [C]ANCEL):"

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
    echo "========================"
    echo "2FA-Auth // Delete token"
    echo "========================"
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! There are no services to be excluded!"
    else
        echo "Select a service to be deleted (type 'A' to delete [A]LL or 'C' to [C]ANCEL):"
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
    echo "======================"
    echo "2FA-Auth // List token"
    echo "======================"
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! Nothing to be listed!"
    else
        echo "Listing all available services:"
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
    echo "========================"
    echo "2FA-Auth // Rename token"
    echo "========================"
    echo

    if [[ ! -f ${TokenFile} ]]; then
        echo "ATTENTION! There is nothing to be renamed!"
    else
        echo "Listing all available services:"
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
        read -p "Which service do you want to rename? (type 'C' to [C]ANCEL) " -e -n$( echo ${#Array[*]} | wc -L ) CaseOption
        CaseOption=${CaseOption,,}

        shopt -s extglob
        case ${CaseOption} in
            ${Counter}) Index=${CaseOption}-1
                        Service=${Array[${Index}]}

                        echo "You selected: ${Service}"
                        echo
                        InputData "Type the new name for this service (type 'C' to [C]ANCEL):"

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
    echo "========================"
    echo "2FA-Auth // Export token"
    echo "========================"
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
    echo "=============================="
    echo "2FA-Auth // Generate 2FA codes"
    echo "=============================="
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

function TokenUnify () {
    if [[ -d $HOME/${ConfigDir}/token ]]; then
        if [[ $( find $HOME/${ConfigDir}/token -type f -name *.token | wc -l ) > "0" ]]; then
            echo "Gathering all 2FA tokens into one single file. Please, wait!"
            echo

            cat /dev/null > ${TempFile}

            AmountOfTokens=$( find $HOME/${ConfigDir}/token -type f -name *.token | wc -l )
            Counter=1

            for Service in $( basename -a -s .token $( find $HOME/${ConfigDir}/token -type f -name *.token | sort ) ); do
                echo -n "Processing file ${Counter} of ${AmountOfTokens} (service: ${Service})... "

                Token=$( ${GPG} --quiet --recipient ${UserID} --decrypt $HOME/${ConfigDir}/token/${Service}.token )
                if [[ $? != "0" ]]; then
                    echo "FAIL"
                    echo
                    echo "Something wrong happened!"
                    echo "Did you type your GnuPG password correctly?"

                    exit 1
                else
                    echo "${Service}|${Token}" >> ${TempFile}
                    let Counter+=1
                    echo "done!"
                fi
            done

            ${GPG} --recipient ${UserID} --yes --output ${TokenFile} --encrypt ${TempFile}
            rm -rf ${TempFile} $HOME/${ConfigDir}/token

            echo
            echo "Tokens were unified with success!"
            echo "New token file is: ${TokenFile}"

            PressAnyKey
        fi
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
           Unify) TokenUnify ;;
    esac
}
