#!/usr/bin/env bash

################################################################################
#                                                                              #
#    2FA-Auth // Generating '2FA' codes in your terminal                       #
#    Copyright (C) 2019  Vinicius de Alencar                                   #
#                                                                              #
#    This program is free software: you can redistribute it and/or modify      #
#    it under the terms of the GNU General Public License as published by      #
#    the Free Software Foundation, either version 3 of the License, or         #
#    (at your option) any later version.                                       #
#                                                                              #
#    This program is distributed in the hope that it will be useful,           #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of            #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
#    GNU General Public License for more details.                              #
#                                                                              #
#    You should have received a copy of the GNU General Public License         #
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.    #
#                                                                              #
################################################################################

source $LibraryDir/essential.sh

function Backup () {
    function Create () {
        cd $HOME
        [[ -f $ExportFile ]] && tar --sort=name -cf $BackupFile $ProjectDir $ExportFile \
                             || tar --sort=name -cf $BackupFile $ProjectDir
        cd - &> /dev/null
    }

    function Restore () {
        tar -xf $HOME/$BackupFile -C $HOME
    }

    clear

    echo "========================="
    echo "2FA-Auth // Config backup"
    echo "========================="
    echo

    case $1 in
         Create) if [[ $( $TokenCount ) = "0" ]]; then
                     echo "FAIL! There's no token to backup!"
                 else
                     if [[ ! -f $HOME/$BackupFile ]]; then
                         echo "Saving your config in '$HOME/$BackupFile'..."
                         Create && echo "SUCCESS! Backup file created with your config!" \
                                || echo "FAIL! Something wrong happened while trying to backup!"
                     else
                         Overwrite "Would you like to overwrite the backup file?" \
                                   Create \
                                   "Backup file created with your config!" \
                                   "Something wrong happened while trying to backup your files!" \
                                   "Okay! Keeping your 'old' backup file!"
                     fi
                 fi ;;

        Restore) echo "Restoring your config from '$HOME/$BackupFile'..."
                 if [[ -f $HOME/$BackupFile ]]; then
                     echo
                     echo "Restoring your configuration files, MAYBE you can replace a working"
                     echo "token by a previous one which isn't working anymore. It's up to you"
                     echo "to decide: keep the 'old' config or restore/overwrite your files?"
                     echo

                     Overwrite "Would you like to continue and overwrite your config?" \
                               Restore \
                               "Configuration restored! Restart 2FA-Auth!" \
                               "Something wrong happened while trying to restore your files!" \
                               "Okay! Keeping your 'old' configuration!"
                 else
                     echo "FAIL! No backup file found to restore your config!"
                 fi ;;
    esac
}
