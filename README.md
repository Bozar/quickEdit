# QuickEditTab Readme

## Part A: Quick Start Guide

### A0: Demo Gif

![image](https://github.com/Bozar/quickEditTab/blob/981deb8686104e946e74fd00b4d8ae3ba1ce62ba/demo/pluginDemo.gif)

### A1: A Brief Introduction

`QuickEditTab` provides a new command, `QuickEditTabPage`, to open files in the same or another tab according to a prdefined file list.  Two global variables, `g:path2FileList_quickEditTab` and `g:path2Placeholder_quickEditTab`, are added to store plugin settings.  The plugin requires Vim 8.0 or higher.

### A2: How to Install

Add different lines to your `vimrc` based on package managers.

Vundle:

    Plugin 'Bozar/quickEditTab'

VAM:

    VAMActivate quickEditTab

Vim 8.0's internal package manager:

Unpack everything to this folder: `vimfiles/pack`.

    packadd! quickEditTab

## Part B: Arguments, Variables and the File List

### B0: Execute the Command

Follow these steps to execute `QuickEditTabPage` for the first time.

Copy `fileList` (not `fileList_demo`) from `quickEditTab/demo` to another folder, for example: `~/Documents/tmp`.

Add new lines to your `vimrc`:

    let g:path2FileList_quickEditTab = {}
    let g:path2FileList_quickEditTab['file'] = ['####', 'fileList']

    let g:path2Placeholder_quickEditTab = {}
    let g:path2Placeholder_quickEditTab['demo']
    \= [g:path2FileList_quickEditTab['file'][0], 'fileList']

Replace `####` with the path to `fileList`.

Restart Vim and let the show begin.  `:QuickEditTabPage init`.

If everything goes well (go to the end of B0 if an error occurs), you should see two tabs: `fileList` in Tab 1 and `vimrc_example.vim` in Tab 2.  Now go back to Tab 1, move cursor to `init` in Line 7, and execute the command with arguments.  `:QuickEditTabPage /b /i`.

The same two tabs are reopened and you are in the first tab.  Let's execute the command for the third time to peek behind the scenes.  `:QuickEditTabPage /C init`.

If you receive an error message from `QuickEditTab` plugin when starting Vim, add this line in addition to previous settings to your `vimrc`:

    let g:path2FileList_quickEditTab['comName']
    \= ['QuickEditTabPageAlternative']

If you receive error messages when executing the command,

*   `ERROR: Incorrect g:path2FileList_quickEditTab['file'].`
*   `======File(s) not Found======`

make sure the path to `fileList` is correct.  Do not change anything except `####`.

### B1: Command Arguments

`QuickEditTabPage` requires three arguments: `back`, `tab` and `keyword`.  `Back` and `tab` are case sensitive.  `Keyword` is case insensitive.  All of them can be omitted.

`Back` defines whether or not to move back to the first tab that `QuickEditTabPage` creates:

*   `/b`: Move back to the first tab.
*   `/B`: Stay in the last tab.

`Tab` has three pairs of arguments.  They define the starting tab before editing files:

*   `/c, /C`: Close all other tabs except the current one.  Close all other windows except the current one.  Add new tabs after the current one.
*   `/i, /I`: Move to the first tab.  Insert new tabs before the current one.
*   `/a, /A`: Move to the last tab.  Add new tabs after the current one.

The upper-case arguments show details when executing the command.

`Back` and `tab` will not work if there is no `tabe` command in the file group, see B3.

`Keyword` is used to search in the file list, see B3.

When executing the command, arguments are checked from left to right.  The first argument that is not `back` or `tab` is recognized as `keyword`.  Otherwise, the cursor word (`<cword>`) is used.  The same procedure applies to `back` and `tab`.  Without `back` or `tab`, the default values are used, see B2.  For example, `QuickEditTabPage /B /i foo /a bar /b` equals to `QuickEditTabPage
/B /i foo`.

### B2: Global Variables, Part 1

The global variable `g:path2FileList_quickEditTab`, `g:FileList` for short, is a Dictionary.  A Dictionary is composed of entries.  An entry has a key and a value.  The variable `g:FileList` has five entries.  Keys in `g:FileList` are defined by the plugin and cannot be changed.  Values in `g:FileList` are lists.  For example, you can set `g:FileList` like this:

    let g:path2FileList_quickEditTab
    \= {'file': ['~/Documents', 'fileList']
    \, 'comName': ['QETab']
    \, 'arg': ['/c', '/B']
    \, 'var': ['~/Documents', 'myVars.vim']
    \, 'comp': ['plugin', 'demo', 'init', 'blog']}

First let's take a look at `'comName'` and `'arg'`.

Add this line to your `vimrc` to use `QETab` as the command name:

    let g:path2FileList_quickEditTab['comName'] = ['QETab']

A valid command name begins with upper case alphabet and is followed by zero or more alphabets and/or digits.  If `g:FileList['comName']` is not set or the user defined command name is invalid, `QuickEditTabPage` is used.

Add this line to your `vimrc` to set default arguments:

    let g:path2FileList_quickEditTab['arg'] = ['/c', '/B']

The first item in the list is argument `tab`: `/ciaCIA`.  The second item is argument `back`: `/bB`.  If `g:FileList['arg']` is not set or the argument is invalid, `['/c', '/B']` is used.

### B3: The File List

Read comments in the `fileList` to get familiar with the structure of a file list:

*   Modeline and comments
*   Keywords and bracket pairs
*   Commands and paths to files
*   File names
*   Placeholders
*   Strings to be executed

A valid keyword only contains alphabets, numbers and/or underlines.  Keywords must be unique in a file list.

The `quickEditTab` plugin continues even when `??string` results in an error.  You'd better use `??string` just for splitting, resizing and jumping between windows.

### B4: Global Variables, Part 2

The file list is a txt file.  You can rename it and put it anywhere so long as the plugin can find it:

    let g:path2FileList_quickEditTab['file']
    \= ['{path to the file list}', '{file name}']

There is no default value for `g:FileList['file']`.  If it is not set or the file list is unreadable, the plugin cannot work.

Keywords can be completed by setting `g:FileList['comp']`:

    let g:path2FileList_quickEditTab['comp'] = []
    call add(g:path2FileList_quickEditTab['comp'], '{keyword 1}')
    call add(g:path2FileList_quickEditTab['comp'], '{keyword 2}')

All spaces in the keyword string are deleted.  Invalid keywords are deleted.  The remaining valid keywords are sorted.  If `g:FileList['comp']` is not set or there are no valid keywords, the argument completion does not work.

## Part C: Placeholders and Source the Script

### C0: Placeholders

Placeholders are optional to the plugin.  They can make the file list easy to read and modify.  Both file paths and file names can be replaced by placeholders.  A placeholder begins with a single question mark, and then a key and an index, separated by a dot: `?key.index`.  The key and index points to an entry in `g:path2Placeholder_quickEditTab`, see C1.

### C1: Global Variables, Part 3

The global variable `g:path2Placeholder_quickEditTab`, `g:Place` for short, just like `g:FileList`, is a Dictionary.  There are no restrictions for keys and values in `g:Place`, except that the type of values must be a list.  As mentioned in C0, placeholders and `g:Place` are related.  Let's see an example:

    let g:path2Placeholder_quickEditTab = {}
    let g:path2Placeholder_quickEditTab['demo']
    \= ['~/Documents', 'fileList']

In the file list, `?demo.0` points to `'~/Documents'`, and `?demo.1` points to `'fileList'`.  Keys in a Dictionary are case sensitive.  So you'd better copy and paste keys rather than type them by hand to avoid mistakes.

You can put both global variables into `vimrc`.  But the downside is that, whenever you need to add a new placeholder or command completion, you have to restart Vim.  Here is another way.  Store `g:FileList` and `g:Place` in a script:

    let g:path2FileList_quickEditTab['var']
    \= '{path to the script}', '{script name}']

If `g:Place['var']` exists and the script is readable, it is sourced every time when executing `QuickEditTabPage`.  So you can change almost everything on the fly.  The command name, however, is defined when starting Vim.  In that way, you only need to add one line to your `vimrc` instead of other settings:

    source '{path to the script}' '{script name}'

The Vim script `demo/myVars.vim` provides an example for loading variables.

