## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 8: Handheld Halting
## https://adventofcode.com/2020/day/8
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import intsets
import options
import os
import sequtils
import streams
import strformat
import strutils


type
    Operation = enum
        acc, jmp, nop
    Instruction = tuple[op: Operation, arg: int]
    ProgState = tuple[pc: int, acc: int]


const
    input_url = "https://adventofcode.com/2020/day/8/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): seq[string] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        # streams.lines iterator doesn't work here when nre is imported?
        var line = ""
        while strm.readLine(line):
            result.add(line)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


func parseInstruction(line: string): Instruction =
    let parts = line.split(' ')
    assert parts.len == 2
    (parseEnum[Operation](parts[0]), parseInt(parts[1]))


func run(prog: seq[Instruction], lines_run: var IntSet,
        initial_state: ProgState = (pc: 0, acc: 0)): ProgState =
    var s = initial_state
    while s.pc notin lines_run and s.pc < prog.len:
        lines_run.incl(s.pc)
        let (op, arg) = prog[s.pc]
        case op:
            of nop:
                s.pc += 1
            of acc:
                s.acc += arg
                s.pc += 1
            of jmp:
                s.pc += arg
    s


func complete(state: ProgState, inst_count: int): bool =
    state.pc >= inst_count


func findError(prog: seq[Instruction], swap_ops: seq[(Operation, Operation)]):
        Option[(Operation, Operation, int, ProgState)] =
    var mprog = prog
    let inst_count = mprog.len
    for from_op, to_op in swap_ops.items:
        for line_number, inst in mprog.mpairs:
            if inst.op == from_op:
                inst.op = to_op
                var lines_run = initIntSet()
                let state = mprog.run(lines_run)
                if state.complete(inst_count):
                    return some((from_op, to_op, line_number, state))
                else:
                    inst.op = from_op


if isMainModule:
    getInput()
    let
        lines = parseInput()
        program = lines.map(parseInstruction)
    # echo lines
    # echo program
    var lines_run = initIntSet()
    let final_state = program.run(lines_run)
    echo fmt"final program state: line={final_state.pc}, acc={final_state.acc}"
    echo fmt"lines run: ", lines_run
    let error = program.findError(@[(jmp, nop), (nop, jmp)])
    if error.isSome:
        let fix = error.get()
        echo fmt"Swapped op {fix[0]} to {fix[1]} on line {fix[2]} to fix program"
        echo fmt"final program state: line={fix[3].pc}, acc={fix[3].acc}"
    else:
        echo "could not fix program"
