import Foundation
import AppKit

class MediaController {
    var onPlaybackStateChanged: ((Bool) -> Void)?
    
    private var isCurrentlyPlaying = false
    
    private typealias MRMediaRemoteSendCommandFunction = @convention(c) (UInt32, UnsafeRawPointer?) -> Bool
    private var sendCommand: MRMediaRemoteSendCommandFunction?
    
    init() {
        loadMediaRemote()
    }
    
    private func loadMediaRemote() {
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, 
            NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else {
            return
        }
        
        guard let pointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) else {
            return
        }
        
        sendCommand = unsafeBitCast(pointer, to: MRMediaRemoteSendCommandFunction.self)
    }
    
    func togglePlayPause() {
        if let sendCommand = sendCommand {
            _ = sendCommand(kMRTogglePlayPause, nil)
        }
    }
    
    func nextTrack() {
        if let sendCommand = sendCommand {
            _ = sendCommand(kMRNextTrack, nil)
        }
    }
    
    func previousTrack() {
        if let sendCommand = sendCommand {
            _ = sendCommand(kMRPreviousTrack, nil)
        }
    }
}

private let kMRTogglePlayPause: UInt32 = 2
private let kMRNextTrack: UInt32 = 4
private let kMRPreviousTrack: UInt32 = 5
