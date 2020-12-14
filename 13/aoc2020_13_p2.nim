## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 13: Shuttle Search
## https://adventofcode.com/2020/day/13
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import algorithm
import os
import re
import sequtils
import streams
import strformat
import strutils
import sugar


const
    input_url = "https://adventofcode.com/2020/day/13/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): (int, seq[(int, int)]) =
    ## parse input and return a tuple in the form
    ## `(time: int, seq[bus_id: int, bus_id_sequence: int)]
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        var line = ""
        # read time
        assert strm.readLine(line) == true
        result[0] = parseInt(line)
        assert strm.readLine(line) == true
        let ids = line.split(',')                   # list of ids and 'x'
        result[1] = ids.zip(toSeq(0..<ids.len)).    # add sequence numbers to elements
            filterIt(it[0].match(re"\d+")).         # filter out the 'x'
            mapIt((it[0].parseInt, it[1]))          # parse the ids
        # sort by id
        result[1].sort do (x, y: (int, int)) -> int:
            cmp(x[0], y[0])
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func findNextBus(busses: seq[(int, int)], time: int): int =
    #[
       Realizing the following was essential in solving this puzzle:
       1. The bus ids are prime,
       2. The first occurrence of time `t` and offset `o` where `t % id_1 == 0`
       and `(t + o) % id_2 == 0` may occur before `t = id_1 * id_2`.
       3. The occurrence `t % id_1 == 0` and `(t + o) % id_2 == 0` repeats every
       `t = id_1 * id_2` regardless of `o`.
       So it's possible to sort the id list and start with the smallest id, and
       increment `time` by 1 until `(t + o_1) % id_1 == 0`, then move to the next
       largest id and increment by `1 * id_1`, then move to the next id and
       increment by `1 * id_1 * id_2` and so on. By the last id `n`, the increment
       equals `1 * id_1 * ... * id_n-1` which is very large so relative to the
       brute-force method only a few iterations are necessary.
       Making a table from `time=0` to `time=40` for `id_1=3` and `id_2=5` with
       `o_1 = 0`(offset id 1 (3) is 0) and `o_2 = 1` (offset id 2 (5) is 1)
       helped me a great deal with solving this problem.
    ]#
    let max_iter = 1_000
    var step = 1
    var t = 0
    for (id, offset) in busses:
        for _ in (0..<max_iter):
            if (t + offset) mod id == 0:
                step *= id
                break
            t += step
    t


if isMainModule:
    getInput()
    let (time, busses) = parseInput()
    echo "parsed notes: ", time, busses
    let bus_time = busses.findNextBus(time)
    echo fmt"time {bus_time}"
