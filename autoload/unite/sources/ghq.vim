let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
 \  'name': 'ghq',
 \  'default_action': { '*': 'lcd' },
 \  'default_kind': 'directory'
 \ }


if exists('g:unite_ghq_command')
  let s:ghq_command = g:unite_ghq_command
else
  let s:ghq_command = "ghq"
endif

function! s:ghq_roots()
  return map(
        \ split(unite#util#system('git config --path --get-all ghq.root'), "\n"),
        \ 'resolve(expand(v:val)). "\/"'
        \ ) 
endfunction

function! s:ghq_root_prefix_pattern()
  let l:roots = s:ghq_roots()
  if !empty(l:roots)
    return "\\V" . join(l:roots, "\\|")
  else
    return "\\V" . expand('~/.ghq') . "\/"
  endif
endfunction

function! unite#sources#ghq#define()
  return s:unite_source
endfunction

function! s:unite_source.gather_candidates(args, context)
  let l:root_pat = s:ghq_root_prefix_pattern()
  " リポジトリの.gitの更新時間でソートする
  return map(
    \   split(system('ghq list --full-path | xargs -I{} ls -dl --time-style=+%s {}/.git | sed ''s/.*\([0-9]\{10\}\)/\1/'' | sort -nr | cut -d'' '' -f2 | sed ''s/\/.git//'''), "\n"),
    \   '{
    \     "word": substitute(v:val, l:root_pat, "", ""),
    \     "action__directory": fnamemodify(v:val, ":p:h"),
    \     "action__path": v:val
    \   }'
    \ )
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
