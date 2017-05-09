fun! getText_auto#OpenFile(stat, pathToFile)
    let l:path = expand(a:pathToFile)
    if a:stat ==? 'open'
        wincmd s
        if bufexists(l:path)
            exe 'silent buffer '. bufnr(l:path)
        else
            exe 'silent e ' . l:path
            call getText_auto#ChangeDir()
        endif
        let s:cursor = getpos('.')

    elseif (a:stat ==? 'close') && bufexists(l:path)
        \ && (bufnr('%') == bufnr(l:path))
        call setpos('.', s:cursor)
        if winnr('$') > 1
            wincmd c
        endif
    endif
endfun

fun! getText_auto#ChangeDir()
    let l:work = expand(getcwd())
    let l:workEscape = escape(l:work, '\')
    let l:file = expand('%:p:h')

    if match(l:file, '^' . l:workEscape) > -1
        exe 'cd ' . getcwd()
    endif
endfun

fun! getText_auto#Range(start, end, looseStart)
    let l:pat_start = a:start
    let l:pat_end = a:end
    let l:looseStart = a:looseStart
    let l:error = []

    1normal! 0
    if search(l:pat_start, 'cW')
        let l:start = line('.')
    else
        let l:start = 0
        call add(l:error, 'start')
    endif
    if search(l:pat_end, 'cW')
        let l:end = line('.')
    else
        let l:end = 0
        call add(l:error, 'end')
    endif
    if (l:start != 0) && (l:looseStart != '')
        \ && search(l:looseStart, 'bcW') && (line('.') != l:start)
        let l:end = 0
        call add(l:error, 'loose')
    endif

    $normal! 0
    if search(l:pat_start, 'bcW') && (line('.') != l:start)
        call add(l:error, 'duplicate')
    endif

    let l:result = [l:error, [l:start, l:end]]
    return l:result
endfun

fun! getText_auto#RawText(rangeList, ...)
    if exists('a:1')
        let l:start = a:rangeList[0] + a:1
    else
        let l:start = a:rangeList[0]
    endif
    if exists('a:2')
        let l:end = a:rangeList[1] + a:2
    else
        let l:end = a:rangeList[1]
    endif

    let l:rawText = getline(l:start, l:end)
    return l:rawText
endfun

fun! getText_auto#noSpace(text, comment)
    let l:text = deepcopy(a:text)
    let l:comment = a:comment
    let l:noSpace = []
    let l:pat_space = '\v^\s*(.{-})\s*$'
    let l:pat_empty = '\v^\s*$'

    for l:tmpItem in l:text
        let l:shrink = substitute(l:tmpItem, l:pat_space, '\1', '')
        call add(l:noSpace, l:shrink)
    endfor

    let l:noEmptyLine = filter(l:noSpace
    \, 'v:val !~ ''' . l:pat_empty . '''')

    if a:comment !=? ''
        let l:pat_comment = 'v:val !~? ''' . a:comment . ''''
        let l:noCommentLine = filter(l:noEmptyLine, l:pat_comment)
    else
        let l:noCommentLine = l:noEmptyLine
    endif

    return l:noCommentLine
endfun

fun! getText_auto#CutTrailSlash(path)
    let l:path = expand(a:path)
    let l:pat_trailSlash = '\v^(.{-})(\\|\/)*$'
    let l:path = substitute(l:path, l:pat_trailSlash, '\1', '')
    return l:path
endfun

