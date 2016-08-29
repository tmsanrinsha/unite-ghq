#!/usr/bin/env bash

# .gitの更新時刻でソートされたghqのディレクトリを取得する
# .gitがない場合は更新時刻を0とする

while getopts f OPT; do
  case ${OPT} in
    f) full_path=1;;
  esac
done

ghq_roots="$(git config --path --get-all ghq.root)"

for dir in $(ghq list --full-path)
do
    if [ -d "$dir/.git" ]; then
        stdout="$stdout\n$(ls -dl --time-style=+%s "$dir/.git" | sed 's/.*\([0-9]\{10\}\)/\1/' | sed 's/\/.git//')"
    else
        stdout="$stdout\n$(echo 0 "$dir")"
    fi
done

stdout="$(echo -e "$stdout" | sort -nr | sed 's/^[0-9]\+ //')"
if [ -z "$full_path" ]; then
    echo "$stdout" | sed "s@\(${ghq_roots//$'\n'/\\|}\)/@@"
else
    echo "$stdout"
fi
