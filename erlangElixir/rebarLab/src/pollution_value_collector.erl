%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. maj 2026 12:12
%%%-------------------------------------------------------------------
-module(pollution_value_collector).

-behaviour(gen_statem).

-export([
  start_link/0,
  stop/0,

  set_station/1,
  add_value/3,
  store_data/0
]).

-export([
  init/1,
  callback_mode/0,

  idle/3,
  collecting/3
]).

%%%===================================================
%%% API
%%%===================================================

start_link() ->
  gen_statem:start_link(
    {local, ?MODULE},
    ?MODULE,
    [],
    []
  ).

stop() ->
  gen_statem:stop(?MODULE).

set_station(Station) ->
  gen_statem:call(
    ?MODULE,
    {set_station, Station}
  ).

add_value(DateTime, Type, Value) ->
  gen_statem:call(
    ?MODULE,
    {add_value, DateTime, Type, Value}
  ).

store_data() ->
  gen_statem:call(
    ?MODULE,
    store_data
  ).

%%%===================================================
%%% callbacks
%%%===================================================

callback_mode() ->
  state_functions.

init([]) ->
  {ok, idle, #{}}.

%%%===================================================
%%% STATE: idle
%%%===================================================

idle(
    {call, From},
    {set_station, {Name, Coords}},
    _Data
) ->

  pollution_gen_server:add_station(Name, Coords),

  NewData = #{
    station => Name,
    coords => Coords,
    values => []
  },

  {
    next_state,
    collecting,
    NewData,
    [{reply, From, ok}]
  };

idle({call, From}, _, Data) ->
  {
    keep_state,
    Data,
    [{reply, From, error}]
  }.

%%%===================================================
%%% STATE: collecting
%%%===================================================

collecting(
    {call, From},
    {add_value, DT, Type, Value},
    Data
) ->

  Values = maps:get(values, Data),

  NewValues =
    [{DT, Type, Value} | Values],

  NewData =
    Data#{values => NewValues},

  {
    keep_state,
    NewData,
    [{reply, From, ok}]
  };

collecting(
    {call, From},
    store_data,
    Data
) ->

  Station =
    maps:get(station, Data),

  Values =
    maps:get(values, Data),

  lists:foreach(
    fun({DT, Type, Value}) ->

      pollution_gen_server:add_value(
        Station,
        DT,
        Type,
        Value
      )

    end,
    Values
  ),

  {
    next_state,
    idle,
    #{},
    [{reply, From, ok}]
  };

collecting({call, From}, _, Data) ->
  {
    keep_state,
    Data,
    [{reply, From, error}]
  }.