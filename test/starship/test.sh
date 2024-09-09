#!/bin/bash

set -e

source dev-container-features-test-lib

check "Info: starship version" starship -V

reportResults