function! rspec_context#state#get_current_file()
  if !exists('t:rspec_context_state')
    let t:rspec_context_state = s:RSpecContext.new()
  endif

  return t:rspec_context_state
endfunction

let s:RSpecContext = {
      \ '_current' : {}
      \ }

function! s:RSpecContext.new() abort dict
  return deepcopy(self)
endfunction

function! s:RSpecContext.getCurrent() abort dict
  return self._current
endfunction

function! s:RSpecContext.setCurrent(rspec_context)
  let self._current = a:rspec_context
endfunction
