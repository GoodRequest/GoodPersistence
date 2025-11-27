# AI Usage Rules for GoodPersistence

## Overview

GoodPersistence is a Swift property wrapper library that simplifies storing Codable values in UserDefaults and Keychain. This document provides comprehensive guidelines for AI agents building code that uses this library.

**Key Principles:**
- Always prefer the property wrapper APIs (`@UserDefaultValue`, `@KeychainValue`) for standard use cases
- Use the underlying KeychainAccess library directly only for advanced scenarios not covered by the wrappers
- Ensure all stored types conform to `Codable` and `Equatable` (for KeychainValue)
- Handle errors gracefully using the monitoring system

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Advanced Features](#advanced-features)
3. [Keychain Configuration](#keychain-configuration)
4. [Using KeychainAccess Directly](#using-keychainaccess-directly)
5. [Monitoring and Error Handling](#monitoring-and-error-handling)
6. [Best Practices](#best-practices)
7. [Common Patterns](#common-patterns)
8. [Migration and Compatibility](#migration-and-compatibility)

---

## Basic Usage

### UserDefaults Storage

Use `@UserDefaultValue` for storing non-sensitive data that should persist across app launches.

**Basic Pattern:**
```swift
import GoodPersistence

class SettingsManager {
    @UserDefaultValue("username", defaultValue: "")
    var username: String
    
    @UserDefaultValue("appTheme", defaultValue: AppTheme.light)
    var appTheme: AppTheme
    
    @UserDefaultValue("userPreferences", defaultValue: UserPreferences())
    var userPreferences: UserPreferences
}
```

**Key Points:**
- First parameter is the storage key (String)
- Second parameter is the default value (must match the property type)
- The wrapped value automatically handles encoding/decoding
- Setting a value to its default removes it from storage

### Keychain Storage

Use `@KeychainValue` for storing sensitive data (tokens, passwords, credentials).

**Basic Pattern:**
```swift
import GoodPersistence

class AuthManager {
    @KeychainValue("accessToken", defaultValue: "")
    var accessToken: String
    
    @KeychainValue(
        "refreshToken",
        defaultValue: "",
        accessibility: .afterFirstUnlockThisDeviceOnly
    )
    var refreshToken: String
}
```

**KeychainValue Parameters:**
- `key`: String identifier for the stored value
- `defaultValue`: Default value if keychain read fails
- `accessibility`: KeychainAccess.Accessibility level (default: `.afterFirstUnlock`)
- `synchronizable`: Bool for iCloud Keychain sync (default: `false`)
- `authenticationPolicy`: Optional authentication policy for biometric protection

**Accessibility Options:**
- `.afterFirstUnlock` - Accessible after first device unlock (default)
- `.afterFirstUnlockThisDeviceOnly` - Same as above, device-only
- `.whenPasscodeSetThisDeviceOnly` - Requires passcode, device-only
- `.whenUnlocked` - Accessible when device is unlocked
- `.whenUnlockedThisDeviceOnly` - Same as above, device-only

**Authentication Policy:**
```swift
@KeychainValue(
    "biometricToken",
    defaultValue: "",
    accessibility: .whenPasscodeSetThisDeviceOnly,
    authenticationPolicy: [.biometryAny] // Touch ID or Face ID
)
var biometricToken: String
```

---

## Advanced Features

### Combine Publishers

Both property wrappers expose Combine publishers for reactive programming.

**UserDefaultValue Publisher:**
```swift
class SettingsManager {
    @UserDefaultValue("username", defaultValue: "")
    var username: String
    
    // Access publisher via underscore prefix
    lazy var usernamePublisher = _username.publisher
        .dropFirst() // Skip initial value
        .removeDuplicates()
        .eraseToAnyPublisher()
}
```

**KeychainValue Publisher:**
```swift
class AuthManager {
    @KeychainValue("accessToken", defaultValue: "")
    var accessToken: String
    
    // Access publisher via underscore prefix
    lazy var accessTokenPublisher = _accessToken.valuePublisher
        .removeDuplicates()
        .eraseToAnyPublisher()
}
```

**Note:** KeychainValue uses `valuePublisher` (not `publisher`) and handles authentication policy delays automatically.

### SwiftUI Bindings

Both wrappers support SwiftUI bindings via the `$` prefix.

```swift
import SwiftUI
import GoodPersistence

struct SettingsView: View {
    @UserDefaultValue("username", defaultValue: "")
    var username: String
    
    var body: some View {
        TextField("Username", text: $username)
    }
}
```

```swift
struct SecureSettingsView: View {
    @KeychainValue("apiKey", defaultValue: "")
    var apiKey: String
    
    var body: some View {
        SecureField("API Key", text: $apiKey)
    }
}
```

### Custom Codable Types

The library supports any Codable type, including custom structs and enums.

```swift
struct UserPreferences: Codable, Equatable {
    var notificationsEnabled: Bool
    var language: String
    var theme: AppTheme
}

enum AppTheme: String, Codable, Equatable {
    case light, dark, system
}

class SettingsManager {
    @UserDefaultValue("preferences", defaultValue: UserPreferences(
        notificationsEnabled: true,
        language: "en",
        theme: .system
    ))
    var preferences: UserPreferences
}
```

**Important:** For `@KeychainValue`, the type must also conform to `Equatable`.

---

## Keychain Configuration

### Default Keychain Configuration

The library automatically configures a default Keychain instance using the app's bundle identifier. For custom configuration, use `Keychain.configure(with:)`.

**Configuration Options:**
```swift
import GoodPersistence

// Configure with service name
Keychain.configure(with: KeychainConfiguration(
    service: "com.yourapp.service"
))

// Configure with server and protocol (for internet passwords)
Keychain.configure(with: KeychainConfiguration(
    server: "https://api.example.com",
    protocolType: .https
))

// Configure with access group (for app groups)
Keychain.configure(with: KeychainConfiguration(
    service: "com.yourapp.service",
    accessGroup: "group.com.yourapp.shared"
))
```

**When to Configure:**
- Before using any `@KeychainValue` properties
- Typically in `AppDelegate` or app initialization code
- When you need shared keychain access across app extensions
- When storing internet passwords for web credentials

**Example App Initialization:**
```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    // Configure keychain before first use
    Keychain.configure(with: KeychainConfiguration(
        service: Bundle.main.bundleIdentifier ?? "com.yourapp"
    ))
    
    // Configure monitoring
    GoodPersistence.Configuration.configure(
        monitors: [LoggingPersistenceMonitor(logger: OSLogLogger())]
    )
    
    return true
}
```

---

## Using KeychainAccess Directly

For advanced scenarios not covered by the property wrappers, you can use KeychainAccess directly.

**When to Use KeychainAccess Directly:**
- Storing internet passwords (server credentials)
- Shared web credentials
- Batch operations (getting all keys, removing multiple items)
- Custom keychain queries
- Operations that don't fit the property wrapper pattern

### Accessing the Default Keychain Instance

```swift
import GoodPersistence
import KeychainAccess

// Access the configured default instance
let keychain = Keychain.default

// Perform direct operations
try? keychain.set("value", key: "customKey")
let value = try? keychain.get("customKey")
try? keychain.remove("customKey")
```

### Internet Passwords

For storing web credentials (usernames/passwords for websites):

```swift
import KeychainAccess

// Create a keychain for internet passwords
let keychain = KeychainAccess.Keychain(
    server: "https://api.example.com",
    protocolType: .https
)

// Store credentials
try? keychain.set("password123", key: "user@example.com")

// Retrieve credentials
let password = try? keychain.get("user@example.com")
```

### Shared Web Credentials

For sharing credentials with Safari and other apps:

```swift
import KeychainAccess

let keychain = KeychainAccess.Keychain(
    server: "https://www.example.com",
    protocolType: .https
)

// Get shared password from iCloud Keychain
keychain.getSharedPassword("user@example.com") { password, error in
    if let password = password {
        // Use password
    }
}

// Set shared password
keychain.setSharedPassword("password123", account: "user@example.com")
```

### Batch Operations

```swift
import KeychainAccess

let keychain = Keychain.default

// Get all keys
let allKeys = keychain.allKeys()
for key in allKeys {
    print("Key: \(key)")
}

// Get all items
let allItems = keychain.allItems()
for item in allItems {
    print("Item: \(item)")
}

// Remove all items
for key in allKeys {
    try? keychain.remove(key)
}
```

### Custom Keychain Instances

Create custom Keychain instances for specific use cases:

```swift
import KeychainAccess

// Custom service keychain
let customKeychain = KeychainAccess.Keychain(service: "com.custom.service")
    .synchronizable(true) // Enable iCloud sync
    .accessibility(.whenUnlocked)

// Custom server keychain with authentication
let secureKeychain = KeychainAccess.Keychain(
    server: "https://secure.example.com",
    protocolType: .https
)
.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: [.biometryAny])
```

**Reference:** For complete KeychainAccess documentation, see: https://github.com/kishikawakatsumi/KeychainAccess

---

## Monitoring and Error Handling

### Setting Up Monitoring

Configure monitors to track errors and operations:

```swift
import GoodPersistence
import GoodLogger

// In AppDelegate or app initialization
GoodPersistence.Configuration.configure(
    monitors: [
        LoggingPersistenceMonitor(logger: OSLogLogger())
    ]
)
```

### Custom Monitors

Create custom monitors by conforming to `PersistenceMonitor`:

```swift
import GoodPersistence

class CustomMonitor: PersistenceMonitor {
    func didReceive(_ monitor: PersistenceMonitor, error: Error) {
        // Handle errors (analytics, crash reporting, etc.)
        print("Persistence error: \(error.localizedDescription)")
    }
    
    func didReceive(_ monitor: PersistenceMonitor, message: String) {
        // Handle informational messages
        print("Persistence message: \(message)")
    }
}

// Configure
GoodPersistence.Configuration.configure(monitors: [CustomMonitor()])
```

### Error Handling

The property wrappers handle errors gracefully:

- **Read Errors:** Returns default value and logs error
- **Write Errors:** Logs error, value may not be saved
- **Decode Errors:** Falls back to Plist decoder for backwards compatibility, then returns default value

**Manual Error Handling:**
```swift
// For direct KeychainAccess usage
do {
    try keychain.set("value", key: "key")
} catch {
    // Handle error
    print("Failed to save: \(error)")
}
```

---

## Best Practices

### 1. Key Naming

Use descriptive, namespaced keys to avoid conflicts:

```swift
// Good
@UserDefaultValue("com.yourapp.settings.username", defaultValue: "")
var username: String

// Avoid
@UserDefaultValue("username", defaultValue: "")
var username: String
```

### 2. Default Values

Always provide meaningful default values:

```swift
// Good - explicit default
@UserDefaultValue("theme", defaultValue: AppTheme.system)
var theme: AppTheme

// Avoid - unclear default
@UserDefaultValue("theme", defaultValue: AppTheme.light)
var theme: AppTheme // What if user never set a preference?
```

### 3. Security Considerations

- **UserDefaults:** Use only for non-sensitive data (preferences, settings, cache)
- **Keychain:** Use for sensitive data (tokens, passwords, API keys)
- **Accessibility:** Choose appropriate accessibility levels based on security requirements
- **Synchronization:** Be cautious with `synchronizable: true` - only for data that should sync across devices

### 4. Type Safety

Ensure types are properly Codable and Equatable:

```swift
// Good - explicit conformance
struct UserSettings: Codable, Equatable {
    var notificationsEnabled: Bool
    var language: String
}

// Ensure all properties are Codable
struct ComplexType: Codable, Equatable {
    var id: UUID // Codable
    var date: Date // Codable
    var data: Data // Codable
}
```

### 5. Initialization Order

Configure Keychain before using property wrappers:

```swift
// In AppDelegate
func application(_:didFinishLaunchingWithOptions:) -> Bool {
    // 1. Configure Keychain first
    Keychain.configure(with: KeychainConfiguration(
        service: Bundle.main.bundleIdentifier ?? "com.yourapp"
    ))
    
    // 2. Configure monitoring
    GoodPersistence.Configuration.configure(monitors: [...])
    
    // 3. Now property wrappers can be used
    return true
}
```

### 6. Thread Safety

- Property wrapper access is thread-safe for reads
- Writes should be performed on the main thread or with proper synchronization
- Publishers emit on the thread where the value is set

### 7. Testing

Clean up test data:

```swift
import XCTest
import GoodPersistence

class SettingsTests: XCTestCase {
    @KeychainValue("testKey", defaultValue: "")
    var testValue: String
    
    override func tearDown() {
        // Clean up
        try? Keychain.default.remove("testKey")
        super.tearDown()
    }
}
```

---

## Common Patterns

### Settings Manager Pattern

```swift
import GoodPersistence
import Combine

class SettingsManager {
    // User Preferences
    @UserDefaultValue("settings.notifications", defaultValue: true)
    var notificationsEnabled: Bool
    
    @UserDefaultValue("settings.theme", defaultValue: AppTheme.system)
    var theme: AppTheme
    
    // Authentication
    @KeychainValue("auth.accessToken", defaultValue: "")
    var accessToken: String
    
    @KeychainValue(
        "auth.refreshToken",
        defaultValue: "",
        accessibility: .afterFirstUnlockThisDeviceOnly
    )
    var refreshToken: String
    
    // Publishers
    lazy var themePublisher = _theme.publisher
        .dropFirst()
        .removeDuplicates()
        .eraseToAnyPublisher()
    
    lazy var accessTokenPublisher = _accessToken.valuePublisher
        .removeDuplicates()
        .eraseToAnyPublisher()
    
    // Helper methods
    func clearAuth() {
        accessToken = ""
        refreshToken = ""
    }
    
    func isAuthenticated() -> Bool {
        !accessToken.isEmpty
    }
}
```

### Cache Manager Pattern

```swift
import GoodPersistence

class CacheManager {
    @UserDefaultValue("cache.lastUpdate", defaultValue: Date.distantPast)
    var lastUpdate: Date
    
    @UserDefaultValue("cache.userData", defaultValue: UserData())
    var userData: UserData
    
    @KeychainValue("cache.apiKey", defaultValue: "")
    var apiKey: String
    
    func updateCache(_ data: UserData) {
        userData = data
        lastUpdate = Date()
    }
    
    func isCacheValid(maxAge: TimeInterval) -> Bool {
        Date().timeIntervalSince(lastUpdate) < maxAge
    }
}
```

### ViewModel Integration

```swift
import Combine
import GoodPersistence

class HomeViewModel {
    private let settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        
        // Observe settings changes
        settingsManager.themePublisher
            .sink { [weak self] theme in
                self?.handleThemeChange(theme)
            }
            .store(in: &cancellables)
    }
    
    private func handleThemeChange(_ theme: AppTheme) {
        // Update UI
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import GoodPersistence

class AppSettings: ObservableObject {
    @UserDefaultValue("settings.darkMode", defaultValue: false)
    var darkMode: Bool
    
    @KeychainValue("settings.apiKey", defaultValue: "")
    var apiKey: String
}

struct SettingsView: View {
    @StateObject private var settings = AppSettings()
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $settings.darkMode)
            SecureField("API Key", text: $settings.apiKey)
        }
    }
}
```

---

## Migration and Compatibility

### Backwards Compatibility

The library supports backwards compatibility with V1 data:

- **JSON Encoding:** Current version uses JSON encoding (default)
- **Plist Decoding:** Falls back to Plist decoder if JSON decoding fails
- **Automatic Migration:** No manual migration needed for existing data

### Migration from V1

If migrating from a custom V1 implementation:

1. Existing Plist-encoded data will be automatically decoded
2. New writes use JSON encoding
3. Old data is preserved until overwritten

### Testing Migration

```swift
// Test that old data can be read
@KeychainValue("legacyKey", defaultValue: "")
var legacyValue: String

// If old data exists, it will be read successfully
// New writes will use JSON encoding
```

---

## Quick Reference

### Property Wrapper Comparison

| Feature | UserDefaultValue | KeychainValue |
|---------|-----------------|---------------|
| Storage | UserDefaults | Keychain |
| Security | Low | High |
| Type Requirement | Codable | Codable + Equatable |
| Publisher | `publisher` | `valuePublisher` |
| Binding | `$property` | `$property` |
| Default Value | Required | Required |
| Accessibility | N/A | Configurable |
| Sync | N/A | Optional (iCloud) |
| Biometric | N/A | Optional |

### When to Use What

- **UserDefaults (`@UserDefaultValue`):** App preferences, settings, non-sensitive cache, UI state
- **Keychain (`@KeychainValue`):** Tokens, passwords, API keys, sensitive user data
- **Direct KeychainAccess:** Internet passwords, shared web credentials, batch operations, custom queries

### Common Accessibility Levels

- `.afterFirstUnlock` - Default, accessible after first unlock
- `.whenUnlocked` - Only when device is unlocked
- `.whenPasscodeSetThisDeviceOnly` - Requires passcode, device-only
- `.afterFirstUnlockThisDeviceOnly` - After unlock, device-only

---

## Additional Resources

- **GoodPersistence Documentation:** https://goodrequest.github.io/GoodPersistence/documentation/goodpersistence/
- **KeychainAccess GitHub:** https://github.com/kishikawakatsumi/KeychainAccess
- **Sample App:** See `GoodPersistence-Sample/` directory for complete examples

---

## Summary for AI Agents

When building code with GoodPersistence:

1. **Always use property wrappers** (`@UserDefaultValue`, `@KeychainValue`) for standard persistence needs
2. **Choose the right storage:** UserDefaults for non-sensitive data, Keychain for sensitive data
3. **Configure Keychain** before first use if custom configuration is needed
4. **Use publishers** for reactive programming patterns
5. **Use bindings** (`$property`) for SwiftUI integration
6. **Access KeychainAccess directly** only for advanced scenarios (internet passwords, shared credentials, batch operations)
7. **Handle errors** through the monitoring system
8. **Follow best practices** for key naming, default values, and security
9. **Ensure types conform** to Codable (and Equatable for KeychainValue)
10. **Test thoroughly** and clean up test data

For any advanced KeychainAccess features not covered here, refer to the official KeychainAccess documentation: https://github.com/kishikawakatsumi/KeychainAccess

