"TODO:
"remove s:editPath
"auto s:commandList
"   convert: path, win command
"auto s:exeCommand

fun! s:InitVar()
    let s:pat_com_path = '#(EDIT|TABE):'
    let s:pat_full = '^\v\/(i|a|c|b)$'
    let s:pat_tab = '^\v\/(i|a|c)$'
    let s:pat_back = '^\/b$'
    let s:pat_comment = '^/'
    let s:pathToScript = ''
    let s:pathToScript .= '~/vimfiles/pack/quickEdit/opt/'
    let s:pathToScript .= 'tab_quickEdit/autoload/tab_quickEdit_auto.vim'

    let s:error_start = 'ERROR: Incorrect opening tag.'
    let s:error_end = 'ERROR: Incorrect closing tag.'
    let s:error_dupKey = 'ERROR: Dupliacated opening tags.'
    let s:error_path = 'ERROR: Incorrect path to files.'
    let s:error_gFile_M0 = 'ERROR: Missing g:fileList[0].'
    let s:error_gFile_W0 = 'ERROR: Incorrect g:fileList[0].'
    let s:error_gFile =
    \ 'ERROR: Incorrect fileList var, ''g:pathToFileList_quickEdit''.'
    let s:error_gPlace_M = 'ERROR: Missing g:placeHolder[]'

    let s:note_start = 'NOTE: Check command argument(s).'
    let s:note_gFile_3 = 'NOTE: Check g:filelist[2].'
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

    let s:errMsg = []
    let s:debugMsg = []

    let l:val_defNewTab = '/c'
    let l:val_defBack = '/B'

    if !exists('g:load_tab_quickEdit') || (g:load_tab_quickEdit < 1)
        let s:winOnly = 1
    else
        let s:winOnly = 0
    endif

    if !exists('g:pathToFileList_quickEdit')
        \ || !exists('g:pathToFileList_quickEdit[0][0]')
        \ || !exists('g:pathToFileList_quickEdit[0][1]')

        let g:pathToFileList_quickEdit = []
        call add(s:errMsg, s:error_gFile_M0)
        call add(s:errMsg, s:note_gFile_F)
        call s:DebugMsg('', s:pathToScript)

        let s:defNewTab = l:val_defNewTab
        let s:defBack = l:val_defBack
        let s:pathToFileList = ''
        return
    endif
    let s:path_file = copy(g:pathToFileList_quickEdit)

    if exists('s:path_file[1][0]') && exists('s:path_file[1][1]')
        let l:pathToVar = getText_auto#CutTrailSlash(s:path_file[1][0])
        \ . '/' . s:path_file[1][1]
        if filereadable(l:pathToVar)
            exe 'source ' . l:pathToVar
        endif
    endif

    if exists('s:path_file[2][0]') && (s:path_file[2][0] =~? s:pat_tab)
        let s:defNewTab = s:path_file[2][0]
    else
        let s:defNewTab = l:val_defNewTab
    endif

    if exists('s:path_file[2][1]') && (s:path_file[2][1] =~? s:pat_back)
        let s:defBack = s:path_file[2][1]
    else
        let s:defBack = l:val_defBack
    endif

    if !exists('g:pathToPlaceholder_quickEdit')
        let g:pathToPlaceholder_quickEdit = []
    endif
    let s:path_place = g:pathToPlaceholder_quickEdit

    let l:path = public_quickEdit_auto#convertStr('path'
    \ , s:path_file[0][0], s:path_place)
    let l:path = l:path[1]
    let s:pathToFileList = l:path . '/' . s:path_file[0][1]
    if !filereadable(s:pathToFileList)
        call add(s:errMsg, s:error_gFile_W0)
        call add(s:errMsg, s:note_gFile_3)
        call add(s:errMsg, s:note_gFile_F)
        call add(s:errMsg, s:note_gPlace_F)
        call add(s:errMsg, s:note_fileList)
        call s:DebugMsg('', s:pathToScript)
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
            call add(s:errMsg, s:error_start)
            call add(s:errMsg, s:note_start)
        elseif index(l:error, 'end') > -1
            call add(s:errMsg, s:error_end)
        elseif index(l:error, 'duplicate') > -1
            call add(s:errMsg, s:error_dupKey)
        endif
        call add(s:errMsg, s:note_fileList)
        call getText_auto#OpenFile('close', '')
        return
    else
        let s:range = l:range
        call s:DebugMsg(s:echoMsg[2][1][0], s:pathToScript)
        call s:DebugMsg(s:range, s:pathToScript)
    endif
endfun

fun! s:FileList()
    let s:FileList = public_quickEdit_auto#FileList(s:range
    \ , [s:pat_comment, '\v^' . s:pat_com_path])

    call s:DebugMsg(s:echoMsg[2][1][1], s:pathToScript)
    call s:DebugMsg(s:FileList, s:pathToScript)
endfun

fun! s:CommandList()
    let l:item_split = s:FileList
    let l:commandList = []

    for l:tmpItem in l:item_split
        let l:com_path = remove(l:tmpItem,0)
        let l:file = l:tmpItem

        let l:pat_split = '\v' . s:pat_com_path . '\s*' . '(.*)$'
        let l:command = substitute(l:com_path, l:pat_split, '\1', '')
        let l:command = public_quickEdit_auto#convertStr('edFile'
        \ , l:command, s:winOnly)

        let l:path = substitute(l:com_path, l:pat_split, '\2', '')
        let l:path =
        \ public_quickEdit_auto#convertStr('path', l:path, s:path_place)
        let l:errList = filter(l:path[0], 'v:val == 1')
        if !empty(l:errList)
            call add(s:errMsg, s:error_path)
            call add(s:errMsg, s:note_fileList)
            call add(s:errMsg, s:note_gPlace_F)
            return
        endif
        let l:path = l:path[1]

        let l:combine = []
        let l:combine = insert(l:file, l:path)
        let l:combine = insert(l:combine, l:command)
        let l:commandList = add(l:commandList, l:combine)
    endfor

    let s:CommandList = l:commandList
    call s:DebugMsg(s:echoMsg[2][1][2], s:pathToScript)
    call s:DebugMsg(s:CommandList, s:pathToScript)
endfun

"delete
"fun! s:CommandList()
"    let l:item_split = s:FileList
"
"    let l:command = []
"    for l:tmpItem in l:item_split
"        let l:com_path = remove(l:tmpItem,0)
"        let l:file_combine = l:tmpItem
"
"        let l:pat_split = '\v' . s:pat_com_path . '\s*' . '(.*)$'
"        let l:com_combine = substitute(l:com_path, l:pat_split, '\1', '')
"        let l:com_combine = tolower(l:com_combine)
"
"        let l:path = substitute(l:com_path, l:pat_split, '\2', '')
"        let l:path_combine = s:EditPath(l:path)
"        if !empty(s:errMsg)
"            call add(s:errMsg, s:note_fileList)
"            call add(s:errMsg, s:note_gPlace_F)
"            return
"        endif
"
"        let l:combine = insert(l:file_combine, l:path_combine)
"        let l:combine = insert(l:combine, l:com_combine)
"        let l:command = add(l:command, l:combine)
"    endfor
"
"    let s:CommandList = l:command
"    call s:DebugMsg(s:echoMsg[2][1][2], s:pathToScript)
"    call s:DebugMsg(s:CommandList, s:pathToScript)
"endfun

fun! s:MoveToTab()
    if s:newTab ==# '/i'
        exe 'silent 0tabe ' . expand('%')
        let s:tabStart = 1
    elseif s:newTab ==# '/a'
        exe 'silent $tabe ' . expand('%')
        let s:tabStart = tabpagenr()
    elseif s:newTab ==# '/c'
        if (tabpagenr('$') > 1)
            tabo
        endif
        let s:tabStart = 1
        if winnr('$') > 1
            wincmd o
        endif
    endif
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
                    call s:DebugMsg(s:echoMsg[2][2], s:pathToScript)
                    let l:fileList = 0
                endif
                call s:DebugMsg(l:pathTofile, s:pathToScript)
            endif
        endfor
    endfor

    if s:moveBack
        exe s:tabStart . 'tabnext'
    endif
endfun

fun! s:DebugMsg(debugMsg, pathToScript, ...)
    if string(a:debugMsg) !~ '^\s*$'
        let s:debugMsg = add(s:debugMsg, string(a:debugMsg))
    endif
    if exists('a:1')
        let s:errMsg = add(s:errMsg, string(a:1))
    endif

    let l:history = 'e ' . a:pathToScript

    let l:testOnly = 0
    if l:testOnly
        if histget(':',-1) !=? l:history
            call histadd(':', l:history)
        endif
    endif
endfun

fun! s:EchoMessage(pos, ...)
    if a:pos ==? 'head'
        echom s:echoMsg[0][0]
        echom s:echoMsg[0][1]
    elseif a:pos ==? 'tail'
        echom s:echoMsg[2][0]
        for l:tmpItem in s:debugMsg
            echom l:tmpItem
        endfor
        if exists('a:1') && a:1
            echom s:echoMsg[1][0]
            for l:tmpItem in s:errMsg
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
        if empty(s:errMsg)
            exe 'call ' . l:tmpItem
            if l:debug
                echom l:tmpItem
            endif
        else
            if l:debug
                call s:EchoMessage('tail', 1)
            endif
            let l:errCopy = copy(s:errMsg)
            let l:pat_filter = '\\v(' . s:error_path . ')'
            call filter(l:errCopy, 'v:val !~? "' . l:pat_filter . '"')
            if !empty(l:errCopy)
                call confirm(l:errCopy[0])
            else
                call confirm(s:errMsg[0])
            endif
            return
        endif
    endfor

    if l:debug
        call s:EchoMessage('tail', 0)
    endif
endfun

