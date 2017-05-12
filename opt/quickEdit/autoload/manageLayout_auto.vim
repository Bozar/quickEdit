fun! manageLayout_auto#ResizeWin(direction, percent, size)
    let l:direction = a:direction
    let l:percent = a:percent
    let l:size = a:size

    let l:scale = 0.0
    let l:newSize = []
    let l:fullSize = []

    if l:percent == 0
        let l:newSize = [l:size, l:size]
    elseif l:percent > 0
        let l:scale = l:size / 100.0
        let l:fullSize = s:GetWinSize()
        let l:newSize
        \ = [l:fullSize[0] * l:scale, l:fullSize[1] * l:scale]
    endif

    if l:direction ==? 'h'
        exe 'silent resize ' . string(l:newSize[0])
    elseif l:direction ==? 'w'
        exe 'silent vertical resize ' . string(l:newSize[1])
    endif
endfun

fun! s:GetWinSize()
    let l:height = 0
    let l:width = 0
    let l:newTab = 0

    if winnr('$') > 1
        call manageLayout_auto#OpenNewTab()
        let l:newTab = 1
    endif

    let l:height = winheight('%')
    let l:width = winwidth('%')

    if l:newTab
        tabprevious
        +tabclose
    endif

    return [l:height, l:width]
endfun

fun! manageLayout_auto#OpenNewTab(...)
    let l:file = expand('%:p')
    if (l:file == '')
        let l:file = $MYVIMRC
    endif
    if exists('a:1')
        exe 'silent ' . a:1 . 'tabe ' . l:file
    else
        silent tabe l:file
    endif
endfun

