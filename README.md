# Aussie Portfolio iOS App

A comprehensive portfolio management app built with UIKit, MVVM architecture, Coordinators pattern, and Realm for persistence.

## Architecture

- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Coordinators**: Navigation flow management
- **Realm Database**: Local data persistence
- **Combine Framework**: Reactive data binding

## Setup Instructions

### Adding Realm via Swift Package Manager (Recommended)

1. Open `Aussie Porfolio.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the Realm Swift URL: `https://github.com/realm/realm-swift.git`
4. Set the version to **10.45.0** or later
5. Click **Add Package**
6. Select **RealmSwift** from the package products
7. Click **Add Package**

### Alternative: Manual SPM Setup

If the above doesn't work:

1. In Xcode, select your project in the navigator
2. Select your app target
3. Go to the **General** tab
4. Scroll down to **Frameworks, Libraries, and Embedded Content**
5. Click the **+** button
6. Search for and add **RealmSwift**

## Project Structure

```
Aussie Porfolio/
├── Models/              # Realm data models
│   ├── Property.swift
│   ├── Asset.swift
│   ├── CashAccount.swift
│   └── Liability.swift
├── ViewModels/          # Business logic and data management
│   ├── DashboardViewModel.swift
│   └── PropertyViewModel.swift
├── Views/               # View controllers and UI
│   ├── Dashboard/
│   ├── Properties/
│   ├── Assets/
│   ├── CashAccounts/
│   └── Liabilities/
├── Coordinators/        # Navigation coordinators
│   ├── Coordinator.swift
│   └── MainCoordinator.swift
└── Services/            # Data services
    └── RealmService.swift
```

## Features

- **Dashboard**: Overview of total portfolio value, net worth, and asset allocation
- **Properties**: Manage real estate investments with loan tracking
- **Assets**: Track shares, cash, and other investments
- **Cash Accounts**: Monitor savings and bank accounts
- **Liabilities**: Track debts and loans

## Running the App

1. Open `Aussie Porfolio.xcodeproj` in Xcode
2. Add Realm dependency (see setup instructions above)
3. Select your target device or simulator
4. Press Cmd+R to build and run

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+