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
    spawner(Files),

    % @todo keep a list of workers, we can exit only when we have received data from all
    % (is there an Erlang way to do this?)
    loop().

loop() ->
    receive
        {pairs, Res} ->
            io:format("Received pairs (print 5 most common): ~n"),
            pairs:print(pairs:take(Res, 5))
    end,
    loop().


spawner([]) -> ok;
spawner([H | T]) ->
    G = 2,
    spawn(app, worker, [self(), H, G]),
    spawner(T).

