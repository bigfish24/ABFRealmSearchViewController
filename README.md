# ABFRealmSearchViewController

The `ABFRealmSearchViewController` class creates a controller object that manages a table view and search bar to display and respond to input for text search against a Realm object class. 

_**This allows for the creation of a text search interface in as little as 27 lines of code!**_

The class performs the text search on a background thread (via [RBQFetchedResultsController](https://github.com/Roobiq/RBQFetchedResultsController)) allowing for non-blocking as-you-type searching.

The controller is meant to be subclassed. By default the `resultsDataSource` and `resultsDelegate` protocols are set as `self`, so that the subclass can implement these methods.

####Installation
`ABFRealmSearchViewController` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:
```
pod "ABFRealmSearchViewController"
```
####Demo

Build and run/test the Example project in Xcode to see `ABFRealmSearchViewController` in action. This project uses CocoaPods. If you don't have [CocoaPods](http://cocoapods.org/) installed, grab it with [sudo] gem install cocoapods.

```
git clone https://github.com/bigfish24/ABFRealmSearchViewController.git
cd ABFRealmSearchViewController/ABFRealmSearchViewControllerExample
pod install
open ABFRealmSearchViewController.xcworkspace
```
#####Note (as of June 2nd, 2015)
Cocoapods has a [reported issue](https://github.com/CocoaPods/CocoaPods/issues/3557) that overwrites the file permissions for resources included with the pod. To fix, perform this call after `pod install`:
```
chmod 644 Pods/RealmSFRestaurantData/SFRestaurantScores.realm
```

#####Requirements

* iOS 8+
* Xcode 6

