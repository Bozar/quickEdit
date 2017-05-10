fun! resizeWin_auto#main(direction, percent)
    let l:result = s:InitVar(a:direction, a:percent)
    let l:error = l:result[0]
    if !empty(l:error)
        return
    endif

    let l:direction = l:result[1]
    let l:percent = l:result[2]
    let l:size = s:GetWinSize()

    if l:direction ==? 'h'
        let l:size = float2nr(l:size[0] * l:percent)
        exe 'resize ' . l:size
    elseif l:direction ==? 'w'
        let l:size = float2nr(l:size[1] * l:percent)
        exe 'vertical resize ' . l:size
    endif
endfun

fun! s:InitVar(direction, percent)
    let l:dir = a:direction
    let l:per = a:percent
    let l:error = []

    if (type(l:dir) != v:t_string) || (l:dir !~? '\v^(h|w)$')
        call add(l:error, 'argument')
    endif
    if (type(l:per) != v:t_number) && (type(l:per) != v:t_float)
        let l:per = 0
        call add(l:error, 'number')
    endif

    if l:per < 0
        let l:per = abs(l:per)
    endif
    if l:per > 1
        let l:per = l:per / 100.0
    endif

    return [l:error, l:dir, l:per]
endfun

fun! s:GetWinSize()
    let l:height = 0
    let l:width = 0

    if winnr('$') > 1
        let l:file = expand('%:p')
        if (l:file == '')
            let l:file = $MYVIMRC
        endif
        tabe l:file
    endif

    let l:height = winheight('%')
    let l:width = winwidth('%')

    if exists('l:file')
        tabprevious
        +tabclose
    endif

    return [l:height, l:width]
endfun

