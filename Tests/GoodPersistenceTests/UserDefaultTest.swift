import XCTest
import GoodPersistence
import Combine

final class UserDefaultsTests: XCTestCase {

    enum C {

        static let userDefaultsObjectTestMonitorKey = "Test Monitor"
        static let firstCondition = [1]
        static let secondCondition = [1,2]
        static let userDefaultsObjectKey = "numbers3"
    }

    @UserDefaultValue(C.userDefaultsObjectKey, defaultValue: C.firstCondition)
    var numbers: [Int]

    var cancellable: AnyCancellable?

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

    func testUserDefaultsValueInitialization() {
        let keychainValue = UserDefaultValue("testKey1", defaultValue: "default")

        XCTAssertEqual(keychainValue.wrappedValue, "default", "Expected default value to be 'default'")
    }

    func testUserDefaultsValueRetrieval() {
        let keychainValue = UserDefaultValue("testKey2", defaultValue: "default")

        keychainValue.wrappedValue = "newValue"

        XCTAssertEqual(keychainValue.wrappedValue, "newValue", "Expected retrieved value to be 'newValue'")
    }

    func testUserDefaultsValueDefault() {
        let keychainValue = UserDefaultValue("nonexistentKey", defaultValue: "default")

        XCTAssertEqual(keychainValue.wrappedValue, "default", "Expected default value to be 'default' for nonexistent key")
    }

    func testUserDefaultsValueSaveAndRetrieve() {
        let keychainValue = UserDefaultValue("saveRetrieveKey", defaultValue: "default")

        keychainValue.wrappedValue = "savedValue"

        XCTAssertEqual(keychainValue.wrappedValue, "savedValue", "Expected retrieved value to be 'savedValue'")
    }

    func testUserDefaultsValuePublisher() {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values")
        let userDefaultsValue = UserDefaultValue("publisherKey1", defaultValue: "default")
        userDefaultsValue.wrappedValue = "default"

        var receivedValues: [String] = []
        cancellable = userDefaultsValue.publisher
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 2 {
                    expectation.fulfill()
                }
            }

        userDefaultsValue.wrappedValue = "newValue"

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(receivedValues, ["default", "newValue"], "Expected publisher to emit 'default' and 'newValue'")
    }

    func testUserDefaultsValuePublisher2() {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values after error")
        let userDefaultsValue = UserDefaultValue("publisherKey2", defaultValue: "default")
        userDefaultsValue.wrappedValue = "default"

        enum CustomError: Error {

            case customError

        }

        var receivedValues: [String] = []

        print("Starting with", userDefaultsValue.wrappedValue)

        cancellable = userDefaultsValue.publisher
            .share(replay: 1)
            .sink { [self] value in
                receivedValues.append(value)
                if receivedValues.count == 3 {
                    expectation.fulfill()
                    cancellable?.cancel()
                }
            }

        userDefaultsValue.wrappedValue = "newValue"
        userDefaultsValue.wrappedValue = "evenNewerValue"

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(receivedValues, ["default", "newValue", "evenNewerValue"], "Expected publisher to emit 'default' and 'newValue'")
    }

    func testUserDefaultsValuePublisherThreaded() {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values from different threads")
        let userDefaultsValue = UserDefaultValue("publisherKey3", defaultValue: "default")
        userDefaultsValue.wrappedValue = "default"

        var receivedValues: [String] = []

        print("Starting with", userDefaultsValue.wrappedValue)


        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        cancellable = userDefaultsValue.publisher
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 11 {
                    expectation.fulfill()
                    self.cancellable?.cancel()
                }
            }

        let values1 = ["val1","val2","val3", "val4", "val5"]
        let values2 = ["val6","val7","val8", "val9", "val10"]

        queue1.async {
            values1.forEach {
                userDefaultsValue.wrappedValue = $0
            }
        }

        queue2.async {
            values2.forEach {
                userDefaultsValue.wrappedValue = $0
            }
        }

        wait(for: [expectation], timeout: 5.0)
        if #available(iOS 16.0, *) {
            let values = [values1, values2, ["default"]].flatMap { $0 }
            XCTAssertTrue(values.allSatisfy{ val in receivedValues.contains(where: { $0 == val})}, "Expected publisher to emit \(values1)\(values2),[default] but got \(receivedValues) instead")
        } else {
            // Fallback on earlier versions
        }
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectKey)
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectTestMonitorKey)
        GoodPersistence.Configuration.configure(monitors: [])
    }

}
