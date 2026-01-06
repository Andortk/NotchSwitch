import SwiftUI

struct NotchButton: View {
    let icon: String
    let label: String
    var color: Color = .white
    var isMediaButton: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        isHovering
                            ? color.opacity(0.2)
                            : Color.white.opacity(0.06)
                    )
                    .frame(width: 40, height: 40)
                
                Circle()
                    .strokeBorder(
                        isHovering ? color.opacity(0.4) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isHovering ? color : .white.opacity(0.85))
            }
            .scaleEffect(isPressed ? 0.9 : (isHovering ? 1.05 : 1.0))
            
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(isHovering ? color.opacity(0.9) : .white.opacity(0.5))
                .lineLimit(1)
        }
        .frame(width: 56)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            HapticFeedback.perform()
            action()
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isHovering = hovering
            }
        }
    }
}

enum HapticFeedback {
    static func perform() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            .alignment,
            performanceTime: .default
        )
    }
}
