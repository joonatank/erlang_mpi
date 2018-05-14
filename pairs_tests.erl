% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Under a copyleft, do what you want.
%
% Tests for pairs module


-module(pairs_tests).

-include_lib("eunit/include/eunit.hrl").

%find_pairs_test() -> ?assert(#{{a,b} => 2, {b,a} => 1} = pairs:find_pairs("abab", 2)).
find_pairs_test() -> #{{97,98} := 1} = pairs:find_pairs("ab", 1).
find_pairs2_test() -> #{{97,98} := 2, {98,97} := 1} = pairs:find_pairs("abab", 1).
%TODO 2 and 3 gap test
find_pairs3_test() -> #{{97,98} := 2, {97,97} := 1, {98,97} := 1, {98,98} := 1} = pairs:find_pairs("abab", 2).
find_pairs4_test() ->
    #{{97,98} := 2, {97,97} := 1, {98,97} := 1, {98,98} := 1, {97,99} := 1, {98,99} := 1} = pairs:find_pairs("ababc", 2).

merge1_test() -> #{a := 2, b := 1} = pairs:merge(#{a => 1}, #{a => 1, b => 1}).
merge2_test() -> #{a := 3, b := 1, c := 1} = pairs:merge([#{a => 1}, #{a => 1, b => 1}, #{a => 1, c => 1}]).

sort_test() -> [{a, b, 3}, {b, b, 2}, {b, c, 1}] = pairs:sort(#{{b,c} => 1, {a, b} => 3, {b, b} => 2}).

take_test() -> [{a, b, 3}] = pairs:take(#{{b,c} => 1, {a, b} => 3, {b, b} => 2}, 1).
