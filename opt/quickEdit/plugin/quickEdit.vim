if (v:version < 800)
    finish
endif

if !exists('g:commandName_QuickEditTabPage')
    \|| g:commandName_QuickEditTabPage =~ '^\s*$'
    let g:commandName_QuickEditTabPage = 'QuickEditTabPage'
endif
if !exists(':' . g:commandName_QuickEditTabPage)
    exe 'com! -nargs=* -complete=customlist,quickEdit_auto#CompleteArg '
    \. g:commandName_QuickEditTabPage
    \. ' call quickEdit_auto#Main(<f-args>)'
endif

