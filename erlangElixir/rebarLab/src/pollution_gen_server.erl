%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. kwi 2026 14:22
%%%-------------------------------------------------------------------
-module(pollution_gen_server).

-behaviour(gen_server).

%% API
-export([
  start_link/0,
  stop/0,
  crash/0,

  add_station/2,
  add_value/4,
  remove_value/3,

  get_one_value/3,
  get_station_min/2,
  get_station_mean/2,
  get_daily_mean/2,
  get_moving_mean/2
]).

%% callbacks
-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).

%%%===================================================
%%% API
%%%===================================================

start_link() ->
  gen_server:start_link(
    {local, ?MODULE},
    ?MODULE,
    [],
    []
  ).

stop() ->
  gen_server:call(?MODULE, stop).

crash() ->
  gen_server:call(?MODULE, crash).

add_station(Name, Coords) ->
  gen_server:call(
    ?MODULE,
    {add_station, Name, Coords}
  ).

add_value(Id, DateTime, Type, Value) ->
  gen_server:call(
    ?MODULE,
    {add_value, Id, DateTime, Type, Value}
  ).

remove_value(Id, DateTime, Type) ->
  gen_server:call(
    ?MODULE,
    {remove_value, Id, DateTime, Type}
  ).

get_one_value(Id, DateTime, Type) ->
  gen_server:call(
    ?MODULE,
    {get_one_value, Id, DateTime, Type}
  ).

get_station_min(Id, Type) ->
  gen_server:call(
    ?MODULE,
    {get_station_min, Id, Type}
  ).

get_station_mean(Id, Type) ->
  gen_server:call(
    ?MODULE,
    {get_station_mean, Id, Type}
  ).

get_daily_mean(Type, Date) ->
  gen_server:call(
    ?MODULE,
    {get_daily_mean, Type, Date}
  ).

get_moving_mean(Id, Type) ->
  gen_server:call(
    ?MODULE,
    {get_moving_mean, Id, Type}
  ).

%%%===================================================
%%% gen_server callbacks
%%%===================================================

init([]) ->
  Monitor = pollution:create_monitor(),
  {ok, Monitor}.

handle_call(stop, _From, State) ->
  {stop, normal, ok, State};

handle_call(crash, _From, State) ->
  1 div 0,
  {reply, ok, State};

handle_call({add_station, Name, Coords}, _From, State) ->

  case pollution:add_station(Name, Coords, State) of

    {error, _} = Error ->
      {reply, Error, State};

    NewState ->
      {reply, ok, NewState}
  end;

handle_call(
    {add_value, Id, DT, Type, Value},
    _From,
    State
) ->

  case pollution:add_value(
    Id,
    DT,
    Type,
    Value,
    State
  ) of

    {error, _} = Error ->
      {reply, Error, State};

    NewState ->
      {reply, ok, NewState}
  end;

handle_call(
    {remove_value, Id, DT, Type},
    _From,
    State
) ->

  case pollution:remove_value(
    Id,
    DT,
    Type,
    State
  ) of

    {error, _} = Error ->
      {reply, Error, State};

    NewState ->
      {reply, ok, NewState}
  end;

handle_call(
    {get_one_value, Id, DT, Type},
    _From,
    State
) ->

  Result =
    pollution:get_one_value(
      Id,
      DT,
      Type,
      State
    ),

  {reply, Result, State};

handle_call(
    {get_station_min, Id, Type},
    _From,
    State
) ->

  Result =
    pollution:get_station_min(
      Id,
      Type,
      State
    ),

  {reply, Result, State};

handle_call(
    {get_station_mean, Id, Type},
    _From,
    State
) ->

  Result =
    pollution:get_station_mean(
      Id,
      Type,
      State
    ),

  {reply, Result, State};

handle_call(
    {get_daily_mean, Type, Date},
    _From,
    State
) ->

  Result =
    pollution:get_daily_mean(
      Type,
      Date,
      State
    ),

  {reply, Result, State};

handle_call(
    {get_moving_mean, Id, Type},
    _From,
    State
) ->

  Result =
    pollution:get_moving_mean(
      Id,
      Type,
      State
    ),

  {reply, Result, State};

handle_call(_, _From, State) ->
  {reply, unknown_request, State}.

handle_cast(_, State) ->
  {noreply, State}.

handle_info(_, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.