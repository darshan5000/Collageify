# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Collageify' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'ImageScrollView'
  pod 'IQKeyboardManagerSwift'
  pod 'IGColorPicker'
  pod 'SVProgressHUD'
  pod 'ZoomImageView'
  pod 'DKImagePickerController’
  pod 'Firebase/Analytics'
  pod 'SwiftyStoreKit'
  pod 'Firebase/RemoteConfig'
  pod 'lottie-ios'
  pod 'Google-Mobile-Ads-SDK'

  # Pods for CollageMaker

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
           end
      end
    end
  end
end
