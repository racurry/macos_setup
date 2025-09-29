# Testing Strategy

## Four main goals

- Test suite for ./scripts/ and ./lib/
- A github action workflow that can run the tests
- A github action workflow that can run the actual scripts against a VM or docker image directly.  (This might not be possible, I do not know)
- A local ability to fully run ./setup.sh against a macos vm using UTM.  This can be manual,but ideally we automate it as much as possible.  This is just so we can see how the setup works against a truly fresh machine.

## Test Suite

These are linters and unit tests for any ./scripts/ or ./lib/ file.  Note this is a polyglot repo, so we will need to use different linters and test frameworks for different languages.

One entry point, .test.sh should run all tests

The main point of this repo is utility.  Tests that do not add value should be not be added.  Tests that require extensive mocking of external commands should be removed.  Tests that are too complex to maintain should be removed.  The goal is to have a lightweight test suite that can be run quickly and easily, and that provides value.

## Github actions for tests

A github action workflow should run the test suite on every PR and push to main.  It should run on macos if possible, ubuntu otherwise.  It should collect artifacts of the test runs, and report any failures.

## Github actions setup run

A github action workflow should run the actual setup scripts against a macos runners.  This is to ensure that the scripts actually work in a realistic environment.  This might not be possible, but if it is, it should be done.

## Local UTM setup run

A script should be provided to run the setup scripts against a local macos vm using UTM.  This is to allow for manual testing of the setup scripts against a fresh macos installation.  The script should be as automated as possible, but it can require some manual setup of the vm.  This does NOT need to run in a CI environment.
