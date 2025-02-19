//
//  AnyEndpoint.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.IO {
    
    /// Type-erased box that can contain `MIDI.IO.InputEndpoint` or `MIDI.IO.OutputEndpoint`.
    public struct AnyEndpoint: _MIDIIOEndpointProtocol {
        
        public let endpointType: MIDI.IO.EndpointType
        
        // MARK: MIDIIOObjectProtocol
        
        public let name: String
        
        public typealias UniqueID = MIDI.IO.AnyUniqueID
        public let uniqueID: UniqueID
        
        public let coreMIDIObjectRef: MIDI.IO.CoreMIDIEndpointRef
        
        // MARK: Init
        
        internal init<E: _MIDIIOEndpointProtocol>(_ base: E) {
            
            switch base {
            case is MIDI.IO.InputEndpoint:
                endpointType = .input
                
            case is MIDI.IO.OutputEndpoint:
                endpointType = .output
                
            case let otherCast as Self:
                endpointType = otherCast.endpointType
                
            default:
                preconditionFailure("Unexpected MIDIIOEndpointProtocol type: \(base)")
                
            }
            
            self.coreMIDIObjectRef = base.coreMIDIObjectRef
            self.name = base.name
            self.uniqueID = .init(base.uniqueID.coreMIDIUniqueID)
            
        }
        
    }
    
}

extension _MIDIIOEndpointProtocol {
    
    /// Returns the endpoint as a type-erased `AnyEndpoint`.
    public func asAnyEndpoint() -> MIDI.IO.AnyEndpoint {
        
        .init(self)
        
    }
    
}

extension Collection where Element : MIDIIOEndpointProtocol {
    
    /// Returns the collection as a collection of type-erased `AnyEndpoint` endpoints.
    public func asAnyEndpoints() -> [MIDI.IO.AnyEndpoint] {
        
        map { $0.asAnyEndpoint() }
        
    }
    
}
