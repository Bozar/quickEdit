if (v:version < 800)
    finish
endif

if !exists('g:commandName_QuickEditTabPage')
    \|| g:commandName_QuickEditTabPage !~# '^\v\u(\a|\d)*$'
    let g:commandName_QuickEditTabPage = 'QuickEditTabPage'
endif

if !exists(':' . g:commandName_QuickEditTabPage)
    exe 'com! -nargs=* -complete=customlist,quickEdit_auto#CompleteArg '
    \. g:commandName_QuickEditTabPage
    \. ' call quickEdit_auto#Main(<f-args>)'
else
    echom '======quickEdit.vim Plugin======'
    echom 'ERROR: ''' . g:commandName_QuickEditTabPage
    \. ''' already exists.'
    echom 'NOTE: (Re)set ''g:commandName_QuickEditTabPage'''
    echom ' and restart Vim.'
endif

