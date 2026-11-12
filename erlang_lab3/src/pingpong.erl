
-module(pingpong).
-author("user").

%% API
-export([start/0,stop/0]).

start() ->
  register(pong,spawn(fun pongLoop/0)),
  pingLoop().

stop()->
  spawn(fun() -> pong ! stop end),
  spawn(fun() -> ping ! stop end).


pingLoop()->
  receive
    N when N>0 -> timer:sleep(1000),
      pong ! N-1,
      io:format("Ping~n"),
      pingLoop();
    0 -> io:format("finito~n"),
      pingLoop();
    stop -> ok
  after 1000000 -> io:format("runtime~n"),ok
  end.


pongLoop()->
  receive
    N when N>0 ->  timer:sleep(1000),
      ping ! N-1,
      io:format("Pong~n"),
      pongLoop();
    0 -> io:format("finito~n"), pongLoop();
    stop -> ok
  after 1000000 -> io:format("runtime~n"),ok
  end.

