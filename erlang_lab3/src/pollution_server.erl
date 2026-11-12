%%%-------------------------------------------------------------------
%%% @author user
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. kwi 2026 15:00
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("user").

-export([start/0, stop/0, init/0]).
-export([
  add_station/2,
  add_value/4,
  remove_value/3,
  get_one_value/3,
  get_station_min/2,
  get_station_mean/2,
  get_daily_mean/2,
  get_moving_mean/2
]).


start() ->
  register(pollution_server, spawn(?MODULE, init, [])).

stop() ->
  pollution_server ! stop,
  ok.

init() ->
  InitialMonitor = pollution:create_monitor(),
  loop(InitialMonitor).

add_station(Name, Coords) ->
  call({add_station, Name, Coords}).

add_value(Id, DateTime, Type, Value) ->
  call({add_value, Id, DateTime, Type, Value}).

remove_value(Id, DateTime, Type) ->
  call({remove_value, Id, DateTime, Type}).

get_one_value(Id, DateTime, Type) ->
  call({get_one_value, Id, DateTime, Type}).

get_station_min(Id, Type) ->
  call({get_station_min, Id, Type}).

get_station_mean(Id, Type) ->
  call({get_station_mean, Id, Type}).

get_daily_mean(Type, Date) ->
  call({get_daily_mean, Type, Date}).

get_moving_mean(Id, Type) ->
  call({get_moving_mean, Id, Type}).


call(Message) ->
  %% Wysyłamy wiadomość wraz z naszym PIDem, aby serwer wiedział gdzie odpowiedzieć
  pollution_server ! {request, self(), Message},
  receive
    {reply, Reply} -> Reply
  end.


loop(Monitor) ->
  receive
    {request, Pid, {add_station, Name, Coords}} ->
      case pollution:add_station(Name, Coords, Monitor) of
        {error, _} = Error ->
          Pid ! {reply, Error},
          loop(Monitor); %% Stan bez zmian
        NewMonitor ->
          Pid ! {reply, ok},
          loop(NewMonitor) %% Aktualizujemy stan
      end;

    {request, Pid, {add_value, Id, DateTime, Type, Value}} ->
      case pollution:add_value(Id, DateTime, Type, Value, Monitor) of
        {error, _} = Error ->
          Pid ! {reply, Error},
          loop(Monitor);
        NewMonitor ->
          Pid ! {reply, ok},
          loop(NewMonitor)
      end;

    {request, Pid, {remove_value, Id, DateTime, Type}} ->
      case pollution:remove_value(Id, DateTime, Type, Monitor) of
        {error, _} = Error ->
          Pid ! {reply, Error},
          loop(Monitor);
        NewMonitor ->
          Pid ! {reply, ok},
          loop(NewMonitor)
      end;

    {request, Pid, {get_one_value, Id, DateTime, Type}} ->
      Result = pollution:get_one_value(Id, DateTime, Type, Monitor),
      Pid ! {reply, Result},
      loop(Monitor);

    {request, Pid, {get_station_min, Id, Type}} ->
      Result = pollution:get_station_min(Id, Type, Monitor),
      Pid ! {reply, Result},
      loop(Monitor);

    {request, Pid, {get_station_mean, Id, Type}} ->
      Result = pollution:get_station_mean(Id, Type, Monitor),
      Pid ! {reply, Result},
      loop(Monitor);

    {request, Pid, {get_daily_mean, Type, Date}} ->
      Result = pollution:get_daily_mean(Type, Date, Monitor),
      Pid ! {reply, Result},
      loop(Monitor);

    {request, Pid, {get_moving_mean, Id, Type}} ->
      Result = pollution:get_moving_mean(Id, Type, Monitor),
      Pid ! {reply, Result},
      loop(Monitor);

    stop ->
      ok
  end.