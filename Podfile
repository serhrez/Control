# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TodoApp' do
  use_frameworks!

  # UI
  pod 'Material', :git => 'https://github.com/cointowitcher/Material'
  pod 'NewPopMenu', :path => 'LocalPods/NewPopMenu'
  pod 'SnapKit'
  pod 'AttributedLib', :git => 'https://github.com/cointowitcher/Attributed'
  pod 'SwipeCellKit'
  pod 'Typist'
  pod 'WSTagsField', :git => 'https://github.com/cointowitcher/WSTagsField'
  pod 'ResizingTokenField', :path => 'LocalPods/ResizingTokenField'
  pod 'GrowingTextView'
  pod 'JTAppleCalendar'
  pod 'InfiniteLayout'

  # Not UI
  pod 'RealmSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'SwiftDate'
  pod 'SwiftyBeaver'
  pod 'ReactorKit'
  pod 'DeepDiff'

  def testing_pods
    pod 'Quick'
    pod 'Nimble'
  end

  target 'TodoAppTests' do
    testing_pods
  end

  target 'TodoAppUITests' do
    testing_pods
  end

end
