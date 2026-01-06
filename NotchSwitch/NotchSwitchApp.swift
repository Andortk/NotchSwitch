import SwiftUI
import AppKit

@main
struct NotchSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: NotchPanelController?
    private var mouseTracker: MouseTracker?
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        panelController = NotchPanelController()
        
        panelController?.onExpandedStateChanged = { [weak self] isExpanded in
            self?.mouseTracker?.setExpanded(isExpanded)
        }
        
        panelController?.viewModel.onOpenSettings = { [weak self] in
            self?.openSettings()
        }
        
        mouseTracker = MouseTracker { [weak self] isInNotchArea in
            self?.handleMouseHover(isInNotchArea: isInNotchArea)
        }
        mouseTracker?.startTracking()
        
        setupStatusBarItem()
        PermissionChecker.shared.checkAllPermissions()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        mouseTracker?.stopTracking()
    }
    
    private func handleMouseHover(isInNotchArea: Bool) {
        if isInNotchArea {
            panelController?.showPanel()
        } else {
            panelController?.scheduleHidePanel()
        }
    }
    
    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            if let statusBarIcon = NSImage(named: "StatusBarIcon") {
                statusBarIcon.isTemplate = true
                button.image = statusBarIcon
            } else {
                button.image = NSImage(systemSymbolName: "rectangle.topthird.inset.filled", accessibilityDescription: "NotchSwitch")
            }
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About NotchSwitch", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Check Permissions", action: #selector(checkPermissions), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "NotchSwitch"
        alert.informativeText = "Version 1.0\n\nThe Dynamic Island-style app switcher for MacBook Pro.\n\nHover over the notch to reveal your workflow shortcuts."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        
        if let appIcon = NSImage(named: "AppLogo") {
            alert.icon = appIcon
        }
        
        alert.runModal()
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.title = "NotchSwitch Settings"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func checkPermissions() {
        PermissionChecker.shared.showPermissionStatus()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
