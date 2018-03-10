#!/bin/bash

# Fast fail the script on failures.
set -e

# Verify the
if [ "${TRAVIS_DART_VERSION}" = "dev" ]; then
  dart --preview-dart-2 test/all_tests.dart
fi

# Verify the coverage of the tests.
if [ "${COVERALLS_TOKEN}" ] && [ "${TRAVIS_DART_VERSION}" = "stable" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token "${COVERALLS_TOKEN}" \
    --retry 2 \
    --exclude-test-files \
    test/all_tests.dart
fi
