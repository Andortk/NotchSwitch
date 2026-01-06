import Foundation
import AppKit

enum AppSwitcher {
    static func activateApp(bundleIdentifier: String) {
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            app.activate(options: [.activateIgnoringOtherApps])
        } else {
            launchApp(bundleIdentifier: bundleIdentifier)
        }
    }
    
    static func launchOpenCodeInTerminal(_ terminal: TerminalApp) {
        let bundleId = terminal == .other 
            ? AppConfiguration.shared.customTerminalBundleId 
            : terminal.rawValue
        
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first {
            app.activate(options: [.activateIgnoringOtherApps])
            return
        }
        
        launchTerminalWithOpenCode(bundleId: bundleId, terminal: terminal)
    }
    
    private static func sendOpenCodeCommandToTerminal(_ terminal: TerminalApp) {
        let script: String
        
        switch terminal {
        case .iterm2:
            script = """
            tell application "iTerm"
                activate
                tell current session of current window
                    write text "opencode"
                end tell
            end tell
            """
        case .terminal:
            script = """
            tell application "Terminal"
                activate
                do script "opencode" in front window
            end tell
            """
        default:
            return
        }
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
    }
    
    private static func launchTerminalWithOpenCode(bundleId: String, terminal: TerminalApp) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            showAppNotFoundAlert(bundleIdentifier: bundleId)
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    showLaunchError(error: error)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    sendOpenCodeCommandToTerminal(terminal)
                }
            }
        }
    }
    
    private static func launchApp(bundleIdentifier: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            showAppNotFoundAlert(bundleIdentifier: bundleIdentifier)
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    showLaunchError(error: error)
                }
            }
        }
    }
    
    private static func showAppNotFoundAlert(bundleIdentifier: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Application Not Found"
            alert.informativeText = "Could not find application with bundle identifier: \(bundleIdentifier)\n\nPlease ensure the app is installed."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private static func showLaunchError(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Launch Error"
        alert.informativeText = "Failed to launch application: \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
