let s:buffer_seqno = 0
let s:new_window = 0

function! s:buf_name() abort
  if !exists('t:rspec_context_buf_name')
    let s:buffer_seqno += 1
    let t:rspec_context_buf_name = '__rspec_context__' . s:buffer_seqno
  endif

  return t:rspec_context_buf_name
endfunction

function! s:goto_win(winnr, ...) abort
  let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w' : 'wincmd ' . a:winnr
  let noauto = a:0 > 0 ? a:1 : 0

  if noauto
    noautocmd execute cmd
  else
    execute cmd
  endif
endfunction

function! s:highlight() abort
endfunction

function! s:init(flag)
  return 1
endfunction

function! s:open_tab() abort
  let current_file = fnamemodify(bufname('%'), ':p')
  let current_line = line('.')

  let winnr = bufwinnr(s:buf_name())

  if winnr != -1
    if winnr() != winnr
      call s:goto_win(winnr)
      call s:highlight()
    endif

    return
  endif

  let previous_win_id = win_getid()

  if winnr('$') > 1
    call s:goto_win('p', 1)
    let pprevious_win_id = win_getid()
    call s:goto_win('p', 1)
  endif

  if !s:init(0)
    return 0
  endif

  let mode = 'vertical'
  let open = 'botright'
  let width = 50 " TODO: config

  execute join(['silent keepalt', open, mode, width, 'split', s:buf_name()])
  execute join(['silent', mode, 'resize', width])

  call s:initialize_window()

  call s:auto_update(current_file)
  call s:highlight()

  if exists('pprevious_win_id')
    noautocmd call win_gotoid(pprevious_win_id)
  endif

  call win_gotoid(previous_win_id)
endfunction

" s:initialize_window() {{{2
function! s:initialize_window() abort
  setlocal filetype=rspec_context
  setlocal noreadonly " in case the "view" mode is used
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodifiable
  setlocal textwidth=0

  " Window-local options
  setlocal nolist
  setlocal nowrap
  setlocal winfixwidth
  setlocal nospell

  setlocal nonumber
  setlocal norelativenumber
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal foldmethod&
  setlocal foldexpr&

  call s:set_line_status()

  let s:new_window = 1

  let cpoptions_save = &cpoptions
  set cpoptions&vim

  if !exists('b:rspec_context_mapped_keys')
    call s:mapping_keys()
  endif

  let &cpoptions = cpoptions_save
endfunction

function! s:jump_to_line()
  let spec_file = rspec_context#state#get_current_file().getCurrent()
  let line = line('.') - 1

  if empty(spec_file.node_lines)
    return
  elseif has_key(spec_file.node_lines, line)
    let node = spec_file.node_lines[line]
    let nextLine = node.rspec_method.line_no + 1
  endif
endfunction

function! s:mapping_keys() abort
  if exists('b:rspec_context_mapped_keys')
    return
  endif

  let maps = [
        \ ['<CR>', 'jump_to_line()'],
        \ ]

  let map_options = '<script><silent><buffer><nowait>'

  for [map, func] in maps
    execute 'nnoremap' . map_options . ' ' . map . ' :call <SID>' . func . '<CR>'
  endfor

  augroup RSpecContext
    " 先頭に移動する
    " autocmd CursorMoved <buffer> :execute '^'<CR>
  augroup END

  let b:rspec_context_mapped_keys = 1
endfunction

" " s:close_window() {{{2
" function! s:close_window() abort
"   let winnr = bufwinnr(s:buf_name())
"   if winnr == -1
"     return
"   endif
"
"   " Close the preview window if it was opened by us
"   if s:pwin_by_rspec_context
"     pclose
"     let winnr = bufwinnr(s:buf_name())
"   endif
"
"   if winnr() == winnr
"     if winbufnr(2) != -1
"       " Other windows are open, only close the rspec_context one
"
"       let current_file = rspec_context#state#get_current_file(0)
"
"       close
"
"       " Try to jump to the correct window after closing
"       call s:goto_win('p')
"
"       if !empty(current_file)
"         let filebufnr = bufnr(current_file.fpath)
"
"         if bufnr('%') != filebufnr
"           let filewinnr = bufwinnr(filebufnr)
"           if filewinnr != -1
"             call s:goto_win(filewinnr)
"           endif
"         endif
"       endif
"     endif
"   else
"     " Go to the rspec_context window, close it and then come back to the original
"     " window. Save a win-local variable in the original window so we can
"     " jump back to it even if the window number changed.
"     call s:mark_window()
"     call s:goto_win(winnr)
"     close
"
"     call s:goto_markedwin()
"   endif
"
"   call s:ShrinkIfExpanded()
"
"   " The window sizes may have changed due to the shrinking happening after
"   " the window closing, so equalize them again.
"   if &equalalways
"     wincmd =
"   endif
"
"   if s:autocommands_done && !s:statusline_in_use
"     autocmd! TagbarAutoCmds
"     let s:autocommands_done = 0
"   endif
" endfunction

function! s:auto_update(file_path) abort
  let bufnr = bufnr(a:file_path)
  let file_type = getbufvar(bufnr, '&filetype')

  if file_type == 'rspec_context'
    return
  endif

  let spec_file = get(split(file_type, '\.'), 0, '')

  if a:file_path !~ '_spec.rb$'
    return
  endif

  let current_state = rspec_context#state#get_current_file()
  let spec_file = rspec_context#spec_file#get(a:file_path)
  call current_state.setCurrent(spec_file)

  let rspec_context = spec_file.getTree(1)

  if empty(rspec_context)
    return
  endif

  let node_lines = s:render_content(rspec_context)
  call spec_file.setNodeLines(node_lines)

  call s:highlight()
  call s:set_line_status()
endfunction

function! s:render_content(rspec_context)
  let s:new_window = 0
  let rspec_context = a:rspec_context

  let rspec_contextwinnr = bufwinnr(s:buf_name())

  if &filetype == 'rspec_context'
    let in_rspec_context = 1
  else
    let in_rspec_context = 0
    let prevwinnr = winnr()

    call s:goto_win('p', 1)
    let pprevwinnr = winnr()
    call s:goto_win(rspec_contextwinnr, 1)
  endif

  " if !empty(rspec_context#state#get_current_file()) && rspec_context.path ==# rspec_context#state#get_current_file().fpath
  "   let saveline = line('.')
  "   let savecol  = col('.')
  "   let topline  = line('w0')
  " endif

  let lazyredraw_save = &lazyredraw
  set lazyredraw
  let eventignore_save = &eventignore
  set eventignore=all

  setlocal modifiable

  silent %delete _

  if empty(rspec_context)
    silent 0put ='No spec found.'
    return
  else
    let node_lines = s:print_node(rspec_context)
  endif

  " Delete empty lines at the end of the buffer
  for linenr in range(line('$'), 1, -1)
    if getline(linenr) =~ '^$'
      execute 'silent ' . linenr . 'delete _'
    else
      break
    endif
  endfor

  setlocal nomodifiable

  " if !empty(rspec_context#state#get_current_file()) && rspec_context.fpath ==# rspec_context#state#get_current_file().fpath
  "   let scrolloff_save = &scrolloff
  "   set scrolloff=0
  "
  "   call cursor(topline, 1)
  "   normal! zt
  "   call cursor(saveline, savecol)
  "
  "   let &scrolloff = scrolloff_save
  " else
  "   execute 1
  "   call winline()
  "
  "   let s:last_highlight_tline = 0
  " endif

  let &lazyredraw  = lazyredraw_save
  let &eventignore = eventignore_save

  if !in_rspec_context
    call s:goto_win(pprevwinnr, 1)
    call s:goto_win(prevwinnr, 1)
  endif

  return node_lines
endfunction

function! s:parse_node(node, indent, output, node_lines) abort
  let node = a:node
  let indent = a:indent
  let output = a:output
  let node_lines = a:node_lines

  let rspec_method = node.rspec_method
  let method_name = rspec_method.method_name
  let source_method = method_name == 'it' || method_name == 'subject'

  if method_name == 'let'
    return
  endif

  if source_method && empty(rspec_method.arguments)
    let lines = split(rspec_method.source, "\n")
    let line = lines[0]

    if len(lines) > 1
      let line = line . '...'
    endif
  else
    let line = rspec_method.method_name . '(' . join(rspec_method.arguments, ',') . ')'
  endif

  let with_indent = repeat('  ', indent) . line

  let node_lines[len(output)] = node
  call add(output, with_indent)

  if !empty(a:node.children)
    for child_node in node.children
      call s:parse_node(child_node, indent + 1, output, node_lines)
    endfor
  endif

  return [output, node_lines]
endfunction

function! s:print_node(node) abort
  let [output, node_lines] = s:parse_node(a:node, 0, [], {})

  let outstr = join(output, "\n")
  silent 0put =outstr

  return node_lines
endfunction

function! s:process_file(file_path, file_type)
endfunction

function! s:set_line_status()
endfunction

function! rspec_context#tree#open_tab()
  call s:open_tab()
endfunction
