#!/usr/bin/env bash

#  2FA-Auth // Generating '2FA' codes in your terminal
#  Copyright (C) 2020  Vinicius de Alencar
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

function Backup () {
    BackupFile="2fa-config-backup.tar"

    function Create () {
        cd $HOME

        if [[ -f $ExportFile ]]; then
            echo "A file with exported tokens was found at you user's HOME!"
            InputData "Would you like to include it in your backup file? [y/N]"

            [[ -z $Input ]] && Input="n" || Input=${Input,,}
            [[ $Input = "y" ]] && tar --sort=name -cf $BackupFile $ConfigDir $ExportFile \
                               || tar --sort=name -cf $BackupFile $ConfigDir
        else
            tar --sort=name -cf $BackupFile $ConfigDir
        fi

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
         Create) if [[ ! -f $TokenFile ]]; then
                     echo "FAIL! No token file was found!"
                     echo "It isn't possible to backup your tokens!"
                 else
                     if [[ ! -f $HOME/$BackupFile ]]; then
                         echo "Saving your 2FA tokens and your 2FA-Auth config in '$HOME/$BackupFile'..."
                         Create && echo "SUCCESS! Backup file created successfully!" \
                                || echo "FAIL! Something wrong happened during the backup process!"
                     else
                         Overwrite "Would you like to overwrite the backup file?" \
                                   Create \
                                   "Backup file created (overwritten) with your tokens/config!" \
                                   "Something wrong happened when trying to backup your files!" \
                                   "Okay! Keeping your 'old' backup file!"
                     fi
                 fi ;;

        Restore) echo "Restoring your config from '$HOME/$BackupFile'..."
                 if [[ -f $HOME/$BackupFile ]]; then
                     echo
                     echo "If you restore your 2FA-Auth file with a 'old' backup file, MAYBE"
                     echo "you can replace a 2FA token that is working perfectly well by a 2FA"
                     echo "token which isn't associated anymore with your logins."
                     echo "It's up to you to decide if you want to keep the 'old' configuration"
                     echo "or restore/overwrite your files."
                     echo

                     Overwrite "Would you like to continue and overwrite your tokens/config?" \
                               Restore \
                               "Configuration restored!" \
                               "Something wrong happened while trying to restore your files!" \
                               "Okay! Keeping your 'old' files!"

                     UserID=$( grep "UserID" $InfoFile | cut -d' ' -f2- )
                     KeyID=$( grep "KeyID" $InfoFile | cut -d' ' -f2 )
                 else
                     echo "FAIL! No backup file was found to restore your tokens/config!"
                 fi ;;
    esac
}
