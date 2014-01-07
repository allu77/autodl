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
    CoreCommand=/path/to/autodl/bin/handle-download "%FILE"
    GUIEnabled=0
    GUICommand=

## handle-finished-transmission ##

`handle-finished-transmission`

As of release 2.52, you can configure Transmission to execute a script when a download is complete. However, the
script is executed as soon as the download is finished and doesn't take into account the fact that you configured
a seeding ratio in order to keep seeding the file for some time. This script will look for **really** finished
downloads in the `trasmission-remote`. For every finished download found, the torrent will be removed from Transmission
and then `handle-download` is executed for the downloaded file(s). If the scripts finds any seeding torrent, no 
action will be taken on that torrent, but the script will re-schedule its execution in 10 minutes, in order to wait for 
seeding to finish. Once there will be no more seeding torrents, the script won't re-schedule anymore.

This script is not meant to be used via CLI, although it will work anyway. You can configure Transmission to execute
the script when downloads are finished by editing the two following parameters in `/etc/transmission/settings.json`

    "script-torrent-done-enabled": true, 
    "script-torrent-done-filename": "/path/to/autodl/bin/handle-finished-transmission", 
    
## monitor-download ##

`monitor-download`

This script monitors aMule and Transmission and limits concurrent downloads to limits configured in 
`/etc/autodl/autodl.conf`.

## download-sleep ##

`download-sleep [-s seconds]`

Running this script will cause `monitor-download` to stop all active downloads for a sleep time (as configured
in `/etc/autodl/autodl.conf`). You can change add further sleep time by specifing -s option.

## add-amule-downloads and add-torrent-downloads ##
`add-amule-downloads`
`add-torrent-downloads`

This two script execute a configured command to get new amule or torrent links. If a new link is found,
it is added to aMule or Trasmission download queue. `monitor-download` is then added to crontab.
