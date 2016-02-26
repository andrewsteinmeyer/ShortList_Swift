use_frameworks!

pod 'Groot'
pod 'GoogleMaps'
pod 'ObjectMapper'
pod 'ChameleonFramework/Swift'
pod 'DZNEmptyDataSet'
pod 'PhoneNumberKit', '~> 0.6'
pod 'FLEX', '~> 2.0', :configurations => ['Debug']

post_install do |installer|
    `rm -rf Pods/Headers/Private`
    `find Pods -regex 'Pods\/.*\.modulemap' -print0 | xargs -0 sed -i '' 's/private header.*//'`
end
