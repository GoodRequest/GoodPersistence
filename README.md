# GoodPersistence

[![iOS Version](https://img.shields.io/badge/iOS_Version->=_12.0-brightgreen?logo=apple&logoColor=green)]()
[![Swift Version](https://img.shields.io/badge/Swift_Version-5.5-green?logo=swift)](https://docs.swift.org/swift-book/)
[![Supported devices](https://img.shields.io/badge/Supported_Devices-iPhone/iPad-green)]()
[![Contains Test](https://img.shields.io/badge/Tests-YES-blue)]()
[![Dependency Manager](https://img.shields.io/badge/Dependency_Manager-SPM-red)](#swiftpackagemanager)

A property wrapper, designed to simplify the process of caching data into the keychain and UserDefaults storage. 
This wrapper makes it possible to quickly and easily implement caching mechanisms in the applications,
without having to write extensive amounts of code. 
The property wrapper takes care of all the underlying complexity, allowing developers to focus on their application's functionality.

## Documentation
You can check GoodPersistence package documentation [here](https://goodrequest.github.io/GoodPersistence/documentation/goodpersistence/)

## Installation
### Swift Package Manager

Create a `Package.swift` file and add the package dependency into the dependencies list.
Or to integrate without package.swift add it through the Xcode add package interface.

[//]: # (Don't forget to add the version once available)
```swift

import PackageDescription

let package = Package(
    name: "SampleProject",
    dependencies: [
        .Package(url: "https://github.com/GoodRequest/iOS-GoodPersistence" from: "addVersion")
    ]
)

```

## Usage

Storing to the UserDeaults
```swift
@UserDefaultValue(String(describing: AppState.self), defaultValue: .initial)
var appState: AppState
```

Storing to the KeyChain
```swift
@KeychainValue("accessToken", defaultValue: "", accessibility: .afterFirstUnlockThisDeviceOnly)
var accessToken: String
```

Using Publishers
```swift
lazy var appStatePublisher = _appState.publisher
    .dropFirst()
    .removeDuplicates()
    .eraseToAnyPublisher()
```

## License
GoodPersistence is released under the MIT license. See [LICENSE](LICENSE.md) for details.
