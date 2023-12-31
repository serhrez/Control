//
//  Notifications.swift
//  TodoApp
//
//  Created by sergey on 12.01.2021.
//

import Foundation
import UserNotifications
import SwiftDate

class Notifications: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    static let shared = Notifications()
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Authorization) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(.authorized)
            case .denied, .ephemeral, .provisional:
                completion(.deniedPreviously)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (didAllow, error) in
                    if didAllow {
                        completion(.authorized)
                    } else {
                        print(String(describing: error))
                        completion(.denied)
                    }
                }
            @unknown default:
                completion(.deniedPreviously)
            }
        }
    }
        
    func removeNotifications(id: String) {
        let identifier1 = id
        let identifier2 = id + "reminder"
        let identifiers = [identifier1, identifier2]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
        
    func scheduleTask(task: RlmTask, date: Date, reminder: Reminder?, repeatt: Repeat?) {
        removeNotifications(id: task.id)
        scheduleReminder(task: task, date: date, reminder: reminder)
        scheduleNotification(identifier: task.id, name: task.name, body: task.taskDescription, date: date, repeatt: repeatt)
    }
    
    private func scheduleReminder(task: RlmTask, date: Date, reminder: Reminder?) {
        guard let reminder = reminder else { return }
        let newDate: Date
        switch reminder {
        case .oneDayEarly:
            newDate = date.dateAt(.yesterday)
        case .oneHourBefore: newDate = date - 1.hours
        case .oneWeekBefore: newDate = date - 1.weeks
        case .tenMinutesBefore: newDate = date - 10.minutes
        case .thirtyMinutesBefore: newDate = date - 30.minutes
        case .twoHoursBefore: newDate = date - 2.hours
        case .fiveMinutesBefore: newDate = date - 5.minutes
        }
        scheduleNotification(identifier: task.id + "reminder", name: "\(task.name)", body: task.taskDescription, date: newDate, repeatt: nil)
        // Postpone date according to reminder or cancel nexisting notifications
    }
    
    private func scheduleNotification(identifier: String, name: String, body: String, date: Date, repeatt: Repeat?) {
        let categoryIdentifier = identifier + "ctg"
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifier
        
        let triggerDate: DateComponents
        if let repeatt = repeatt {
            let dateComponents: Set<Calendar.Component>
            switch repeatt {
            case .everyYear:
                dateComponents = [.month, .day, .hour, .minute, .second]
            case .everyDay:
                dateComponents = [.hour, .minute, .second]
            case .everyWeek:
                dateComponents = [.weekday, .hour, .minute, .second]
            case .everyMonth:
                dateComponents = [.day, .hour, .minute, .second]
            }
            triggerDate = Calendar.current.dateComponents(dateComponents, from: date)
        } else {
            triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }

}
extension Notifications {
    enum Authorization {
        case deniedPreviously
        case denied
        case authorized
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
