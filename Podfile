use_frameworks!

pod 'Groot', '1.2'
pod 'GoogleMaps', '1.12.1'
pod 'ObjectMapper', '1.1.5'
pod 'ChameleonFramework/Swift', '2.1.0'
pod 'DZNEmptyDataSet', '1.7.3'
pod 'PhoneNumberKit', '~> 0.6'
pod 'FLEX', '~> 2.0', :configurations => ['Debug']

post_install do |installer|
    `rm -rf Pods/Headers/Private`
    `find Pods -regex 'Pods\/.*\.modulemap' -print0 | xargs -0 sed -i '' 's/private header.*//'`
end
