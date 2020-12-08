# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'MapQuiz' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MapQuiz
  pod 'Firebase/Core'
  pod 'Fabric', '~> 1.9.0'
  pod 'Crashlytics', '~> 3.12.0'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end