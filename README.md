libbash: bashing for the masses
=========

Ever have been in a situation in bash where...

  - You need starred password input?
  - Need microtime, nanotime or millitime?
  - Need to convert timestamps to dates?
  - Need an easy way to make output colorful?
  - Need a standard way to create sequence scripts?

... then libbash is for you.

**And never forget that [Bash cures cancer]**

So, what does it do?
-----------

libbash has a few files containing helper functions:

*  **bashr.sh**  : A quick-and-dirty bash framework for creating and nicely displaying sequencial process (builds, bootstraps, etc). See example.sh for more details
*  **colorize.sh** : echo "I feel blue" | red | bold
*  **date.sh** : Deals with time-based issues
*  **query.sh**  : query $(echo "I feel blue. How do you feel?" | red | bold)
*  **spinner.sh** : Attach a spinner to a given process, and dies out when the process disappears. See example.sh for more options.
*  **memcached.sh** : Gives access to utility functions for interacting with Memcached/Membase.

Sounds great. How do I use thoses?

In your script

`. /usr/lib/bash/colorize.sh`

You can put this in any bash script you want, and bam, coloring pipes available. You can also decide to import this in your .bashrc *and use them as user command in your shell*.

Example, you could do this:

`mbGet some_memcached_key | sed '1 d;$ d' | tee dump | grey | less -R`

... ok, not super useful. But you get the point, and hopefully, you will see the potential I see in this.

But what about the other [libbash]?
--------------

Looks dead to me, so i though I could use the name. If the name is confusing, I have nothing against changing it.

Up next
------------

* Parsers for JSON, XML, and other (if anyone is up for it!)
* Some bugfixes.
* Bash networking library.
* Basic HTTP request manager.

Installation
--------------

1. git clone https://github.com/Wizcorp/libbash.git /usr/lib/bash

NOTE: You can choose a revision by loading a specific tag. See the list here on GitHub

Collaborators
---------------

* [stelcheck]

  [libbash]: http://sourceforge.net/mailarchive/forum.php?forum_name=libbash-common
  [Bash cures cancer]: http://bashcurescancer.com/
  [stelcheck]: http://www.github.com/stelcheck

