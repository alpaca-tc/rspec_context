let s:spec_files = {}

function! rspec_context#spec_file#get(path)
  let full_path = expand(a:path)

  if has_key(s:spec_files, full_path)
    return s:spec_files[full_path]
  else
    let spec_file = s:SpecFile.new(full_path)
    let s:spec_files[full_path] = spec_file

    return spec_file
  endif
endfunction

let s:SpecFile = {
      \ 'last_updated_at': '',
      \ 'path': '',
      \ 'tree': '',
      \ 'success': 0,
      \ }

function! s:SpecFile.new(path) abort
  let spec_file = deepcopy(s:SpecFile)
  let spec_file.path = a:path

  return spec_file
endfunction

function! s:SpecFile.setNodeLines(node_lines) abort
  let self.node_lines = a:node_lines
endfunction

function! s:SpecFile.getTree(force) abort
  if a:force || empty(self.tree)
    let self.tree = rspec_context#api#tree(self.path)
    let self.node_lines = {}
    let self.success = !empty(self.tree)
    let self.last_updated_at = rspec_context#util#reltime()
  end

  return self.tree
endfunction
