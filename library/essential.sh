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

function ConfirmAction () {
    Message="$1"
    Action="$2"
    Success="SUCCESS! $3"
    Fail="FAIL! $4"
    NoChange="$5"

    read -p "$Message [y/N] " -e -n1 Confirm
    [[ -z "$Confirm" ]] && Confirm="n" || Confirm=${Confirm,,}

    case $Confirm in
        y) $Action && echo "$Success" || echo "$Fail" ;;
        n) echo "$NoChange" ;;
        *) echo "Invalid option!" ;;
    esac
}

function InputData () {
    Message="$1"
    Input=

    read -p "$Message " -e Input
    if [[ -z $Input ]]; then
        echo "ATTENTION!!! You *MUST* type something!!!"
        InputData "$Message"
    fi
}

function Overwrite () {
    Message="$1"
    Action="$2"
    MsgSuccess="SUCCESS! $3"
    MsgFail="FAIL! $4"
    MsgKeep="$5"

    read -p "$Message [y/N] " -e -n1 OverwriteAnswer
    [[ -z "$OverwriteAnswer" ]] && OverwriteAnswer="n" || OverwriteAnswer=${OverwriteAnswer,,}

    case $OverwriteAnswer in
        y) $Action && echo "$MsgSuccess" || echo "$MsgFail" ;;
        n) echo "$MsgKeep" ;;
        *) echo "Invalid option!" ;;
    esac
}

function PressAnyKey () {
    echo
    read -p "Press any key to continue... " -e -n1
}
