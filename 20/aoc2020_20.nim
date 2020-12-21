## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 20: Jurassic Jigsaw
## https://adventofcode.com/2020/day/20
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## HashSet: https://nim-lang.org/docs/sets.html#HashSet
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html
## Nim memory model: http://zevv.nl/nim-memory/#_memory_organization_in_nim
## Nim Npeg: https://github.com/zevv/npeg


import algorithm
import sets
import os
import options
import sequtils
import streams
import strformat
import strutils
#import sugar
#import tables
import tilegrid


const
    input_url = "https://adventofcode.com/2020/day/20/input"
    input_filename = "input_test_1.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[Tile] =
    ## Parse input data file into appropriate Nim data structures
    var
        strm = newFileStream(filename, fmRead)
        tile = none(Tile)
    if not isNil(strm):
        for line in strm.lines:
            if line.len == 0:
                if tile.isSome:
                    # tile is parsed up -> down and stored down -> up
                    let parts = tile.get().data.distribute(tile_height)
                    tile.get().data = parts.reversed.concat()
                    result.add(tile.get())
                    tile = none(Tile)
                continue
            if Digits in line:
                let parts = line.split(' ')
                tile = some(Tile(
                    id: parts[1][0 .. ^2].parseInt,
                    data: newSeqOfCap[char](tile_width * tile_height)
                ))
            else:
                tile.get().data.add(line)
        strm.close()
        # make sure all tiles have been added to results
        assert tile.isNone
    else:
        echo fmt"input file {filename} does not exist"


proc align(tiles: seq[Tile]) =
    var
        group = Group(data: @[])
        rem = tiles[1 .. ^1]
        match = true

    assert group.tryInsertAt(tiles[0], (0, 0, 0, false))

    echo "matching tiles without rotation"
    while (rem.len > 0 and match):
        block match_tile:
            for point in group.perimeter.items:
                for i in 0 ..< rem.len:
                    if group.tryInsertAt(rem[i], (point.x, point.y, 0, false)):
                        rem.delete(i, i)
                        match = true
                        break match_tile
            match = false

    echo fmt"group: {group}"
    echo fmt"tiles remaining: {rem}"


if isMainModule:
    getInput()
    let tiles = parseInput()
    #for tile in tiles:
    #    echo tile
    tiles.align()
