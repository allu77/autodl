autodl
======

A set of scripts to automate aMule and Transmission

# How to install #

1. Create `/etc/autodl` folder
2. Copy content of `etc` to `/etc/autodl`
3. Copy content of `bin` to wherever suits your system configuration (e.g. `/usr/local/bin`)
4. Edit `/etc/autodl/autodl.conf` to match your needs (configuration file is not commented yet, send me an email if you need help)

# How to use #

## handle-download ##

`handle-download [FILE]...`

This script looks for rename, copy and move rules for the given FILEs and apply them. If FILE is a folder, 
the contained files will be also evaluated. If FILE is a zip or rar files, the archive contents will be extracted
to a temporary direcory and evaluated. 

You can have aMule running this script for completed files by adding the following configuration to amule.conf

    [UserEvents/DownloadCompleted]
    CoreEnabled=1
    CoreCommand=/usr/local/share/autodl/handle-download "%FILE"
    GUIEnabled=0
    GUICommand=
