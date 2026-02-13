//
//  ZedifyApp.swift
//  Zedify
//
//  Created by Alessio Faraci on 12/02/26.
//

import AppKit

@main
struct ZedifyApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let path = getCurrentFinderPath() else {
            NSApp.terminate(nil)
            return
        }

        openInZed(path: path)
        NSApp.terminate(nil)
    }

    private func getCurrentFinderPath() -> String? {
        let script = """
        tell application "Finder"
            if (count of windows) > 0 then
                return POSIX path of (target of front window as alias)
            else
                return missing value
            end if
        end tell
        """

        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        let output = appleScript?.executeAndReturnError(&error)

        if error != nil { return nil }
        return output?.stringValue
    }
    
    private func openInZed(path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Zed", path]

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus != 0 {
                showError()
            }
        } catch {
            showError()
        }
    }

    private func showError() {
        let alert = NSAlert()
        alert.messageText = "Unable to find application named 'Zed.app'"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
