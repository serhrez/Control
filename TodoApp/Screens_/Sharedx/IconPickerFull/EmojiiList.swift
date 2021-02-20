//
//  EmojiiList.swift
//  TodoApp
//
//  Created by sergey on 24.12.2020.
//

import Foundation
extension IconPickerFullVc {
    
    struct Emojii {
        var emoji: String
        var description: String
    }
    
    enum EmojiiSection: String {
        case smileysAndPeople
        case animalsAndNature
        case foodAndDrink
        case activity
        case travelAndPlaces
        case objects
        case symbols
        case flags
        
        var viewString: String {
            switch self {
            case .smileysAndPeople: return "Smileys & People".localizable()
            case .animalsAndNature: return "Animals & Nature".localizable()
            case .foodAndDrink: return "Food & Drink".localizable()
            case .activity: return "Activity".localizable()
            case .travelAndPlaces: return "Travel & Places".localizable()
            case .objects: return "Objects".localizable()
            case .symbols: return "Symbols".localizable()
            case .flags: return "Flags".localizable()
            }
        }
    }
    static let allEmojis: [ItemWithSection] = Readerr.getAllEmojis()

}

fileprivate enum Readerr {
    static func getAllEmojis() -> [(IconPickerFullVc.EmojiiSection, [IconPickerFullVc.Emojii])] {
        guard let fullString = getFullString() else { return [] }
        print("all emojis got")
        return fullString
            .split(separator: "_")
            .map { $0.split(whereSeparator: { $0.isNewline }) }
            .compactMap { (str: [Substring.SubSequence]) -> (IconPickerFullVc.EmojiiSection, [IconPickerFullVc.Emojii])? in
                guard let sectionString = str.first.flatMap({ String($0) }),
                      let section = IconPickerFullVc.EmojiiSection(rawValue: sectionString) else { return nil }
                let formatted = str.dropFirst().map { $0.split(separator: "^") }
                let emojiis = formatted.map { IconPickerFullVc.Emojii(emoji: String($0[0]), description: String($0[1])) }
                return (section, emojiis)
            }
    }
    
    private static func getFullString() -> String? {
        if let filePath = Bundle.main.path(forResource: "EmojiList", ofType: "txt") {
            let contents = try? String(contentsOfFile: filePath)
            return contents
        }
        return nil
    }
}
