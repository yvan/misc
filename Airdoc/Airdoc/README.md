Airdoc
======

Share files fast and easy.


Structure of userdata json files (soft data)
=====================================
```
user.JSON
{
    "users" = {
        "0" = {
            name = "yvan"
            email = "yvanscher@gmail.com"
        }
        "1" = {
            name = "roman"
            email = "roman@gmail.com"
        }
        "2" = {
            name = "roman"
            email = ""
        }
    }

    "loggedInUser" = {
        name = "roman"
        email = "roman@gmail.com"
    }

    "previouslyLoggedInUser" = {
        name = "yvan"
        email = "yvanscher@gmail.com"
    }
    
    "timestamp" = {
        ...
    }
}

people.JSON
{
    "acquaintances" = {
        "0" = {
            name = "person_exchanged_with"
            email = "person@gmail.com"
            friend = "YES"
        }
        "1" = {
            name = "peer_exchanged_with_soon_to_be_made_friend"
            email = "peer@gmail.com"
            friend = "NO"
        }
    }

    "timestamp" = {
        ...
    }
}

inbox.JSON
{
    UUID1 = {
        sentDate = "2015-02-09 at 7:16:05"
        sentBy = "yvan"
        sentByUserUUID = @"32jkjh3-wrkw4iu-w4rfw3w3-3rhjw"
        files = {
            "0" = {
                isDirectory = 0
                fileName = "sent_file1"
                fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1"
            }
            "1" = {
                isDirectory = 0
                fileName = "sent_file1"
                fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1"
            }
            "2" = {
                isDirectory = 0
                fileName = "sent_file1"
                fileUrl = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/inbox/"sent_file1" 
            }
        }
    }
    UUID2 = {
        ...
    }
}

history.JSON
{
    "0" = {
        sentDate = "2015-01-07 at 15:17:06"
        sentTo = "yvan"
        sentToEmail = "yvanscher@gmail.com"
        files = {
            "0" = {
                isDirectory = 0
                name = "text1.txt"
                url = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/dir1/text1.txt"
            }
            "1" = {
                ...
            }
        }
    }
    "1" = {
        ...
    }
    ...
    "25" = {

    }

    "timestamp" = {
        ...
    }
}
```

Filesystem Wrapper
=================
For doing filesystem operations, use the FileSystem class. Basically it contains directory support for making directories, as well as other file support mechanisms, like creating files, moving files, etc. The code it heavily commented and there are tests for the functions that can break.


Format of filesystem.json (hard data)
====================================
```
{
    "text1.txt" = {
        created = "2015-01-07 at 15:17:06";
        isDirectory = 0;
        name = "text1.txt";
        url = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/dir1/text1.txt";
    };
    "text2.txt" = {
        created = "2015-01-07 at 15:17:06";
        isDirectory = 0;
        name = "text2.txt";
        url = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/dir1/text2.txt";
    };
    "dir1" = {
    	created = "2015-01-07 at 15:17:06";
    	isDirectory = 1;
    	name = "dir1";
    	url = "/Users/yvanscher/Library/Developer/CoreSimulator/Devices/8487F2E2-2612-4B40-B188-235474287E34/data/Containers/Data/Application/B7508B2D-37E1-4B1C-881C-5EB609EBFD65/Documents/dir1";
	};
    timestamp = "2015-01-07 at 15:17:06";
}
```


How do our API integrations work????
====================================
Dropbox - I just followed the online setup tutorial, it was good and it worked basically 100%.

Box - This was challenging....but way better than google's. 

GoogleDrive - The iOS SDK is a clusterfck. Still trying to get this working right, post authentication, can't even get teh root directory yet.
