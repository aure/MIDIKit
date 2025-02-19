//
//  MIDI Packet.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI {
    
    /// A type that can hold any MIDI packet type.
    public enum Packet {
        
        /// MIDI 1.0 MIDI Packet
        case packet(PacketData)
        
        /// MIDI 2.0 Universal MIDI Packet
        case universalPacket(UniversalPacketData)
        
        /// Flat array of raw bytes
        @inline(__always)
        public var bytes: [MIDI.Byte] {
            
            switch self {
            case .packet(let packetData):
                return packetData.bytes
                
            case .universalPacket(let universalPacketData):
                return universalPacketData.bytes
            }
            
        }
        
        /// Core MIDI packet timestamp
        @inline(__always)
        public var timeStamp: MIDI.IO.CoreMIDITimeStamp {
            
            switch self {
            case .packet(let packetData):
                return packetData.timeStamp
                
            case .universalPacket(let universalPacketData):
                return universalPacketData.timeStamp
            }
            
        }
        
    }
    
}
