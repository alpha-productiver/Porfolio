platform :ios, '14.0'
use_frameworks!

project 'Aussie Porfolio/Aussie Porfolio.xcodeproj'

target 'Aussie Porfolio' do
  # Realm for database persistence
  pod 'RealmSwift', '~> 10.45.0'
  
  # Optional: Add these for additional functionality
  # pod 'Charts' # For portfolio charts
  # pod 'IQKeyboardManagerSwift' # For better keyboard handling
  # pod 'SnapKit' # For easier Auto Layout
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end