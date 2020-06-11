Templates
=========
Basically just a bunch of templates for working with various libraries.

These are just basic starter templates, note that the sigma.js one will usually
not work on a browser, as cross-site XML protection prevents you from making XMLHTTP 
requests on your own file system. SigmaJS makes these requests if you used a gexf file format.

For Sigma.js you'll need to host the file on a localhost. Not going to explain how to do that here, I reccommend using express and Node.js to do that. Look around on google "how to create basic web app express and Node" you should find a way to create an app that serves static files, that will let you serve the index.html in the Sigma.js template. 

