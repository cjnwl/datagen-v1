# ---------------------------------------------------------
# ---------------------------------------------------------
# datagen.awk
# (c) cne : june 2017
# ---------------------------------------------------------
# ---------------------------------------------------------

##b --------------------------------------- initialisations
BEGIN {
    srand()
    _ord_init()
    ctr = 1
    OFS = "\t"
    # make these into a single is[] array ?
    is_first = 0
    is_last = 0
    is_name = 0
    is_words = 0
    is_usage = 0
}
##e

##b ---------------------------------- read definition file
{
    switch ($1) {
        case "":
            break
        case "records":
            records = $2
            break
        case "ofs":
            switch ($2) {
                case "tab":
                    OFS = "\t"
                    break
                case "newline":
                    OFS = "\n"
                    ORS = "\n\n"
                    break
                default:
                    OFS = $2
                    break
            }
            print ord(OFS)
            break
        case /field/:
            type[ctr] = $2
            if (NF <= 2) {
                params[ctr][1] = ""
            }
            for (i = 3; i <= NF; i++) {
                params[ctr][i-2] = $i
            } 
            spacer[ctr] = OFS
            ctr++
            break
        case "'":
        case "-":
        case "--":
        case "#":
            break
        default:      
            usage()
            break
    }
    switch ($2) {
        case "first":
            is_first = 1
            break
        case "last":
            is_last = 1
            break
        case "name":
            is_name = 1
            break
        case "word":
            is_words = 1
            break
        default:
            break
    }
    if ($1 == "field2") {
        spacer[ctr-1] = ""
    }
}
##e

##b --------------------------------------------- main loop
END {
    if (is_usage) {
        exit
    }
    if (is_name) {
        is_first = 1
        is_last  = 1
    }
    if (is_first) {
        load_firsts()
    }
    if (is_last) {
        load_lasts()
    }
    if (is_words) {
        load_words()
    }
    for (i = 1; i <= records; i++) {
        record = ""
        spacer[1] = ""
        for ( j = 1; j < ctr; j++) {
            if (type[j] == "lower")     { record = record spacer[j] lower(params[j])   }
            if (type[j] == "upper")     { record = record spacer[j] upper(params[j])   }
            if (type[j] == "alpha")     { record = record spacer[j] alpha(params[j])   }
            if (type[j] == "integer")   { record = record spacer[j] integer(params[j]) }
            if (type[j] == "number")    { record = record spacer[j] number(params[j])  }
            if (type[j] == "word")      { record = record spacer[j] word(params[j])    }
            if (type[j] == "first")     { record = record spacer[j] first(params[j])   }
            if (type[j] == "last")      { record = record spacer[j] last(params[j])    }
            if (type[j] == "name")      { record = record spacer[j] name(params[j])    }
            if (type[j] == "sep")       { record = record spacer[j] sep(params[j])     }
            if (type[j] == "date")      { record = record spacer[j] date(params[j])    }
            if (type[j] == "choose")    { record = record spacer[j] choose(params[j])  }
            if (type[j] == "yn")        { record = record spacer[j] yn()               }
            if (type[j] == "yesno")     { record = record spacer[j] yesno()            }
            if (type[j] == "tf")        { record = record spacer[j] tf()               }
            if (type[j] == "truefalse") { record = record spacer[j] truefalse()        }
            if (type[j] == "id")        { record = record spacer[j] id(params[j], i)   }
            if (type[j] == "space")     { record = record spacer[j] space()            }
            if (type[j] == "tab")       { record = record spacer[j] tab()              }
            if (type[j] == "newline")   { record = record spacer[j] newline()          }
            if (type[j] == "value")     { record = record spacer[j] value(params[j][1])}
            if (type[j] == "chr")       { record = record spacer[j] chr(params[j][1])  }
            if (type[j] == "day")       { record = record spacer[j] day(params[j])     }
            if (type[j] == "weekday")   { record = record spacer[j] weekday(params[j]) }
            if (type[j] == "month")     { record = record spacer[j] month(params[j])   }
            if (type[j] == "year")      { record = record spacer[j] year(params[j])    }
        }
        print i, record
    }
}
##e

##b -------------------------------------- output functions
function lower(p,      min, max, len, k, char, out) {
    min = p[1]
    max = p[2]
    len = randint(min, max)
    out=""
    for ( k = 1; k <= len; k++) {
        char = chr(96 + randint(1, 26))
        out = out char
    }
    return out
}

function upper(p,      min, max, len, k, char, out) {
    min = p[1]
    max = p[2]  
    len = randint(min, max)
    out=""
    for (k = 1; k <= len; k++) {
        char = chr(64 + randint(1, 26))
        out = out char
    }
    return out
}

function alpha(p,      min, max, str, k, strlen, len, char, out) {
    min = p[1]
    max = p[2]
    str = p[3]
    len = randint(min, max)
    strlen = length(str)
    out=""
    for (k = 1; k <= len; k++) {
        char = substr(str, randint(1, strlen), 1)
        out = out char
    }
    return out
}

function integer(p,      min, max, zero, len, str) {
    min = p[1]
    max = p[2]
    zero = p[3]
    return randint(min, max, zero)
}

function number(p,      min, max, dec) {
    min = p[1]
    max = p[2]
    dec = p[3]
    return sprintf("%" length(max " ")-1 "." dec "f", randint(min * 10^dec, max * 10^dec)/10^dec)
}

function word(p,      min, max) {
#    min = p[1]
#    max = p[2]
    return words[randint(1,length(words))]
}

function first(p) {
   return firsts[randint(1,length(firsts))]
}

function last(p) {
   return lasts[randint(1,length(lasts))]
}

function choose(p) {
    return p[randint(1, length(p))]
}

function yn(      p) {
    p[1] = "y"
    p[2] = "n"
    return p[randint(1, length(p))]
}

function yesno(      p) {
    p[1] = "yes"
    p[2] = "no"
    return p[randint(1, length(p))]
}

function tf(      p) {
    p[1] = "t"
    p[2] = "f"
    return p[randint(1, length(p))]
}

function truefalse(      p) {
    p[1] = "true"
    p[2] = "false"
    return p[randint(1, length(p))]
}

function name(p) {
    return first() sep() last()
}

function date(p,      min, max, interval, dat) {
    min = p[1]
    max = p[2]
    # param format has to be yyyymmdd, insert spaces for awk mktime function
    sub(/[0-9][0-9][0-9][0-9][0-9][0-9]/, "& ", min)
    sub(/[0-9][0-9][0-9][0-9]/, "& ", min)
    sub(/[0-9][0-9][0-9][0-9][0-9][0-9]/, "& ", max)
    sub(/[0-9][0-9][0-9][0-9]/, "& ", max)
    min = mktime(min " 00 00 00")
    max = mktime(max " 00 00 00")
    interval = max - min
    dat = min + randint(0, interval)
    return strftime("%Y %m %d", dat)
}

function sep(p,      char) {
    char = p[1]
    if (length(char) == 0) {
        return " "
    } else { 
        return char
    }
}

function id(p, n) {
    init = p[1]
    step = p[2]
    if (init == "") init = 1
    if (step == "") step = 1
    return init + (n-1)*step
}

function space() {
    return " "
}

function tab() {
    return "\t"
}

function newline() {
    return "\n"
}

function value(v) {
    return v
}

function day(p) {
    format = p[1]
    if (format == "9") return randint(1, 31)
    if (format == "99") return randint(1, 31, "02")
    
}

function weekday(p,      days) {
    format = p[1]
    days[1] = "monday"
    days[2] = "tuesday"
    days[3] = "wednesday"
    days[4] = "thursday"
    days[5] = "friday"
    days[6] = "saturday"
    days[7] = "sunday"    
    if (format == "9") return randint(1, 7)
    if (format == "A") return substr(days[randint(1,7)],1,1)
    if (format == "AA") return substr(days[randint(1,7)],1,2)
    if (format == "AAA") return substr(days[randint(1,7)],1,3)
    if (format == "AAAA") return days[randint(1,7)]
}

function month(p,      months) {
    format = p[1]
    months[1] = "january"
    months[2] = "february"
    months[3] = "march"
    months[4] = "april"
    months[5] = "may"
    months[6] = "june"
    months[7] = "july"  
    months[8] = "august"  
    months[9] = "september"  
    months[10] = "october"  
    months[11] = "november"  
    months[12] = "december"    
    if (format == "9") return randint(1, 12)
    if (format == "99") return randint(1, 12, "02")    
    if (format == "A") return substr(months[randint(1,12)],1,1)
    if (format == "AA") return substr(months[randint(1,12)],1,2)
    if (format == "AAA") return substr(months[randint(1,12)],1,3)
    if (format == "AAAA") return months[randint(1,12)]
}

function year(p,      y) {
    min = p[1]
    max = p[2]
    format = p[3]
    y = randint(min, max)
    if (format == "99") return substr(y,length(y)-1)    
    if (format == "9999") return y
}
##e 

##b ------------------------------------------------- usage

function usage() {
    print "# ---------------------------------------------------------"
    print "# ----- usage"
    print "# ---------------------------------------------------------"
    is_usage = 1
}
##e

##b ----------------------------------------------- support
function randint(min, max, zero) {
    if (substr(zero,1,1) == "0") {
        len = substr(zero,2)
        str = repeat("0", len) randint(min, max)
        return substr(str, length(str)-len+1)
    }
    return int(min + (max - min + 1) * rand())
}

function repeat(char, times,      i, out) {
    for (i = 1; i <= times; i++) {
        out = out char
    }
    return out
}

function _ord_init(        low, high, i, t) {
    low = sprintf("%c", 7) # BEL is ascii 7
    if (low == "\a") {        # regular ascii
        low = 0
        high = 127
    } else if (sprintf("%c", 128 + 7) == "\a") {
        # ascii, mark parity
        low = 128
        high = 255
    } else {                # ebcdic(!)
        low = 0
        high = 255
    }
    for (i = low; i <= high; i++) {
        t = sprintf("%c", i)
        _ord_[t] = i
    }
}

function ord(str,        c) {
    # only first character is of interest
    c = substr(str, 1, 1)
    return _ord_[c]
}

function chr(c) {
    # force c to be numeric by adding 0
    return sprintf("%c", c + 0)
}

##e

##b --------------------------------------------- lists
function load_words() {
    words[1]  = "i"
    words[2]  = "it"
    words[3]  = "when"
    words[4]  = "buy"
    words[5]  = "smith"
    words[6]  = "constitutional"
    words[7]  = "europe"
    words[8]  = "elaine"
    words[9]  = "artane"
    words[10] = "golden"
    words[11] = "ingrid"
    words[12] = "terenure"
}

function load_firsts() {
    firsts[1]  = "joe"
    firsts[2]  = "simon"
    firsts[3]  = "giuseppe"
    firsts[4]  = "albert"
    firsts[5]  = "jane"
    firsts[6]  = "sally"
    firsts[7]  = "aoibhe"
    firsts[8]  = "jenny"
    firsts[9]  = "cunégonde"
    firsts[10] = "gretchen"
    firsts[11] = "diederik"
    firsts[12] = "pavel"
    firsts[13] = "vladimir"
    firsts[14] = "mohamed"
    firsts[15] = "indira"
    firsts[16] = "sun"
    firsts[17] = "azai"
    firsts[18] = "angela"
}

function load_lasts() {
    lasts[1]  = "smith"
    lasts[2]  = "jones"
    lasts[3]  = "couty"
    lasts[4]  = "dupont"
    lasts[5]  = "schmidt"
    lasts[6]  = "merkel"
    lasts[7]  = "gyuradinovics"
    lasts[8]  = "czszepinski"
    lasts[9]  = "putin"
    lasts[10] = "delaney"
    lasts[11] = "o'brien"
    lasts[12] = "padovani"
    lasts[13] = "patel"
    lasts[14] = "singh"
    lasts[15] = "nguyen"
    lasts[16] = "li"
    lasts[17] = "el-achraoui"
}
##e

# ---------------------------------------------------------
# ----- eof -----------------------------------------------
# ---------------------------------------------------------