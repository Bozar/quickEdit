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

fun! ioMessage_auto#DictValue(key, idx, dict)
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

