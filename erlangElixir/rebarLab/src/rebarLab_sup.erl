%%%-------------------------------------------------------------------
%% @doc rebarLab top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(rebarLab_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link(
    {local, ?SERVER},
    ?MODULE,
    []
  ).

init([]) ->

  SupFlags = #{
    strategy => one_for_one,
    intensity => 5,
    period => 10
  },

  PollutionServer = #{
    id => pollution_gen_server,

    start =>
    {pollution_gen_server,
      start_link,
      []},

    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [pollution_gen_server]
  },

  Collector = #{
    id => pollution_value_collector,

    start =>
    {pollution_value_collector,
      start_link,
      []},

    restart => permanent,
    shutdown => 5000,
    type => worker,
    modules => [pollution_value_collector]
  },

  ChildSpecs = [
    PollutionServer,
    Collector
  ],

  {ok, {SupFlags, ChildSpecs}}.