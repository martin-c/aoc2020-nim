## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 3: Toboggan Trajectory
## https://adventofcode.com/2020/day/3
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import os
import streams
import strformat
import sequtils
import strutils


const input_url = "https://adventofcode.com/2020/day/3/input"
const input_filename = "input.txt"


type
    ObstacleTable = seq[seq[char]]
    ObstacleKey = tuple[free: char, blocked: set[char]]


proc getInput(url: string=input_url, filename: string=input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string): ObstacleTable =
    ## parse input text into a sequence of sequences, where the first sequence
    ## represents the rows of the text file and the second sequence represents
    ## the positions within that row
    var strm = newFileStream(filename, fmRead)
    var line_length = 0
    if not isNil(strm):
        let lines = toSeq(strm.lines).filterIt(it.len > 0)
        for line in lines:
            # ensure all lines are equal length
            if line_length == 0:
                line_length = line.len
            else:
                assert line.len == line_length
            result.add(cast[seq[char]](line))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"

func CountCollisions(table: ObstacleTable, key: ObstacleKey,
        slope: tuple[x: int, y: int]=(1,1)): int =
    var
        pos_x: int = 0
        pos_y: int = 0

    while pos_y < table.len:
        var row = table[pos_y]
        var x = pos_x mod row.len
        if row[x] in key.blocked:
            result += 1
        pos_x += slope.x
        pos_y += slope.y
    debugEcho fmt"ended collision detection at x={pos_x} and y={pos_y}"


if isMainModule:
    getInput()
    var obstacle_table = parseInput(input_filename)
    let obstacle_key = ('.', {'#'})
    let slopes = @[(1,1), (3,1), (5,1), (7,1), (1,2)]
    let collisions = slopes.mapIt(CountCollisions(obstacle_table, obstacle_key, it))
    echo collisions
    echo fmt"product of all collisions: ", collisions.foldl(a * b, 1)
