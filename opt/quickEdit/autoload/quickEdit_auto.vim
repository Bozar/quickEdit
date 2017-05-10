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
    call add(s:echoMsg['range'], 'ERROR: Dupliacated opening tags.')
    call add(s:echoMsg['range'], 'ERROR: Containing another opening tag.')

    let s:echoMsg['path'] = []
    call add(s:echoMsg['path'], 'ERROR: Incorrect path to file: ''')
    call add(s:echoMsg['path'], 'ERROR: Incorrect g:fileList[''file''].')
    call add(s:echoMsg['path'], 'ERROR: FileList not found.')

    let s:echoMsg['note'] = []
    call add(s:echoMsg['note'], 'NOTE: Check command argument(s).')
    call add(s:echoMsg['note'], 'NOTE: Check g:fileList[''file''].')
    call add(s:echoMsg['note'], 'NOTE: Check fileList.')
    call add(s:echoMsg['note'], 'NOTE: Check ''g:placeHolder''.')

    let s:echoMsg['title'] = []
    call add(s:echoMsg['title'], '======Calling Functions======')
    call add(s:echoMsg['title'], '======Error Messages======')
    call add(s:echoMsg['title'], '======Debug Messages======')
    call add(s:echoMsg['title'], '======End of Line======')

    let s:echoMsg['subTitle'] = []
    call add(s:echoMsg['subTitle'], '===s:Range===')
    call add(s:echoMsg['subTitle'], '===s:FileList===')
    call add(s:echoMsg['subTitle'], '===s:CommandList===')
    call add(s:echoMsg['subTitle'], '===File(s) not Found===')

    let s:echoMsg['function'] = []
    call add(s:echoMsg['function'], 's:InitVar()')

    let s:loadStaticVar = 1
endfun

fun! s:InitVar()
    if !exists('s:loadStaticVar')
        call s:LoadStaticVar()
    endif

    let s:collectMsg = {}
    let s:collectMsg = collectMsg_auto#DebugOrError(s:collectMsg, '', '')

    if !exists('g:pathToFileList_quickEdit')
        \ || (type(g:pathToFileList_quickEdit) !=? v:t_dict)
        \ || !exists('g:pathToFileList_quickEdit[''file''][0]')
        \ || !exists('g:pathToFileList_quickEdit[''file''][1]')

        let g:pathToFileList_quickEdit
        \ = {'file': [], 'var': [], 'arg': []}
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
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

    let l:path = s:strToPath(s:path_file['file'][0], s:path_place)
    let l:path = l:path[1]
    let s:pathToFileList = l:path . '/' . s:path_file['file'][1]
    if !filereadable(s:pathToFileList)
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][2])
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][1])
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
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

    if !empty(l:error)
        if index(l:error, 'start') > -1
            let s:collectMsg
            \ = collectMsg_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][0])
            let s:collectMsg
            \ = collectMsg_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['note'][0])
        endif
        if index(l:error, 'end') > -1
            let s:collectMsg
            \ = collectMsg_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][1])
        endif

        if index(l:error, 'duplicate') > -1
            let s:collectMsg
            \ = collectMsg_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][2])
        endif
        if index(l:error, 'loose') > -1
            let s:collectMsg
            \ = collectMsg_auto#DebugOrError(s:collectMsg
            \ , '', s:echoMsg['range'][3])
        endif

        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][2])
        call getText_auto#OpenFile('close', s:pathToFileList)
        return

    else
        let s:Range = l:range
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , s:echoMsg['subTitle'][0], '')
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg, s:Range, '')

    endif
endfun

fun! s:FileList()
    let l:range = deepcopy(s:Range)
    let l:comment = s:pattern['comment']
    let l:command_path = '\v^' . s:pattern['command']

    let l:rawText = getText_auto#RawText(l:range, 1, -1)
    let l:noComment = getText_auto#noSpace(l:rawText, l:comment)

    let l:idx_split
    \ = splitList_auto#SetPoint(l:noComment, l:command_path, 0)
    let l:item_split = splitList_auto#Cut(l:noComment, l:idx_split)
    let l:item_split = filter(l:item_split, 'len(v:val) > 1')

    let s:collectMsg
    \ = collectMsg_auto#DebugOrError(s:collectMsg
    \ , s:echoMsg['subTitle'][1], '')
    let s:collectMsg
    \ = collectMsg_auto#DebugOrError(s:collectMsg
    \ , l:item_split, '')

    let s:FileList = l:item_split
endfun

fun! s:CommandList()
    let l:fileList = deepcopy(s:FileList)
    let l:path_place = s:path_place

    let l:commandList = []
    let l:error = []

    for l:item in l:fileList
        let l:com_path = remove(l:item, 0)
        let l:file = l:item

        let l:split = '\v' . s:pattern['command'] . '\s*(.{-})$'
        let l:command = substitute(l:com_path, l:split, '\1', '')
        let l:command = tolower(l:command)

        let l:path = substitute(l:com_path, l:split, '\2', '')
        let l:path = s:strToPath(l:path, l:path_place)
        let l:error = l:path[0]
        if !empty(l:error)
            let l:commandList = insert(l:commandList, l:error)
            let l:path = ''
            let l:break = 1
            break
        endif
        let l:path = l:path[1]

        let l:combine = []
        let l:combine = insert(l:file, l:path)
        let l:combine = insert(l:combine, l:command)
        let l:commandList = add(l:commandList, l:combine)
    endfor

    if !exists('l:break')
        let l:commandList = insert(l:commandList, l:error)
    endif
    let l:error = remove(l:commandList, 0)
    if !empty(l:error)
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['path'][0] . l:error[0] . '''.')
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][2])
        let s:collectMsg
        \ = collectMsg_auto#DebugOrError(s:collectMsg
        \ , '', s:echoMsg['note'][3])
        return
    endif

    let s:collectMsg
    \ = collectMsg_auto#DebugOrError(s:collectMsg
    \ , s:echoMsg['subTitle'][2], '')
    let s:collectMsg
    \ = collectMsg_auto#DebugOrError(s:collectMsg
    \ , l:commandList, '')

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
                    \ = collectMsg_auto#DebugOrError(s:collectMsg
                    \ , s:echoMsg['subTitle'][3], '')
                    let l:fileList = 0
                endif

                let s:collectMsg
                \ = collectMsg_auto#DebugOrError(s:collectMsg
                \ , l:pathTofile, '')
            endif
        endfor
    endfor

    if s:moveBack
        exe s:tabStart . 'tabnext'
    endif
endfun

fun! s:strToPath(path, refer)
    let l:path = a:path
    let l:refer = deepcopy(a:refer)

    let l:dict = s:pattern['dict']
    let l:empty = s:pattern['empty']
    let l:retPath = ''
    let l:error = []

    if l:path =~? l:dict
        let l:key = substitute(l:path, l:dict, '\1', '')
        let l:idx = substitute(l:path, l:dict, '\2', '')
        if (type(l:refer) ==? v:t_dict)
            \ && exists('l:refer[l:key][l:idx]')
            let l:retPath = l:refer[l:key][l:idx]
        endif
    else
        let l:retPath = l:path
    endif

    if l:retPath =~ l:empty
        call add(l:error, l:path)
    endif

    let l:retPath = getText_auto#CutTrailSlash(l:retPath)
    let l:result = [l:error, l:retPath]
    return l:result
endfun

fun! s:EchoDebugAndError(...)
    let l:debugMsg = deepcopy(s:collectMsg.debug)
    let l:errorMsg = deepcopy(s:collectMsg.error)

    echom s:echoMsg['title'][2]
    for l:item in l:debugMsg
        echom l:item
    endfor

    if exists('a:1') && a:1
        echom s:echoMsg['title'][1]
        for l:item in l:errorMsg
            echom l:item
        endfor
    endif

    echom s:echoMsg['title'][3]
endfun

fun! quickEdit_auto#CallFuns(...)
    call s:InitVar()

    let l:argList = copy(a:000)
    let l:filterFull = 'v:val !~ ''' . s:pattern['full'] . ''''
    let l:filterTab = 'v:val =~ ''' . s:pattern['tab'] . ''''
    let l:filterBack = 'v:val =~ ''' . s:pattern['back'] . ''''

    let l:keyWord
    \ = comArg_auto#FilterArg(l:argList, l:filterFull, expand('<cword>'))

    let l:arg
    \ = comArg_auto#FilterArg(l:argList, l:filterTab, s:defArg['tab'])
    let s:newTab = tolower(l:arg)
    let l:debug = comArg_auto#CheckArgCase(l:arg, 'u')

    let l:arg
    \ = comArg_auto#FilterArg(l:argList, l:filterBack, s:defArg['back'])
    let s:moveBack = comArg_auto#CheckArgCase(l:arg, 'l')

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
        echom s:echoMsg['title'][0]
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
                call s:EchoDebugAndError(1)
            endif
            call confirm(s:collectMsg.error[0])
            return
        endif
    endfor

    if l:debug
        call s:EchoDebugAndError()
    endif
endfun

