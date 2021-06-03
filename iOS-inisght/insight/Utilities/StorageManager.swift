//
//  StorageManager.swift
//  insight
//
//  Created by Nikolay Andonov on 4.06.21.
//

import Foundation
protocol StorageMainainable: Codable, Equatable {
    static var key: String { get }
}

class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private var userDefualts: UserDefaults {
        UserDefaults.standard
    }
    
    func setItem<T: StorageMainainable>(_ item: T) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(item) {
            let defaults = userDefualts
            defaults.set(encoded, forKey: T.key)
        }
    }
    
    func getItem<T: StorageMainainable>() -> T? {
        if let savedItems = userDefualts.object(forKey: T.key) as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode(T.self, from: savedItems) {
                return items
            }
        }
        return nil
    }
    
    func remove<T: StorageMainainable>(_ type: T.Type) {
        userDefualts.removeObject(forKey: T.key)
    }
    
    func getAllItems<T: StorageMainainable>() -> [T] {
        if let savedItems = userDefualts.object(forKey: T.key) as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([T].self, from: savedItems) {
                return items
                
            }
        }
        return []
    }
    
    func addItem<T: StorageMainainable>(_ item: T) {
        var fetchedItems: [T] = []
        if let savedItems = userDefualts.object(forKey: T.key) as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([T].self, from: savedItems) {
                fetchedItems = items
            }
        }
        fetchedItems.append(item)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(fetchedItems) {
            let defaults = userDefualts
            defaults.set(encoded, forKey: T.key)
        }
    }
    
    func removedStoredItem<T: StorageMainainable>(_ item: T) {
        if let savedItem = userDefualts.object(forKey: T.key) as? Data {
            let decoder = JSONDecoder()
            if var items = try? decoder.decode([T].self, from: savedItem) {
                items.removeAll(where: { $0 == item })
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(items) {
                    let defaults = userDefualts
                    defaults.set(encoded, forKey: T.key)
                }
            }
        }
    }
    
    func isItemContained<T: StorageMainainable>(_ item: T) -> Bool {
        if let savedItems = userDefualts.object(forKey: T.key) as? Data {
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([T].self, from: savedItems) {
                return items.contains(where: { $0 == item })
            }
        }
        return false
    }
}
