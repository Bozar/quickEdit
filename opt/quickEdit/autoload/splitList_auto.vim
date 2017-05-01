fun! splitList_auto#SetPoint(list, pat, case)
    let l:idx_split = []
    let l:tmpNum = 0

    for l:tmpItem in a:list
        if a:case == 0 && l:tmpItem =~? a:pat
            call add(l:idx_split, l:tmpNum)
        elseif a:case == 1 && l:tmpItem =~# a:pat
            call add(l:idx_split, l:tmpNum)
        endif
        let l:tmpNum += 1
    endfor

    return l:idx_split
endfun

fun! splitList_auto#Cut(list, split)
    let l:copyList = copy(a:list)
    let l:copySplit = copy(a:split)
    let l:newList = []

    while len(l:copySplit)
        let l:start = remove(l:copySplit, 0)
        if len(l:copySplit)
            let l:end = l:copySplit[0] -1
        else
            let l:end = len(l:copyList) -1
        endif
        call add(l:newList, l:copyList[l:start : l:end])
    endwhile

    return l:newList
endfun

