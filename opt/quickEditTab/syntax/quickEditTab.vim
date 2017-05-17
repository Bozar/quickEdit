syntax case ignore

syntax match qetKeyword /^\v\s*\zs(\a|\d|_)+\ze\s+\{\s*$/
syntax match qetBracket /\v\s+\zs\{\ze\s*$/
syntax match qetBracket /^\v\s*\zs\}\ze\s*$/

syntax match qetCommand /^\v\s*#(EDIT|TABE):.*$/ contains=qetPath
syntax match qetPath /^\v\s*#(EDIT|TABE):\s*\zs\S.{-}$/ contained
syntax match qetPlaceHolder /^\v\s*\?[^?].*$/
syntax match qetExeString /^\v\s*\?{2}.*$/

syntax match qetComment /^\s*\zs\/.*$/

highlight link qetKeyword Type
highlight link qetBracket PreProc

highlight link qetCommand Identifier
highlight link qetPath Type
highlight link qetPlaceHolder Type
highlight link qetExeString Constant

highlight link qetComment Comment

