-module(pollution_server_test).
-author("user").

-include_lib("eunit/include/eunit.hrl").

%% --- Fixtures (Konfiguracja środowiska testowego) ---

setup() ->
  %% Uruchamia proces przed każdym testem
  pollution_server:start().

cleanup(_) ->
  %% Ubija proces po każdym teście
  pollution_server:stop().

pollution_server_test_() ->
  {foreach,
    fun setup/0,
    fun cleanup/1,
    [
      ?_test(add_station_t()),
      ?_test(add_value_t()),
      ?_test(add_value_fail_t()),
      ?_test(add_value_non_existing_station_t()),
      ?_test(remove_value_t()),
      ?_test(remove_value_and_add_back_t()),
      ?_test(remove_value_fail_t()),
      ?_test(get_one_value_t()),
      ?_test(get_one_value_fail_t()),
      ?_test(get_station_mean_t()),
      ?_test(get_station_mean_fail_t()),
      ?_test(get_daily_mean_t()),
      ?_test(get_daily_mean_fail_t()),
      ?_test(get_moving_mean_t()),
      ?_test(get_moving_mean_fail_t())
    ]}.

%% --- Testy ---

add_station_t() ->
  ?assertEqual(ok, pollution_server:add_station("Stacja 1", {1,1})),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 1", {1,1})),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 1", {2,2})),
  ?assertMatch({error, _}, pollution_server:add_station("Stacja 2", {1,1})).

add_value_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  ?assertEqual(ok, pollution_server:add_value("Stacja 1", Time, "PM10", 46.3)),
  ?assertEqual(ok, pollution_server:add_value("Stacja 1", Time, "PM1", 46.3)),
  ?assertEqual(ok, pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3)),

  timer:sleep(1100),
  Time2 = calendar:local_time(),
  ?assertEqual(ok, pollution_server:add_value({1,1}, Time2, "PM10", 46.3)),
  ?assertEqual(ok, pollution_server:add_value({1,1}, Time2, "PM1", 46.3)),
  ?assertEqual(ok, pollution_server:add_value({1,1}, {{2023,3,27},{11,16,10}}, "PM10", 46.3)).

add_value_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),

  ?assertMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM10", 46.3)),
  ?assertMatch({error, _}, pollution_server:add_value("Stacja 1", Time, "PM10", 36.3)),
  ?assertMatch({error, _}, pollution_server:add_value({1,1}, Time, "PM10", 46.3)),
  ?assertMatch({error, _}, pollution_server:add_value({1,1}, Time, "PM10", 36.3)).

add_value_non_existing_station_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  ?assertMatch({error, _}, pollution_server:add_value("Stacja 2", calendar:local_time(), "PM10", 46.3)),
  ?assertMatch({error, _}, pollution_server:add_value({1,2}, calendar:local_time(), "PM10", 46.3)).

remove_value_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 46.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3),

  ?assertEqual(ok, pollution_server:remove_value("Stacja 1", Time, "PM10")),
  ?assertEqual({error, not_found}, pollution_server:get_one_value("Stacja 1", Time, "PM10")),
  ?assertEqual(ok, pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10")).

remove_value_and_add_back_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 46.3),

  pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10"),
  ?assertEqual(ok, pollution_server:add_value({1,1}, {{2023,3,27},{11,16,9}}, "PM10", 46.3)).

remove_value_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),

  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 1", Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10")),
  ?assertMatch({error, _}, pollution_server:remove_value({1,2}, Time, "PM10")),
  ?assertMatch({error, _}, pollution_server:remove_value("Stacja 2", Time, "PM10")).

get_one_value_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),
  pollution_server:add_value("Stacja 1", Time, "PM1", 36.3),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10", 26.3),

  ?assertEqual(46.3, pollution_server:get_one_value("Stacja 1", Time, "PM10")),
  ?assertEqual(36.3, pollution_server:get_one_value("Stacja 1", Time, "PM1")),
  ?assertEqual(46.3, pollution_server:get_one_value({1,1}, Time, "PM10")),
  ?assertEqual(26.3, pollution_server:get_one_value("Stacja 1", {{2023,3,27},{11,16,9}}, "PM10")).

get_one_value_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  Time = calendar:local_time(),
  pollution_server:add_value("Stacja 1", Time, "PM10", 46.3),

  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 1", Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:get_one_value({1,1}, Time, "PM25")),
  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10")),
  ?assertMatch({error, _}, pollution_server:get_one_value("Stacja 2", Time, "PM1")),
  ?assertMatch({error, _}, pollution_server:get_one_value({1,2}, Time, "PM10")).

get_station_mean_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,11}}, "PM10", 20),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,12}}, "PM10", 10),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,13}}, "PM10", 20),

  ?assertEqual(15.0, pollution_server:get_station_mean("Stacja 1", "PM10")),
  ?assertEqual(15.0, pollution_server:get_station_mean({1,1}, "PM10")).

get_station_mean_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 1", "PM10")),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 1", "PM25")),
  ?assertMatch({error, _}, pollution_server:get_station_mean("Stacja 2", "PM25")).

get_daily_mean_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 2", {2,2}),
  pollution_server:add_station("Stacja 3", {3,3}),

  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,12}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,13}}, "PM10", 20),

  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,14}}, "PM25", 100),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,15}}, "PM25", 220),

  pollution_server:add_value("Stacja 1", {{2023,3,28},{11,16,16}}, "PM10", 2000),
  pollution_server:add_value("Stacja 2", {{2023,3,28},{11,16,17}}, "PM10", 3000),

  pollution_server:add_value("Stacja 3", {{2023,3,27},{11,16,18}}, "PM10", 1234),

  ?assertEqual(15.0, pollution_server:get_daily_mean("PM10",{2023,3,27})).

get_daily_mean_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  pollution_server:add_station("Stacja 2", {2,2}),
  ?assertMatch({error, _}, pollution_server:get_daily_mean("PM10",{2023,3,27})),
  pollution_server:add_value("Stacja 1", {{2023,3,27},{11,16,10}}, "PM10", 10),
  pollution_server:add_value("Stacja 2", {{2023,3,27},{11,16,11}}, "PM10", 20),

  ?assertMatch({error, _}, pollution_server:get_daily_mean("PM25",{2023,3,27})),
  ?assertMatch({error, _}, pollution_server:get_daily_mean("PM10",{2023,3,29})).

get_moving_mean_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),

  Now = calendar:local_time(),
  SecNow = calendar:datetime_to_gregorian_seconds(Now),

  T0 = Now,
  T1 = calendar:gregorian_seconds_to_datetime(SecNow - 3600),
  T2 = calendar:gregorian_seconds_to_datetime(SecNow - 7200),

  pollution_server:add_value("Stacja 1", T0, "PM10", 10),
  pollution_server:add_value("Stacja 1", T1, "PM10", 20),
  pollution_server:add_value("Stacja 1", T2, "PM10", 30),

  Result = pollution_server:get_moving_mean("Stacja 1", "PM10"),
  ?assert(abs(Result - 19.71014) < 0.001).

get_moving_mean_fail_t() ->
  pollution_server:add_station("Stacja 1", {1,1}),
  ?assertMatch({error, no_data}, pollution_server:get_moving_mean("Stacja 1", "PM10")),
  ?assertMatch({error, station_not_found}, pollution_server:get_moving_mean("Nieznana", "PM10")).