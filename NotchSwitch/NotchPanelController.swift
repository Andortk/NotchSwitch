import SwiftUI
import AppKit

class NotchPanelController: NSObject {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<NotchContentView>?
    private var hideTimer: Timer?
    var viewModel = NotchViewModel()
    var onExpandedStateChanged: ((Bool) -> Void)?
    
    private let panelWidth: CGFloat = 380
    private let panelHeight: CGFloat = 140
    
    override init() {
        super.init()
        setupPanel()
    }
    
    private func setupPanel() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.frame
        let panelX = (screenFrame.width - panelWidth) / 2 + screenFrame.origin.x
        let panelY = screenFrame.maxY - panelHeight
        
        let panelFrame = NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        
        panel = NSPanel(
            contentRect: panelFrame,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        guard let panel = panel else { return }
        
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.isMovable = false
        panel.isMovableByWindowBackground = false
        panel.alphaValue = 0
        panel.acceptsMouseMovedEvents = true
        panel.becomesKeyOnlyIfNeeded = true
        
        let contentView = NotchContentView(viewModel: viewModel)
        hostingView = NSHostingView(rootView: contentView)
        hostingView?.frame = panel.contentView?.bounds ?? .zero
        hostingView?.autoresizingMask = [.width, .height]
        
        panel.contentView = hostingView
        panel.orderFrontRegardless()
    }
    
    func showPanel() {
        hideTimer?.invalidate()
        hideTimer = nil
        
        panel?.ignoresMouseEvents = false
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel?.animator().alphaValue = 1.0
        }
        
        viewModel.expand()
        onExpandedStateChanged?(true)
    }
    
    func scheduleHidePanel() {
        if viewModel.isMenuOpen {
            return
        }
        
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            self?.hidePanel()
        }
    }
    
    private func hidePanel() {
        viewModel.collapse()
        onExpandedStateChanged?(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                self?.panel?.animator().alphaValue = 0
            } completionHandler: {
                self?.panel?.ignoresMouseEvents = true
            }
        }
    }
    
    func cancelHide() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
}

class NotchViewModel: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var isPlaying: Bool = false
    @Published var isMenuOpen: Bool = false
    var onOpenSettings: (() -> Void)?
    
    private let mediaController = MediaController()
    
    var currentProfile: WorkProfile {
        AppConfiguration.shared.selectedProfile
    }
    
    init() {
        mediaController.onPlaybackStateChanged = { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.isPlaying = isPlaying
            }
        }
    }
    
    func expand() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.72, blendDuration: 0.1)) {
            isExpanded = true
        }
    }
    
    func collapse() {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
            isExpanded = false
        }
    }
    
    func executeButton(_ index: Int) {
        let config = AppConfiguration.shared
        let profile = config.selectedProfile
        let actionType = config.getButtonActionType(profile: profile, index: index)
        let target = config.getButtonTarget(profile: profile, index: index)
        
        switch actionType {
        case .terminal:
            activateOpenCode()
        case .app:
            if !target.isEmpty {
                AppSwitcher.activateApp(bundleIdentifier: target)
            }
        case .browserTab:
            if !target.isEmpty {
                BrowserTabSwitcher.switchToTab(containing: target)
            }
        }
    }
    
    func activateOpenCode() {
        let config = AppConfiguration.shared
        if config.selectedTerminal == .notSet {
            TerminalPicker.promptForTerminalSelection { terminal in
                if let terminal = terminal {
                    config.selectedTerminal = terminal
                    AppSwitcher.launchOpenCodeInTerminal(terminal)
                }
            }
        } else {
            AppSwitcher.launchOpenCodeInTerminal(config.selectedTerminal)
        }
    }
    
    func togglePlayPause() {
        mediaController.togglePlayPause()
    }
    
    func executeSelectedMultiAction() {
        let actionRaw = AppConfiguration.shared.multiFunctionAction
        guard let action = MultiAction(rawValue: actionRaw) else {
            mediaController.togglePlayPause()
            return
        }
        executeMultiAction(action)
    }
    
    func executeMultiAction(_ action: MultiAction) {
        switch action {
        case .toggleMusic:
            mediaController.togglePlayPause()
        case .nextTrack:
            mediaController.nextTrack()
        case .previousTrack:
            mediaController.previousTrack()
        case .missionControl:
            openMissionControl()
        }
    }
    
    private func openMissionControl() {
        DispatchQueue.global(qos: .userInitiated).async {
            let script = """
            tell application "System Events"
                key code 126 using {control down}
            end tell
            """
            
            var error: NSDictionary?
            if let appleScript = NSAppleScript(source: script) {
                appleScript.executeAndReturnError(&error)
            }
        }
    }
    
    func openSettings() {
        onOpenSettings?()
    }
}
