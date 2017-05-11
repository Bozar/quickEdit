fun! manageTabs_auto#OpenNewTab(...)
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

