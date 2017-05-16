# OrangeRealm

[![CI Status](http://img.shields.io/travis/pisces/OrangeRealm.svg?style=flat)](https://travis-ci.org/pisces/OrangeRealm)
[![Version](https://img.shields.io/cocoapods/v/OrangeRealm.svg?style=flat)](http://cocoapods.org/pods/OrangeRealm)
[![License](https://img.shields.io/cocoapods/l/OrangeRealm.svg?style=flat)](http://cocoapods.org/pods/OrangeRealm)
[![Platform](https://img.shields.io/cocoapods/p/OrangeRealm.svg?style=flat)](http://cocoapods.org/pods/OrangeRealm)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- OrangeRealm helps you safety multithreading and UI integration using Realm

## Features
- Thread safety
- Simple interface
- Easy UI integration
- Support query limit, max, offset with filter, unlink
- Abstraction for life cycle of Realm

## Import

```swift
import OrangeRealm
```

## Example
![](etc/wqPDqB.gif)

### First - Create your RealmManager

#### Your RealmManager will match to one realm file by one to one

```swift
import RealmSwift
import OrangeRealm

class SampleRealmManager: AbstractRealmManager {

    // MARK: - Overridden: AbstractRealmManager

    override class var shared: AbstractRealmManager {
        struct Static {
            static let instance = SampleRealmManager()
        }
        return Static.instance
    }
    
    override var schemaVersion: UInt64 {
        return 1
    }
    
    override var fileURL: URL {
        return URL(fileURLWithPath: "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)/sample.realm", isDirectory: false)
    }
    
    override var objectTypes: [Object.Type]? {
        return [SampleObject.self]
    }
    
    override func deleteAll(_ realm: Realm) {
        realm.deleteAll()
    }
    
    override func process(forMigration migration: Migration, oldSchemaVersion: UInt64) {
    }
    
    override func recover() {
    }
}
```

### Second - Create your Realm Object

#### It is same to bagic implementation for realm object

```swift
import RealmSwift

class SampleObject: Object {
    dynamic var name: String?
    dynamic var id: Int = 0
    
    convenience init(id: Int, name: String?) {
        self.init()
        
        self.id = id
        self.name = name
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
```

### And Last - Integrate your UI

#### This sample is integration with UITableView

```swift
// Sync section for UITableView
// Update UITableView after add notification for realm
let result: RealmQueryResult<SampleObject> = SampleRealmManager.shared.query("id > 0", sortProperty: "id", ascending: false)
    .set(section: 1)
    .changed({ [weak self] (section, deletions, insertions, modifications) in
        guard let weakSelf = self else {return}
        
        weakSelf.tableView.beginUpdates()
        weakSelf.tableView.deleteRows(at: deletions, with: .none)
        weakSelf.tableView.insertRows(at: insertions, with: .none)
        weakSelf.tableView.reloadRows(at: modifications, with: .none)
        weakSelf.tableView.endUpdates()
    })

self.tableView.reloadData()
```

### Support results of 3 types - RealmQueryResult, Generic array, RealmResult
```swift
let result: RealmQueryResult<SampleObject> = SampleRealmManager.shared.query()
let result: [SampleObject] = SampleRealmManager.shared.objects()
let result: Results<SampleObject> = SampleRealmManager.shared.results()
```

### Doing limit, max query
```swift
let result: RealmQueryResult<SampleObject> = SampleRealmManager.shared.query("id > 0", sortProperty: "id", ascending: false, limit: 10, max: 10)
```

### Doing offset query with filter
```swift
let offset = 2

let result: RealmQueryResult<SampleObject> = SampleRealmManager.shared.query("id > 0", sortProperty: "id", ascending: false) { (object) -> Bool in
    return object.id! > offset
}
```

### Gain unlinked objects from Realm
```swift
let result: RealmQueryResult<SampleObject> = SampleRealmManager.shared.query("id > 0", sortProperty: "id", ascending: false, unlink: true)
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build OrangeRealm 0.1.0+.

To integrate OrangeRealm into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target '<Your Target Name>' do
    pod 'OrangeRealm', '~> 0.1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/OrangeRealm" ~> 0.1.0
```

Run `carthage update` to build the framework and drag the built `OrangeRealm.framework` into your Xcode project.

## Requirements

iOS Deployment Target 8.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

OrangeRealm is available under the MIT license. See the LICENSE file for more info.
