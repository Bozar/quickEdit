"TODO:
"use placeholder for: win command
"convert str to win command

fun! s:LoadStaticVar()
    let s:defArg = {}
    let s:defArg['tab'] = '/c'
    let s:defArg['back'] = '/B'

    let s:pattern = {}
    let s:pattern['command'] = '#(EDIT|TABE):' 
    let s:pattern['comment'] = '^/' 
    let s:pattern['prefix'] = '?' 

    let s:pattern['full'] = '^\v\/(i|a|c|b)$' 
    let s:pattern['tab'] = '^\v\/(i|a|c)$' 
    let s:pattern['back'] = '^\/b$' 

    let s:pattern['start'] = ['^\v\s*\V', '\v\s+\{\s*$']
    let s:pattern['end'] = '^\v\s*\}\s*$'
    let s:pattern['looseStart'] = '^\v\s*[^\/]\S.{-}\s+\{\s*$'

    let s:pattern['dict']
    \ = '^\v\' . s:pattern['prefix'] . '\s*(\S.{-})\.(\d+)$'
    let s:pattern['empty'] = '^\v\s*$'

    let s:echoMsg = {}

    let s:echoMsg['range'] = []
    call add(s:echoMsg['range'], 'ERROR: Incorrect opening tag.')
    call add(s:echoMsg['range'], 'ERROR: Incorrect closing tag.')
    call add(s:echoMsg['range']
    \ , 'ERROR: Containing duplicated opening tag in ')
    call add(s:echoMsg['range']
    \ , 'ERROR: Containing another opening tag in ')

    let s:echoMsg['path'] = []
    call add(s:echoMsg['path'], 'ERROR: Incorrect placeHolder: ''')
    call add(s:echoMsg['path'], 'ERROR: Incorrect g:fileList[''file''].')
    call add(s:echoMsg['path'], 'ERROR: FileList not found.')

    let s:echoMsg['note'] = []
    call add(s:echoMsg['note'], 'NOTE: Check command argument(s).')
    call add(s:echoMsg['note'], 'NOTE: Check g:fileList[''file''].')
    call add(s:echoMsg['note'], 'NOTE: Check fileList.')
    call add(s:echoMsg['note'], 'NOTE: Check ''g:placeHolder''.')

    let s:echoMsg['title'] = []
    call add(s:echoMsg['title'], '======Calling Function(s)======')
    call add(s:echoMsg['title'], '======Error Message(s)======')
    call add(s:echoMsg['title'], '======Debug Message(s)======')
    call add(s:echoMsg['title'], '======End of Line======')
    call add(s:echoMsg['title'], '======File(s) not Found======')

    let s:echoMsg['subTitle'] = []
    call add(s:echoMsg['subTitle'], '===s:Range===')
    call add(s:echoMsg['subTitle'], '===s:FileList===')
    call add(s:echoMsg['subTitle'], '===s:CommandList===')

    let s:echoMsg['function'] = []
    call add(s:echoMsg['function'], 's:InitVar()')

    let s:loadStaticVar = 1
endfun

fun! s:InitVar()
    if !exists('s:loadStaticVar')
        call s:LoadStaticVar()
    endif

    let s:dynArg = {}
    let s:dynArg['hasTab'] = 0

    let s:collectMsg = {}
    let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg, '', '')

    let l:error = 0

    if exists('g:path2FileList_quickEdit')
        \ && exists('g:path2FileList_quickEdit[''var''][1]')
        let l:path2Var =
        \ ioMessage_auto#DelTrailSlash(
        \ g:path2FileList_quickEdit['var'][0])
        \ . '/' . g:path2FileList_quickEdit['var'][1]
        if filereadable(l:path2Var)
            silent exe 'source ' . l:path2Var
        endif
        if !exists('g:path2FileList_quickEdit')
            \ || !exists('g:path2FileList_quickEdit[''file''][1]')
            \ || !exists('g:path2FileList_quickEdit[''var''][1]')
            \ || !exists('g:path2FileList_quickEdit[''arg''][1]')

            let l:error = 1
        endif
    else
        let l:error = 1
    endif

    if l:error > 0
        let g:path2FileList_quickEdit
        \ = {'file': [], 'var': [], 'arg': []}
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][1])

        let s:path2FileList = ''
        return
    endif

    let s:path_file = deepcopy(g:path2FileList_quickEdit)

    if (s:path_file['arg'][0] =~? s:pattern['tab'])
        let s:defArg['tab'] = s:path_file['arg'][0]
    endif
    if (s:path_file['arg'][1] =~? s:pattern['back'])
        let s:defArg['back'] = s:path_file['arg'][1]
    endif

    if !exists('g:path2Placeholder_quickEdit')
        let g:path2Placeholder_quickEdit = {}
    endif
    let s:path_place = deepcopy(g:path2Placeholder_quickEdit)

    let l:err_path = ioMessage_auto#SearchDictList(
    \ s:path_file['file'][0]
    \ , s:path_place, s:pattern['dict'], '\1', '\2')
    let l:path = l:err_path[1]
    let l:path = ioMessage_auto#DelTrailSlash(l:path)

    let s:path2FileList = l:path . '/' . s:path_file['file'][1]
    if !filereadable(s:path2FileList)
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][2])
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][1])
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][3])

        return
    endif
endfun

fun! s:Range(keyword)
    let l:start
    \ = s:pattern['start'][0] . a:keyword . s:pattern['start'][1]
    let l:end = s:pattern['end']
    let l:looseStart = s:pattern['looseStart']

    let l:error_range
    \ = getText_auto#Range(l:start, l:end, l:looseStart)
    let l:error = l:error_range[0]
    let l:range = l:error_range[1]
    let l:errLine = l:error_range[1][0]

    if !empty(l:error)
        if index(l:error, 'start') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][0])
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['note'][0])

        elseif index(l:error, 'end') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][1])

        elseif index(l:error, 'duplicate') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][2] . 'Line ' . l:errLine . '.')

        elseif index(l:error, 'loose') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][3] . 'Line ' . l:errLine . '.')
        endif

        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][2])
        call getText_auto#OpenFile('close', s:path2FileList)
        return

    else
        let s:Range = l:range
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , s:echoMsg['subTitle'][0], '')
        let s:collectMsg
        \ = ioMessage_auto#DebugOrError(s:collectMsg, s:Range, '')

    endif
endfun

fun! s:FileList()
    let l:range = deepcopy(s:Range)
    let l:comment = s:pattern['comment']
    let l:command_path = '\v^' . s:pattern['command']

    let l:rawText = getText_auto#RawText(l:range, 1, -1)
    let l:noComment = ioMessage_auto#DelSpace(l:rawText, l:comment, 0)

    let l:idx_split
    \ = ioMessage_auto#GetSplitIdx(l:noComment, l:command_path, 0)
    let l:item_split = ioMessage_auto#SplitList(l:noComment, l:idx_split)
    let l:item_split = filter(l:item_split, 'len(v:val) > 1')

    let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
    \ , s:echoMsg['subTitle'][1], '')
    for l:tmp in l:item_split
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , l:tmp, '')
    endfor

    let s:FileList = l:item_split
endfun

fun! s:CommandList()
    let l:fileList = deepcopy(s:FileList)

    let l:commandList = []
    let l:error = []

    for l:item in l:fileList
        let l:com_path = remove(l:item, 0)
        let l:file = l:item

        let l:split = '\v' . s:pattern['command'] . '\s*(.{-})$'
        let l:command = substitute(l:com_path, l:split, '\1', '')
        let l:command = tolower(l:command)
        if l:command == 'tabe'
            let s:dynArg['hasTab'] = 1
        endif

        let l:path = substitute(l:com_path, l:split, '\2', '')
        let l:err_path = ioMessage_auto#SearchDictList(
        \ l:path
        \ , s:path_place, s:pattern['dict'], '\1', '\2')
        let l:error = l:err_path[0]
        if !empty(l:error)
            break
        endif
        let l:path = l:err_path[1]
        let l:path = ioMessage_auto#DelTrailSlash(l:path)

        let l:err_file = s:ConvertFileName(l:file)
        let l:error = l:err_file[0]
        if !empty(l:error)
            break
        endif
        let l:file = l:err_file[1]

        let l:combine = []
        let l:combine = insert(l:file, l:path)
        let l:combine = insert(l:combine, l:command)
        let l:commandList = add(l:commandList, l:combine)
    endfor

    if !empty(l:error)
        let l:echoErr = '?' . l:error[0] . '.' . l:error[1]
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][0] . l:echoErr . '''.')
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][2])
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][3])
        return
    endif

    let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
    \ , s:echoMsg['subTitle'][2], '')
    for l:item in l:commandList
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , l:item, '')
    endfor

    let s:CommandList = l:commandList
endfun

fun! s:Move2Tab()
    if s:dynArg['hasTab'] == 0
        let s:tabStart = '.'
        return
    endif

    if s:newTab ==# '/i'
        call manageLayout_auto#OpenNewTab(0)
        let l:tabStart = 1
    elseif s:newTab ==# '/a'
        call manageLayout_auto#OpenNewTab('$')
        let l:tabStart = tabpagenr()
    elseif s:newTab ==# '/c'
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

    for l:item in l:command
        let l:exe = remove(l:item, 0, 1)

        for l:subItem in l:item
            let l:path_file = l:exe[1]
            let l:path2file = l:path_file . '/' . l:subItem

            if bufexists(l:path2file)
                if l:exe[0] =~# 'edit'
                    silent exe 'buffer ' . bufname(l:path2file)
                else
                    silent exe 'tabe ' . bufname(l:path2file)
                endif
            elseif filereadable(l:path2file)
                silent exe l:exe[0] . ' ' . l:path2file
                call getText_auto#ChangeDir()

            else
                if l:fileList
                    let s:collectMsg
                    \ = ioMessage_auto#DebugOrError(s:collectMsg
                    \ , s:echoMsg['title'][4], '')
                    let l:fileList = 0
                endif

                let s:collectMsg
                \ = ioMessage_auto#DebugOrError(s:collectMsg
                \ , l:path2file, '')
            endif
        endfor
    endfor

    if s:moveBack && s:dynArg['hasTab']
        exe s:tabStart . 'tabnext'
    endif
endfun

fun! s:ConvertFileName(fileNameList)
    let l:file = deepcopy(a:fileNameList)
    let l:err_file = []
    let l:error = []
    let l:newFile = []

    for l:item in l:file
        let l:err_file = ioMessage_auto#SearchDictList(
        \ l:item
        \ , s:path_place, s:pattern['dict'], '\1', '\2')
        let l:error = l:err_file[0]
        if !empty(l:error)
            break
        endif
        let l:tmp = l:err_file[1]

        let l:newFile = add(l:newFile, l:tmp)
    endfor

    return [l:error, l:newFile]
endfun

fun! s:EchoDebugOrError(...)
    let l:debugMsg = deepcopy(s:collectMsg.debug)
    let l:errorMsg = deepcopy(s:collectMsg.error)
    let l:value = deepcopy(s:echoMsg['subTitle'])
    let l:idx = index(l:debugMsg, s:echoMsg['title'][4])

    if exists('a:1') && a:1
        call ioMessage_auto#EchoHi(s:echoMsg['title'][1], 'Error')
        for l:item in l:errorMsg
            echom l:item
        endfor
    endif

    if l:idx > -1
        let l:notFound = remove(l:debugMsg, l:idx, len(l:debugMsg)-1)
        call remove(l:notFound, 0)
        call ioMessage_auto#EchoHi(s:echoMsg['title'][4], 'Error')
        for l:item in l:notFound
            echom l:item
        endfor
    endif

    call ioMessage_auto#EchoHi(s:echoMsg['title'][2], 'Type')
    for l:item in l:debugMsg
        if index(l:value, l:item) > -1
            call ioMessage_auto#EchoHi(l:item, 'Identifier')
        else
            echom l:item
        endif
    endfor

    call ioMessage_auto#EchoHi(s:echoMsg['title'][3], 'Type')
endfun

fun! quickEdit_auto#Main(...)
    call s:InitVar()

    let l:argList = copy(a:000)
    let l:filterFull = 'v:val !~? ''' . s:pattern['full'] . ''''
    let l:filterTab = 'v:val =~? ''' . s:pattern['tab'] . ''''
    let l:filterBack = 'v:val =~? ''' . s:pattern['back'] . ''''

    let l:keyWord = ioMessage_auto#FilterList(l:argList
    \ , l:filterFull, expand('<cword>'))

    let l:arg = ioMessage_auto#FilterList(l:argList
    \ , l:filterTab, s:defArg['tab'])
    let s:newTab = tolower(l:arg)
    let l:debug = ioMessage_auto#CheckCase(l:arg, 'u')

    let l:arg = ioMessage_auto#FilterList(l:argList
    \ , l:filterBack, s:defArg['back'])
    let s:moveBack = ioMessage_auto#CheckCase(l:arg, 'l')

    let l:funs = []
    call add(l:funs, 'getText_auto#OpenFile(''open'','''
    \ . s:path2FileList . ''')')
    call add(l:funs, 's:Range(''' . l:keyWord . ''')')
    call add(l:funs, 's:FileList()')
    call add(l:funs, 'getText_auto#OpenFile(''close'','''
    \ . s:path2FileList . ''')')
    call add(l:funs, 's:CommandList()')
    call add(l:funs, 's:Move2Tab()')
    call add(l:funs, 's:ExeCommand()')

    if l:debug
        call ioMessage_auto#EchoHi(s:echoMsg['title'][0], 'Type')
        echom s:echoMsg['function'][0]
    endif

    for l:item in l:funs
        if empty(s:collectMsg.error)
            exe 'call ' . l:item
            if l:debug
                echom l:item
            endif

        else
            if l:debug
                call s:EchoDebugOrError(1)
            endif
            if l:debug < 1
                redraw
            endif
            call ioMessage_auto#EchoHi(s:collectMsg.error[0], 'Error')
            return
        endif
    endfor

    if l:debug
        call s:EchoDebugOrError()
    endif
endfun

