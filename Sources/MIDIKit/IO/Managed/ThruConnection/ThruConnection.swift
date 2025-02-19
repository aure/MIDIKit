//
//  ThruConnection.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

// Apple Core MIDI play-through connection documentation:
// https://developer.apple.com/documentation/coremidi/midi_thru_connection
//
// Thru connections are observable in:
// ~/Library/Preferences/ByHost/com.apple.MIDI.<UUID>.plist
// but you can't manually modify the plist file.

import Foundation
@_implementationOnly import CoreMIDI

extension MIDI.IO {
    
    /// A managed MIDI thru connection created in the system by the MIDI I/O `Manager`.
    ///
    /// Core MIDI play-through connections can be non-persistent (client-owned, auto-disposed when `Manager` de-initializes) or persistent (maintained even after system reboots).
    ///
    /// - Note: Do not store or cache this object unless it is unavoidable. Instead, whenever possible call it by accessing non-persistent thru connections using the `Manager`'s `managedThruConnections` collection.
    ///
    /// Ensure that it is only stored weakly and only passed by reference temporarily in order to execute an operation. If it absolutely must be stored strongly, ensure it is stored for no longer than the lifecycle of the managed thru connection (which is either at such time the `Manager` is de-initialized, or when calling `.remove(.nonPersistentThruConnection, ...)` or `.removeAll` on the `Manager` to destroy the managed thru connection.)
    public class ThruConnection: _MIDIIOManagedProtocol {
        
        // _MIDIIOManagedProtocol
        internal weak var midiManager: MIDI.IO.Manager?
        
        // MIDIIOManagedProtocol
        public private(set) var api: MIDI.IO.APIVersion
        
        // class-specific
        
        public private(set) var coreMIDIThruConnectionRef: MIDI.IO.CoreMIDIThruConnectionRef? = nil
        public private(set) var outputs: [OutputEndpoint]
        public private(set) var inputs: [InputEndpoint]
        public private(set) var lifecycle: Lifecycle
        public private(set) var parameters: Parameters
        
        // init
        
        /// Internal init.
        /// This object is not meant to be instanced by the user. This object is automatically created and managed by the MIDI I/O `Manager` instance when calling `.addThruConnection()`, and destroyed when calling `.remove(.nonPersistentThruConnection, ...)` or `.removeAll()`.
        ///
        /// - Parameters:
        ///   - outputs: One or more output endpoints, maximum of 8.
        ///   - inputs: One or more input endpoints, maximum of 8.
        ///   - lifecycle: Non-persistent or persistent.
        ///   - params: Optionally supply custom parameters for the connection.
        ///   - midiManager: Reference to I/O Manager object.
        ///   - api: Core MIDI API version.
        internal init(outputs: [OutputEndpoint],
                      inputs: [InputEndpoint],
                      lifecycle: Lifecycle = .nonPersistent,
                      params: Parameters = .init(),
                      midiManager: MIDI.IO.Manager,
                      api: MIDI.IO.APIVersion = .bestForPlatform()) {
            
            // truncate arrays to 8 members or less;
            // Core MIDI thru connections can only have up to 8 outputs and 8 inputs
            
            self.outputs = Array(outputs.prefix(8))
            self.inputs = Array(inputs.prefix(8))
            self.lifecycle = lifecycle
            self.midiManager = midiManager
            self.api = api.isValidOnCurrentPlatform ? api : .bestForPlatform()
            
            // prep params
            self.parameters = params
            self.parameters.outputs = outputs.map { $0.coreMIDIObjectRef }
            self.parameters.inputs = inputs.map { $0.coreMIDIObjectRef }
            
        }
        
        deinit {
            
            _ = try? dispose()
            
        }
        
    }
    
}

extension MIDI.IO.ThruConnection {
    
    internal func create(in manager: MIDI.IO.Manager) throws {
        
        var newConnection = MIDIThruConnectionRef()
        
        var params = parameters.coreMIDIThruConnectionParams()
        
        // prepare params
        let pLen = MIDIThruConnectionParamsSize(&params)
        
        let paramsData = withUnsafePointer(to: &params) { ptr in
            NSData(bytes: ptr, length: pLen)
        }
        
        // non-persistent/persistent
        var cfPersistentOwnerID: CFString? = nil
        
        if case .persistent(ownerID: let ownerID) = lifecycle {
            cfPersistentOwnerID = ownerID as CFString
        }
        
        switch cfPersistentOwnerID {
        case nil:
            // non-persistent thru connection
            
            // TODO: fix MIDI thru bug
            // There is a bug in Core MIDI's Swift bridging whereby passing nil into MIDIThruConnectionCreate fails to create a non-persistent thru connection and actually creates a persistent thru connection, despite what the Core MIDI documentation states.
            // Radar FB9836833 was filed with Apple.
            
            try MIDIThruConnectionCreate(
                nil, // this doesn't work, it needs an Obj-c NULL somehow
                paramsData,
                &newConnection
            )
                .throwIfOSStatusErr()
            
        case .some(let id):
            // persistent thru connection
            try MIDIThruConnectionCreate(
                id,
                paramsData,
                &newConnection
            )
            .throwIfOSStatusErr()
        }
        
        coreMIDIThruConnectionRef = newConnection
        
        //switch lifecycle {
        //case .nonPersistent:
        //    logger.debug("MIDI: Thru Connection: Successfully formed non-persistent connection.")
        //
        //case .persistent(let ownerID):
        //    logger.debug("MIDI: Thru Connection: Successfully formed persistent connection with ID //\(ownerID.otcQuoted).")
        //}
        
    }
    
    /// Disposes of the the thru connection if it's already been created in the system via the `create()` method.
    ///
    /// Errors thrown can be safely ignored and are typically only useful for debugging purposes.
    internal func dispose() throws {
        
        guard let unwrappedThruConnectionRef = self.coreMIDIThruConnectionRef else { return }
        
        defer {
            self.coreMIDIThruConnectionRef = nil
        }
        
        try MIDIThruConnectionDispose(unwrappedThruConnectionRef)
            .throwIfOSStatusErr()
        
    }
    
}

extension MIDI.IO.ThruConnection: CustomStringConvertible {
    
    public var description: String {
        
        var thruConnectionRefString: String = "nil"
        if let unwrappedThruConnectionRef = coreMIDIThruConnectionRef {
            thruConnectionRefString = "\(unwrappedThruConnectionRef)"
        }
        
        return "ThruConnection(ref: \(thruConnectionRefString), outputs: \(outputs), inputs: \(inputs), \(lifecycle)"
        
    }
    
}
