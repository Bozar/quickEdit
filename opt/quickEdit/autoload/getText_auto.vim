fun! getText_auto#OpenFile(stat, path2File)
    let l:path = expand(a:path2File)
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
        \&& (bufnr('%') == bufnr(l:path))
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
    let l:start = 0
    let l:end = 0
    let l:error = []

    1normal! 0
    if empty(l:error) && search(l:pat_start, 'cW')
        let l:start = line('.')
    else
        call add(l:error, 'start')
    endif
    if empty(l:error) && search(l:pat_end, 'cW')
        let l:end = line('.')
    else
        call add(l:error, 'end')
    endif

    $normal! $
    if empty(l:error) && search(l:pat_start, 'bcW')
        \&& (line('.') != l:start)
        let l:start = line('.')
        call add(l:error, 'duplicate')
    endif

    exe l:end . 'normal! $'
    if empty(l:error) && (l:looseStart != '')
        \&& search(l:looseStart, 'bcW', l:start)
        \&& (line('.') != l:start)
        let l:start = line('.')
        call add(l:error, 'loose')
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

