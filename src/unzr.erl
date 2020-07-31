-module(unzr).
-copyright('ДП "Інфотех"').
-behaviour(application).
-include("unzr.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("kvs/include/metainfo.hrl").
-behaviour(supervisor).
-export([start/2, stop/1, init/1, metainfo/0, allocate/2, pad/2 ]).

stop(_)        -> ok.
metainfo()     ->  #schema { name = unzr, tables = tables() }.
tables()       -> [ #table { name = unzr, fields = record_info(fields, unzr)} ].
pad(I,S)       -> lists:flatten(string:pad(integer_to_list(I),S,leading,"0")).
init([])       -> {ok, { {one_for_one, 5, 10}, []} }.
start(_,_)     -> kvs:join(), supervisor:start_link({local, ?MODULE}, ?MODULE, []).
name(Y,M,D)    -> pad(Y,4) ++ pad(M,2) ++ pad(D,2).
check(Y,M,D,C) -> lists:sum(name(Y,M,D) ++ pad(C,4)) rem 10.

allocate({Y,M,D},Sex) ->
  Name = name(Y,M,D) ++ [48+Sex],
  Counter = case kvs:get(id_seq,Name) of
    {error,_} -> kvs:seq(Name,Sex);
    {ok,_} -> case kvs:seq(Name,2) of 666 -> kvs:seq(Name,2); X -> X end end,
  Sum = check(Y,M,D,Counter),
  Key = erlang:iolist_to_binary(name(Y,M,D) ++ pad(Counter,4) ++ [48+Sum]),
  kvs:put(#unzr{key=Key,checksum=Sum,counter=Counter,value=[]}),
  Key.
