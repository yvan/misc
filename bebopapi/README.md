The cowboy bebop API <a href="https://bebopquotes.herokuapp.com/quotes/random">https://bebopquotes.herokuapp.com/quotes/random</a>
====================
I made this little api as an experiment. I also noticed there wasn't a
real API for cowboy bebop yet.

Just a word on the database structure.

Super simple. 

1. There is a mongodb database called "bebop."

2. There is a a collection called "quotes" that stores objects of format:
{_id:"DocumentId", quote:"Da quote."}

To get a greeting navigate to: `https://bebopquotes.herokuapp.com/`
To get a list of all quotes: `https://bebopquotes.herokuapp.com/quotes`
To get a random quote: `https://bebopquotes.herokuapp.com/quotes/random`

That's it for now If you have any ideas about quotes to add hit me up <a href="https://twitter.com/yvanscher">@yvanscher</a>.
