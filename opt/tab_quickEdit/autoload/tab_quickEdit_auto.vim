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

    let s:error_start = 'ERROR: Incorrect opening tag.'
    let s:error_end = 'ERROR: Incorrect closing tag.'
    let s:error_dupKey = 'ERROR: Dupliacated opening tags.'
    let s:error_path = 'ERROR: Incorrect path to files.'
    let s:error_gFile_M0 = 'ERROR: Missing ''g:fileList.file''.'
    let s:error_gFile_W0 = 'ERROR: Incorrect ''g:fileList.file''.'
    let s:error_gFile =
    \ 'ERROR: Incorrect fileList var, ''g:pathToFileList_quickEdit''.'
    let s:error_gPlace_M = 'ERROR: Missing g:placeHolder'

    let s:note_start = 'NOTE: Check command argument(s).'
    let s:note_gFile_3 = 'NOTE: Check g:filelist.arg.'
    let s:note_gFile_F =
    \ 'NOTE: Check fileList var, ''g:pathToFileList_quickEdit''.'
    let s:note_gPlace_F =
    \ 'NOTE: Check placeHolder var, ''g:pathToPlaceholder_quickEdit''.'
    let s:note_fileList = 'NOTE: Check fileList.'

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

    let s:message = {}
    let s:message = collectMsg#DebugOrError(s:message, '')

    let l:val_defNewTab = '/c'
    let l:val_defBack = '/B'

    if !exists('g:load_tab_quickEdit') || (g:load_tab_quickEdit < 1)
        let s:winOnly = 1
    else
        let s:winOnly = 0
    endif

    if !exists('g:pathToFileList_quickEdit')
        \ || (type(g:pathToFileList_quickEdit) !=? v:t_dict)
        \ || !exists('g:pathToFileList_quickEdit.file[0]')
        \ || !exists('g:pathToFileList_quickEdit.file[1]')

        let g:pathToFileList_quickEdit =
        \ {'file': [], 'var': [], 'arg': []}
        call collectMsg#DebugOrError(s:message, '', s:error_gFile_M0)
        call collectMsg#DebugOrError(s:message, '', s:note_gFile_F)

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

    let l:path = public_quickEdit_auto#convertStr('path'
    \ , s:path_file.file[0], s:path_place)
    let l:path = l:path[1]
    let s:pathToFileList = l:path . '/' . s:path_file.file[1]
    if !filereadable(s:pathToFileList)
        call collectMsg#DebugOrError(s:message, '', s:error_gFile_W0)
        call collectMsg#DebugOrError(s:message, '', s:note_gFile_3)
        call collectMsg#DebugOrError(s:message, '', s:note_gFile_F)
        call collectMsg#DebugOrError(s:message, '', s:note_gPlace_F)
        call collectMsg#DebugOrError(s:message, '', s:note_fileList)

        return
    endif
endfun

fun! s:Range(keyword)
    let l:pat_start = '^\v\s*\V' . a:keyword . '\v\s+\{\s*$'
    let l:pat_end = '^\v\s*\}\s*$'
    let l:pat_looseStart = '^\v\s*[^\/]\S.{-}\s+\{\s*$'

    let l:error_range =
    \ getText_auto#Range(l:pat_start, l:pat_end, l:pat_looseStart)
    let l:error = l:error_range[0]
    let l:range = l:error_range[1]

    if !empty(l:error)
        if index(l:error, 'start') > -1
            call collectMsg#DebugOrError(s:message, '', s:error_start)
            call collectMsg#DebugOrError(s:message, '', s:note_start)

        endif
        if index(l:error, 'end') > -1
            call collectMsg#DebugOrError(s:message, '', s:error_end)
        endif
        if index(l:error, 'duplicate') > -1
            call collectMsg#DebugOrError(s:message, '', s:error_dupKey)
        endif
        call collectMsg#DebugOrError(s:message, '', s:note_fileList)
        call getText_auto#OpenFile('close', '')
        return
    else
        let s:Range = l:range
        call collectMsg#DebugOrError(s:message, s:echoMsg[2][1][0])
        call collectMsg#DebugOrError(s:message, s:Range)

    endif
endfun

fun! s:FileList()
    let l:range = s:Range
    let l:comment = s:pat_comment
    let l:command_path = '\v^' . s:pat_com_path

    let l:fileList =
    \ public_quickEdit_auto#FileList(l:range, l:comment, l:command_path)

    call collectMsg#DebugOrError(s:message, s:echoMsg[2][1][1])
    call collectMsg#DebugOrError(s:message, l:fileList)

    let s:FileList = l:fileList
endfun

fun! s:CommandList()
    let l:fileList = s:FileList
    let l:pat_com_path = s:pat_com_path
    let l:path_place = s:path_place
    let l:winOnly = s:winOnly

    let l:error_command =
    \ public_quickEdit_auto#CommandList(l:fileList, l:pat_com_path
    \ , l:path_place, l:winOnly)

    let l:error = remove(l:error_command, 0)
    let l:commandList = l:error_command
    if !empty(l:error)
        call collectMsg#DebugOrError(s:message, '', s:error_path)
        call collectMsg#DebugOrError(s:message, '', s:note_fileList)
        call collectMsg#DebugOrError(s:message, '', s:note_gPlace_F)

        return
    endif
    call collectMsg#DebugOrError(s:message, s:echoMsg[2][1][2])
    call collectMsg#DebugOrError(s:message, l:commandList)

    let s:CommandList = l:commandList
endfun

fun! s:MoveToTab()
    let l:newTab = s:newTab
    let l:tabStart = public_quickEdit_auto#MoveToTab(l:newTab)
    let s:tabStart = l:tabStart
endfun

fun! s:ExeCommand()
    let l:command = s:CommandList
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
                    call collectMsg#DebugOrError(s:message, s:echoMsg[2][2])
                    let l:fileList = 0
                endif
                call collectMsg#DebugOrError(s:message, l:pathTofile)
            endif
        endfor
    endfor

    if s:moveBack
        exe s:tabStart . 'tabnext'
    endif
endfun

fun! s:EchoMessage(pos, ...)
    let l:debugMsg = copy(s:message.debug)
    let l:errorMsg = copy(s:message.error)

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

fun! tab_quickEdit_auto#CallFuns(...)
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
    call add(l:funs, 'getText_auto#OpenFile("open",'''
    \ . s:pathToFileList . ''')')
    call add(l:funs, 's:Range(''' . l:keyWord . ''')')
    call add(l:funs, 's:FileList()')
    call add(l:funs, 'getText_auto#OpenFile("close","")')
    call add(l:funs, 's:CommandList()')
    call add(l:funs, 's:MoveToTab()')
    call add(l:funs, 's:ExeCommand()')

    if l:debug
        call s:EchoMessage('head')
    endif

    for l:tmpItem in l:funs
        if empty(s:message.error)
            exe 'call ' . l:tmpItem
            if l:debug
                echom l:tmpItem
            endif
        else
            if l:debug
                call s:EchoMessage('tail', 1)
            endif
            let l:errCopy = copy(s:message.error)
            let l:pat_filter = '\v(' . s:error_path . ')'
            call filter(l:errCopy, 'v:val !~? ''' . l:pat_filter . '''')
            if !empty(l:errCopy)
                call confirm(l:errCopy[0])
            else
                call confirm(s:message.error[0])
            endif
            return
        endif
    endfor

    if l:debug
        call s:EchoMessage('tail', 0)
    endif
endfun

