//
//  TodoAppTests.swift
//  TodoAppTests
//
//  Created by sergey on 07.11.2020.
//

import XCTest
@testable import TodoApp

class TodoAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTextIconCoding() throws {
        let encoder = JSONEncoder()
        let icon1 = Icon.text("🚒")
        let data = try! encoder.encode(icon1)
        print(String(data: data, encoding: .utf8)!)
        let unwrappedIcon1 = try! JSONDecoder().decode(Icon.self, from: data)
        XCTAssert(icon1 == unwrappedIcon1)
        
        let icon2 = Icon.assetImage(name: "menu", tintHex: "#fcfcfc")
        let data2 = try! encoder.encode(icon2)
        print(String(data: data2, encoding: .utf8)!)
        let unwrappedIcon2 = try! JSONDecoder().decode(Icon.self, from: data2)
        print("icon2: \(icon2) unwrappedIcon2: \(unwrappedIcon2)")
        XCTAssert(icon2 == unwrappedIcon2)

        let icon3 = Icon.assetImage(name: "menu", tintHex: nil)
        let data3 = try! encoder.encode(icon3)
        print(String(data: data3, encoding: .utf8)!)
        let unwrappedIcon3 = try! JSONDecoder().decode(Icon.self, from: data3)
        print("icon3: \(icon3) unwrappedIcon3: \(unwrappedIcon3)")

        XCTAssert(icon3 == unwrappedIcon3)
        
        let icon4 = Icon.image(url: "url://url")
        let data4 = try! encoder.encode(icon4)
        print(String(data: data4, encoding: .utf8)!)
        let unwrappedIcon4 = try! JSONDecoder().decode(Icon.self, from: data4)
        XCTAssert(icon4 == unwrappedIcon4)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

func ==(lhs: Icon, rhs: Icon) -> Bool {
    switch (lhs, rhs) {
    case let (.text(txt), .text(txt2)):
        return txt == txt2
    case let (.image(url), .image(url2)):
        return url == url2
    case let (.assetImage(name1, tint1), .assetImage(name2, tint2)):
        return name1 == name2 && tint1 == tint2
    default: return false
    }
}
