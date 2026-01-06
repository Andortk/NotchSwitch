import Foundation
import AppKit

enum BrowserTabSwitcher {
    enum Browser: String, CaseIterable {
        case chrome = "com.google.Chrome"
        case safari = "com.apple.Safari"
        case arc = "company.thebrowser.Browser"
        case brave = "com.brave.Browser"
        case firefox = "org.mozilla.firefox"
        case vivaldi = "com.vivaldi.Vivaldi"
        case edge = "com.microsoft.edgemac"
        case opera = "com.operasoftware.Opera"
        
        var bundleIdentifier: String { rawValue }
        
        var displayName: String {
            switch self {
            case .chrome: return "Google Chrome"
            case .safari: return "Safari"
            case .arc: return "Arc"
            case .brave: return "Brave Browser"
            case .firefox: return "Firefox"
            case .vivaldi: return "Vivaldi"
            case .edge: return "Microsoft Edge"
            case .opera: return "Opera"
            }
        }
        
        var isChromiumBased: Bool {
            switch self {
            case .chrome, .brave, .vivaldi, .edge, .opera, .arc:
                return true
            case .safari, .firefox:
                return false
            }
        }
    }
    
    static func switchToTab(containing urlSubstring: String) {
        let defaultBrowser = getDefaultBrowser()
        
        if let browser = defaultBrowser, isRunning(bundleId: browser.bundleIdentifier) {
            if switchTab(in: browser, containing: urlSubstring) {
                return
            }
        }
        
        for browser in Browser.allCases {
            if browser == defaultBrowser { continue }
            if isRunning(bundleId: browser.bundleIdentifier) {
                if switchTab(in: browser, containing: urlSubstring) {
                    return
                }
            }
        }
        
        if isFullURL(urlSubstring) {
            openURLInNewTab(urlSubstring)
        } else {
            showTabNotFoundAlert(urlSubstring: urlSubstring)
        }
    }
    
    private static func isFullURL(_ string: String) -> Bool {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return true
        }
        
        let domainPattern = #"^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+(/.*)?$"#
        if let regex = try? NSRegularExpression(pattern: domainPattern),
           regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
            return true
        }
        
        return false
    }
    
    private static func openURLInNewTab(_ urlString: String) {
        var urlToOpen = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlToOpen.hasPrefix("http://") && !urlToOpen.hasPrefix("https://") {
            urlToOpen = "https://" + urlToOpen
        }
        
        guard let url = URL(string: urlToOpen) else {
            showTabNotFoundAlert(urlSubstring: urlString)
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    private static func getDefaultBrowser() -> Browser? {
        guard let defaultBrowserURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://")!) else {
            return nil
        }
        
        let bundleId = Bundle(url: defaultBrowserURL)?.bundleIdentifier ?? ""
        return Browser.allCases.first { $0.bundleIdentifier == bundleId }
    }
    
    private static func isRunning(bundleId: String) -> Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).isEmpty
    }
    
    private static func switchTab(in browser: Browser, containing urlSubstring: String) -> Bool {
        if browser.isChromiumBased {
            return switchTabInChromium(browser: browser, urlSubstring: urlSubstring)
        }
        
        switch browser {
        case .safari:
            return switchTabInSafari(urlSubstring: urlSubstring)
        case .firefox:
            return switchTabInFirefox(urlSubstring: urlSubstring)
        default:
            return switchTabInChromium(browser: browser, urlSubstring: urlSubstring)
        }
    }
    
    private static func switchTabInChromium(browser: Browser, urlSubstring: String) -> Bool {
        let script = """
        tell application "\(browser.displayName)"
            activate
            set foundTab to false
            set windowCount to count of windows
            repeat with windowIndex from 1 to windowCount
                set w to window windowIndex
                set tabCount to count of tabs of w
                repeat with tabIndex from 1 to tabCount
                    set t to tab tabIndex of w
                    set tabURL to URL of t
                    if tabURL contains "\(urlSubstring)" then
                        set active tab index of w to tabIndex
                        set index of w to 1
                        set foundTab to true
                        return true
                    end if
                end repeat
            end repeat
            return foundTab
        end tell
        """
        
        return executeAppleScript(script, browser: browser.displayName)
    }
    
    private static func switchTabInSafari(urlSubstring: String) -> Bool {
        let script = """
        tell application "Safari"
            activate
            set foundTab to false
            set windowCount to count of windows
            repeat with windowIndex from 1 to windowCount
                set w to window windowIndex
                set tabCount to count of tabs of w
                repeat with tabIndex from 1 to tabCount
                    set t to tab tabIndex of w
                    set tabURL to URL of t
                    if tabURL contains "\(urlSubstring)" then
                        set current tab of w to t
                        set index of w to 1
                        set foundTab to true
                        return true
                    end if
                end repeat
            end repeat
            return foundTab
        end tell
        """
        
        return executeAppleScript(script, browser: "Safari")
    }
    
    private static func switchTabInFirefox(urlSubstring: String) -> Bool {
        let script = """
        tell application "Firefox"
            activate
        end tell
        return true
        """
        
        return executeAppleScript(script, browser: "Firefox")
    }
    
    private static func executeAppleScript(_ source: String, browser: String) -> Bool {
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            let result = script.executeAndReturnError(&error)
            if let err = error {
                print("AppleScript error for \(browser): \(err)")
                return false
            }
            return result.booleanValue
        }
        return false
    }
    
    private static func showTabNotFoundAlert(urlSubstring: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Tab Not Found"
            alert.informativeText = "Could not find a browser tab containing '\(urlSubstring)'.\n\nMake sure:\n1. The tab is open in your browser\n2. NotchSwitch has Automation permission for your browser in System Settings > Privacy & Security > Automation"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
