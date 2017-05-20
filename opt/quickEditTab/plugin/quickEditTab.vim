if (v:version < 800)
    finish
endif

if !exists('g:path2FileList_quickEditTab[''comName'']')
    \|| g:path2FileList_quickEditTab['comName'] !~# '^\v\u(\a|\d)*$'
    let g:path2FileList_quickEditTab['comName'] = 'QuickEditTabPage'
endif

if !exists(':' . g:path2FileList_quickEditTab['comName'])
    exe
    \ 'com! -nargs=* -complete=customlist,quickEditTab_auto#CompleteArg '
    \. g:path2FileList_quickEditTab['comName']
    \. ' call quickEditTab_auto#Main(<f-args>)'
else
    echom '======quickEdit.vim Plugin======'
    echom 'ERROR: ''' . g:path2FileList_quickEditTab['comName']
    \. ''' already exists.'
    echom 'NOTE: (Re)set g:path2FileList_quickEditTab[''comName'']'
    echom ' and restart Vim.'
endif

