## Worker program, called from main program

import macros
import npeg
import sequtils
import strformat
import strutils
import tables


macro eval(value: static[string]): untyped =
  result = parseStmt value

let messages = eval(slurp("messages_out.txt"))


proc check(): seq[bool] =

    let parser = peg("aaa"):
        # insert rules here
        fam <- eau * eaj | cas * eax
        dax <- cab * eau | bad * cas
        cag <- cas * bat | eau * daj
        fag <- eap * eau | eam * cas
        cab <- eau * eau | eau * cas
        dak <- ear * eau | dav * cas
        fak <- cak * eau | aav * cas
        bac <- cai * eau | eaj * cas
        fap <- cas * cat | eau * bai
        ead <- cas * cai | eau * eaj
        fad <- eav * eau | fao * cas
        faf <- daf * cas | cah * eau
        aat <- eau * aae | cas * dau
        cae <- eax * cao
        aag <- fal * cas | bad * eau
        bax <- aae * eau
        cau <- cas * fam | eau * cae
        aam <- dau * eau | eag * cas
        cai <- cas * eau | eau * eau
        cad <- aae * eau | cab * cas
        can <- cag * cas | cac * eau
        eau <- "a"
        eam <- eau * bar | cas * bar
        fan <- aae * cas | aae * eau
        eac <- cas * dal | eau * bar
        dai <- eau * cai | cas * cab
        dat <- cas * baw | eau * bav
        eao <- eau * aax | cas * dao
        cac <- eau * fam | cas * bae
        eaf <- aar * cas | dau * eau
        bal <- eau * aav | cas * eaj
        aah <- eau * fag | cas * daq
        cah <- aae * cas | dal * eau
        eaw <- eau * faj | cas * bal
        eaj <- eau * eau
        caq <- cas * bar | eau * bad
        faq <- dal * cas | eag * eau
        faa <- dal * cas | cak * eau
        eal <- fal * cao
        bam <- cas * fal | eau * aav
        bah <- aaw * cas | bau * eau
        daf <- aae * cas | cak * eau
        aar <- cas * cas | eau * eau
        aas <- eau * aau | cas * bab
        bak <- cas * fai | eau * eal
        daj <- aae * eau | aar * cas
        bau <- fap * eau | daw * cas
        eab <- eau * eax | cas * bad
        eai <- cas * aag | eau * cap
        bad <- cao * cao
        aaa <- aai * aal * !1
        dao <- eau * dau | cas * dal
        eak <- baa * eau | bac * cas
        dav <- eau * ead | cas * fan
        daa <- eau * dac | cas * eao
        das <- cas * aao | eau * dat
        dab <- eax * cas | dau * eau
        aax <- eau * aav | cas * cai
        aav <- cas * eau
        aai <- bas
        caj <- cai * eau | eax * cas
        fac <- eaj * cas | eax * eau
        fal <- cas * cas | cas * eau
        caf <- eau * fab | cas * daa
        dah <- eau * cal | cas * caq
        fae <- cas * eau | eau * cas
        aae <- eau * cas
        cat <- caa * cas | dad * eau
        car <- cas * cab | eau * cak
        eae <- cas * aas | eau * aak
        aaf <- eau * aad | cas * eap
        eag <- eau * eau | cas * cao
        aal <- bas * bah
        bap <- cas * dag | eau * eat
        eap <- cas * eax | eau * aae
        aad <- bar * cas | cai * eau
        eah <- eau * baj | cas * bax
        caw <- eac * eau | eab * cas
        aac <- eax * eau | aae * cas
        aaw <- cas * aap | eau * eaa
        bao <- cas * bag | eau * eas
        eas <- eau * fae | cas * eaj
        baf <- eag * cas | aae * eau
        eav <- cas * dau | eau * fal
        eat <- cab * cao
        bai <- eau * faf | cas * aaq
        baw <- dax * eau | car * cas
        dae <- dai * cas | ean * eau
        aaq <- cas * aac | eau * faa
        eaa <- cas * cam | eau * can
        fah <- eau * eaf | cas * car
        cap <- eax * cas | bad * eau
        dag <- cas * fal | eau * cak
        dau <- cas * eau | cao * cas
        dar <- fad * eau | eai * cas
        eax <- cas * cas | eau * cao
        bae <- eau * aar | cas * cab
        caa <- baf * cas | faj * eau
        eaq <- cas * eac | eau * cav
        dal <- eau * cao | cas * eau
        bar <- cas * cas
        aan <- fac * cas | dan * eau
        bag <- cas * eaj | eau * eaj
        ear <- cas * dab | eau * cad
        bat <- cas * aar | eau * aav
        aab <- cai * cas | aar * eau
        cam <- bao * eau | dah * cas
        aau <- eau * dap | cas * aan
        aao <- aaj * cas | dae * eau
        faj <- eag * cas | cak * eau
        aaj <- fak * eau | aat * cas
        cav <- eau * dau | cas * aar
        daq <- caj * eau | cah * cas
        cal <- cas * aae | eau * cak
        fai <- cas * eax | eau * cak
        cax <- aaf * eau | eah * cas
        ban <- eau * caf | cas * das
        bab <- eau * cau | cas * bak
        baj <- cas * bar | eau * eag
        cao <- eau | cas
        dad <- bag * cas | bam * eau
        dac <- cas * aam | eau * aab
        aak <- cas * cax | eau * dak
        cas <- "b"
        aap <- dam * eau | aah * cas
        cak <- eau * cas | cas * cas
        fao <- cas * cak | eau * aar
        fab <- cas * eaq | eau * fah
        bas <- ban * cas | eae * eau
        baa <- aar * eau | dal * cas
        baq <- eaw * cas | eak * eau
        dan <- dau * eau | fal * cas
        daw <- cas * baq | eau * dar
        dap <- cas * aad | eau * aac
        dam <- bap * cas | caw * eau
        ean <- bar * eau
        bav <- faq * cas | bag * eau

    for msg in messages:
        let res = parser.match(msg)
        result.add(res.ok)


if isMainModule:
    let res = check()
    let count = res.filterIt(it)
    echo fmt"found {count.len} valid messages"
