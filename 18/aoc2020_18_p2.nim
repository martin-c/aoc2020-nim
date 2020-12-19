## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 18: Operation Order
## https://adventofcode.com/2020/day/18
##
## Resources:
## Streams: https://nim-lang.org/docs/streams.html#15
## Array and Sequence Types: https://nim-lang.org/docs/manual.html#types-array-and-sequence-types
## Parseutils: https://nim-lang.org/docs/parseutils.html
## Parsing input: https://old.reddit.com/r/nim/comments/k22h74/advent_of_nim_2020/gealoo3/
## Regular Expressions: https://nim-lang.org/docs/re.html
## Nim memory model: http://zevv.nl/nim-memory/#_memory_organization_in_nim
## Nim Npeg: https://github.com/zevv/npeg


import npeg
import os
import options
import sequtils
import streams
import strformat
import strutils


const
    input_url = "https://adventofcode.com/2020/day/18/input"
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
    ## Parse input data file into appropriate Nim data structures
    var
        strm = newFileStream(filename, fmRead)
    if not isNil(strm):
        for line in strm.lines:
            if line.len == 0:
                continue
            result.add(line)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"


proc hackParens(exp: seq[string]): seq[string] =
    ## insert parens () around each + operators terms
    var
        res = exp
        repeat = true
    while repeat:
        repeat = false
        for n in 0 ..< res.len:
            if res[n] == "+":
                res[n] = "."
                # move right
                var
                    bal = 0
                    j = 0
                for j in n+1 ..< res.len:
                    let t = res[j]
                    if t == "(": bal.inc
                    if t == ")": bal.dec
                    if bal == 0:
                        res.insert(@[")"], j+1)
                        break
                # move left
                bal = 0
                j = n-1
                while j >= 0:
                    let t = res[j]
                    if t == ")": bal.inc
                    if t == "(": bal.dec
                    if bal == 0:
                        res.insert(@["("], j)
                        break
                    j.dec
                repeat = true
                break
    result = res.mapIt(if it == ".": "+" else: it)


proc parseExpr(exp: string): seq[string] =
    ## Parse an expression into its components
    # echo exp
    # This Npeg expression is based on the example found here:
    # https://github.com/zevv/npeg#examples
    let parser = peg "line":
        exp     <- term * *(*' ' * >('+'|'-'|'*'|'/') * *' ' * term)
        term    <- >+{'0'..'9'} | (>'(' * exp * >')')
        line    <- exp * !1
    let res = parser.match(exp)
    assert res.ok
    # echo res, res.captures
    return hackParens(res.captures)


proc evalExpr(exp: string): int =
    ## Evaluate a complete expression
    # It may be possible to avoid using the state machine below through
    # more sophisticated use of the Npeg package, especially the code
    # block captures feature.
    var
        res = 0                 # result of previous operation
        opr = none(char)        # last operand
        # stack for ()
        stk = newSeq[(int, Option[char])]()
    let parts = parseExpr(exp)

    func evo(r: int, o: char, n: int): int =
        ## evaluate an operator `o`, return new result `r`
        result = case o:
            of '+': r + n
            of '-': r - n
            of '*': r * n
            of '/': assert n != 0; r div n
            else: r

    proc evt(r: int, o: var Option[char], n: int): int =
        ## evaluate a number (term) `n`
        if o.isSome:
            result = evo(r, o.get(), n)
            o = none(char)
        else:
            # first number in expression
            result = n

    for p in parts:
        # echo fmt"part: {p}, res: {res}, opr: {opr}"
        case p[0]:
            of {'+', '-', '*', '/'}: opr = some(p[0])
            of '(':
                # push the current state onto the stack
                stk.add((res, opr))
                res = 0; opr = none(char)
            of ')':
                # pop state and restore
                let nr = res
                (res, opr) = stk.pop()
                res = evt(res, opr, nr)
            else:
                # numerical part
                res = evt(res, opr, p.parseInt)
    res


proc runTests() =
    assert evalExpr("((1))") == 1
    assert evalExpr("1 + (2)") == 3
    assert evalExpr("1 + 2 * 3 + 4 * 5 + 6") == 231
    assert evalExpr("1 + (2 * 3) + (4 * (5 + 6))") == 51
    assert evalExpr("2 * 3 + (4 * 5)") == 46
    assert evalExpr("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445
    assert evalExpr("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060
    assert evalExpr("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340


if isMainModule:
    runTests()
    getInput()
    let lines_in = parseInput()
    var a = 0'u64
    echo "sum of results: ", lines_in.map(evalExpr).foldl(a + b)
