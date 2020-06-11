#Envoy
======

#FileSystemWrapper

##fsAbstraction
##fsInterface
##fsFunctions
##fsInit

#ServiceManagers

##DBServiceManager (our interface to normalize dropbox)
##GDServiceManager (our interface to normalize google drive)
##BXServiceManager (our interface to normalize box) (which we decided not to support for now)
##QueryWrappers
##CustomRequestQueue

###What is it?
Basically the custom request queue is a way for us to rate limit ourselves for performance reasons (not trying to load too much stuff in the collection view at once), not bombing the Dropbox/Google Drive APIs and getting rate limited. Realistically we know we're only going to be able to do like 4 file downloads at a time on the dropbox API. 

###How is it structured?
There are two parts to it:

1 - a global counting queue that counts all requests made to the API for downloading and uploading globally. 

2 - a special type of Queue object containing the type of API request to be made and the metadata about the files to make that request on.(basically everything that you would send to a dropbox SDK method)

3 - a checker method that checks how many things are currently being queried. 

Note: The system only applies to downlaods and uploads.

###How does it work?
1 - When we want to make a request we check the globalCutomRequestCount, if it's 4 or less we increment the globalCutomRequestCount and make the query. If it's greater than 4 we queue on the operation and conitnue on our way.

2- When a request successfully finishes we decrement the globalCutomRequestCount. We then check how many things are in the queue and we try to fill it up to the maximum (4). Everytime a request finishes we try to top off the active number of requests by pulling as many out of the queue as we can.

3- When a request fails we decrement the globalCutomRequestCount and check if it's 4 or less we increment the globalCutomRequestCount and make the query. If it's greater than 4 we queue on the operation and conitnue on our way. 

###Special cases that do n:

`Metadata queries` operate outside this queue system. This is for several reasons: 1. they are cheap. 2. putting them on the queue with downloads/uploads is going to slow things done significantly. 3. they don't get retried like other queries and so are much lower risk for repeating automatically and hitting rate limits on the Dropbox / Google Drive API. Still need to rate limit them though. Maybe 3 attempts.

`Creating folders` similar reasons as metadata queries. They are fast, cheap, and if they fail we can easily repeat. Still need to rate limit them though. Maybe 3 attempts.

##QueryLimitHolder

###What is it?

Basically it's a way to limit a particular type of query from occurring too many times. So if you try to download a file into a particular spot one too many times and it fails we don't allow that query for a little bit. 

###How is it structured?

1 - global nsmutablearray that stores query limit objects

2 - a special type of query limit object that uniquely identifies a particular API request by its source, destination, and whether it's an upload or a download.

3 - a checker method that checks if a query is already at its max

4 - an incrementer method that takes the unique identifiers (path1, path2, typeOfQuery) and increments that query's count inside the global nsmutable array.

###How does it work?

1 - when the user performs a query we check to see if that query is already maxed out or even in the global array at all.

2 - if the user's query is not maxed out on attempts / failures or does not exist in array we allow everything to proceed as normal, we create a new query limit object only if an object with the unique traits we want does not already exist in the global query limit array. We do not increment the count right after creation despite calling the query. We only increment the count on a failure.

3 - if a query fails we increase its count once.

4 - when a querylimit query finishes we remove it from the global querylimit array.

5- if a query exceeds the number of tolerated failures then we kill everything associated with that query (except the limit object) and throw an error to the user. If the user tries to perform the same query in the next 3 min we send them a warning prior.

###Difference between querylimitwrapper and querywrapper

The difference is that the querylimitwrapper just stores enough information to uniquely identify a TYPE of query for a particular file. So like if you tried to download the wolf.mp3 file into the local folder 4x querylimitwrappers will track that. Under query limit wrappers downloading wolf.mp3 into /Local/subfolder is considered a different query. Basically it accounts for multipel failure points of any single unique identified query where source and destination paths are the unique identifiers. (We may have to make it only uniquely identify with dropbox path for downloads and phone/documents directory path for files in uploads). querywrappers represent every single call to the api. If you call a download onto wolf.mp3 3 times into the same place that will make anywhere from 1-3 querywrappers and each one stores the unique info needed to do operations and destroy that file download/upload process as it's happening. querywrappers are really abstractions on top of the google drive and dropbox fetchers/servicetickets/restclients, they are used for cancelling uploads/downloads.


##Sharable Links

###What is it?

It's a way to share a large number of links with another phone from your dropbox.

###How is it structured?

1 - a dictionary whose keys are unique file paths that are on phone paths to representations of cloud files. The values start empty but get filled out as the downloadable shareable links produced by dropbox.

2 - 

###How does it work?

1 - the user selects a bunch of files.

2 - the user presses a "share links" button

3 - internally we create a dictionary with the path of each thing shared and grab all the links for those files. Everytime a delegate/response comes in for a link we add the link into the dictionary slot for the file. everytime a link comes in via delegate we check to see if all entries in the dictionary have values (or we pass the expected # of files and check if we got that many links but I like the dictionary method better.) Then once the dictionary is full we call a delegate method and pass it back to the home view controller with all the links. If a user then selects an additional file we go back and add new empty keys to the dictionary. To prevent keys taht already have links from being overwritten we only add a key for a file path if it isn't already present in the global dictionary on the db servicemanager.

4 - these links are now stored and displayed on the send view via a special interface.

5 - if the user deselects one file we remove it's key from the dbservicemanager. if the user deselects all the files somehow we wipe the db servicemanagers global link dictionary.

#Storage Structures

##Structure of userdata json files (soft data)
```
User NSUserDefaults 
{
    firstName = "Yvan"
    lastName = "Scher"
}

Settings NSUserDefaults 
{
    receivePushNotifications: "NO"
    receiveEmailNotifications: "YES"
}

NumUncheckedFilePackages NSUserDefaults 
{
    numUncheckedFilePackages: @"3"
}

`friends.json`

{
    "friends" = {
        "3nfvh2-f3jbeo2-w32w4ff-3jbfw3n" = {
            name = "Carl"
            UUID = "3nfvh2-f3jbeo2-w32w4ff-3jbfw3n"
        }
        "i34gwn3-ev4inier-fkh3ni-wnwrf" = {
            name = "SomeGuyIAdded"
            UUID = "i34gwn3-ev4inier-fkh3ni-wnwrf"
        }
    }
    "timestamp" = {
        ...
    }
}

`inbox.json`

{
    filePackages = {
        UUID1 = {
            receivedDate = "2015-02-09 at 7:16:05"
            sentBy = "yvan"
            sentByUUID = @"32jkjh3-wrkw4iu-w4rfw3w3-3rhjw"
            files = {
                "sent_file1" = {
                    isDirectory = "0"
                    fileName = "sent_file1"
                    fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1"
                }
                "sent_file2" = {
                    isDirectory = "0"
                    fileName = "sent_file2"
                    fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1"
                }
                "sent_file3" = {
                    isDirectory = "0"
                    fileName = "sent_file3"
                    fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1" 
                }
            }
        }
        UUID2 = {
            ...
        }
    }
    "timestamp" = {
    ...
    }
}
```

`filesystem.json`

```
{
    "text1.txt" = {
        created = "2015-01-07 at 15:17:06";
        isDirectory = 0;
        name = "text1.txt";
        url = "/Local/dir1/text1.txt";
    };
    "text2.txt" = {
        created = "2015-01-07 at 15:17:06";
        isDirectory = 0;
        name = "text2.txt";
        url = "/Dropbox/dir1/text2.txt";
    };
    "dir1" = {
        created = "2015-01-07 at 15:17:06";
        isDirectory = 1;
        name = "dir1";
        url = "/GoogleDrive/dir1";
    };
    timestamp = "2015-01-07 at 15:17:06";
}
```

#Notes On SDKs

##Dropbox
`#import <DropboxSDK/DropboxSDK.h>` statments need to be in the .m file and in the .h file referencing the .m file there needs to be a `#import <UIKit/UIKit.h>`. I could care less why
they chose to do this. At this point I just stop questioning arbitrary software choices. If you 
need to write a method that uses a class inside the Dropbox SDK like DBRestClient and it needs
to go into a .h just set it up as an `id` type and cast it to the actual type in the init method in the .m file.
##GoogleDrive
##Box