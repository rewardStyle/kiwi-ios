Pod::Spec.new do |spec|
  spec.name         = 'Kiwi'
  spec.version      = '1.0.0'
  spec.license      = 'MIT'
  spec.summary      = 'Kiwi, a set of controllers for your data.'
  spec.homepage     = 'https://github.com/InQBarna/kiwi-ios'
  spec.author       = { 'David Romacho' => 'david.romacho@inqbarna.com', 'Santiago Becerra' => 'santiago.becerra@inqbarna.com' }
  spec.source       = { :git => 'https://github.com/InQBarna/kiwi-ios.git', :tag => 'v1.0.0' }
  spec.source_files = 'Kiwi/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
  spec.swift_version = '5.0'
  spec.frameworks   = 'Foundation', 'CoreData'
end
