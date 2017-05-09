fun! comArg_auto#FilterArg(argList, pat, def)
    let l:tmpList = deepcopy(a:argList)
    let l:tmpList = filter(l:tmpList, a:pat)
    if !empty(l:tmpList)
       let l:result = l:tmpList[0]
    else
       let l:result = a:def
    endif
    return l:result
endfun

fun! comArg_auto#CheckArgCase(arg, case)
    if a:arg =~# '\' . a:case
        return 1
    else
        return 0
    endif
endfun

