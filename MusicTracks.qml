/*
 * Copyright (C) 2013 Victor Thompson <victor.thompson@gmail.com>
 *                    Daniel Holm <d.holmen@gmail.com>
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
import org.nemomobile.folderlistmodel 1.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import "settings.js" as Settings
import "meta-database.js" as Library
import "playing-list.js" as PlayingList
import "playlists.js" as Playlists


PageStack {
    id: pageStack
    anchors.fill: parent

    property int filelistCurrentIndex: 0
    property int filelistCount: 0

    onFilelistCurrentIndexChanged: {
        tracklist.currentIndex = filelistCurrentIndex
    }

    Page {
        id: mainpage

        tools: ToolbarItems {
            // Settings dialog
            ToolbarButton {
                objectName: "settingsaction"
                iconSource: Qt.resolvedUrl("images/settings.png")
                text: i18n.tr("Settings")

                onTriggered: {
                    console.debug('Debug: Show settings')
                    PopupUtils.open(Qt.resolvedUrl("MusicSettings.qml"), mainView,
                                    {
                                        title: i18n.tr("Settings")
                                    } )
                }
            }

            // Queue dialog
            ToolbarButton {
                objectName: "queuesaction"
                iconSource: Qt.resolvedUrl("images/folder.png") // change this icon later
                text: i18n.tr("Queue")

                onTriggered: {
                    console.debug('Debug: Show queue')
                    PopupUtils.open(Qt.resolvedUrl("QueueDialog.qml"), mainView,
                                    {
                                        title: i18n.tr("Queue")
                                    } )
                }
            }
        }

        title: i18n.tr("Music")
        Component.onCompleted: {
            pageStack.push(mainpage)
        }

        Component {
            id: highlight
            Rectangle {
                width: 5; height: 40
                color: "#DD4814";
                Behavior on y {
                    SpringAnimation {
                        spring: 3
                        damping: 0.2
                    }
                }
            }
        }

        // Popover for tracks, queue and add to playlist, for example
        Component {
            id: trackPopoverComponent
            Popover {
                id: trackPopover
                Column {
                    id: containerLayout
                    anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                    ListItem.Standard {
                        text: i18n.tr("Queue")
                        onClicked: {
                            console.debug("Debug: Queue track: "+chosenTitle)
                            PopupUtils.close(trackPopover)
                            trackQueue.append({"title": chosenTitle, "artist": chosenArtist, "file": chosenTrack})
                        }
                    }
                    ListItem.Standard {
                        text: i18n.tr("Add to playlist")
                        onClicked: {
                            console.debug("Debug: Add track to playlist")
                            PopupUtils.close(trackPopover)
                            PopupUtils.open(addtoPlaylistDialog, mainView)
                        }
                    }
                }
            }
        }

        // Edit name of playlist dialog
        Component {
             id: addtoPlaylistDialog
             Dialog {
                 id: dialogueAddToPlaylist
                 title: i18n.tr("Add to Playlist")
                 text: i18n.tr("Which playlist do you want to add the track to?")

                 ListView {
                     id: addtoPlaylistView
                     model: playlistModel
                     delegate: ListItem.Standard {
                             text: name
                             onClicked: {
                                 console.debug("Debug: Clicked: "+name)
                             }
                     }
                 }

                 Button {
                     text: i18n.tr("Cancel")
                     color: "grey"
                     onClicked: PopupUtils.close(dialogueAddToPlaylist)
                 }
             }
        }

        ListView {
            id: tracklist
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gu(8)
            highlight: highlight
            highlightFollowsCurrentItem: true
            model: libraryModel.model
            delegate: trackDelegate
            onCountChanged: {
                console.log("onCountChanged: " + tracklist.count)
                filelistCount = tracklist.count
            }
            onCurrentIndexChanged: {
                filelistCurrentIndex = tracklist.currentIndex
                console.log("tracklist.currentIndex = " + tracklist.currentIndex)
            }
            onModelChanged: {
                console.log("PlayingList cleared")
                PlayingList.clear()
            }

            Component {
                id: trackDelegate
                ListItem.Standard {
                    id: track
                    property string artist: model.artist
                    property string album: model.album
                    property string title: model.title
                    property string cover: model.cover
                    property string length: model.length
                    property string file: model.file
                    icon: track.cover === "" ? (track.file.match("\\.mp3") ? Qt.resolvedUrl("images/audio-x-mpeg.png") : Qt.resolvedUrl("images/audio-x-vorbis+ogg.png")) : "image://cover-art/"+file
                    iconFrame: false
                    Label {
                        id: trackTitle
                        width: 400
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                        font.pixelSize: 16
                        anchors.left: parent.left
                        anchors.leftMargin: 75
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        text: track.title == "" ? track.file : track.title
                    }
                    Label {
                        id: trackArtistAlbum
                        width: 400
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        font.pixelSize: 12
                        anchors.left: parent.left
                        anchors.leftMargin: 75
                        anchors.top: trackTitle.bottom
                        text: artist == "" ? "" : artist + " - " + album
                    }
                    Label {
                        id: trackDuration
                        width: 400
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        font.pixelSize: 12
                        anchors.left: parent.left
                        anchors.leftMargin: 75
                        anchors.top: trackArtistAlbum.bottom
                        visible: false
                        text: ""
                    }

                    onFocusChanged: {
                        if (focus == false) {
                            selected = false
                        } else {
                            selected = false
                            mainView.currentArtist = artist
                            mainView.currentAlbum = album
                            mainView.currentTracktitle = title
                            mainView.currentFile = file
                            mainView.currentCover = cover
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                        }
                        onPressAndHold: {
                            PopupUtils.open(trackPopoverComponent, mainView)
                            chosenArtist = artist
                            chosenTitle = title
                            chosenTrack = file
                        }
                        onClicked: {
                            if (focus == false) {
                                focus = true
                            }
                            console.log("fileName: " + file)
                            if (tracklist.currentIndex == index) {
                                if (player.playbackState === MediaPlayer.PlayingState)  {
                                    player.pause()
                                } else if (player.playbackState === MediaPlayer.PausedState) {
                                    player.play()
                                }
                            } else {
                                player.stop()
                                player.source = Qt.resolvedUrl(file)
                                tracklist.currentIndex = index
                                playing = PlayingList.indexOf(file)
                                console.log("Playing click: "+player.source)
                                console.log("Index: " + tracklist.currentIndex)
                                player.play()
                            }
                            console.log("Source: " + player.source.toString())
                            console.log("Length: " + length.toString())
                        }
                    }
                    Component.onCompleted: {
                        if (PlayingList.size() === 0) {
                            player.source = file
                        }

                        if (!PlayingList.contains(file)) {
                            console.log("Adding file:" + file)
                            PlayingList.addItem(file, itemnum)
                            console.log(itemnum)
                        }
                        console.log("Title:" + title + " Artist: " + artist)
                        itemnum++
                    }
                }
            }
        }
    }
}
