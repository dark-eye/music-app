/*
 * Copyleft Daniel Holm.
 *
 * Authors:
 *  Daniel Holm <d.holmen@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Qt.labs.folderlistmodel 1.0
import QtMultimedia 5.0

MainView {
    objectName: i18n.tr("mainView")
    applicationName: "Music player"

    width: units.gu(50)
    height: units.gu(75)

    // VARIABLES
    property string musicName: i18n.tr("Music")
    property string musicDir: '/home/USERNAME/MUSICDIR/'
    property string trackStatus: ''
    property string appVersion: '0.3'

    // FUNCTIONS

    // play / pause function
    function onTrackStatusChange(trackStatus) {
        // when resumed signal is sent
        if (trackStatus == 'Resume') {
            console.debug('Debug: '+playTrack) // debug
            playTrack.iconSource = Qt.resolvedUrl("images/icon_pause@20.png") // change toolbar icon
            playTrack.text = i18n.tr("Pause") // change toolbar text
            trackInfo.text = playMusic.metaData.albumArtist+" - "+playMusic.metaData.title // show track meta data
            playMusic.play() // resume the plaback
        }
        // when pause signal is sent
        if (trackStatus == 'Pause') {
            console.debug('Debug: '+playTrack) // debug
            playTrack.iconSource = Qt.resolvedUrl("images/icon_play@20.png") // change toollbar icon
            playTrack.text = i18n.tr("Resume") // change toolbar text
            trackInfo.text = playMusic.metaData.albumArtist+" - "+playMusic.metaData.title // show track meta data
            playMusic.pause() // pause track
        }
        // if anything else
        else {
            console.debug('Debug: '+playTrack)
            playTrack.iconSource = Qt.resolvedUrl("images/icon_pause@20.png")
            playTrack.text = i18n.tr("Pause")
            playMusic.play()
        }

    }

    // previous and next track function

    // Queue function
    function addToQueue(songTrack) {
        console.debug("Debug: added "+songTrack+" to queue.")
    }

    // Get song title
    function getTrackInfo(source) {
        console.debug('Debug: Got it. Trying to get meta data from: '+source) // debug
        musicInfo.source = source
        musicInfo.pause()
        return musicInfo.metaData.title
    }


    // Music stuff
    Audio {
        id: playMusic
        source: ""
    }

    // get file meta data
    Audio {
        id: musicInfo
        source: ""

    ListModel {
        id: trackQueue
        ListElement {
            title: "Dancing in the Moonlight"
            artist: "Thin Lizzy"
            file: "something"
        }
        ListElement {
            title: "Rock and Roll"
            artist: "Led Zeppelin"
            file: "something else"
        }
        ListElement {
            title: "Moonlight Serenade"
            artist: "Frank Sinatra"
            file: "something completely else"
        }
    }

    Tabs {
        id: tabs
        anchors.fill: parent

        // First tab begins here - should be the primary tab
        Tab {
            objectName: "Tab1"

            title: i18n.tr("Playing")

            // Tab content begins here
            page: Page {
                id: playingPage

                // toolbar
                tools: ToolbarActions {

                    // Share
                    Action {
                        id: shareTrack
                        objectName: "share"

                        iconSource: Qt.resolvedUrl("images/icon_share@20.png")
                        text: i18n.tr("Share")

                        onTriggered: {
                            console.debug('Debug: Share pressed')
                        }
                    }

                    // prevous track
                    Action {
                        id: prevTrack
                        objectName: "prev"

                        iconSource: Qt.resolvedUrl("images/prev.png")
                        text: i18n.tr("Previous")

                        onTriggered: {
                            console.debug('Debug: Prev track pressed')
                        }
                    }

                    // Play
                    Action {
                        id: playTrack
                        objectName: "play"

                        iconSource: Qt.resolvedUrl("images/icon_play@20.png")
                        text: i18n.tr("Play")

                        onTriggered: {
                            //trackStatus: 'pause' // this changes on press
                            onTrackStatusChange(playTrack.text)
                        }
                    }

                    // Next track
                    Action {
                        id: nextTrack
                        objectName: "next"

                        iconSource: Qt.resolvedUrl("images/next.png")
                        text: i18n.tr("Next")

                        onTriggered: {
                            console.debug('Debug: next track pressed')
                        }
                    }

                    // Queue
                    Action {
                        id: trackQueueAction
                        objectName: "queuelist"
                        iconSource: Qt.resolvedUrl("images/icon_settings@20.png")
                        text: i18n.tr("Queue")
                        onTriggered: {
                            PopupUtils.open(Qt.resolvedUrl("QueueDialog.qml"), pageLayout,
                                        {
                                            title: i18n.tr("Queue")
                                        } )
                        }
                    }

                    // Settings
                    Action {
                        id: settingsAction
                        objectName: "settings"

                        iconSource: Qt.resolvedUrl("images/icon_settings@20.png")
                        text: i18n.tr("Settings")

                        onTriggered: {
                            console.debug('Debug: Settings pressed')
                            // show settings dialog
                            PopupUtils.open(Qt.resolvedUrl("MusicSettings.qml"), pageLayout,
                                        {
                                            title: i18n.tr("Settings")
                                        } )
                        }
                    }

                }

                Column {
                        id: pageLayout

                        spacing: units.gu(1)

                        Row {
                            spacing: units.gu(1)
                            // Album cover here
                            UbuntuShape {
                                id: trackCoverArt
                                width: units.gu(50)
                                height: units.gu(50)
                                gradientColor: "blue" // test
                                image: Image {
                                    source: "images/music.png"
                                }
                                /*
                                onClicked: {
                                    playMusic.pause()
                                }
                                onPressAndHold: {
                                    playMusic.stop()
                                } */
                            }
                        }

                        // track progress
                        Row {
                            width: parent.width
                            ProgressBar {
                                id: trackProgress
                                minimumValue: 0
                                maximumValue: 100
                                value: 25
                            }
                        }

                        // Track info
                        Row {
                            spacing: units.gu(1)
                            Label {
                                id: trackInfo
                                text: "Track title"
                                //subText: "Artist: + Year:"
                            }
                        }
                    }


            }
        }


        // Second tab begins here - artists here
        Tab {
            objectName: "Artists Tab"

            title: i18n.tr("Artists")
            page: Page {
                anchors.margins: units.gu(2)

            // foreach artist:
            ListItem.Standard {
                height: units.gu(4)
                // when pressed on this row, change to albums of artist
                Row {
                    Label {
                        text: i18n.tr("Artist 1")
                    }
                }
            }

                // toolbar here

            Column {
                anchors.centerIn: parent
                anchors.fill: parent
                ListView {
                    id: artistFolder
                    FolderListModel {
                        id: artistModel
                        folder: musicDir
                        nameFilters: ["//\\"];
                        showDirs: true;
                    }
                    width: parent.width
                    height: parent.height
                    model: artistModel
                    delegate: ListItem.Subtitled {
                        text: fileName
                        subText: "totatl albums: "
                        onClicked: {
                            console.debug('Debug: User pressed '+musicDir+fileName)
                        /*    playMusic.source = musicDir+dirName
                            playMusic.play()
                            trackInfo.text = playMusic.metaData.albumArtist+" - "+playMusic.metaData.title // show track meta data
                            */
                        }
                    }
                }
            }
            }
        }

        // Third tab begins here - albums here
        Tab {
            objectName: "Albums Tab"

            title: i18n.tr("Albums")
            page: Page {
                anchors.margins: units.gu(2)

                Column {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    ListView {
                        id: albumFolder
                        FolderListModel {
                            id: albumModel
                            folder: musicDir
                            nameFilters: ["//\\"];
                            showDirs: true;
                        }
                        width: parent.width
                        height: parent.height
                        model: albumModel
                        delegate: ListItem.Subtitled {
                            text: fileName
                            subText: "Year: "
                            onClicked: {
                                console.debug('Debug: User pressed '+musicDir+fileName)
                            /*    playMusic.source = musicDir+dirName
                                playMusic.play()
                                trackInfo.text = playMusic.metaData.albumArtist+" - "+playMusic.metaData.title // show track meta data
                                */
                            }
                        }
                    }
                }

                // toolbar here

                Column {
                    anchors.centerIn: parent
                }
            }
        }

        // Fourth tab - tracks in ~/Music
        Tab {
            objectName: "Tracks Tab"

            title: i18n.tr("Tracks")
            page: Page {
                anchors.margins: units.gu(2)

                // toolbar here

                Column {
                    anchors.centerIn: parent
                    anchors.fill: parent
                    ListView {
                        id: musicFolder
                        FolderListModel {
                            id: folderModel
                            folder: musicDir
                            showDirs: false
                            nameFilters: ["*.ogg","*.mp3","*.oga","*.wav"]
                        }
                        width: parent.width
                        height: parent.height
                        model: folderModel
                        delegate: ListItem.Subtitled {
                            text: fileName
                            subText: "Artist: "
                            onClicked: {
                                playMusic.source = musicDir+fileName
                                playMusic.play()
                                console.debug('Debug: User pressed '+musicDir+fileName)
                                trackInfo.text = playMusic.metaData.albumArtist+" - "+playMusic.metaData.title // show track meta data
                            }
                            onPressAndHold: {
                                console.debug('Debug: '+fileName+' added to queue.')
                                trackQueue.append({"title": playMusic.metaData.title, "artist": playMusic.metaData.albumArtist, "file": fileName})
                            }
                        }
                    }
                }
            }
        }

    } // tabs
} // main view
