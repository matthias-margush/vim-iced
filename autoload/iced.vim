let s:save_cpo = &cpo
set cpo&vim

function! iced#status() abort
  if !iced#nrepl#is_connected()
    return 'not connected'
  endif

  if iced#nrepl#is_evaluating()
    return 'evaluating'
  else
    return printf('%s repl', iced#nrepl#current_session_key())
  endif
endfunction

function! s:json_resp(resp) abort
  try
    let resp = copy(a:resp)
    if has_key(a:resp, 'value')
      let value = a:resp['value']
      let value = (stridx(value, '"') == 0) ? json_decode(value) : value
      let resp['value'] = json_decode(value)
    endif
    return resp
  catch
    return {}
  endtry
endfunction

function! iced#eval_and_read(code, ...) abort
  let msg = {
      \ 'id': iced#nrepl#id(),
      \ 'op': 'eval',
      \ 'code': printf('(try (require ''clojure.data.json) (clojure.data.json/write-str %s) (catch Exception ex))', a:code),
      \ 'session': iced#nrepl#current_session(),
      \ }
  let Callback = get(a:, 1, '')
  if iced#util#is_function(Callback)
    let msg['callback'] = {resp -> Callback(s:json_resp(resp))}
    call iced#nrepl#send(msg)
  else
    return s:json_resp(iced#nrepl#sync#send(msg))
  endif
endfunction

function! iced#selector(config) abort
  call iced#di#get('selector').select(a:config)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
