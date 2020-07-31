-module(unzr).
-copyright('ДП "Інфотех"').
-behaviour(application).
-include("unzr.hrl").
-include_lib("kvs/include/kvs.hrl").
-include_lib("kvs/include/metainfo.hrl").
-behaviour(supervisor).
-export([start/2, stop/1, init/1, metainfo/0, allocate/2, key/4, test/0, block/1 ]).

% https://zakon.rada.gov.ua/laws/show/z1586-14#Text

stop(_)        -> ok.
m()            -> [7,3,1,7,3,1,7,3,1,7,3,1].
metainfo()     ->  #schema { name = unzr, tables = tables() }.
tables()       -> [ #table { name = unzr, fields = record_info(fields, unzr)} ].
pad(I,S)       -> lists:flatten(string:pad(integer_to_list(I),S,leading,"0")).
init([])       -> {ok, { {one_for_one, 5, 10}, []} }.
start(_,_)     -> kvs:join(), supervisor:start_link({local, ?MODULE}, ?MODULE, []).
name(Y,M,D)    -> pad(Y,4) ++ pad(M,2) ++ pad(D,2).
sum(S)         -> lists:sum(lists:map(fun ({X,Y}) -> X*(Y-48) end, S)).
check(Y,M,D,C) -> sum(lists:zip(m(),name(Y,M,D) ++ pad(C,4))) rem 10.
test()         -> key(1955, 2, 12, 111) == <<"1955021201110">>.
key(_,_,_,666) -> [];
key(Y,M,D,C)   -> erlang:iolist_to_binary(name(Y,M,D) ++ pad(C,4) ++ [48+check(Y,M,D,C)]).
block(S)       -> [ io:format("~s~n", [ allocate({1980+rand:uniform(X), rand:uniform(12),
                  rand:uniform(28)}, rand:uniform(2))]) || X <- lists:seq(1,S) ], ok.

allocate({Y,M,D},Sex) ->
  Name = name(Y,M,D) ++ [48+Sex],
  Counter = case kvs:get(id_seq,Name) of
    {error,_} -> kvs:seq(Name,Sex);
    {ok,_} -> case kvs:seq(Name,2) of 666 -> kvs:seq(Name,2); X -> X end end,
  Sum = check(Y,M,D,Counter),
  Key = key(Y,M,D,Counter),
  kvs:put(#unzr{key=Key,checksum=Sum,counter=Counter,value=[]}),
  Key.
