This forks aims to handle 2 jsfmtrc
- one for storage
- one for view

Here we are doing it for [atom](http://atom.io) and [jsfmt](https://github.com/rdio/jsfmt)

this package is a forked from [atom-jsfmt](https://atom.io/packages/atom-jsfmt)

### TODO Improved UI
- currently this is not the proper 

### .jsfmtrc && .jsfmtviewrc
- the .jsfmtrc is read is weird place
  - it doesnt honnor the path for .jsfmtrc
- it should support the .jsfmtrc in a parent directory
- there is load config function in node_modules/jsfmt/lib/Config.js
- this jsfmt rely on rc() which seems buggy
- there is a need to handle those files properly
- i will likely need to get .jsfmtrc and jsfmtviewrc

### Story

I am tired of all the fights over coding style.
Everybody got its opinion of 'what is best', which is rarely 
the same best unfortunatly. So the fight goes on and on.
It is a very unproductive way to spend time.

Suddently it stroke me "EUREKA!".
We dont have to fight, we can satisfy everybody :)
The principle is simple. 

1. When the file is loaded by the editor, we format it to the developper taste.
Thus the developper will see the style he is the most confortable with
and thus can be more efficient.
2. when the editor save the file, we format it to the project specification.
Thus all the files are stored according to a uniform coding style, thus 
the project is easier to maintain over the long run.

All we need is program which automatically format the code according to some 
specification. [jsfmt](https://github.com/rdio/jsfmt) can do that for javascript files
