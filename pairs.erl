% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Under a copyleft, do what you want.

% Read a file and find N most frequent pairs with a gap constant G
% Return the found pairs as a list

-module(pairs).

-export([sort/1, print/1, take/2, find_pairs/2, find_pairs_file/2]).

% Map manipulation functions

% Sort the map and return a list with the biggest element at top
% returns a list of {c, c, int} tuples
sort(Map) ->
    L = maps:to_list(Map),
    Convert = fun({{A, B}, C}) -> {A, B, C} end,
    L1 = lists:map(Convert, L),
    lists:reverse(lists:keysort(3, L1)).

% A function to take N most common elements from value map
% List version first
take(_, 0) -> [];
take([H | T], N) ->
    [H|take(T, N-1)];
% Then a map version
take(Map, N) ->
    take(sort(Map), N).


% @todo add a function to drop eleemtns with less than X values

make_pairs(_, [], M) ->
    M;
% @todo fix hardcoded space with proper whitespace
% Need to use an accepted characters set instead (a-z, A-Z, I think)
make_pairs(32, _, Map) ->
    Map;
make_pairs(X, [32 | T], Map) ->
    make_pairs(X, T, Map);
make_pairs(X, [H | T], M) ->
    Pair = {X, H},
    Map = make_pairs(X, T, M),
    case maps:find(Pair, Map) of
        {ok, Val} ->
            Map#{Pair := Val+1};
        error ->
            Map#{Pair => 1}
    end.

% We need (char, char) -> N type of a map
% counts the amount of characters withing distance of gap constant G
% @todo count to more than 1 (cap constant)
% @todo do we filter whitespace and misc characters (like ')?
% Matches only forward that is abba => {a, b} => 2, {b, b} => 1, {b, a} => 1, {a, a} => 1
% Skips whitespace but counts it in to the gap constant (logical distance)
%
% Should never happen
pairs(_, 0, _) ->
    error;
% one element left nothing to match
pairs([_H], _, Map) ->
    Map;
pairs([32, X | T], G, Map) ->
    pairs([X | T], G, Map);
pairs([H | T], G, Map) ->
    M = make_pairs(H, lists:sublist(T, G), Map),
    pairs(T, G, M).

print(List) when is_list(List) ->
    F = fun({X, Y, Z}, _) -> io:format("{~c, ~c} => ~w~n", [X, Y, Z]) end,
    lists:foldl(F, 0, List);
print(Map) when is_map(Map) ->
    F = fun({X, Y}, V, _) -> io:format("{~c, ~c} => ~w~n", [X, Y, V]) end,
    maps:fold(F, 0, Map).


% Returns an unsorted map of {c1, c2} character pair -> value
find_pairs([], _, Map) ->
    Map;
find_pairs([H | T], G, Map) ->
    Res = pairs(H, G, Map),
    find_pairs(T, G, Map),
    Res.

find_pairs(List, G) ->
    find_pairs(List, G, #{}).

% @todo this doesn't seem to work properly: test with G=2 and G=5 (oh with G=10 it gives different results
%   create an artificial test file that we have hand counted.
find_pairs_file(Filename, G) ->
    % Read file into a list
    {_,Cont} = file:read_file(Filename),
    % FIXME this only works on UNIX files, need \r and \n\r too
    X = [binary_to_list(Bin) || Bin <- binary:split(Cont,<<"\n">>,[global]),
                           Bin =/= << >>],
    find_pairs(X, G).

