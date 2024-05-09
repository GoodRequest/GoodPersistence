//
//  MajorMigrationTestsV1.swift
//
//
//  Created by Andrej Jasso on 10/04/2024.
//

import XCTest
import GoodPersistence

typealias VoidClosure = (() -> ())

final class KeychainMajorMigrationV1Tests: XCTestCase {

    enum C {

        static let keychainObjectKey = "TestString"
        static let testValue = "Hello there general Kenobi"

    }
    
    @KeychainValueV1(C.keychainObjectKey, defaultValue: C.testValue)
    var testString: String?

    @KeychainValue(C.keychainObjectKey, defaultValue: C.testValue)
    var testString2: String?

    func testMigrationFromv1tov2() {
        testString = nil

        XCTAssert(self.testString == nil)
        XCTAssert(self.testString2 == nil)

        self.testString2 = C.testValue

        XCTAssert(self.testString == C.testValue)
        XCTAssert(self.testString2 == C.testValue)
    }

    override class func tearDown() {
        try? Keychain.default.remove(C.keychainObjectKey)
    }

}

