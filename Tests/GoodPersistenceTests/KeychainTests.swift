import XCTest
import GoodPersistence

final class KeychainTests: XCTestCase {

    enum C {

        static let firstCondition = [1]
        static let secondCondition = [1,2]
        static let keychainObjectKey = "numbers"
    }

    @KeychainValue(C.keychainObjectKey, defaultValue: [1])
    var numbers: [Int]

    func testUserDefaultsContainer() {
        XCTAssert(
            numbers == C.firstCondition,
            "\(C.keychainObjectKey) contains: \(numbers) but should contain \(C.firstCondition)"
        )
        numbers.append(2)
        XCTAssert(
            numbers == C.secondCondition,
            "\(C.keychainObjectKey) contains: \(numbers) but should contain \(C.secondCondition)"
        )
    }

    override class func tearDown() {
        KeychainWrapper.standard.removeObject(forKey: C.keychainObjectKey)
    }

}
