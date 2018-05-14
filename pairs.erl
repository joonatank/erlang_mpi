% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Under a copyleft, do what you want.

% Read a file and find N most frequent pairs with a gap constant G
% Return the found pairs as a list

-module(pairs).

-export([sort/1, print/1, take/2, merge/1, merge/2, split_lines/1, find_pairs/2, find_pairs_file/2]).

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

% merge
merge(M1, M2) when not is_list(M1) ->
    maps:fold(fun(K, V, Map) -> maps:update_with(K, fun(X) -> X + V end, V, Map) end, M1, M2);
% list of maps merge
merge([], Map) -> Map;
merge([H | T], Map) ->
    merge(H, merge(T, Map)).

merge(L) when is_list(L) -> merge(L, #{}).

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

print(List) when is_list(List) ->
    F = fun({X, Y, Z}, _) -> io:format("{~c, ~c} => ~w~n", [X, Y, Z]) end,
    lists:foldl(F, 0, List);
print(Map) when is_map(Map) ->
    F = fun({X, Y}, V, _) -> io:format("{~c, ~c} => ~w~n", [X, Y, V]) end,
    maps:fold(F, 0, Map).


% We need (char, char) -> N type of a map
% counts the amount of characters withing distance of gap constant G
% @todo do we filter whitespace and misc characters (like ')?
% Matches only forward that is abba => {a, b} => 2, {b, b} => 1, {b, a} => 1, {a, a} => 1
% Skips whitespace but counts it in to the gap constant (logical distance)

% Returns an unsorted map of {c1, c2} character pair -> value
% Takes a list of characters i.e. a line
% returns a map of character pairs
find_pairs([], _, Map) ->
    Map;
% ignore spaces
find_pairs([32, X | T], G, Map) ->
    find_pairs([X | T], G, Map);
find_pairs([H | T], G, Map) ->
    Res = make_pairs(H, lists:sublist(T, G), Map),
    find_pairs(T, G, Res).

find_pairs(List, G) ->
    find_pairs(List, G, #{}).

split_lines(Cont) ->
    % FIXME this only works on UNIX files, need \r and \n\r too
    [binary_to_list(Bin) || Bin <- binary:split(Cont,<<"\n">>,[global]),
                           Bin =/= << >>].

% @todo this doesn't seem to work properly: test with G=2 and G=5 (oh with G=10 it gives different results
%   create an artificial test file that we have hand counted.
%
% Returns {ok, Map} whit no errors and {error, #{}} for errors.
find_pairs_file(Filename, G) ->
    case filelib:is_regular(Filename) of
        true ->
            % Read file into a list
            {_,Cont} = file:read_file(Filename),
            X = split_lines(Cont),
            % find_pairs works on a single line, so we map over it
            F = fun (H) -> find_pairs(H, G) end,
            L = lists:map(F, X),
            {ok, merge(L, #{})};
        false ->
            {error, #{}}
    end.

