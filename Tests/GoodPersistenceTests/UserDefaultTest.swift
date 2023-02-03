import XCTest
import GoodPersistence

final class UserDefaultsTests: XCTestCase {

    enum C {

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

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: C.userDefaultsObjectKey)
        UserDefaults.standard.synchronize()
    }

}
