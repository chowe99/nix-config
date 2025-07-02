#!/usr/bin/env bash
# cat-files.sh: Cat all files in a directory with optional include and ignore lists

set -euo pipefail

usage() {
  cat <<EOF
Usage: ${0##*/} [options] <directory>

Options:
  -i "list"   Space-separated list of files or directories (relative to <directory>) to include.
               If omitted, all files under <directory> are considered.
  -e "list"   Space-separated list of files or directories to ignore (relative to <directory>).
  -h          Show this help message and exit.

Example:
  ${0##*/} -i "nix-config/ k3s.txt" -e "secret.txt temp/" ~/projects
EOF
  exit 1
}

# Parse flags
includes=()
ignores=()
while getopts ":i:e:h" opt; do
  case $opt in
  i) IFS=' ' read -r -a includes <<<"$OPTARG" ;;
  e) IFS=' ' read -r -a ignores <<<"$OPTARG" ;;
  h) usage ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    usage
    ;;
  esac
done
shift $((OPTIND - 1))

# Ensure directory argument
if [[ $# -ne 1 ]]; then
  usage
fi

dir=${1%/}
if [[ ! -d $dir ]]; then
  echo "Error: Directory '$dir' does not exist or is not a directory." >&2
  exit 2
fi

# Build initial file list
files=()
if [[ ${#includes[@]} -gt 0 ]]; then
  for inc in "${includes[@]}"; do
    path="$dir/${inc%/}"
    if [[ -d $path ]]; then
      while IFS= read -r -d $'' f; do
        files+=("$f")
      done < <(find "$path" -type f -print0)
    elif [[ -f $path ]]; then
      files+=("$path")
    else
      echo "Warning: Include path '$inc' not found under '$dir', skipping." >&2
    fi
  done
else
  while IFS= read -r -d $'' f; do
    files+=("$f")
  done < <(find "$dir" -type f -print0)
fi

# Apply ignores
if [[ ${#ignores[@]} -gt 0 ]]; then
  filtered=()
  for f in "${files[@]}"; do
    skip=false
    for ign in "${ignores[@]}"; do
      ignpath="$dir/${ign%/}"
      if [[ $f == "$ignpath"* ]]; then
        skip=true
        break
      fi
    done
    $skip || filtered+=("$f")
  done
  files=("${filtered[@]}")
fi

# Cat each file
for f in "${files[@]}"; do
  echo "==== $f ===="
  cat "$f"
  echo
done
