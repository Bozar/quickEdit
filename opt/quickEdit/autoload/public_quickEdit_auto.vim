fun! public_quickEdit_auto#CommandList(fileList, comPath, placePath,win)
    let l:item_split = a:fileList
    let l:pat_com_path = a:comPath
    let l:placePath = a:placePath
    let l:winOnly = a:win

    let l:commandList = []
    let l:errorList = []

    for l:tmpItem in l:item_split
        let l:com_path = remove(l:tmpItem,0)
        let l:file = l:tmpItem

        let l:pat_split = '\v' . l:pat_com_path . '\s*' . '(.*)$'
        let l:command = substitute(l:com_path, l:pat_split, '\1', '')
        let l:command = public_quickEdit_auto#convertStr('edFile'
        \ , l:command, l:winOnly)

        let l:path = substitute(l:com_path, l:pat_split, '\2', '')
        let l:path =
        \ public_quickEdit_auto#convertStr('path', l:path, l:placePath)
        let l:errorList = l:path[0]
        if !empty(l:errorList)
            let l:commandList = insert(l:commandList, l:errorList)
            return l:commandList
        endif
        let l:path = l:path[1]

        let l:combine = []
        let l:combine = insert(l:file, l:path)
        let l:combine = insert(l:combine, l:command)
        let l:commandList = add(l:commandList, l:combine)
    endfor

    let l:commandList = insert(l:commandList, l:errorList)
    return l:commandList
endfun

fun! public_quickEdit_auto#convertStr(type, str, refer)
    if a:type ==? 'path'
        return s:strToPath(a:str, a:refer)
    elseif a:type ==? 'edFile'
        return s:strToEdFile(a:str, a:refer)
    endif
endfun

fun! public_quickEdit_auto#FileList(range, comment, comPath)
    let l:pat_comment = a:comment
    let l:pat_command_path = a:comPath

    let l:rawText = getText_auto#RawText(a:range, 1, -1)
    let l:noComment = getText_auto#noSpace(l:rawText, l:pat_comment)

    let l:idx_split =
        \ splitList_auto#SetPoint(l:noComment, l:pat_command_path, 0)
    let l:item_split = splitList_auto#Cut(l:noComment, l:idx_split)
    let l:item_split = filter(l:item_split, 'len(v:val) > 1')

    return l:item_split
endfun

fun! public_quickEdit_auto#MoveToTab(newTab)
    if a:newTab ==# '/i'
        exe 'silent 0tabe ' . expand('%')
        let l:tabStart = 1
    elseif a:newTab ==# '/a'
        exe 'silent $tabe ' . expand('%')
        let l:tabStart = tabpagenr()
    elseif a:newTab ==# '/c'
        if (tabpagenr('$') > 1)
            tabo
        endif
        let l:tabStart = 1
        if winnr('$') > 1
            wincmd o
        endif
    endif
    return l:tabStart
endfun

fun! s:strToPath(path, refer)
    let l:pat_dict = '^%\v\s*(\S.{-})\.(\d+)$'
    let l:pat_empty = '^\v\s*$'
    let l:retPath = ''
    let l:error = []
    let l:refer = deepcopy(a:refer)

    if a:path =~? l:pat_dict
        let l:key = substitute(a:path, l:pat_dict, '\1', '')
        let l:idx = substitute(a:path, l:pat_dict, '\2', '')
        if (type(l:refer) ==? v:t_dict)
            \ && exists('l:refer[l:key][l:idx]')
            let l:retPath = l:refer[l:key][l:idx]
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

fun! s:strToEdFile(str, refer)
    let l:winOnly = a:refer
    if l:winOnly == 1
        let l:editFile = 'edit'
    elseif l:winOnly == 0
        let l:editFile = tolower(a:str)
    endif
    return l:editFile
endfun
