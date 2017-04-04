ExStealerGame
========

ExStealerGame was created as a study project, only for praticing Elixir-lang.  
This is a silly game of stealing points from the other players.

Installation
------------

# Using Docker

The project doesn't have much dependencies, but there is a simple  
setup script "bin/setup".  

So, to setup the application, the only thing you need to do is run:  
`$ ./bin/setup`

After it, you're ready to run it.

How to run it
-------------

To start the game, first you need a server running.  
If you're the one who's going to host the server, to do start it, run:  
`$ docker-compose up server`

Once you've done it, anyone can connect to the server using a telnet client:  
`$ telnet <host_of_the_server> 4040`

How to play it
--------------

When you start the client and conect to the server, the client's going to  
ask your name. After writing your name and pressing enter, you will see  
a screen with a list of players and their scores.  

Then, the game is going to keep a loop asking you who you want to steal points from.  
Whenever you write the id of a player(every line on the players list has a number at its  
begining, that's the player's id) and hit enter, the target player is going to lose 1 point  
and you're going to receive 1 point.

The game ends when one player reach the double of starting points(as default, it would be 20)

PrintScreen
-----------

![screenshot](https://github.com/kleberngueriero/ex_stealer_game/blob/master/screenshot.png)
