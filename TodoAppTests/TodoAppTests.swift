//
//  TodoAppTests.swift
//  TodoAppTests
//
//  Created by sergey on 07.11.2020.
//

import XCTest
@testable import TodoApp
import RealmSwift

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
        XCTAssert(icon2 == unwrappedIcon2)

        let icon3 = Icon.assetImage(name: "menu", tintHex: nil)
        let data3 = try! encoder.encode(icon3)
        print(String(data: data3, encoding: .utf8)!)
        let unwrappedIcon3 = try! JSONDecoder().decode(Icon.self, from: data3)

        XCTAssert(icon3 == unwrappedIcon3)
        
        let icon4 = Icon.image(url: "url://url")
        let data4 = try! encoder.encode(icon4)
        print(String(data: data4, encoding: .utf8)!)
        let unwrappedIcon4 = try! JSONDecoder().decode(Icon.self, from: data4)
        XCTAssert(icon4 == unwrappedIcon4)
    }
    
    func testRealmCascadeDeleting() {
        let realm = try! Realm(configuration: .init(inMemoryIdentifier: "realminmemory"))
        let project = RlmProject(name: "Project")
        let task = RlmTask(name: "Task", priority: .high, isDone: false)
        let tag = RlmTag(name: "Tag")
        let subtask = RlmSubtask(name: "Subtask")
        let taskDate = RlmTaskDate(date: .init(), reminder: .onDay, repeat: .everyWeekday)
        project.tasks.append(task)
        task.tags.append(tag)
        task.subtask.append(subtask)
        task.date = taskDate
        XCTAssert(realm.isEmpty)
        try! realm.write {
            realm.add(project)
        }
        XCTAssertNotNil(realm.objects(RlmProject.self).filter { $0.name == "Project" }.first!)
        XCTAssertNotNil(realm.objects(RlmTask.self).filter { $0.name == "Task" }.first!)
        XCTAssertNotNil(realm.objects(RlmTag.self).filter { $0.name == "Tag" }.first!)
        XCTAssertNotNil(realm.objects(RlmSubtask.self).filter { $0.name == "Subtask" }.first!)
        XCTAssertNotNil(realm.objects(RlmTaskDate.self).filter { $0.reminder == .onDay }.first!)
        try! realm.write {
            realm.cascadeDelete(project)
        }
        XCTAssert(!realm.isEmpty)
        try! realm.write {
            realm.delete(tag)
        }
        XCTAssert(realm.isEmpty)
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
