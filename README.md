Coursework for Advanced Functional Programming 2018 at UTA

## What does it do
Requires N+1 input files:
* config file (explained below)
* N data files

Config file: TODO table

{CAP_CONSTANT} : int : distance between two characters
{N_FREQUENT_PAIRS} : int : How many frequent pairs do we output
{FILENAME} : string : name of the first datafile
...
{FILENAME_N} : string : name of the N datafile

Data file: TODO table

Random text file

Output file: TODO table

{CHAR1} {CHAR2} {N_PAIR_FOUND} {N_LINES_TOTAL}
where
* CHAR1 first character of the pair
* CHAR2 second character of the pair
* N_PAIR_FOUND is the number of lines the character pair was found in all input files
* N_LINES_TOTAL is the number of lines total in all input files



We look for pairs of characters within distance of gap constant. Example (a,b) in string "acdeb" is within gap constant 4.

Data files are processed in separate worker threads.

## How is it made

### Erlang

### Haskell

