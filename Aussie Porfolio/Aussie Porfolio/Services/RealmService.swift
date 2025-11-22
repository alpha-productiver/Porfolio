import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()
    
    let realm: Realm
    
    private init() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 6,
                migrationBlock: { migration, oldSchemaVersion in
                    // Migration from v1 to v2: Removed otherCosts, stampDuty, legalFees
                    if oldSchemaVersion < 3 {
                        // Realm automatically handles removed properties
                    }
                    // Migration from v3 to v4: Added insurance field
                    if oldSchemaVersion < 4 {
                        // Realm automatically handles new optional properties
                    }
                    // Migration from v4 to v5: Restructured insurance to separate building and landlord
                    if oldSchemaVersion < 5 {
                        // Realm automatically handles property changes
                    }
                    // Migration to v6: Added repaymentFrequencyPerYear, customPaymentPerPeriod, usesManualRepayment to PropertyLoan
                    if oldSchemaVersion < 6 {
                        migration.enumerateObjects(ofType: "PropertyLoan") { _, newObject in
                            newObject?["repaymentFrequencyPerYear"] = 12
                            newObject?["customPaymentPerPeriod"] = 0.0
                            newObject?["usesManualRepayment"] = false
                        }
                    }
                },
                deleteRealmIfMigrationNeeded: false
            )

            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()

            print("Realm database path: \(realm.configuration.fileURL?.absoluteString ?? "Unknown")")
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func save<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            print("Failed to save object: \(error)")
        }
    }
    
    func update(block: () -> Void) {
        do {
            try realm.write(block)
        } catch {
            print("Failed to update: \(error)")
        }
    }
    
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Failed to delete object: \(error)")
        }
    }
    
    func fetch<T: Object>(_ type: T.Type) -> [T] {
        return Array(realm.objects(type))
    }
    
    func fetch<T: Object>(_ type: T.Type, predicate: NSPredicate) -> [T] {
        return Array(realm.objects(type).filter(predicate))
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Failed to delete all: \(error)")
        }
    }
}
