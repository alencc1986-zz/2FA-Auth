# 2FA-Auth

---

![2FA](image/2FA-Auth.png "Generating 2FA login codes in your terminal")

<br>

***2FA-Auth*** is a BASH script that provides a user-friendly way to generate *"Two-Factor Authentication (2FA)"* code. It works like Google Authenticator (and similar programs), but you can use your GNU/Linux terminal, instead of cellphone with any authentication software.

For more information, look for *"Two-Factor Authentication"* in sites or forums.

<br>

**System Requirement**

* GNU/Linux distribution with BASH

* *GIT* (used to clone 2FA-Auth into your computer)

* *GnuPG* (used to keep your site/service token encrypted)

* *OATH Toolkit* (a.k.a. OATHTOOL, used to generate 2FA codes)

2FA-Auth can automatically install GnuPG and OAth Toolkit, but if it fails, please check how to install the programs above, according to your distribution.

This automatic method of package installation involves these package managers:

* APT and APT-GET for Debian-based systems
* DNF, URPMI and YUM for RedHat-based systems
* EMERGE and EQUO for Gentoo-based systems
* PACMAN for Arch-based systems
* ZYPPER for SUSE/openSUSE-based systems

The next step is that you **MUST** create (or import) *GPG Keys* in your profile. They are used by GnuPG to encrypt and decrypt your tokens.

If you don't know how to use GnuPG, feel free to read these articles at ***Reddit r/linux*** forum clicking in the links bellow.

[[Tutorial for beginners] How to install and use GnuPG on GNU/Linux](https://www.reddit.com/r/linux/comments/creb29/tutorial_for_beginners_how_to_install_and_use/)

[[Tutorial for beginners] GnuPG: how to export, import, delete and revoke your keys](https://www.reddit.com/r/linux/comments/ct7yjr/tutorial_for_beginners_gnupg_how_to_export_import/)

<br>

**PDF FILE: "2FA-Auth/doc/How_to_use_2FA-Auth.pdf"**

This file explain how to use 2FA-Auth.

It's a simple "how to use" manual, but it helps you A LOT!

<br>

**Where does 2FA-Auth save my tokens and GnuPG IDs?**

First things first, do **NOT** confuse *GnuPG ID* with *GnuPG Key*.

GPG key is created (or imported) into ***$HOME/.gnupg/*** while GPG IDs are parts of your key (UserID and KeyID) and 2FA-Auth asks for them. KeyID is the group of last 16 digits of your GPG key (fingerprint), while your UserID is the e-mail used to create your key.

***2FA-Auth*** saves your 2FA token(s) in this directory: ***$HOME/.config/2fa-auth/token/*** and your GnuPG IDs (UserID and KeyID) are saved in ***$HOME/.config/2fa-auth/2fa-info***

<br>

---
*Created by Vinicius de Alencar (alencc1986) - 2019 - GNU GPLv3.0*
