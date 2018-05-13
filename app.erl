% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Does threaded reading of multiple input files and processes them with pairs module

-module(app).

-export([start/1, start/3, worker/3]).

worker(Pid, File, G) ->
    M = pairs:find_pairs_file(File, G),
    Pid ! {pairs, M}.


start(InputConfig) ->
    {_,Cont} = file:read_file(InputConfig),
    [Gap, K | Files] = pairs:split_lines(Cont),
    % @todo check that the files exist

    start(Files, list_to_integer(K), list_to_integer(Gap)).

% @todo check for empty files
start(Files, K, Gap) ->
    % @todo pass the collector PID here (or our pid)
    % when we have spawned all the processes we wait for them to finish
    % before outputting results
    % So as data a worker needs: A filename, Pid where to send messages
    {_, N} = spawner(Files, Gap, 0),
    io:format("count = ~w~n", [N]),

    % wait for all workers
    Res = loop(N),
    % print five most common character pairs from all files
    io:format("Received all pairs - Print ~w most common: ~n", [K]),
    pairs:print(pairs:take(pairs:sort(Res), K)).

% Receive N messages from workers
% return all results in a single map (unsorted)
loop(0) -> #{};
loop(N) ->
    receive
        {pairs, Res} ->
            % combine previous results into single map
            pairs:merge(Res, loop(N-1))
    end.


spawner([], _Gap, Count) -> {ok, Count};
spawner([H | T], Gap, Count) ->
    spawn(app, worker, [self(), H, Gap]),
    spawner(T, Gap, Count+1).

