import Foundation
import AppKit

class MouseTracker {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private let onHoverStateChanged: (Bool) -> Void
    
    private var isInNotchArea = false
    private var isExpanded = false
    private let expandedHeight: CGFloat = 110
    private let expandedWidth: CGFloat = 350
    
    init(onHoverStateChanged: @escaping (Bool) -> Void) {
        self.onHoverStateChanged = onHoverStateChanged
    }
    
    func startTracking() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMove(event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMove(event)
            return event
        }
    }
    
    func stopTracking() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }
    
    func setExpanded(_ expanded: Bool) {
        isExpanded = expanded
    }
    
    private func handleMouseMove(_ event: NSEvent) {
        guard let screen = NSScreen.main else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame
        let screenCenterX = screenFrame.midX
        let topBound = screenFrame.maxY
        
        let notchGeometry = getNotchGeometry(screen: screen)
        
        let nowInNotchArea: Bool
        
        if isExpanded {
            let bottomBound = topBound - expandedHeight
            let isNearTop = mouseLocation.y >= bottomBound && mouseLocation.y <= topBound
            let expandedLeftBound = screenCenterX - (expandedWidth / 2)
            let expandedRightBound = screenCenterX + (expandedWidth / 2)
            let isInCenter = mouseLocation.x >= expandedLeftBound && mouseLocation.x <= expandedRightBound
            nowInNotchArea = isNearTop && isInCenter
        } else {
            let isInNotchBounds = mouseLocation.x >= notchGeometry.left &&
                                   mouseLocation.x <= notchGeometry.right &&
                                   mouseLocation.y >= notchGeometry.bottom &&
                                   mouseLocation.y <= topBound
            nowInNotchArea = isInNotchBounds
        }
        
        if nowInNotchArea != isInNotchArea {
            isInNotchArea = nowInNotchArea
            onHoverStateChanged(isInNotchArea)
        }
    }
    
    private func getNotchGeometry(screen: NSScreen) -> (left: CGFloat, right: CGFloat, bottom: CGFloat) {
        let screenFrame = screen.frame
        let screenCenterX = screenFrame.midX
        
        if let auxiliaryTopLeftArea = screen.auxiliaryTopLeftArea,
           let auxiliaryTopRightArea = screen.auxiliaryTopRightArea {
            let notchLeft = auxiliaryTopLeftArea.maxX
            let notchRight = auxiliaryTopRightArea.minX
            let notchBottom = screenFrame.maxY - auxiliaryTopLeftArea.height
            return (notchLeft, notchRight, notchBottom)
        }
        
        let fallbackNotchWidth: CGFloat = 200
        let fallbackNotchHeight: CGFloat = 34
        return (
            screenCenterX - (fallbackNotchWidth / 2),
            screenCenterX + (fallbackNotchWidth / 2),
            screenFrame.maxY - fallbackNotchHeight
        )
    }
    
    deinit {
        stopTracking()
    }
}
