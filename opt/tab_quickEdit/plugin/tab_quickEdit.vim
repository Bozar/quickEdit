if v:version < 800
    finish
endif

if !exists('g:commandName_tab_quickEdit')
    \ || g:commandName_tab_quickEdit =~ '^\s*$'
    let g:commandName_tab_quickEdit = 'QuickEditTabPage'
endif
if !exists(':' . g:commandName_tab_quickEdit)
    exe 'com! -nargs=* ' .
    \ g:commandName_tab_quickEdit .
    \ ' call tab_quickEdit_auto#CallFuns(<f-args>)'
endif

