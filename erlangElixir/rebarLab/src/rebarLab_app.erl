%%%-------------------------------------------------------------------
%% @doc rebarLab public API
%% @end
%%%-------------------------------------------------------------------

-module(rebarLab_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    rebarLab_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
