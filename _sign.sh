#!/bin/sh

# Copyright 2016-2018 Viktor Szakats <https://vszakats.net/>
# See LICENSE.md

if [ -f "${CODESIGN_KEY}" ] && \
   ls "$(dirname "$0")/osslsigncode-determ"* > /dev/null 2>&1; then

  # Detect host OS
  case "$(uname)" in
    *_NT*)   os='win';;
    Linux*)  os='linux';;
    Darwin*) os='mac';;
    *BSD)    os='bsd';;
  esac

  _ref="$1"
  shift

  case "${os}" in
    bsd|mac) unixts="$(TZ=UTC stat -f '%m' "${_ref}")";;
    *)       unixts="$(TZ=UTC stat -c '%Y' "${_ref}")";;
  esac

  # Add code signature
  for file in $@; do
  (
    set +x
    # -ts 'http://timestamp.digicert.com'
    "$(dirname "$0")/osslsigncode-determ" sign -h sha256 \
      -in "${file}" -out "${file}-signed" \
      -st "${unixts}" \
      -pkcs12 "${CODESIGN_KEY}" -pass "${CODESIGN_KEY_PASS}"
    mv -f "${file}-signed" "${file}"
  )
  done
fi
