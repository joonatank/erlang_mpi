% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Does threaded reading of multiple input files and processes them with pairs module

-module(app).

-export([start/1, worker/3]).

worker(Pid, File, G) ->
    M = pairs:find_pairs_file(File, G),
    Pid ! {pairs, M}.


start(Files) ->
    % @todo pass the collector PID here (or our pid)
    % when we have spawned all the processes we wait for them to finish
    % before outputting results
    % So as data a worker needs: A filename, Pid where to send messages
    {_, N} = spawner(Files, 0),
    io:format("count = ~w~n", [N]),

    % wait for all workers
    Res = loop(N),
    % print five most common character pairs from all files
    io:format("Received all pairs - Print 5 most common: ~n"),
    pairs:print(pairs:take(pairs:sort(Res), 5)).

% Receive N messages from workers
% return all results in a single map (unsorted)
loop(0) -> #{};
loop(N) ->
    receive
        {pairs, Res} ->
            % combine previous results into single map
            pairs:merge(Res, loop(N-1))
    end.


spawner([], Count) -> {ok, Count};
spawner([H | T], Count) ->
    G = 2,
    spawn(app, worker, [self(), H, G]),
    spawner(T, Count+1).

