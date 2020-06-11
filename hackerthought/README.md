Hackerthought - Usable hackernews in terminal
=============
[![NPM](https://nodei.co/npm/hackerthought.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/hackerthought/)

NOTE: This package is pretty out of date. It actually scrapes hackernews everytime you run the command which is getting harder and harder now that HN has an API. Sometimes I have to run "hackerthought" a couple times before I can get the pages. Sometimes the module just doesn't scrape. I'll need to head back and check the dependencies on this thing and set the proper node engine and such. It was the first package I made so it's missing a bunch of things that would normally keep it running.

Download with:
```
npm install -g hackerthought
```
Get headlines from hackernews in terminal. Immediately open the stories you want
with one command. Get stories from any page you want. Visit source sites without
having to use an involved prompt or interrupt your workflow.

It's non involved, you can run 'hackerthought' and then 5 minutes later run
'hackerthought -p 25' or 'ht -p 25' and the app will immediately display page 25.
There's no need to stay stuck in some prompt on your terminal or to mothball the
process and restart it. I made this to have access to hackernews with minimal
workflow interruption.

No logging-in, voting, or comments yet. Maybe if I get a little extra time in
the next few weeks I'll add it.

Usage
=============

Run:
```
hackerthought

```
This will setup the app and load in the most recent pages from hackernews. This
should be run everytime you use the app or anytime you want to refresh the stories.

After running the 'hackerthought' command the following commands can be run
anytime during any other workflow:
```
hackerthought -t   -- get top page of hackernews

hackerthought -s   -- (SAMPLE DOES NOT YET WORK)

hackerthought -p 2 -- get page 2 of hackernews

hackerthought 25   -- open post # 25 of the most recently opened page
```
Example Usage:
```
hackerthought       -- initializes app/populates news
hackerthought  -t    -- get top page of HN
hackerthought  3     -- open 3rd story on the top page
hackerthought  -p 5  -- prints the 5th page
hackerthought  3     -- open 3rd story on the 5th page
```
A NOTE: for some reason the alias 'ht' isn't working so I removed it.


Todo
======
1. Update the package to use hackernews endpoints. I literally published this right when the API was released and so the whole package is built off of scraping which was reliable when I made it, but since has I guess been discouraged by the people running hackernews either that or there's some other problem in my code causing reliability issues. 
