"TODO:
"auto s:commandList
"   convert: path, win command
"auto s:exeCommand
"procedure:
"   input value
"   call public fun
"   store value
"   output error/debug message
"   output result

fun! s:InitVar()
    let s:pat_com_path = '#(EDIT|TABE):'
    let s:pat_full = '^\v\/(i|a|c|b)$'
    let s:pat_tab = '^\v\/(i|a|c)$'
    let s:pat_back = '^\/b$'
    let s:pat_comment = '^/'

    "delete
    "====================

    let l:echoHead = []
    call add(l:echoHead, '======Calling Functions======')
    call add(l:echoHead, 's:InitVar()')

    let l:echoErr = []
    call add(l:echoErr, '======Error Messages======')

    let l:echoDebug = []
    call add(l:echoDebug, '======Debug Messages======')
    call add(l:echoDebug, [])
    call add(l:echoDebug[1], '===s:Range===')
    call add(l:echoDebug[1], '===s:FileList===')
    call add(l:echoDebug[1], '===s:CommandList===')
    call add(l:echoDebug, '===File(s) not Found===')

    let l:echoEOL = []
    call add(l:echoEOL, '======End of Line======')

    let s:echoMsg = []
    call add(s:echoMsg, l:echoHead)
    call add(s:echoMsg, l:echoErr)
    call add(s:echoMsg, l:echoDebug)
    call add(s:echoMsg, l:echoEOL)
    "====================
    "delete

    let s:echomMessage = {}

    let s:echomMessage['range'] = []
    call add(s:echomMessage['range'], 'ERROR: Incorrect opening tag.')
    call add(s:echomMessage['range'], 'ERROR: Incorrect closing tag.')
    call add(s:echomMessage['range'], 'ERROR: Dupliacated opening tags.')
    call add(s:echomMessage['range'], 'ERROR: Containing another opening tag.')

    let s:echomMessage['path'] = []
    call add(s:echomMessage['path'], 'ERROR: Incorrect path to files.')
    call add(s:echomMessage['path'], 'ERROR: Missing ''g:fileList[file]''.')
    call add(s:echomMessage['path'], 'ERROR: Incorrect ''g:fileList[file]''.')

    let s:echomMessage['note'] = []
    call add(s:echomMessage['note'], 'NOTE: Check command argument(s).')
    call add(s:echomMessage['note'], 'NOTE: Check g:fileList[arg].')
    call add(s:echomMessage['note'], 'NOTE: Check fileList.')
    call add(s:echomMessage['note'], 'NOTE: Check ''g:placeHolder''.')

    let s:collectMsg = {}
    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, '', '')

    let l:val_defNewTab = '/c'
    let l:val_defBack = '/B'

    if !exists('g:pathToFileList_quickEdit')
        \ || (type(g:pathToFileList_quickEdit) !=? v:t_dict)
        \ || !exists('g:pathToFileList_quickEdit.file[0]')
        \ || !exists('g:pathToFileList_quickEdit.file[1]')

        let g:pathToFileList_quickEdit =
        \ {'file': [], 'var': [], 'arg': []}
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['path'][1])

        let s:defNewTab = l:val_defNewTab
        let s:defBack = l:val_defBack
        let s:pathToFileList = ''
        return
    endif
    let s:path_file = deepcopy(g:pathToFileList_quickEdit)

    if exists('s:path_file.var[0]') && exists('s:path_file.var[1]')
        let l:pathToVar = getText_auto#CutTrailSlash(s:path_file.var[0])
        \ . '/' . s:path_file.var[1]
        if filereadable(l:pathToVar)
            exe 'source ' . l:pathToVar
        endif
    endif

    if exists('s:path_file.arg[0]') && (s:path_file.arg[0] =~? s:pat_tab)
        let s:defNewTab = s:path_file.arg[0]
    else
        let s:defNewTab = l:val_defNewTab
    endif

    if exists('s:path_file.arg[1]') && (s:path_file.arg[1] =~? s:pat_back)
        let s:defBack = s:path_file.arg[1]
    else
        let s:defBack = l:val_defBack
    endif

    if !exists('g:pathToPlaceholder_quickEdit')
        let g:pathToPlaceholder_quickEdit = {}
    endif
    let s:path_place = deepcopy(g:pathToPlaceholder_quickEdit)

    let l:path = s:strToPath(s:path_file.file[0], s:path_place)
    let l:path = l:path[1]
    let s:pathToFileList = l:path . '/' . s:path_file.file[1]
    if !filereadable(s:pathToFileList)
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['path'][2])
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][1])
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][3])
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][2])

        return
    endif
endfun

fun! s:Range(keyword)
    let l:pat_start = '^\v\s*\V' . a:keyword . '\v\s+\{\s*$'
    let l:pat_end = '^\v\s*\}\s*$'
    let l:pat_looseStart = '^\v\s*[^\/].{-}\s+\{\s*$'

    let l:error_range =
    \ getText_auto#Range(l:pat_start, l:pat_end, l:pat_looseStart)
    let l:error = l:error_range[0]
    let l:range = l:error_range[1]

    if !empty(l:error)
        if index(l:error, 'start') > -1
            let s:collectMsg =
            \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['range'][0])
            let s:collectMsg =
            \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][0])
        endif
        if index(l:error, 'end') > -1
            let s:collectMsg =
            \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['range'][1])
        endif
        if index(l:error, 'duplicate') > -1
            let s:collectMsg =
            \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['range'][2])
        endif
        if index(l:error, 'loose') > -1
            let s:collectMsg =
            \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['range'][3])
        endif
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][2])
        call getText_auto#OpenFile('close', s:pathToFileList)
        return
    else
        let s:Range = l:range
        let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, s:echoMsg[2][1][0], '')
        let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, s:Range, '')

    endif
endfun

fun! s:FileList()
    let l:range = deepcopy(s:Range)
    let l:comment = s:pat_comment
    let l:command_path = '\v^' . s:pat_com_path

    let l:rawText = getText_auto#RawText(l:range, 1, -1)
    let l:noComment = getText_auto#noSpace(l:rawText, l:comment)

    let l:idx_split =
        \ splitList_auto#SetPoint(l:noComment, l:command_path, 0)
    let l:item_split = splitList_auto#Cut(l:noComment, l:idx_split)
    let l:item_split = filter(l:item_split, 'len(v:val) > 1')

    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, s:echoMsg[2][1][1], '')
    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, l:item_split, '')

    let s:FileList = l:item_split
endfun

fun! s:CommandList()
    let l:fileList = deepcopy(s:FileList)
    let l:path_place = s:path_place

    let l:commandList = []
    let l:error = []

    for l:tmpItem in l:fileList
        let l:com_path = remove(l:tmpItem, 0)
        let l:file = l:tmpItem

        let l:pat_split = '\v' . s:pat_com_path . '\s*' . '(.{-})$'
        let l:command = substitute(l:com_path, l:pat_split, '\1', '')
        let l:command = tolower(l:command)

        let l:path = substitute(l:com_path, l:pat_split, '\2', '')
        let l:path = s:strToPath(l:path, l:path_place)
        let l:error = l:path[0]
        if !empty(l:error)
            let l:commandList = insert(l:commandList, l:error)
            let l:path = ''
            break
        endif
        let l:path = l:path[1]

        let l:combine = []
        let l:combine = insert(l:file, l:path)
        let l:combine = insert(l:combine, l:command)
        let l:commandList = add(l:commandList, l:combine)
    endfor

    let l:commandList = insert(l:commandList, l:error)
    let l:error = remove(l:commandList, 0)
    if !empty(l:error)
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['path'][0])
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][2])
        let s:collectMsg =
        \ collectMsg_auto#DebugOrError(s:collectMsg, '', s:echomMessage['note'][3])

        return
    endif
    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, s:echoMsg[2][1][2], '')
    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, l:commandList, '')

    let s:CommandList = l:commandList
endfun

fun! s:MoveToTab()
    let l:newTab = s:newTab

    if l:newTab ==# '/i'
        exe 'silent 0tabe ' . expand('%')
        let l:tabStart = 1
    elseif l:newTab ==# '/a'
        exe 'silent $tabe ' . expand('%')
        let l:tabStart = tabpagenr()
    elseif l:newTab ==# '/c'
        if (tabpagenr('$') > 1)
            tabo
        endif
        let l:tabStart = 1
        if winnr('$') > 1
            wincmd o
        endif
    endif

    let s:tabStart = l:tabStart
endfun

fun! s:ExeCommand()
    let l:command = deepcopy(s:CommandList)
    let l:fileList = 1

    for l:tmpItem in l:command
        let l:exe = remove(l:tmpItem, 0, 1)
        for l:tmpSubItem in l:tmpItem
            let l:path_file = l:exe[1]
            let l:pathTofile = l:path_file . '/' . l:tmpSubItem
            if bufexists(l:pathTofile)
                if l:exe[0] =~# 'edit'
                    exe 'silent buffer ' . bufname(l:pathTofile)
                else
                    exe 'silent tabe ' . bufname(l:pathTofile)
                endif
            elseif filereadable(l:pathTofile)
                exe 'silent ' . l:exe[0] . ' ' . l:pathTofile
                call getText_auto#ChangeDir()
            else
                if l:fileList
                    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, s:echoMsg[2][2], '')
                    let l:fileList = 0
                endif
                let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, l:pathTofile, '')
            endif
        endfor
    endfor

    if s:moveBack
        exe s:tabStart . 'tabnext'
    endif
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

fun! s:EchoMessage(pos, ...)
    let l:debugMsg = copy(s:collectMsg.debug)
    let l:errorMsg = copy(s:collectMsg.error)

    if a:pos ==? 'head'
        echom s:echoMsg[0][0]
        echom s:echoMsg[0][1]
    elseif a:pos ==? 'tail'
        echom s:echoMsg[2][0]
        for l:tmpItem in l:debugMsg
            echom l:tmpItem
        endfor
        if exists('a:1') && a:1
            echom s:echoMsg[1][0]
            for l:tmpItem in l:errorMsg
                echom l:tmpItem
            endfor
        endif
        echom s:echoMsg[3][0]
    endif
endfun

fun! quickEdit_auto#CallFuns(...)
    call s:InitVar()

    let l:argList = copy(a:000)
    let l:filterFull = 'v:val !~ ''' . s:pat_full . ''''
    let l:filterTab = 'v:val =~ ''' . s:pat_tab . ''''
    let l:filterBack = 'v:val =~ ''' . s:pat_back . ''''

    let l:keyWord =
    \ comArg_auto#FilterArg(l:argList, l:filterFull, expand('<cword>'))

    let l:tmpArg =
    \ comArg_auto#FilterArg(l:argList, l:filterTab, s:defNewTab)
    let s:newTab = tolower(l:tmpArg)
    let l:debug = comArg_auto#CheckArgCase(l:tmpArg, 'u')

    let l:tmpArg =
    \ comArg_auto#FilterArg(l:argList, l:filterBack, s:defBack)
    let s:moveBack = comArg_auto#CheckArgCase(l:tmpArg, 'l')

    let l:funs = []
    call add(l:funs, 'getText_auto#OpenFile(''open'','''
    \ . s:pathToFileList . ''')')
    call add(l:funs, 's:Range(''' . l:keyWord . ''')')
    call add(l:funs, 's:FileList()')
    call add(l:funs, 'getText_auto#OpenFile(''close'','''
    \ . s:pathToFileList . ''')')
    call add(l:funs, 's:CommandList()')
    call add(l:funs, 's:MoveToTab()')
    call add(l:funs, 's:ExeCommand()')

    if l:debug
        call s:EchoMessage('head')
    endif

    for l:tmpItem in l:funs
        if empty(s:collectMsg.error)
            exe 'call ' . l:tmpItem
            if l:debug
                echom l:tmpItem
            endif
        else
            if l:debug
                call s:EchoMessage('tail', 1)
            endif
            let l:errCopy = deepcopy(s:collectMsg.error)
            let l:pat_filter = '\v(' . s:echomMessage['path'][0] . ')'
            call filter(l:errCopy, 'v:val !~? ''' . l:pat_filter . '''')
            if !empty(l:errCopy)
                call confirm(l:errCopy[0])
            else
                call confirm(s:collectMsg.error[0])
            endif
            return
        endif
    endfor

    if l:debug
        call s:EchoMessage('tail', 0)
    endif
endfun

