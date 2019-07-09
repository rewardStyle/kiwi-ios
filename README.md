# Kiwi - iOS
Kiwi, a set of controllers for your data

## Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries in your projects.

## Development pod
This is a development pod, to use it in your project, clone the repo on a folder of your computer and point to it in the pod file using the ` :path => `  sintax

Anytime you want to change the code, treat it as a normal repositry, making commits and pushing when necessary

Running ` pod install ` or  ` pod update ` doesn't override the changes as the podfile is pointing to your local copy of the repository

### Podfile
```ruby
pod 'Kiwi', :path => '~/Path/To/Folder/Containing/Kiwi'
```
