let s:bin = expand('<sfile>:p:h:h:h:h') . '/bin/rspec_context'
let s:V = vital#rspec_context#new()
let s:JSON = s:V.import('Web.JSON')

function! s:execute(path)
  let response = system(join([s:bin, '--file_path', a:path, ' 2> /dev/tty']))

  try
    return s:JSON.decode(response)
  catch /.*/
    return ''
  endtry
endfunction

function! rspec_context#api#tree(path)
  let path = expand(a:path)
  return s:execute(path)
endfunction
