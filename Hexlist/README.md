 ```
                                           _   _           _ _     _   
                                          | | | | _____  _| (_)___| |_ 
                                          | |_| |/ _ \ \/ / | / __| __|
                                          |  _  |  __/>  <| | \__ \ |_ 
                                          |_| |_|\___/_/\_\_|_|___/\__|
                                                                                
```

#Content From Service Managers

##QueryWrappers

Query wrappers are objects that uniquely identify a request for a bundle of links or metadata. they mainly exist so we can find the navigation query and get info from the wrapper so that we can cancel it. That's why operations on it need to be in queues or they can cause a crash.

##Metadata

Metadata requests are requests to a content service (like dropbox or box). The response block for a metadata request only fires off once, because we only ever request info on one folder.

##Sharable Links

Requests for shareable links. Each time you request a group of links for multiple files or content sources we stack them together. Response blocks for sharable links should be expected to fire off multiple times per group of links requested. This is because the block executes for each link.

###What is it?

It's a way to share a large number of links with another phone from your dropbox.

###How is it structured?

1 - a dictionary whose keys are unique file paths that are on phone paths to representations of cloud files. The values start empty but get filled out as the downloadable shareable links produced by dropbox.

2 - a delegate method that returns the dictionary of links from gd service manager or db service manager to whatever class implements the delegate (links in the inbox probably).

###How does it work?

1 - the user selects a bunch of content sources(files).

2 - the user presses a button to store, grab, or send links

3 - internally we create a dictionary with the path of each thing shared and grab all the links for those files. Everytime a delegate/response comes in for a link we add the link into the dictionary slot for the file. everytime a link comes in via delegate we check to see if all entries in the dictionary have values (or we pass the expected # of files and check if we got that many links but I like the dictionary method better.) Then once the dictionary is full we call a delegate method and pass it back to the home view controller with all the links. The dictionary is stored in a query wrapper and so passed through the life of all delegate responses or completion blocks.

#HexManager

This class manages all methods related to Hex and Link objects with respect to the 'Inbox' and 'MyHexlist'.

It Contains methods to convert Hex and Link Objects to their JsonModel equivalents and vice versa. It is designed to give flexibility in the type of information a hexJM/LinkJM object can hold when two peers with different app versions are sending HexJM objects to each other.

The end result is to allow us to recreate a stable Realm Hex object from a hexHM object no matter the version of HexJM/LinkJM the sender and receiver are using

//Case 1: Sender sends hexJM with extra fields -> receiver ignores extra fields and uses only fields it needs.
//Case 2: Sender sends hexJM with missing fields -> receiver fills in missing fields with default values

//The fact that every property of hexJM is optional, allows for us to convert the hexJMJson string into a valid (even if partially filled) hexJM object regardless of any missing properties (no issues arise from extra properties to begin with).

#Storage Structures

##Realm

###Realm Objects

`Hex`

A Hex is used to package a set of links, and contains metadata on the contents as well as the sender (when the hex is sent from a user). Hexes are used to store sets of links in-app and can be sent between users (when converted to their JsonModel equivalents).

`Link`

A Link is used to represent a real world link. It is composed of a url as well as description & service metadata.

`File`

A representation of a file object in realm, previous stored as .filesystem.json. 

###JsonModel Objects

Most of our JsonModel objects are used as close mirrors of our realm objects, and are used to give us extra flexibility with our object models than we normally have with Realm Objects alone. 

These JsonModels are primarily used during multipeer data sends, so that we may easily generate a json representation of our Realm objects, which can be turned into nsdata and sent/reconstructed between peers.

Our JsonModels capture the essential information contained in a Realm Object, while ommitting certain properties that are only useful in the context of persistence, such as UUID, HexLocation, and (creation) timestamp.

`dataSendWrapper`

This is the top level JsonModel object that we send between peers in multipeer data sends. It consists of a version field (app version), a operationType field to identify what to do with the data, a jmObjectType field to identify which type of JM object it contains, as well as a jmObject field containing the object.

This wrapper class allows us to identify JM objects that are stringified or turned into NSData and that need to be reconstructed elsewhere without context of the type of object and/or with variability in the properties that object can hold.

At this point, versionType is a safeguard to future proof any changes in the way we parse JM objects or communicate data and operations between peers. It should proove useful in the future.

`HexJM`

`LinkJM`

###Json Structures

#FileSystemRealm

An In memory realm that loads and purges everytime we navigate back up a directory. This is the replacement for the on disk persistence with .filesystem.json.

1. We have a stack path filled with Realm Files we push files on an pop files off.

2. Everytime we load a set of metdata we load the new metadata into the RLMFile object for the parent as the parent's children. We then run our sorts directly on the [RLMArray](https://realm.io/docs/objc/latest/api/Classes/RLMArray.html) of children using the method that sorts an rlm array and returns realm results. We then use those realm results to populate the collectionview.

3. Everytime we navigate back up we get a reference to each of the popped parent's children and destroy them from Realm in a background thread.

4. We replaced the parentPath with the parentFile reference.

##fsAbstraction

Stores abstract information about the filesystem, liek references to the root and arrays with selected files.

##fsInterface

Interface with the realm filesystem, populate new directories, save stuff to realm.

##fsInit

Initialize and setup the realm file system.

#SharedSerivceManager

Even though dropbox and box can be queried globally by importing their framework files we access information about them (like whether they are authed) through this global servicemanager.

This is because 1. it's more modular that importing every single service framework everywhere we want to use global methods for dropbox/box/future thigns 2. it's easier to import one shared service manager 3. some services like google cannot be accessed easily in other classes. (for example the google authorizer can't be authorized in more than one place on from the same keychain entry).

Advantages of this are that we do not need to query realm everytime we navigate. It simplifes the process greatly and improves performance.

Learn about RLMArrays here:

https://realm.io/docs/objc/latest/api/Classes/RLMArray.html

You can clone references to realm objects in other realm objects like so:

https://github.com/realm/realm-cocoa/issues/2105

#DBServiceManager (our interface to normalize dropbox)
#GDServiceManager (our interface to normalize google drive)
#BXServiceManager (our interface to normalize box) 


#Resources

Guide to doing stuff with cocoapods:

https://guides.cocoapods.org/

Create UIColor with hexcolors:

https://github.com/mattquiros/UIColorHexColor

Realm Docs:

https://realm.io/news/nspredicate-cheatsheet/

https://realm.io/docs/objc/latest

Realm performance observation:

https://github.com/realm/realm-cocoa/issues/796

How Realm does generics:

```objc
- (RLMResults *)sortedResultsUsingDescriptors:(NSArray RLM_GENERIC(RLMSortDescriptor *) *)properties;
```

Swift:

https://github.com/realm/SwiftLint

https://github.com/github/swift-style-guide

Multi peer ghost peers explanation/resolution:

http://stackoverflow.com/questions/29220497/why-is-multipeer-connectivity-framework-finding-itself-as-a-foreign-peer-as-well

Explanation of iOS property values:

http://stackoverflow.com/questions/2255861/property-and-retain-assign-copy-nonatomic-in-objective-c



#Notes On SDKs

##Dropbox
`#import <DropboxSDK/DropboxSDK.h>` statments need to be in the .m file and in the .h file referencing the .m file there needs to be a `#import <UIKit/UIKit.h>`. 

Setup page for dropbox objective C sdk here:

https://www.dropbox.com/developers-v1/core/sdks/ios

Setup page for dropbox swift sdk here with cocoa pods:

https://github.com/dropbox/SwiftyDropbox

##GoogleDrive

Make sure to install [cocoa pods](https://guides.cocoapods.org/using/getting-started.html):

`sudo gem install cocoapods` 

Set in your podfile like so: 

`pod 'Google-API-Client', '~> 1.0.422'`

then do:

`pod install`

in the same directory as the `Podfile`.

[https://cocoapods.org/pods/Google-API-Client](https://cocoapods.org/pods/Google-API-Client)

Google Drive App Console:

https://console.developers.google.com/apis/credentials

console -> api -> credentials -> oauth screen.

##Box

Make sure to install [cocoa pods](https://guides.cocoapods.org/using/getting-started.html):

`sudo gem install cocoapods` 

Set in your podfile like so: 

`pod 'box-ios-sdk', '~> 1.0.11'`

then do:

`pod install`

in the same directory as the `Podfile`.

After that you can look at this repo:

[https://github.com/box/box-ios-sdk](https://github.com/box/box-ios-sdk)

specifically the `.md` files in the doc folder. 

Note this issue with the login cancel button from their examples as of Jan 9 2016, they don't work at all. You gotta add your own cancel button.

Box App Console:

[https://app.box.com/developers](https://app.box.com/developers)

[https://app.box.com/apps](https://app.box.com/apps)

[http://info.box.com/content-api](http://info.box.com/content-api)

#Encountered Problems

BoxSDK:

Cancel called on BoxRequest object does not actaully cancel the request (it is supposed to if you look in the code) but it doesn't. It does however set a boolean on that request object which you can check via a meethod in your block completion handler; 'isCancelled' is the method name.

Deleting Pods from project:

http://stackoverflow.com/questions/16427421/how-to-remove-cocoapods-from-a-project

follow this guide except do not delete your Podfile

Building google shit for iOS9 (and 6 7 8, apparently their instructions haven't works since iOS 6, somehow biggest software company in the world...) 

http://stackoverflow.com/questions/32822629/gtmsessionfetcher-h-file-not-found-upgrading-app-to-latest-google-api-objectivec

IGNORE THE GOOGLE DRIVE QUICK START here:https://developers.google.com/drive/ios/quickstart
it's fucking useless and it's 3-4 iOS versions out of date.

Ok so this explains why the quickstart guide makes no sense. https://github.com/google/google-api-objectivec-client/issues/127

I was straightup UNABLE to fix google's new api. So i settled on editing the problems with their old one.

Line 778 in GTMHTTPFetcherLogging.m gotta add:
```
[responseDataFileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
```
instead of:

```
NSString *escapedResponseFile = [responseDataFileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
```

To solve the "Multiple methods names initWithArray" found error:
http://stackoverflow.com/questions/32615688/google-api-error-multiple-methods-named-initwitharray-found

its this the real solution? install w/ cocoapods? http://stackoverflow.com/questions/32875078/google-drive-sdk-ios9
https://cocoapods.org/pods/Google-API-Client 

but why is it not listed on google's official cocoapods page here:
https://cocoapods.org/pods/Google

Wtvr it works. Install google with CocoaPods.

Warnings in third party code:

Do this - http://nshipster.com/pragma/
And this - http://fuckingclangwarnings.com/


Test target issue with search paths for frameworks:

```
directory not found for option '-F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator9.2.sdk/Developer/Library/Frameworks':
```

http://stackoverflow.com/questions/30827022/xcode-7-library-search-path-warning

Incorrect version of realm on iOS update:

looks like this - 

```
ld: '/Users/yvanscher/repositories/Hexlist/Pods/Realm/core/librealm-ios.a(encrypted_file_mapping-iPhoneOS-no-bitcode.o)' does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target. for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
use this - http://stackoverflow.com/questions/30848208/new-warnings-in-ios9

Path components appearing lowercased and failing stirng compares:

```
[displayPath pathComponents];
```

converts path components with spaces in them to lower case. Path components without spaces are left upper case. This isn't mentioned anywhere. wtf. That's kind of random. Probably a vestige of some ancient thing they're using under the hood.

Double pushing content service like dropbox on auth, pushing once when the user presses, and then again when finished with auth. It's a result of a confused app, That 1. thinks it's linked so tries to get file info, this fails with a 401 error, then it unlinks, then it tries to link teh user, but the query wrapper created for this original mistaken query is not deleted. This causes dropbox to be double pushed onto the stack because navigationLoad get's called 2x. To settle this all failures need to get rid of the original query fired off from them. This usually occurs if the app is unlinked from a browser or other client while the user is in app.


DBrestClients intializing before auth is done. You cannot initialize any dropbox rest clients before teh auth process is done. This will cause weird 401 errors.

Problems loading % characters for dropbox:

This maybe be because the url request being sent to dropbox is not encoded. pathOnDropbox in getFileInfoFromDropboxPath in DBServiceManager class. 

Learn how to encode url requests in iOS 9 here: http://stackoverflow.com/questions/32242712/replacement-for-stringbyaddingpercentescapesusingencoding-in-ios9

Preventing import loops in classes that rely on dropbox sdk code but need to be imported by other classed that rely on dropbox sdk like DBServiceManager:

If you need to write a method that uses a class inside the Dropbox SDK like DBRestClient and it needs
to go into a .h just set it up as an `id` type and cast it to the actual type in the init method in the .m file.

Huge issue on loadSharableLinkFailedWithError ('fixed magically using dispatch async main queue'):

In the loadSharableLinkFailedWithError in the DBServiceManager class has a mysterious enigmatic crash.

1. it's not caused by any of the inputs to the method (attached to query wrappers or otherwise), not caused by delegate methods referencing deallocated stuff (we checked)
2. the crash is related to the dbQueryWrapperHolder removeObjectsAtIndexes but not directly caused by the call to that method. It doesn't crash when the call happens but only when the delegate method containing the sync block + call ends. If you put an infinite loop at the end of the delegate method after the sync block the crash never happens. If you comment out removeObjectsAtIndexes there is no crash.
3.The thing is: the remove successfully completes, and then that query wrapper isn't referenced again anywhere.
4.We tried putting break points everywhere and no breakpoints trigger a crash. Everythng executes just fine with break points. No crash after stepping through entire program.
5.If you comment out the sync block is still crashes so it can't run normally on the main queue.
6.The only solution is to put it dispatch async on the main queue.


It must be an error in ARC source code.

What to do: report to Apple and google. email someone good.

[How to remove share extension from app.](http://stackoverflow.com/questions/25951033/how-to-remove-ios-today-extension-from-app)


How to deal with signing issues:

https://forums.developer.apple.com/thread/37208#114105


