KVB Twitter Ticker
==================

This Ruby script is a live [KVB](http://www.kvb-koeln.de/) information ticker for Twitter. All new information is posted directly to Twitter under username:

[@KVBStoerungen](https://twitter.com/KVBStoerungen)

KVB (Kölner Verkehrs-Betriebe) operates Cologne urban transportation system, like trams, metro, buses. It has a real-time tracker for informations like schedule changes, accidents, and so on, available on every stop. The problem is that you don’t know about them until you get on the tram or a bus stop.

That’s why I created this Twitter tracker. It reads [KVB’s ticker online](http://www.kvb-koeln.de/german/home/mofis.html), and posts new messages to Twitter. That way you can be informed about schedule departures on the go without the need of going to the website or being surprised at the bus stop that your bus is delayed 20 minutes.

The code is really simple, runs on Heroku using plain Ruby. No special magic.
