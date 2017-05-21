if exists('g:path2Placeholder_quickEditTab')
    unlet g:path2Placeholder_quickEditTab
endif
let g:path2Placeholder_quickEditTab = {}

let g:path2Placeholder_quickEditTab['loadVar'] = []
call add(g:path2Placeholder_quickEditTab['loadVar'], getcwd())

let s:path = '~\vimfiles\pack\quickEditTab\opt\quickEditTab\'
let g:path2Placeholder_quickEditTab['qETab'] = []
call add(g:path2Placeholder_quickEditTab['qETab'], s:path . 'autoload')
call add(g:path2Placeholder_quickEditTab['qETab'], s:path . 'plugin')

let g:path2Placeholder_quickEditTab['name'] = []
call add(g:path2Placeholder_quickEditTab['name'], 'ioMessage_auto.vim')
call add(g:path2Placeholder_quickEditTab['name'], 'getText_auto.vim')

