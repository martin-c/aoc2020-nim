
    for msg in messages:
        let res = parser.match(msg)
        result.add(res.ok)


if isMainModule:
    let res = check()
    let count = res.filterIt(it)
    echo fmt"found {count.len} valid messages"
