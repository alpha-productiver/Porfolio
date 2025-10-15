import Foundation
import RealmSwift
internal import Realm

class PropertyViewModel {
    var properties: [Property] = [] {
        didSet { onPropertiesChanged?() }
    }
    var selectedProperty: Property?
    var isAddingProperty = false
    var isEditingProperty = false

    var onPropertiesChanged: (() -> Void)?

    private let realmService: RealmService
    private var notificationToken: NotificationToken?

    init(realmService: RealmService = .shared) {
        self.realmService = realmService
        loadProperties()
    }

    func loadProperties() {
        properties = realmService.fetch(Property.self)
        observeChanges()
    }

    private func observeChanges() {
        let realm = realmService.realm
        notificationToken = realm.objects(Property.self).observe { [weak self] _ in
            self?.properties = self?.realmService.fetch(Property.self) ?? []
        }
    }
    
    func addProperty(_ property: Property) {
        realmService.save(property)
    }
    
    func updateProperty(_ property: Property,
                        address: String,
                        state: String,
                        purchasePrice: Double,
                        currentValue: Double,
                        loanData: (amount: Double, interestRate: Double)?) {
        realmService.update {
            property.name = address
            property.address = address
            property.state = state
            property.purchasePrice = purchasePrice
            property.currentValue = currentValue
            property.updatedAt = Date()

            // Handle loan
            if let loan = loanData {
                if let existingLoan = property.loan {
                    // Update existing loan
                    existingLoan.amount = loan.amount
                    existingLoan.interestRate = loan.interestRate
                } else {
                    // Create new loan
                    let newLoan = PropertyLoan()
                    newLoan.amount = loan.amount
                    newLoan.interestRate = loan.interestRate
                    newLoan.loanType = "variable"
                    property.loan = newLoan
                }
            } else {
                // Remove loan if exists
                if let existingLoan = property.loan {
                    realmService.realm.delete(existingLoan)
                    property.loan = nil
                }
            }
        }
    }
    
    func deleteProperty(_ property: Property) {
        realmService.delete(property)
    }
    
    func createNewProperty() -> Property {
        return Property()
    }
    
    deinit {
        notificationToken?.invalidate()
    }

    // MARK: - Computed Properties

    var totalPropertyValue: Double {
        return properties.reduce(0) { $0 + $1.currentValue }
    }

    var totalEquity: Double {
        return properties.reduce(0) { $0 + $1.equity }
    }

    var totalPropertyValueText: String {
        return "$\(Int(totalPropertyValue).formattedWithSeparator())"
    }

    var totalEquityText: String {
        return "$\(Int(totalEquity).formattedWithSeparator())"
    }
}
