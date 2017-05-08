fun! collectMsg#DebugOrError(store, add, ...)
    let l:store = a:store
    let l:addDebug = a:add
    if exists('a:1')
        let l:addError = a:1
    endif

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

    if exists('l:addError')
        if (type(l:addError) !=? v:t_number)
        \ && (type(l:addError) !=? v:t_string)
            let l:addError = string(l:addError)
        endif
        if l:addError != ''
            call add(l:store.error, l:addError)
        endif
    endif

    return l:store
endfun
