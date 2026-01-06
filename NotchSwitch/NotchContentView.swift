import SwiftUI

struct NotchContentView: View {
    @ObservedObject var viewModel: NotchViewModel
    @ObservedObject var config = AppConfiguration.shared
    @State private var isHovering = false
    @State private var isSettingsHovered = false
    @State private var isMultiButtonHovered = false
    
    private let notchWidth: CGFloat = 200
    private let notchHeight: CGFloat = 34
    private let cornerRadius: CGFloat = 22
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.isExpanded {
                    expandedIsland
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.92, anchor: .top).combined(with: .opacity),
                            removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private var expandedIsland: some View {
        VStack(spacing: 0) {
            topRow
            Spacer().frame(height: 4)
            bottomRow
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
        .frame(width: 320, height: 110)
        .background(islandBackground)
    }
    
    private var islandBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.72, blendDuration: 0.1), value: viewModel.isExpanded)
    }
    
    private var topRow: some View {
        HStack {
            settingsButton
            
            Spacer()
            
            notchSpacer
            
            Spacer()
            
            multiButton
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
    }
    
    private var settingsButton: some View {
        Button(action: viewModel.openSettings) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(isSettingsHovered ? 0.15 : 0.08))
                    .frame(width: 26, height: 26)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(isSettingsHovered ? 0.85 : 0.6))
            }
            .animation(.easeInOut(duration: 0.15), value: isSettingsHovered)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isSettingsHovered = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
    
    private var notchSpacer: some View {
        Color.clear
            .frame(width: notchWidth - 40, height: notchHeight)
    }
    
    private var multiButton: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(isMultiButtonHovered ? 0.15 : 0.08))
                .frame(width: 26, height: 26)
            
            Circle()
                .fill(Color.white.opacity(isMultiButtonHovered ? 0.85 : 0.6))
                .frame(width: 8, height: 8)
        }
        .animation(.easeInOut(duration: 0.15), value: isMultiButtonHovered)
        .contentShape(Rectangle())
        .onHover { hovering in
            isMultiButtonHovered = hovering
        }
        .onTapGesture {
            viewModel.executeSelectedMultiAction()
        }
        .onRightClick {
            DispatchQueue.main.async {
                viewModel.isMenuOpen = true
            }
        }
        .popover(isPresented: $viewModel.isMenuOpen, arrowEdge: .bottom) {
            MultiButtonMenu(
                selectedAction: config.multiFunctionAction,
                onSelect: { action in
                    DispatchQueue.main.async {
                        viewModel.isMenuOpen = false
                        config.multiFunctionAction = action.rawValue
                    }
                }
            )
        }
    }
    
    private var bottomRow: some View {
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { index in
                let buttonConfig = config.selectedProfile.buttonConfigs[index]
                let customIcon = config.getButtonIcon(profile: config.selectedProfile, index: index)
                let customLabel = config.getButtonLabel(profile: config.selectedProfile, index: index)
                NotchButton(
                    icon: customIcon,
                    label: customLabel,
                    color: colorFromString(buttonConfig.color),
                    action: { viewModel.executeButton(index) }
                )
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        default: return .white
        }
    }
}

enum MultiAction: String, CaseIterable {
    case toggleMusic
    case nextTrack
    case previousTrack
    case missionControl
    
    var displayName: String {
        switch self {
        case .toggleMusic: return "Toggle Music"
        case .nextTrack: return "Next Track"
        case .previousTrack: return "Previous Track"
        case .missionControl: return "Mission Control"
        }
    }
    
    var icon: String {
        switch self {
        case .toggleMusic: return "play.fill"
        case .nextTrack: return "forward.fill"
        case .previousTrack: return "backward.fill"
        case .missionControl: return "rectangle.3.group"
        }
    }
}

struct MultiButtonMenu: View {
    let selectedAction: String
    let onSelect: (MultiAction) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(MultiAction.allCases, id: \.rawValue) { action in
                MenuRow(
                    icon: action.icon,
                    title: action.displayName,
                    isSelected: selectedAction == action.rawValue
                ) {
                    onSelect(action)
                }
                if action != MultiAction.allCases.last {
                    Divider()
                }
            }
        }
        .frame(width: 180)
        .padding(.vertical, 4)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .frame(width: 16)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isHovered ? Color.primary.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct RightClickModifier: ViewModifier {
    let action: () -> Void
    @State private var monitor: Any?
    
    func body(content: Content) -> some View {
        content
            .background(
                RightClickDetector(action: action)
            )
    }
}

struct RightClickDetector: NSViewRepresentable {
    let action: () -> Void
    
    func makeNSView(context: Context) -> RightClickNSView {
        let view = RightClickNSView()
        view.onRightClick = action
        return view
    }
    
    func updateNSView(_ nsView: RightClickNSView, context: Context) {
        nsView.onRightClick = action
    }
}

class RightClickNSView: NSView {
    var onRightClick: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupRightClickMonitor()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRightClickMonitor()
    }
    
    private var eventMonitor: Any?
    
    private func setupRightClickMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            guard let self = self,
                  let window = self.window,
                  event.window == window else {
                return event
            }
            
            let locationInWindow = event.locationInWindow
            let locationInView = self.convert(locationInWindow, from: nil)
            
            if self.bounds.contains(locationInView) {
                self.onRightClick?()
                return nil
            }
            return event
        }
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

extension View {
    func onRightClick(perform action: @escaping () -> Void) -> some View {
        modifier(RightClickModifier(action: action))
    }
}
