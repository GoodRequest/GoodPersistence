import XCTest
import GoodPersistence

final class UserDefaultsTests: XCTestCase {

    enum C {

        static let userDefaultsObjectTestMonitorKey = "Test Monitor"
        static let firstCondition = [1]
        static let secondCondition = [1,2]
        static let userDefaultsObjectKey = "numbers3"
    }

    @UserDefaultValue(C.userDefaultsObjectKey, defaultValue: C.firstCondition)
    var numbers: [Int]

    func testUserDefaultsContainer() {
        XCTAssert(
            numbers == C.firstCondition,
            "\(C.userDefaultsObjectKey) contains: \(numbers) but should contain \(C.firstCondition)"
        )
        numbers.append(2)
        XCTAssert(
            numbers == C.secondCondition,
            "\(C.userDefaultsObjectKey) contains: \(numbers) but should contain \(C.secondCondition)"
        )

    }

    func testUserDefaultsStoresStructureIsNotRetrievedBecauseIsEmpty() {
        struct EmptyTest: Codable {
            let value: String
        }

        let monitor = TestMonitor()
        GoodPersistence.Configuration.configure(monitors: [monitor])

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: ""))
        var test: EmptyTest

        let _ = test

        XCTAssert(
            monitor.message == "Default UserDefaults value [EmptyTest(value: \"\")] for key [Test Monitor] used. Reason: Data not retrieved.",
            "Monitor should contain message for using default value. Contains: \(monitor.message)."
        )
    }

    func testUserDefaultsStoresStructureDataHasChanged() {
        struct EmptyTest: Codable {
            let value: String
        }

        let monitor = TestMonitor()
        GoodPersistence.Configuration.configure(monitors: [monitor])

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: ""))
        var test: EmptyTest

        test = .init(value: "newValue")

        XCTAssert(
            monitor.message == "UserDefaults data for key [Test Monitor] has changed to EmptyTest(value: \"newValue\").",
            "Monitor should contain message for using default value. Contains: \(monitor.message)."
        )
    }

    func testMessageForUserDefaultsStoresStructureIsNotDecodedCorrectly() {
        struct EmptyTest: Codable {
            let value: String
        }

        struct EmptyTestFailure: Codable {
            let value: String
            let secondValue: String
        }

        let monitor = TestMonitor()
        GoodPersistence.Configuration.configure(monitors: [monitor])

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: ""))
        var test: EmptyTest
        test = .init(value: "value")

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: "", secondValue: ""))
        var testFailure: EmptyTestFailure
        let _ = testFailure

        XCTAssert(
            monitor.message == "Default UserDefaults value [EmptyTestFailure(value: \"\", secondValue: \"\")] for key [Test Monitor] used. Reason: Decoding error.",
            "Monitor should contain message for using default value. Contains: \(monitor.message)."
        )

        XCTAssert(
            monitor.error != nil,
            "Monitor should contain error for using default value. Contains error: \(monitor.error)."
        )
    }

    func testErrorForDefaultsStoresStructureIsNotDecodedCorrectly() {
        struct EmptyTest: Codable {
            let value: String
        }

        struct EmptyTestFailure: Codable {
            let value: String
            let secondValue: String
        }

        let monitor = TestMonitor()
        GoodPersistence.Configuration.configure(monitors: [monitor])

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: ""))
        var test: EmptyTest
        test = .init(value: "value")

        @UserDefaultValue(C.userDefaultsObjectTestMonitorKey, defaultValue: .init(value: "", secondValue: ""))
        var testFailure: EmptyTestFailure
        let _ = testFailure

        XCTAssert(
            monitor.error != nil,
            "Monitor should contain error for using default value. Contains error: \(monitor.error)."
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectKey)
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectTestMonitorKey)
        GoodPersistence.Configuration.configure(monitors: [])
    }

}
