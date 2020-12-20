## Advent of Code 2020
## Solutions implemented in Nim Programming Language (www.nim-lang.org)
## Day 19: Monster Messages
## https://adventofcode.com/2020/day/19
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
import sugar
import tables


const
    input_url = "https://adventofcode.com/2020/day/19/input"
    input_filename = "input_test_2.txt"
    rules_output_filename = "rules_out.txt"
    message_output_filename = "messages_out.txt"


type ParseState = tuple
    key: string
    id: string
    res: seq[string]

type Capture = object
    s: string      # The captured string
    si: int        # The index of the captured string in the subject


proc getInput(url: string = input_url, filename: string = input_filename) =
    ## Save input from `input_url` into a text file `input_filename` inside
    ## working directory. Skip if `input_filename` exists.
    echo "using directory ", getCurrentDir()
    if not fileExists(input_filename):
        let cmd = fmt"wget --load-cookies=../cookies-adventofcode-com.txt -O input.txt {url}"
        let res = execShellCmd(cmd)
        echo fmt"wget returned {res}"


proc parseInput(filename: string = input_filename): (Table[int, string], seq[string]) =
    ## Parse input data file into appropriate Nim data structures
    var
        strm = newFileStream(filename, fmRead)
        rules = initTable[int, string]()
        input = newSeq[string]()
    if not isNil(strm):
        for line in strm.lines:
            if line.len == 0:
                continue
            let parts = line.split(':')
            if parts.len > 1:
                # parse a rule
                rules[parts[0].parseInt] =
                    parts[1].
                    unindent.
                    replace("\"")
            else:
                # parse input
                input.add(line)
        strm.close()
    else:
        echo fmt"input file {filename} does not exist"
    result = (rules, input)


proc c(num: string): string =
    ## convert an identifier like '42' to a string like 'db'
    var n = num.parseInt()
    chr(ord('a') + n div 24) & "a" & chr(ord('a') + n mod 24)


proc generateNpegRules(rules: Table[int, string]): seq[string] =

    let parser = peg("rule", st: ParseState):
        lit     <- "a" | "b" * !1:
            st.res.add(fmt"{st.id} <- " & "\"" & capture[0].s & "\"")
        dgs     <- +Digit * *(' ' * +Digit)
        sec     <- >+dgs * *(" | " * >+dgs) * !1:
            #for i in (0 ..< capture.len):
            #    echo capture[i].s
            let items = capture[1].s.split(' ').map(c)
            var s = st.id & " <- " & items.join(" * ")
            if st.key == "0":
                s = s & " * !1"
            for i in (2 ..< capture.len):
                #echo capture[i].s
                let items = capture[i].s.split(' ').map(c)
                s = s & " | " & items.join(" * ")
            st.res.add(s)
        rule    <- lit | sec

    var
        res = newSeq[string]()
        state = (key: "", id: "", res: res)
    for key, val in rules:
        state.key = $key
        state.id = c($key)
        let res = parser.match(val, state)
        #echo fmt"rule {key}, {val}: {res}"
        assert res.ok
    state.res


proc expf(rules: seq[string], filename: string) =
    var
        strm = newFileStream(filename, fmWrite)
    if not isNil(strm):
        for line in rules:
            strm.writeLine(line.indent(2 * 4))
        strm.close()


proc runWorker() =
    const
        fp1 = "worker_part1.nim"
        fp2 = "worker_part2.nim"
    let cmds = @[
        fmt"cat {fp1} {rules_output_filename} {fp2} > worker.nim",
        fmt"nim -r c worker.nim"
    ]
    var ret: seq[int] = @[]
    for cmd in cmds:
        echo cmd
        ret.add(execShellCmd(cmd))
    echo ret


if isMainModule:
    getInput()
    let (rules, messages) = parseInput()
    #echo rules
    #echo messages
    let npeg = generateNpegRules(rules)
    npeg.expf(rules_output_filename)
    @[$messages].expf(message_output_filename)
    runWorker()
