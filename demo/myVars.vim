fun! s:SetComp()
    let l:complete = []

    call add(l:complete, 'plugin')
    call add(l:complete, 'demo')
    call add(l:complete, 'init')

    let g:path2FileList_quickEditTab['comp'] = l:complete
endfun

fun! s:SetPlaceholder()
    let l:place = {}

    let l:place['plugin'] = []
    call add(l:place['plugin']
    \, '~\vimfiles\pack\quickEditTab\opt\quickEditTab\')
    call add(l:place['plugin'], l:place['plugin'][0] . 'autoload')
    call add(l:place['plugin'], l:place['plugin'][0] . 'syntax')
    call add(l:place['plugin'], l:place['plugin'][0] . 'plugin')

    let l:place['test'] = []
    call add(l:place['test'], '%:h')
    call add(l:place['test'], getcwd())

    let l:place['doc'] = [s:workingDir]

    let g:path2Placeholder_quickEditTab = l:place
endfun

fun! s:GetWorkingDir()
    if system('hostname') =~? 'workplace'
        let s:workingDir = '~/Regular_Work/'
        let s:env = 'work'
    elseif system('hostname') =~? 'home'
        let s:workingDir = '~/Documents/'
        let s:env = 'home'
    else
        let s:workingDir = ''
        let s:env = 'unknown'
    endif
endfun

fun! s:SetDefValue()
    let l:file = {}
    let l:file['file'] = [s:workingDir, 'fileList']
    let l:file['var'] = [s:workingDir, 'myVars.vim']
    let l:file['arg'] = ['/c', '/B']
    let l:file['comName'] = ['QETab']

    let g:path2FileList_quickEditTab = l:file
endfun

fun! s:InitGlobalVars()
    let g:path2FileList_quickEditTab = {}
    let g:path2Placeholder_quickEditTab = {}
endfun

fun! s:Main()
    call s:InitGlobalVars()
    call s:GetWorkingDir()
    call s:SetDefValue()
    call s:SetComp()
    call s:SetPlaceholder()
endfun
call s:Main()

