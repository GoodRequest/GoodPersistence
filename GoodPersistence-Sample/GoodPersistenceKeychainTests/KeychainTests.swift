import XCTest
import GoodPersistence
import Combine
import SwiftUI

final class KeychainTests: XCTestCase {

    var cancellable: AnyCancellable?

    var receivedValues: [String] = []

    @AppStorage("sample1") var sample: String = "" {
        didSet {
            receivedValues.append(sample)
        }
    }

    func testKeychainContainer() {
        var numbers: [Int] = [1]
        let keychainValue =  KeychainValue("numbers", defaultValue: [1])

        XCTAssert(
            numbers == [1],
            "\("numbers") contains: \(numbers) but should contain \([1])"
        )
        numbers.append(2)
        XCTAssert(
            numbers ==  [1,2],
            "\("numbers") contains: \(numbers) but should contain \( [1,2])"
        )
    }

    func testKeychainValueInitialization() {
        let keychainValue = KeychainValue("testKey1", defaultValue: "default")

        XCTAssertEqual(keychainValue.wrappedValue, "default", "Expected default value to be 'default'")
    }

    func testKeychainValueRetrieval() {
        let keychainValue = KeychainValue("testKey2", defaultValue: "default")

        keychainValue.wrappedValue = "newValue"

        XCTAssertEqual(keychainValue.wrappedValue, "newValue", "Expected retrieved value to be 'newValue'")
    }

    func testKeychainValueDefault() {
        let keychainValue = KeychainValue("nonexistentKey", defaultValue: "default")

        XCTAssertEqual(keychainValue.wrappedValue, "default", "Expected default value to be 'default' for nonexistent key")
    }

    func testKeychainValueSaveAndRetrieve() {
        let keychainValue = KeychainValue("saveRetrieveKey", defaultValue: "default")

        keychainValue.wrappedValue = "savedValue"

        XCTAssertEqual(keychainValue.wrappedValue, "savedValue", "Expected retrieved value to be 'savedValue'")
    }

    func testKeychainValuePublisher() async {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values")
        let keychainValue = KeychainValue("publisherKey1", defaultValue: "default")
        keychainValue.wrappedValue = "default"

        var receivedValues: [String] = []
        cancellable = keychainValue.valuePublisher
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 2 {
                    expectation.fulfill()
                }
            }

        keychainValue.wrappedValue = "newValue"

        await fulfillment(of: [expectation], timeout: 3.0, enforceOrder: true)
        XCTAssertEqual(receivedValues, ["default", "newValue"], "Expected publisher to emit 'default' and 'newValue'")
    }

    func testKeychainValuePublisher2() async {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values after error")
        let keychainValue = KeychainValue("publisherKey2", defaultValue: "default")
        keychainValue.wrappedValue = "default"

        enum CustomError: Error {

            case customError

        }

        var receivedValues: [String] = []

        print("Starting with", keychainValue.wrappedValue)

        cancellable = keychainValue.valuePublisher
            .share(replay: 1)
            .sink { [self] value in
                receivedValues.append(value)
                if receivedValues.count == 3 {
                    expectation.fulfill()
                    cancellable?.cancel()
                }
            }

        keychainValue.wrappedValue = "newValue"
        keychainValue.wrappedValue = "evenNewerValue"

        await fulfillment(of: [expectation], timeout: 3.0, enforceOrder: true)

        XCTAssertEqual(receivedValues, ["default", "newValue", "evenNewerValue"], "Expected publisher to emit 'default' and 'newValue'")
    }

    func testKeychainValuePublisherThreadedAppStorage() async {
        let expectation = XCTestExpectation(description: "Value publisher should emit new values from different threads")


        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        let values1 = ["val1","val2","val3", "val4", "val5"]
        let values2 = ["val6","val7","val8", "val9", "val10"]

        queue1.async {
            values1.forEach {
                self.sample = $0
            }
        }

        queue2.async {
            values2.forEach {
                self.sample = $0
            }
        }

        await fulfillment(of: [expectation], timeout: 3.0, enforceOrder: true)

        XCTAssertTrue(asyncTestsCondition(receivedValues: receivedValues), expectationAsyncSetError(receivedValues))
    }

    func testKeychainValuePublisherThreaded() async {
        let expectation = XCTestExpectation(description: "Value publisher should be able emit new values from different threads")
        let keychainValue = KeychainValue("publisherKey3", defaultValue: "default")
        keychainValue.wrappedValue = "default"

        var receivedValues: [String] = []

        print("Starting with", keychainValue.wrappedValue)


        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        cancellable = keychainValue.valuePublisher
            .receive(on: DispatchQueue.main)
            .sink { value in
                debugPrint("value", value)
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
                keychainValue.wrappedValue = $0
            }
        }

        queue2.async {
            values2.forEach {
                keychainValue.wrappedValue = $0
            }
        }

        await fulfillment(of: [expectation], timeout: 3.0, enforceOrder: true)

        XCTAssertTrue(asyncTestsCondition(receivedValues: receivedValues), expectationAsyncSetError(receivedValues))
    }

    func testKeychainValuePublisherTaskGroup() async {
        let expectation = XCTestExpectation(description: "Value publisher should be able to emit new values from different threads")
        let keychainValue = KeychainValue("publisherKey3", defaultValue: "default")
        keychainValue.wrappedValue = "default"

        var receivedValues: [String] = []

        print("Starting with", keychainValue.wrappedValue)

        let queue1 = DispatchQueue(label: "com.test.queue1")
        let queue2 = DispatchQueue(label: "com.test.queue2")

        cancellable = keychainValue.valuePublisher
            .receive(on: DispatchQueue.main)
            .collect(11)
            .sink { value in
                receivedValues.append(contentsOf: value)
                expectation.fulfill()
                self.cancellable?.cancel()
            }

        let values1 = ["val1","val2","val3", "val4", "val5"]
        let values2 = ["val6","val7","val8", "val9", "val10"]

        await withTaskGroup(of: Void.self) { group in

            group.addTask { @MainActor in
                values1.forEach {
                    keychainValue.wrappedValue = $0
                }
            }

            group.addTask { @MainActor in
                values2.forEach {
                    keychainValue.wrappedValue = $0
                }
            }

            await group.waitForAll()
        }

        await fulfillment(of: [expectation], timeout: 3.0, enforceOrder: true)
        print(receivedValues)
        XCTAssertTrue(asyncTestsCondition(receivedValues: receivedValues), expectationAsyncSetError(receivedValues))
    }

    let testSetAsync = ["default","val1","val2","val3", "val4", "val5","val6","val7","val8", "val9", "val10"]

    func expectationAsyncSetError(_ receivedValues: [String]) -> String {
        "Expected publisher to emit \(testSetAsync) but got \(receivedValues) instead"
    }

    func asyncTestsCondition(receivedValues: [String]) -> Bool {
        testSetAsync.allSatisfy{receivedValues.contains($0)}
    }

}
