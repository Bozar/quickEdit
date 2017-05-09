fun! collectMsg_auto#DebugOrError(store, debug, error)
    let l:store = deepcopy(a:store)
    let l:addDebug = deepcopy(a:debug)
    let l:addError = deepcopy(a:error)

    if !has_key(l:store, 'debug')
        let l:store.debug = []
    endif
    if !has_key(l:store, 'error')
        let l:store.error = []
    endif

    if (type(l:addDebug) !=? v:t_number)
        \ && (type(l:addDebug) !=? v:t_string)
        let l:addDebug = string(l:addDebug)
    endif
    if l:addDebug != ''
        call add(l:store.debug, l:addDebug)
    endif

    if (type(l:addError) !=? v:t_number)
        \ && (type(l:addError) !=? v:t_string)
        let l:addError = string(l:addError)
    endif
    if l:addError != ''
        call add(l:store.error, l:addError)
    endif

    return l:store
endfun

