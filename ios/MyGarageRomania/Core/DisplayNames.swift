import Foundation

enum FuelTypeDisplay {
    static func displayName(_ rawValue: String) -> String {
        rawValue.localizedDomainLabel(namespace: "fuel.type")
    }
}

enum LegalDocumentType {
    static func displayName(_ rawValue: String) -> String {
        rawValue.localizedDomainLabel(namespace: "legal.type")
    }
}

enum MaintenanceType {
    static func displayName(_ rawValue: String) -> String {
        rawValue.localizedDomainLabel(namespace: "maintenance.type")
    }
}

enum ExpenseType {
    static func displayName(_ rawValue: String) -> String {
        rawValue.localizedDomainLabel(namespace: "expense.type")
    }
}

enum StatusDisplay {
    static func displayName(_ rawValue: String) -> String {
        rawValue.localizedDomainLabel(namespace: "status")
    }
}

extension String {
    func localizedDomainLabel(namespace: String) -> String {
        let key = "\(namespace).\(self)"
        let fallback = domainDisplayName
        return NSLocalizedString(key, tableName: nil, bundle: .main, value: fallback, comment: "")
    }
}
