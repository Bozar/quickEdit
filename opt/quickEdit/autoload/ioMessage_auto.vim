"REQUIRE: getText_auto.vim

fun! ioMessage_auto#DebugOrError(store, debug, error)
    let l:store = deepcopy(a:store)
    let l:addDebug = deepcopy(a:debug)
    let l:addError = deepcopy(a:error)

    if !has_key(l:store, 'debug')
        let l:store['debug'] = []
    endif
    if !has_key(l:store, 'error')
        let l:store['error'] = []
    endif

    let l:addDebug = getText_auto#ConvertToStr(l:addDebug)
    if l:addDebug != ''
        call add(l:store['debug'], l:addDebug)
    endif

    let l:addError = getText_auto#ConvertToStr(l:addError)
    if l:addError != ''
        call add(l:store['error'], l:addError)
    endif

    return l:store
endfun

fun! ioMessage_auto#EchoHi(message, highlight)
    exe 'echoh ' . a:highlight
    echom a:message
    echoh none
endfun

fun! ioMessage_auto#SearchDict(str, dict, patKeyIdx, patKey, patIdx)
    let l:str = a:str
    let l:dict = deepcopy(a:dict)

    let l:str
    \ = ioMessage_auto#StrToKeyIdx(l:str, a:patKeyIdx, a:patKey, a:patIdx)
    if l:str[0] == 0
        let l:result = ['' , l:str[1]]
    elseif l:str[0] == 1
        let l:result
        \ = ioMessage_auto#GetDictValue(l:str[1], l:str[2], l:dict)
    endif

    return l:result
endfun

fun! ioMessage_auto#StrToKeyIdx(string, patKeyIdx, patKey, patIdx)
    let l:str = a:string
    let l:patKeyIdx = a:patKeyIdx
    let l:patKey = a:patKey
    let l:patIdx = a:patIdx
    let l:result = []

    if l:str =~? l:patKeyIdx
        let l:key = substitute(l:str, l:patKeyIdx, l:patKey, '')
        let l:idx = substitute(l:str, l:patKeyIdx, l:patIdx, '')
        let l:result = [1, l:key, l:idx]
    else
        let l:result = [0, l:str]
    endif

    return l:result
endfun

fun! ioMessage_auto#GetDictValue(key, idx, dict)
    let l:key = a:key
    let l:idx = a:idx
    let l:dict = deepcopy(a:dict)
    let l:value = ''
    let l:error = ''

    if (type(l:dict) ==? v:t_dict) && exists('l:dict[l:key][l:idx]')
        let l:value = l:dict[l:key][l:idx]
    else
        let l:error = [l:key, l:idx]
    endif

    return [l:error, l:value]
endfun

fun! ioMessage_auto#FilterList(argList, pat, def)
    let l:tmpList = deepcopy(a:argList)
    let l:tmpList = filter(l:tmpList, a:pat)
    if !empty(l:tmpList)
       let l:result = l:tmpList[0]
    else
       let l:result = a:def
    endif
    return l:result
endfun

fun! ioMessage_auto#CheckCase(str, case)
    if a:str =~# '\' . a:case
        return 1
    else
        return 0
    endif
endfun

fun! ioMessage_auto#GetSplitIdx(list, pat, case)
    let l:idx_split = []
    let l:tmpNum = 0

    for l:tmpItem in a:list
        if (a:case == 0) && (l:tmpItem =~? a:pat)
            call add(l:idx_split, l:tmpNum)
        elseif (a:case == 1) && (l:tmpItem =~# a:pat)
            call add(l:idx_split, l:tmpNum)
        endif
        let l:tmpNum += 1
    endfor

    return l:idx_split
endfun

fun! ioMessage_auto#SplitList(list, split)
    let l:list = deepcopy(a:list)
    let l:split = deepcopy(a:split)
    let l:newList = []

    while !empty(l:split)
        let l:start = remove(l:split, 0)
        if !empty(l:split)
            let l:end = l:split[0] -1
        else
            let l:end = len(l:list) -1
        endif
        call add(l:newList, l:list[l:start : l:end])
    endwhile

    return l:newList
endfun

