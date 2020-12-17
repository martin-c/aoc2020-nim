## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 17: Conway Cubes
## https://adventofcode.com/2020/day/17
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html
## Nim memory model: http://zevv.nl/nim-memory/#_memory_organization_in_nim


import os
import sequtils
import streams
import strformat
import strutils


const
    input_url = "https://adventofcode.com/2020/day/17/input"
    input_filename = "input.txt"
    min_x = -19
    max_x = 20
    size_x = max_x - min_x + 1
    min_y = -19
    max_y = 20
    size_y = max_y - min_y + 1
    min_z = -19
    max_z = 20
    size_z = max_z - min_z + 1
    min_w = -19
    max_w = 20
    size_w = max_w - min_w + 1


type
    Field = seq[bool]


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


func xi(x, y, z, w: int): int =
    ## transform x,y,z coordinates into an array index
    assert x >= min_x and x <= max_x
    assert y >= min_y and y <= max_y
    assert z >= min_z and z <= max_z
    assert w >= min_w and w <= max_w
    (x + size_x div 2 - 1) +
    (y + size_y div 2 - 1) * size_y +
    (z + size_z div 2 - 1) * size_y * size_z +
    (w + size_w div 2 - 1) * size_y * size_z * size_w


proc parseInput(filename: string = input_filename): seq[(int, int, int, int)] =
    ## Parse input data file into appropriate Nim data structures
    var
        strm = newFileStream(filename, fmRead)
        line = ""
        x, y = 0
    if not isNil(strm):
        while strm.readLine(line):
            x = 0
            for chr in line:
                if chr == '#':
                    result.add((x, y, 0, 0))
                x.inc
            y.inc
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


proc setInitial(f: var Field, cubes: seq[(int, int, int, int)]) =
    for (x, y, z, w) in cubes:
        f[xi(x, y, z, w)] = true


func countActive(f: Field, cx, cy, cz, cw: int): int =
    #debugEcho fmt"check {cx}, {cy}, {cz}, {cw}"
    for x in (cx - 1) .. (cx + 1):
        for y in (cy - 1) .. (cy + 1):
            for z in (cz - 1) .. (cz + 1):
                for w in (cw - 1) .. (cw + 1):
                    if x == cx and y == cy and z == cz and w == cw: continue
                    #debugEcho x, y, z, w
                    if f[xi(x, y, z, w)]:
                        result.inc()
                    if result > 3:
                        # don't care how much more than 3
                        return result


proc runStep(f: var Field, n: var Field) =
    # bounds for printing active cubes
    for x in (min_x + 1) .. (max_x - 1):
        for y in (min_y + 1) .. (max_y - 1):
            for z in (min_z + 1) .. (max_z - 1):
                for w in (min_w + 1) .. (max_w - 1):
                    let i = xi(x, y, z, w)
                    let act = countActive(f, x, y, z, w)
                    if act == 3 or (act == 2 and f[i]):
                        n[i] = true
                        assert x > (min_x + 1) and x < (max_x - 1)
                        assert y > (min_y + 1) and y < (max_y - 1)
                        assert z > (min_z + 1) and z < (max_z - 1)
                        assert w > (min_w + 1) and w < (max_w - 1)


proc run(inicub: seq[(int, int, int, int)], cycles=6): int =
    const field_size = size_x * size_y * size_z * size_w
    var fld = newSeq[bool](field_size)
    fld.setInitial(inicub)
    for c in 1..cycles:
        echo fmt"run cycle {c}"
        var newfld = newSeq[bool](field_size)
        fld.runStep(newfld)
        fld = newfld
    result = fld.foldl(if b: a + 1 else: a, 0)


if isMainModule:
    getInput()
    let init_cubes = parseInput()
    echo init_cubes
    let act_count = run(init_cubes)
    echo fmt"{act_count} active cubes"
