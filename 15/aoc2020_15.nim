## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 15: Rambunctious Recitation
## https://adventofcode.com/2020/day/15
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import strformat
import strutils
import tables


func nthNumber(index: TableRef[int, seq[int]], start: seq[int], n: int): int =
    var
        i = 0           # iteration counter
        cur = 0         # current number
        pre = 0         # prev number
    assert n > start.len
    # initialize index
    for sn in start:
        i.inc
        # debugEcho(fmt"turn {i} say number {sn}")
        index[sn] = @[i]
        pre = sn
    # compute nth number from index
    while i < n:
        i.inc
        # debugEcho index
        if pre in index:
            let seq = index[pre]
            if seq.len > 1:
                cur = seq[^1] - seq[^2]
            else:
                cur = i - 1 - seq[^1]
        else:
            cur = 0
        # debugEcho(fmt"turn {i} say number {cur}")
        if cur notin index:
            index[cur] = newSeq[int]()
        index[cur].add(i)
        if index[cur].len > 2:
            index[cur].delete(0)
        pre = cur
    cur

if isMainModule:
    let inputs = @[
        @[0, 3, 6],
        @[1, 3, 2],
        @[2, 1, 3],
        @[1, 2, 3],
        @[2, 3, 1],
        @[3, 2, 1],
        @[3, 1, 2],
        @[13, 16, 0, 12, 15, 1]
    ]

    for input in inputs:
        var index = newTable[int, seq[int]]()
        let ns = nthNumber(index, input, 2020)
        echo fmt"for input {input} the nth number spoken is {ns}"
