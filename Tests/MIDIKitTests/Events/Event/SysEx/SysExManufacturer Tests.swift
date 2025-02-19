//
//  SysExManufacturer Tests.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

#if !os(watchOS)

import XCTest
@testable import MIDIKit

class SysExManufacturerTests: XCTestCase {
    
    func testOneByte() {
        
        // valid conditions
        
        // min/max valid
        XCTAssertTrue(
            MIDI.Event.SysExManufacturer.oneByte(0x01).isValid
        )
        XCTAssertTrue(
            MIDI.Event.SysExManufacturer.oneByte(0x7D).isValid
        )
        
        // invalid conditions
        
        // 0x00 is reserved as first byte of 3-byte IDs
        XCTAssertFalse(
            MIDI.Event.SysExManufacturer.oneByte(0x00).isValid
        )
        
        // 0x7E and 0x7F are reserved for universal sys ex
        XCTAssertFalse(
            MIDI.Event.SysExManufacturer.oneByte(0x7E).isValid
        )
        XCTAssertFalse(
            MIDI.Event.SysExManufacturer.oneByte(0x7F).isValid
        )
        
    }
    
    func testThreeByte() {
        
        // valid conditions
        
        // min/max valid
        XCTAssertFalse(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x00, byte3: 0x00).isValid
        )
        XCTAssertTrue(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x01, byte3: 0x00).isValid
        )
        XCTAssertTrue(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x00, byte3: 0x01).isValid
        )
        XCTAssertTrue(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x7F, byte3: 0x7F).isValid
        )
        
    }
    
    func testName() {
        
        // spot-check: manufacturer name lookup
        // test first and last manufacturer in each section
        
        // single byte ID
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.oneByte(0x01).name,
            "Sequential Circuits"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.oneByte(0x3F).name,
            "Quasimidi"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.oneByte(0x40).name,
            "Kawai Musical Instruments MFG. CO. Ltd"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.oneByte(0x5F).name,
            "SD Card Association"
        )
        
        // 3-byte ID
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x00, byte3: 0x58).name,
            "Atari Corporation"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x00, byte3: 0x58).name,
            "Atari Corporation"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x02, byte3: 0x3B).name,
            "Sonoclast, LLC"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x20, byte3: 0x00).name,
            "Dream SAS"
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x21, byte3: 0x59).name,
            "Robkoo Information & Technologies Co., Ltd."
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x40, byte3: 0x00).name,
            "Crimson Technology Inc."
        )
        
        XCTAssertEqual(
            MIDI.Event.SysExManufacturer.threeByte(byte2: 0x40, byte3: 0x07).name,
            "Slik Corporation"
        )
        
    }
    
}

#endif
