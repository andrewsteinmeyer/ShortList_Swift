use_frameworks!
pod 'Meteor'
pod 'Groot'
pod 'GoogleMaps'
pod 'ObjectMapper'
pod 'ChameleonFramework/Swift'

post_install do |installer|
    `rm -rf Pods/Headers/Private`
    `find Pods -regex 'Pods\/.*\.modulemap' -print0 | xargs -0 sed -i '' 's/private header.*//'`
end
