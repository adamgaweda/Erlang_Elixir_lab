%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. mar 2026 13:54
%%%-------------------------------------------------------------------
-module(lab2).
-author("user").

%% API
-export([]).

%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. mar 2026 14:30
%%%-------------------------------------------------------------------
-module(makota).
-author("user").

%% API
-export([]).

less_than(List,Arg)->[X || X <:- List , X<Arg].

grt_eq_than(List,Arg)->[X || X <:- List, X>=Arg].


qs([])->[];
qs([Pivot|Tail])->qs(less_than(Tail,Pivot))++[Pivot]++qs(grt_eq_than(Tail,Pivot)).

rand_elems(N,Min,Max)->[rand:uniform(Max-Min+1)+Min-1 || _<:- lists:seq(1,N)]

compare_speeds(Args,Fun1,Fun2) ->
  Time1 = timer:tc(Fun1,Args),
  Time2 = timer:tc(Fun2,Args),
  io:format("").
end.


isdivideable(Number,Divide)->
    Number rem Divide == 0.


F(List) -> lists:foldl(fun(A,E) -> E++A, [], LL) end.
