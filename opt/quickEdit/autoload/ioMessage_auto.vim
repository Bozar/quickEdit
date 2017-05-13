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

    let l:addDebug = ioMessage_auto#Convert2Str(l:addDebug)
    if l:addDebug != ''
        call add(l:store['debug'], l:addDebug)
    endif

    let l:addError = ioMessage_auto#Convert2Str(l:addError)
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

fun! ioMessage_auto#SearchDictList(str, dict, patKeyIdx, patKey, patIdx)
    let l:str = a:str
    let l:dict = deepcopy(a:dict)

    let l:str
    \ = ioMessage_auto#Str2KeyIdx(l:str, a:patKeyIdx, a:patKey, a:patIdx)
    if l:str[0] == 0
        let l:result = ['' , l:str[1]]
    elseif l:str[0] == 1
        let l:result
        \ = ioMessage_auto#GetDictValue(l:str[1], l:str[2], l:dict)
    endif

    return l:result
endfun

fun! ioMessage_auto#Str2KeyIdx(string, patKeyIdx, patKey, patIdx)
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

fun! ioMessage_auto#DelTrailSlash(path)
    let l:path = expand(a:path)
    let l:pat_trailSlash = '\v^(.{-})(\\|\/)*$'
    let l:path = substitute(l:path, l:pat_trailSlash, '\1', '')
    return l:path
endfun

fun! ioMessage_auto#Convert2Str(input)
    let l:input = deepcopy(a:input)
    if (type(l:input) !=? v:t_number) && (type(l:input) !=? v:t_string)
        let l:input = string(l:input)
    endif
    return l:input
endfun

fun! ioMessage_auto#DelSpace(text, comment, inner)
    let l:text = deepcopy(a:text)
    let l:comment = a:comment
    let l:delInnerSpace = a:inner
    let l:noSpace = []
    let l:pat_space = '\v^\s*(.{-})\s*$'
    let l:pat_empty = '\v^\s*$'

    for l:tmpItem in l:text
        let l:shrink = substitute(l:tmpItem, l:pat_space, '\1', '')
        if l:delInnerSpace > 0
            let l:shrink = substitute(l:shrink, '\s', '', 'g')
        endif
        call add(l:noSpace, l:shrink)
    endfor

    let l:noEmptyLine = filter(l:noSpace
    \, 'v:val !~ ''' . l:pat_empty . '''')

    if a:comment !=? ''
        let l:pat_comment = 'v:val !~? ''' . a:comment . ''''
        let l:noCommentLine = filter(l:noEmptyLine, l:pat_comment)
    else
        let l:noCommentLine = l:noEmptyLine
    endif

    return l:noCommentLine
endfun

fun! ioMessage_auto#SearchDictPat(string, dict)
    let l:string = a:string
    let l:dict = deepcopy(a:dict)
    let l:result = []

    let l:filter = filter(copy(l:dict), '''' . l:string . ''' =~# v:key')
    if empty(l:filter)
        let l:result = [0, l:string]
    else
        let l:result = [1, values(l:filter)[0]]
    endif

    return l:result
endfun

