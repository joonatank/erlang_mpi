% @author Joonatan Kuosa (joonatan.kuosa@gmail.com) 425555
% @date 2018-05-07
%
% Coursework for Advanced functional programming 2018 at UTA
%
% Does threaded reading of multiple input files and processes them with pairs module

-module(app).

-export([start/1, start/4, worker/3]).

% Gracefully handles non-existing files by propagating the error and ignoring the faulty file.
worker(Pid, File, G) ->
    {Res, M, Lines} = pairs:find_pairs_file(File, G),
    Pid ! {pairs, M, Lines},
    % Not a very nice way of doing error handling, but print it and propagate
    case Res of
        error ->
            io:format("ERROR: find_pairs_file, incorrect file: ~s~n", [File]),
            error;
        ok ->
            ok
    end.


start(InputConfig) ->
    % check that file exists
    case filelib:is_regular(InputConfig) of
        true ->
            {_,Cont} = file:read_file(InputConfig),
            [Gap, K | Files] = pairs:split_lines(Cont),

            Output = "output.txt",
            start(Files, Output, list_to_integer(K), list_to_integer(Gap));
        false ->
            % @todo proper errors/exceptions
            io:format("ERROR: incorrect input file: ~s~n", [InputConfig]),
            error
    end.

% Non-existing files are handled upstream
start(Files, Output, K, Gap) ->
    % @todo pass the collector PID here (or our pid)
    % when we have spawned all the processes we wait for them to finish
    % before outputting results
    % So as data a worker needs: A filename, Pid where to send messages
    {_, N} = spawner(Files, Gap, 0),
    io:format("Processed ~w files.~n", [N]),

    % wait for all workers
    {Res, Lines} = loop(N),

    % print K most common character pairs from all files
    io:format("Printing ~w most common pairs: ~n", [K]),
    pairs:print(pairs:take(pairs:sort(Res), K)),

    % open a file from scratch
    {_, File} = file:open(Output, write),
    pairs:file_print(File, pairs:take(pairs:sort(Res), K), Lines).


% Receive N messages from workers
% return all results in a single map (unsorted)
loop(0) -> {#{}, 1};
loop(N) ->
    receive
        {pairs, Res, Lines} ->
            % combine previous results into single map
            {M, L} = loop(N-1),
            {pairs:merge(Res, M), Lines+L}
    end.


spawner([], _Gap, Count) -> {ok, Count};
spawner([H | T], Gap, Count) ->
    spawn(app, worker, [self(), H, Gap]),
    spawner(T, Gap, Count+1).

