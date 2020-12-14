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
    InstType = enum
        mask_e, value_e

    Inst = object
        case kind: InstType
        of mask_e:
            set_m: uint64
            float_m: uint64
        of value_e:
            adr: uint64
            val: uint64


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
            set_m: val.replace('X', '0').fromBin[:uint64],
            float_m: val.replace('1', '0').replace('X', '1').fromBin[:uint64]
            )
        return inst
    elif "mem" in cmd:
        let a = cmd[0..^2].split('[')[1]
        let inst = Inst(
            kind: value_e,
            adr: a.parseBiggestUInt,
            val: val.parseBiggestUInt
        )
        return inst


func decodeAddresses(float_m: uint64, offset: uint64): seq[uint64] =
    result.add(offset)
    for bit_index in (0..<36):
        if float_m.testBit(bit_index):
            var v = 0'u64
            v.setBit(bit_index)
            # make a copy for iterating over
            var l = result
            for item in l:
                result.add(item + v)


proc applyInst(mem: TableRef, set_m, float_m: var uint64, inst: Inst) =
    case inst.kind:
        of mask_e:
            set_m = inst.set_m
            float_m = inst.float_m
        of value_e:
            # compute memory base value
            var adr_val = inst.adr
            setMask(adr_val, set_m)
            # clear all floating mask bits initially
            clearMask(adr_val, float_m)
            # compute address permuations from base value
            let addresses = decodeAddresses(float_m, adr_val)
            for a in addresses:
                mem[a] = inst.val


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
    var set_m, float_m = 0'u64
    for inst in insts:
        echo inst
        applyInst(mem_state, set_m, float_m, inst)
        # echo "memstate: ", mem_state
        # echo "mask set:", set_m, ", float:", float_m
    var total = 0'u64
    for v in mem_state.values:
        total += v
    echo "total of all values: ", total
