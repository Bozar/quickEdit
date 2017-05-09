fun! splitList_auto#SetPoint(list, pat, case)
    let l:idx_split = []
    let l:tmpNum = 0

    for l:tmpItem in a:list
        if (a:case == 0) && (l:tmpItem =~? a:pat)
            call add(l:idx_split, l:tmpNum)
        elseif (a:case == 1) && (l:tmpItem =~# a:pat)
            call add(l:idx_split, l:tmpNum)
        endif
        let l:tmpNum += 1
    endfor

    return l:idx_split
endfun

fun! splitList_auto#Cut(list, split)
    let l:list = deepcopy(a:list)
    let l:split = deepcopy(a:split)
    let l:newList = []

    while !empty(l:split)
        let l:start = remove(l:split, 0)
        if !empty(l:split)
            let l:end = l:split[0] -1
        else
            let l:end = len(l:list) -1
        endif
        call add(l:newList, l:list[l:start : l:end])
    endwhile

    return l:newList
endfun

