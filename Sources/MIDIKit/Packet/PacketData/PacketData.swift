//
//  PacketData PacketData.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

@_implementationOnly import CoreMIDI

extension MIDI.Packet {
    
    /// Clean consolidated data encapsulation of raw data from a Core MIDI `MIDIPacket` (MIDI 1.0).
    public struct PacketData {
        
        @inline(__always)
        let bytes: [MIDI.Byte]
        
        /// Core MIDI packet timestamp
        @inline(__always)
        let timeStamp: MIDI.IO.CoreMIDITimeStamp
        
        @inline(__always)
        public init(bytes: [MIDI.Byte], timeStamp: MIDI.IO.CoreMIDITimeStamp) {
            
            self.bytes = bytes
            self.timeStamp = timeStamp
            
        }
        
    }
    
}

extension MIDI.Packet.PacketData {
    
    @inline(__always)
    internal init(_ midiPacketPtr: UnsafePointer<MIDIPacket>) {
        
        self = Self.safePacketUnwrapper(midiPacketPtr)
        
    }
    
    @inline(__always)
    fileprivate static let midiPacketDataOffset: Int = MemoryLayout.offset(of: \MIDIPacket.data)!
    
    @inline(__always)
    fileprivate static func safePacketUnwrapper(_ midiPacketPtr: UnsafePointer<MIDIPacket>) -> MIDI.Packet.PacketData {
        
        let packetDataCount = Int(midiPacketPtr.pointee.length)
        
        guard packetDataCount > 0 else {
            return MIDI.Packet.PacketData(
                bytes: [],
                timeStamp: midiPacketPtr.pointee.timeStamp
            )
        }
        
        // Access the raw memory instead of using the .pointee
        // This workaround is needed due to a variety of crashes that can occur when either the thread sanitizer is on, or large/malformed MIDI packet lists / packets arrive
        let rawMIDIPacketDataPtr = UnsafeRawBufferPointer(
            start: UnsafeRawPointer(midiPacketPtr) + midiPacketDataOffset,
            count: packetDataCount
        )
        
        return MIDI.Packet.PacketData(
            bytes: Array<MIDI.Byte>(rawMIDIPacketDataPtr),
            timeStamp: midiPacketPtr.pointee.timeStamp
        )
        
    }
    
}
