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
    call add(s:echoMsg['range'], 'ERROR: Containing duplicated opening tag in ')
    call add(s:echoMsg['range'], 'ERROR: Containing another opening tag in ')

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

    if !exists('g:pathToFileList_quickEdit')
        \ || (type(g:pathToFileList_quickEdit) !=? v:t_dict)
        \ || !exists('g:pathToFileList_quickEdit[''file''][0]')
        \ || !exists('g:pathToFileList_quickEdit[''file''][1]')

        let g:pathToFileList_quickEdit
        \ = {'file': [], 'var': [], 'arg': []}
        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][1])

        let s:pathToFileList = ''
        return
    endif
    let s:path_file = deepcopy(g:pathToFileList_quickEdit)

    if exists('s:path_file[''var''][1]')
        let l:pathToVar
        \ = getText_auto#CutTrailSlash(s:path_file['var'][0]) . '/'
        \ . s:path_file['var'][1]
        if filereadable(l:pathToVar)
            exe 'source ' . l:pathToVar
        endif
    endif

    if exists('s:path_file[''arg''][0]')
        \ && (s:path_file['arg'][0] =~? s:pattern['tab'])
        let s:defArg['tab'] = s:path_file['arg'][0]
    endif
    if exists('s:path_file[''arg''][1]')
        \ && (s:path_file['arg'][1] =~? s:pattern['back'])
        let s:defArg['back'] = s:path_file['arg'][1]
    endif

    if !exists('g:pathToPlaceholder_quickEdit')
        let g:pathToPlaceholder_quickEdit = {}
    endif
    let s:path_place = deepcopy(g:pathToPlaceholder_quickEdit)

    let l:err_path = s:GetDictValue(s:path_file['file'][0], s:path_place)
    let l:path = l:err_path[1]
    let l:path = getText_auto#CutTrailSlash(l:path)

    let s:pathToFileList = l:path . '/' . s:path_file['file'][1]
    if !filereadable(s:pathToFileList)
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
        endif
        if index(l:error, 'end') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][1])
        endif

        if index(l:error, 'duplicate') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][2] . 'Line ' . l:errLine . '.')
        endif

        if index(l:error, 'loose') > -1
            let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][3] . 'Line ' . l:errLine . '.')
        endif

        let s:collectMsg = ioMessage_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][2])
        call getText_auto#OpenFile('close', s:pathToFileList)
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
    let l:noComment = getText_auto#NoSpace(l:rawText, l:comment)

    let l:idx_split
    \ = splitList_auto#SetPoint(l:noComment, l:command_path, 0)
    let l:item_split = splitList_auto#Cut(l:noComment, l:idx_split)
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
        let l:err_path = s:GetDictValue(l:path, s:path_place)
        let l:error = l:err_path[0]
        if !empty(l:error)
            break
        endif
        let l:path = l:err_path[1]
        let l:path = getText_auto#CutTrailSlash(l:path)

        let l:err_file = s:ProcessFileName(l:file)
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

fun! s:MoveToTab()
    if s:dynArg['hasTab'] == 0
        let s:tabStart = '.'
        return
    endif

    if s:newTab ==# '/i'
        call manageTabs_auto#OpenNewTab(0)
        let l:tabStart = 1
    elseif s:newTab ==# '/a'
        call manageTabs_auto#OpenNewTab('$')
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
            let l:pathTofile = l:path_file . '/' . l:subItem

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
                    let s:collectMsg
                    \ = ioMessage_auto#DebugOrError(s:collectMsg
                    \ , s:echoMsg['title'][4], '')
                    let l:fileList = 0
                endif

                let s:collectMsg
                \ = ioMessage_auto#DebugOrError(s:collectMsg
                \ , l:pathTofile, '')
            endif
        endfor
    endfor

    if s:moveBack && s:dynArg['hasTab']
        exe s:tabStart . 'tabnext'
    endif
endfun

fun! s:GetDictValue(string, dict)
    let l:str = a:string
    let l:dict = deepcopy(a:dict)

    let l:str = s:StrToKeyIdx(l:str)
    if l:str[0] == 0
        let l:result = ['' , l:str[1]]
    elseif l:str[0] == 1
        let l:result
        \ = ioMessage_auto#DictValue(l:str[1], l:str[2], l:dict)
    endif

    return l:result
endfun

fun! s:StrToKeyIdx(string)
    let l:str = a:string
    let l:result = []

    if l:str =~? s:pattern['dict']
        let l:key = substitute(l:str, s:pattern['dict'], '\1', '')
        let l:idx = substitute(l:str, s:pattern['dict'], '\2', '')
        let l:result = [1, l:key, l:idx]
    else
        let l:result = [0, l:str]
    endif

    return l:result
endfun

fun! s:ProcessFileName(fileNameList)
    let l:file = deepcopy(a:fileNameList)
    let l:err_file = []
    let l:error = []
    let l:newFile = []

    for l:item in l:file
        let l:err_file = s:GetDictValue(l:item, s:path_place)
        let l:error = l:err_file[0]
        if !empty(l:error)
            break
        endif
        let l:newFile = add(l:newFile, l:err_file[1])
    endfor

    return [l:error, l:file]
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
    let l:filterFull = 'v:val !~ ''' . s:pattern['full'] . ''''
    let l:filterTab = 'v:val =~ ''' . s:pattern['tab'] . ''''
    let l:filterBack = 'v:val =~ ''' . s:pattern['back'] . ''''

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
    \ . s:pathToFileList . ''')')
    call add(l:funs, 's:Range(''' . l:keyWord . ''')')
    call add(l:funs, 's:FileList()')
    call add(l:funs, 'getText_auto#OpenFile(''close'','''
    \ . s:pathToFileList . ''')')
    call add(l:funs, 's:CommandList()')
    call add(l:funs, 's:MoveToTab()')
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
            call confirm(s:collectMsg.error[0])
            return
        endif
    endfor

    if l:debug
        call s:EchoDebugOrError()
    endif
endfun

