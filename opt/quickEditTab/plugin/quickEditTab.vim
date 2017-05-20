if (v:version < 800)
    finish
endif

if !exists('g:path2FileList_quickEditTab[''comName''][0]')
    \|| (type(g:path2FileList_quickEditTab['comName']) != v:t_list)
    \|| g:path2FileList_quickEditTab['comName'][0] !~# '^\v\u(\a|\d)*$'
    let g:path2FileList_quickEditTab['comName'] = ['']
    let g:path2FileList_quickEditTab['comName'][0] = 'QuickEditTabPage'
endif

if !exists(':' . g:path2FileList_quickEditTab['comName'][0])
    exe
    \ 'com! -nargs=* -complete=customlist,quickEditTab_auto#CompleteArg '
    \. g:path2FileList_quickEditTab['comName'][0]
    \. ' call quickEditTab_auto#Main(<f-args>)'
else
    echom '======quickEdit.vim Plugin======'
    echom 'ERROR: ''' . g:path2FileList_quickEditTab['comName'][0]
    \. ''' already exists.'
    echom 'NOTE: (Re)set g:path2FileList_quickEditTab[''comName''][0]'
    echom ' and restart Vim.'
endif

