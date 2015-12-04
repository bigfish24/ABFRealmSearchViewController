Pod::Spec.new do |s|
  s.name         = "RealmSearchViewController"
  s.version      = "1.5"
  s.summary      = "Drop-in text search interface for Realm Swift"
  s.description  = <<-DESC
The RealmSearchViewController class creates a controller object that manages a table view and search bar to display and respond to input for text search against a Realm Swift object class.
                   DESC
  s.homepage     = "https://github.com/bigfish24/ABFRealmSearchViewController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adam Fish" => "af@realm.io" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/bigfish24/ABFRealmSearchViewController.git", :tag => "v#{s.version}" }
  s.source_files  = "RealmSearchViewController/*.{swift}"
  s.requires_arc = true
  s.dependency "RBQFetchedResultsController", ">= 2.4"
  s.dependency "RealmSwift", ">= 0.96"

end
