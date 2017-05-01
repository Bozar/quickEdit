if v:version < 800
    finish
endif

if !exists('g:commandName_quickEdit_tab')
    \ || g:commandName_quickEdit_tab =~ '^\s*$'
    let g:commandName_quickEdit_tab = 'QuickEditTabPage'
endif
if !exists(':' . g:commandName_quickEdit_tab)
    exe 'com! -nargs=* ' .
    \ g:commandName_quickEdit_tab .
    \ ' call tab_quickEdit_auto#CallFuns(<f-args>)'
endif

