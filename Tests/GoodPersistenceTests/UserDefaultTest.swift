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
        let firstMessage = monitor.messages.first

        XCTAssert(
            firstMessage == "GoodPersistence: UserDefaults value [EmptyTest(value: \"\")] for key [Test Monitor] used. Reason: Data not retrieved.",
            "Monitor should contain message for using default value. Contains: \(String(describing: firstMessage))."
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
        let firstMessage = monitor.messages.first

        XCTAssert(
            firstMessage == "GoodPersistence: data for key [Test Monitor] has changed to EmptyTest(value: \"newValue\").",
            "Monitor should contain message for using default value. Contains: \(String(describing: firstMessage))."
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
        let firstErrors = monitor.errors.first

        let testMessage1 = "GoodPersistence: UserDefaults value [EmptyTestFailure(value: \"\", secondValue: \"\")] for key [Test Monitor] used. Reason: Decoding error using JSON Decoder."
        let testMessage2 = "GoodPersistence: UserDefaults value [EmptyTestFailure(value: \"\", secondValue: \"\")] for key [Test Monitor] used. Reason: Decoding error using PList Decoder."

        XCTAssert(
            monitor.messages.contains { $0 == testMessage1},
            "Monitor should contain message for using default value. Contains: \(monitor.messages))."
        )

        XCTAssert(
            monitor.messages.contains { $0 == testMessage2},
            "Monitor should contain message for using default value. Contains: \(monitor.messages))."
        )

        XCTAssert(
            firstErrors != nil,
            "Monitor should contain error for using default value. Contains error: \(String(describing: firstErrors))."
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
        let firstErrors = monitor.errors.first

        XCTAssert(
            firstErrors != nil,
            "Monitor should contain error for using default value. Contains error: \(String(describing: firstErrors))."
        )
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectKey)
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectTestMonitorKey)
        GoodPersistence.Configuration.configure(monitors: [])
    }

}
