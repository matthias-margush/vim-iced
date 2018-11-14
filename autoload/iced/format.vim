let s:save_cpo = &cpo
set cpo&vim

let g:iced#format#rule = get(g:, 'iced#format#rule', {})

function! s:formatting_options(ns_name) abort
  return {
        \ 'indents': g:iced#format#rule,
        \ 'alias-map': iced#nrepl#ns#alias_dict(a:ns_name),
        \ }
endfunction

function! iced#format#form() abort
  if !iced#nrepl#is_connected()
    silent exe "normal \<Plug>(sexp_indent)"
    return
  endif

  let view = winsaveview()
  let reg_save = @@
  let ns_name = iced#nrepl#ns#name()

  try
    let res = iced#paredit#get_current_top_list_raw()
    let code = res['code']
    if empty(code)
      call iced#message#warning('finding_code_error')
    else
      let options = s:formatting_options(ns_name)
      let resp = iced#nrepl#op#cider#sync#format_code(code, options)
      if has_key(resp, 'formatted-code') && !empty(resp['formatted-code'])
        let @@ = resp['formatted-code']
        silent normal! gvp
      elseif has_key(resp, 'error')
        call iced#message#error_str(resp['error'])
      endif
    endif
  finally
    let @@ = reg_save
    call winrestview(view)
    call iced#sign#refresh()
  endtry
endfunction

function! iced#format#minimal() abort
  if !iced#nrepl#is_connected()
    silent exe "normal \<Plug>(sexp_indent)"
    return
  endif

  let view = winsaveview()
  let reg_save = @@
  let ns_name = iced#nrepl#ns#name()
  try
    " NOTE: vim-sexp's slurp move cursor to tail of form
    normal! %
    let ncol = max([col('.')-1, 1])

    let char = getline('.')[ncol]
    if char ==# '['
      silent normal! va[y
    elseif char ==# '{'
      silent normal! va{y
    else
      silent normal! va(y
    endif
    let code = @@
    let options = s:formatting_options(ns_name)
    let resp = iced#nrepl#op#cider#sync#format_code(code, options)
    if has_key(resp, 'formatted-code') && !empty(resp['formatted-code'])
      let @@ = iced#util#add_indent(ncol, resp['formatted-code'])
      silent normal! gvp
    endif
  finally
    let @@ = reg_save
    call winrestview(view)
  endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
