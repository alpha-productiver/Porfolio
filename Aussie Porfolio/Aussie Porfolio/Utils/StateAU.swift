import Foundation

enum StateAU: String, CaseIterable {
    case NSW = "NSW"
    case VIC = "VIC"
    case QLD = "QLD"
    case WA = "WA"
    case SA = "SA"
    case TAS = "TAS"
    case ACT = "ACT"
    case NT = "NT"

    var fullName: String {
        switch self {
        case .NSW: return "New South Wales"
        case .VIC: return "Victoria"
        case .QLD: return "Queensland"
        case .WA: return "Western Australia"
        case .SA: return "South Australia"
        case .TAS: return "Tasmania"
        case .ACT: return "Australian Capital Territory"
        case .NT: return "Northern Territory"
        }
    }
}
