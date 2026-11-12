

-module(pollution).
-author("user").

-export([
  create_monitor/0,
  add_station/3,
  add_value/5,
  remove_value/4,
  get_one_value/4,
  get_station_min/3,
  get_station_mean/3,
  get_daily_mean/3,
  get_moving_mean/3
]).

-record(monitor, {
  stations = #{},
  coords = #{},
  measurements = #{}
}).

create_monitor() ->
  #monitor{}.

add_station(Name, Coords, Monitor) ->
  case {maps:is_key(Name, Monitor#monitor.stations), maps:is_key(Coords, Monitor#monitor.coords)} of
    {false, false} ->
      Monitor#monitor{
        stations = maps:put(Name, Coords, Monitor#monitor.stations),
        coords = maps:put(Coords, Name, Monitor#monitor.coords)
      };
    _ ->
      {error, station_exists}
  end.


resolve_coords(Id, Monitor) ->
  case Id of
    {_, _} = Coords ->
      case maps:is_key(Coords, Monitor#monitor.coords) of
        true -> {ok, Coords};
        false -> {error, station_not_found}
      end;
    Name ->
      case maps:find(Name, Monitor#monitor.stations) of
        {ok, Coords} -> {ok, Coords};
        error -> {error, station_not_found}
      end
  end.

add_value(Id, DateTime, Type, Value, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Key = {Coords, DateTime, Type},
      case maps:is_key(Key, Monitor#monitor.measurements) of
        false ->
          NewMeasurements = maps:put(Key, Value, Monitor#monitor.measurements),
          Monitor#monitor{measurements = NewMeasurements};
        true ->
          {error, measurement_exists}
      end;
    Error -> Error
  end.

remove_value(Id, DateTime, Type, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Key = {Coords, DateTime, Type},
      case maps:is_key(Key, Monitor#monitor.measurements) of
        true ->
          NewMeasurements = maps:remove(Key, Monitor#monitor.measurements),
          Monitor#monitor{measurements = NewMeasurements};
        false ->
          {error, not_found}
      end;
    Error -> Error
  end.

get_one_value(Id, DateTime, Type, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Key = {Coords, DateTime, Type},
      case maps:find(Key, Monitor#monitor.measurements) of
        {ok, Value} -> Value;
        error -> {error, not_found}
      end;
    Error -> Error
  end.

get_station_min(Id, Type, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Values = [V || {{C, _, T}, V} <- maps:to_list(Monitor#monitor.measurements),
        C =:= Coords, T =:= Type],
      case Values of
        [] -> {error, no_data};
        _ -> lists:min(Values)
      end;
    Error -> Error
  end.

get_station_mean(Id, Type, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Values = [V || {{C, _, T}, V} <- maps:to_list(Monitor#monitor.measurements),
        C =:= Coords, T =:= Type],
      case Values of
        [] -> {error, no_data};
        _ -> lists:sum(Values) / length(Values)
      end;
    Error -> Error
  end.

get_daily_mean(Type, Date, Monitor) ->
  Values = [V || {{_, {D, _}, T}, V} <- maps:to_list(Monitor#monitor.measurements),
    D =:= Date, T =:= Type],
  case Values of
    [] -> {error, no_data};
    _ -> lists:sum(Values) / length(Values)
  end.


get_moving_mean(Id, Type, Monitor) ->
  case resolve_coords(Id, Monitor) of
    {ok, Coords} ->
      Now = calendar:local_time(),
      SecNow = calendar:datetime_to_gregorian_seconds(Now),

      FilteredWithWeights = [
        {V, 24 - ((SecNow - Sec) div 3600)} ||
        {{C, D, T}, V} <- maps:to_list(Monitor#monitor.measurements),
        C =:= Coords,
        T =:= Type,
        begin
          Sec = calendar:datetime_to_gregorian_seconds(D),
          Diff = SecNow - Sec,
          Diff >= 0 andalso Diff < 24 * 3600
        end
      ],

      case FilteredWithWeights of
        [] -> {error, no_data};
        _ ->
          {SumVals, SumWeights} = lists:foldl(
            fun({V, W}, {AccV, AccW}) ->
              {AccV + (V * W), AccW + W}
            end, {0, 0}, FilteredWithWeights),
          SumVals / SumWeights
      end;
    Error -> Error
  end.

