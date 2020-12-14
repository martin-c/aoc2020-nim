## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 14: Docking Data
## https://adventofcode.com/2020/day/14
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html


import bitops
import os
import parseutils
import re
import sequtils
import streams
import strformat
import strutils
import sugar
import tables


type
    Mask = tuple
        set_m: uint64
        clr_m: uint64

    Value = tuple
        adr: uint64
        val: uint64

    InstType = enum
        mask_e, value_e

    Inst = object
        case kind: InstType
        of mask_e: imask: Mask
        of value_e: ivalue: Value


const
    input_url = "https://adventofcode.com/2020/day/14/input"
    input_filename = "input.txt"


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


func parseInst(cmd: string, val: string): Inst =
    if cmd == "mask":
        let inst = Inst(
            kind: mask_e,
            imask: (
                set_m: val.replace('X', '0').fromBin[:uint64],
                clr_m: val.replace('X', '1').fromBin[:uint64]
                )
            )
        return inst
    elif "mem" in cmd:
        let a = cmd[0..^2].split('[')[1]
        let inst = Inst(
            kind: value_e,
            ivalue: (
                adr: a.parseBiggestUInt,
                val: val.parseBiggestUInt
            )
        )
        return inst


proc applyInst(mem: TableRef, msk: var Mask, inst: Inst) =
    case inst.kind:
        of mask_e:
            msk = inst.imask
        of value_e:
            var mem_val = inst.ivalue.val
            setMask(mem_val, msk.set_m)
            mask(mem_val, msk.clr_m)
            mem[inst.ivalue.adr] = mem_val


proc parseInput(filename: string = input_filename): seq[Inst] =
    var strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        var line = ""
        while strm.readLine(line):
            if line.len == 0:
                continue
            let parts = line.split(" = ")
            result.add(parseInst(parts[0], parts[1]))
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


if isMainModule:
    getInput()
    let insts = parseInput()
    var mem_state = newTable[uint64, uint64]()
    var mask_state = (set_m: 0'u64, clr_m: 0'u64)
    for inst in insts:
        echo inst
        applyInst(mem_state, mask_state, inst)
        # echo "memstate: ", mem_state
        # echo "mask: ", mask_state
    var total = 0'u64
    for v in mem_state.values:
        total += v
    echo "total of all values: ", total
