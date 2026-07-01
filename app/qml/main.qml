/*******************************************************************************
* Copyright (c) 2013-2021 "Filippo Scognamiglio"
* https://github.com/Swordfish90/cool-retro-term
*
* This file is part of cool-retro-term.
*
* cool-retro-term is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/
import QtQuick 2.2

import "menus"

QtObject {
    id: appRoot

    property ApplicationSettings appSettings: ApplicationSettings {
        onInitializedSettings: appRoot.createWindow()
    }

    property TimeManager timeManager: TimeManager {
        enableTimer: windowsModel.count > 0
    }

    property SettingsWindow settingsWindow: SettingsWindow {
        visible: false
    }

    property AboutDialog aboutDialog: AboutDialog {
        visible: false
    }

    property Component windowComponent: Component {
        TerminalWindow { }
    }

    property ListModel windowsModel: ListModel { }

    // Whitelist of runtime-controllable parameters (all normalized 0.0..1.0),
    // mapping a friendly protocol name to the backing settings property.
    readonly property var controllableParams: ({
        "contrast": "contrast",
        "brightness": "brightness",
        "ambientLight": "ambientLight",
        "opacity": "windowOpacity",
        "staticNoise": "staticNoise",
        "screenCurvature": "screenCurvature",
        "glowingLine": "glowingLine",
        "burnIn": "burnIn",
        "bloom": "bloom",
        "chromaColor": "chromaColor",
        "saturationColor": "saturationColor",
        "jitter": "jitter",
        "horizontalSync": "horizontalSync",
        "flickering": "flickering",
        "rgbShift": "rgbShift",
        "frameGloss": "_frameShininess",
        "frameSize": "_frameSize",
        "screenRadius": "_screenRadius",
        "margin": "_margin"
    })

    // Handles commands from the optional --control-port TCP server. Protocol
    // (newline-terminated):
    //   set <param> <0..1>   apply live (not persisted until "save")
    //   get <param>          read current value
    //   list                 list controllable parameters
    //   save                 persist the current live state to the profile
    //   reload               reload the saved profile, discarding live changes
    property Connections controlConnection: Connections {
        target: controlServer
        function onCommandReceived(line) {
            var parts = line.split(/\s+/)
            var cmd = parts[0]
            var params = appRoot.controllableParams

            if (cmd === "list") {
                controlServer.reply(Object.keys(params).join(" "))
                return
            }

            if (cmd === "get") {
                var gprop = params[parts[1]]
                if (gprop === undefined) {
                    controlServer.reply("error unknown param " + parts[1])
                    return
                }
                controlServer.reply(parts[1] + " " + appSettings[gprop])
                return
            }

            if (cmd === "set") {
                var sprop = params[parts[1]]
                if (sprop === undefined) {
                    controlServer.reply("error unknown param " + parts[1])
                    return
                }
                var value = parseFloat(parts[2])
                if (isNaN(value)) {
                    controlServer.reply("error invalid value " + parts[2])
                    return
                }
                value = Math.max(0.0, Math.min(1.0, value))
                appSettings[sprop] = value
                controlServer.reply("ok " + parts[1] + " " + value)
                return
            }

            if (cmd === "save") {
                appSettings.storeSettings()
                controlServer.reply("ok save")
                return
            }

            if (cmd === "reload") {
                appSettings.loadSettings()
                controlServer.reply("ok reload")
                return
            }

            controlServer.reply("error unknown command " + cmd)
        }
    }

    function createWindow() {
        var window = windowComponent.createObject(null)
        if (!window)
            return

        windowsModel.append({ window: window })
        window.show()
        window.requestActivate()
    }

    function closeWindow(window) {
        for (var i = 0; i < windowsModel.count; i++) {
            if (windowsModel.get(i).window === window) {
                windowsModel.remove(i)
                break
            }
        }

        window.destroy()

        if (windowsModel.count === 0) {
            appSettings.close()
        }
    }
}
