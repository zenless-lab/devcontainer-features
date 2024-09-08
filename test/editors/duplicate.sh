#!/bin/bash

set -e

source dev-container-features-test-lib

check "Info: emacs version" emacs --version
check "Info: nano version" nano --version
check "Info: vim version" vim --version

reportResults
