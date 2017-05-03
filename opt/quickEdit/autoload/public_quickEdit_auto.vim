fun! public_quickEdit_auto#convertStr(type, str, refer)
    if a:type ==? 'path'
        return s:strToPath(a:str, a:refer)
    endif
endfun

fun! s:strToPath(path, refer)
    let l:pat_idx = '^%\v(\d*)$'
    let l:pat_subIdx = '^%\v(\d+)\.(\d+)$'
    let l:pat_empty = '^\v\s*$'
    let l:retPath = ''
    let l:error = [0]

    if a:path =~? l:pat_subIdx
        let l:idx = substitute(a:path, l:pat_subIdx, '\1', '')
        let l:subIdx = substitute(a:path, l:pat_subIdx, '\2', '')
        let l:item = get(a:refer, l:idx, '')
        if type(l:item) ==# v:t_list
            let l:item = get(l:item, l:subIdx)
        else
            let l:item = ''
        endif
        if l:item == ''
            call add(l:error, 1)
        else
            let l:retPath = a:refer[l:idx][l:subIdx]
        endif

    elseif a:path =~? l:pat_idx
        let l:idx = substitute(a:path, l:pat_idx, '\1', '')
        let l:item = get(a:refer, l:idx, '')
        if (type(l:item) ==# v:t_list) || (l:item == '')
            let l:item = ''
        endif
        if l:item == ''
            call add(l:error, 1)
        else
            let l:retPath = a:refer[l:idx]
        endif

    else
        let l:retPath = a:path
    endif

    if l:retPath =~ l:pat_empty
        call add(l:error, 1)
    endif

    let l:retPath = getText_auto#CutTrailSlash(l:retPath)
    let l:result = [l:error, l:retPath]
    return l:result
endfun
