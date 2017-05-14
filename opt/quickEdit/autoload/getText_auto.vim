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
    let l:error = {}
    let l:continue = 1

    1normal! 0
    if l:continue && search(l:pat_start, 'cW')
        let l:start = line('.')
    else
        let l:error['start'] = l:pat_start
        let l:continue = 0
    endif

    if l:continue && search(l:pat_end, 'cW')
        let l:end = line('.')
    else
        let l:error['end'] = l:pat_end
        let l:continue = 0
    endif

    $normal! $
    if l:continue && search(l:pat_start, 'bcW') && (line('.') != l:start)
        let l:error['duplicate'] = line('.')
        let l:continue = 0
    endif

    exe l:end . 'normal! $'
    if l:continue && (l:looseStart != '')
        \&& search(l:looseStart, 'bcW', l:start)
        \&& (line('.') != l:start)
        let l:error['loose'] = line('.')
        let l:continue = 0
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

