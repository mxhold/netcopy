# netcopy

[![Build Status](https://travis-ci.org/mxhold/netcopy.svg?branch=master)](https://travis-ci.org/mxhold/netcopy)
[![Code Climate](https://codeclimate.com/github/mxhold/netcopy/badges/gpa.svg)](https://codeclimate.com/github/mxhold/netcopy)
[![Test Coverage](https://codeclimate.com/github/mxhold/netcopy/badges/coverage.svg)](https://codeclimate.com/github/mxhold/netcopy/coverage)

netcopy is a very simple pastebin service written in Ruby.

## Getting started

    git clone https://github.com/mxhold/netcopy.git
    cd netcopy
    bundle

To run the tests, run:

    bin/rake

To start the server at <http://localhost:8080>, run:

    bin/unicorn

## Usage

    $ echo "hello, world" | curl http://localhost:8080 --data-binary @-
    http://localhost:8080/3cdf55b6-2ffe-42c9-97be-d94ef66e58c6

    $ curl http://localhost:8080/3cdf55b6-2ffe-42c9-97be-d94ef66e58c6
    hello, world

## Client

For added convenience, run `bin/install` to create a wrapper around the above
cURL command.

After installing, you can now use the service more simply:

    $ echo "hello, world" | netcopy

To specify a URL for the netcopy service other than `http://localhost:8080`, use
`NETCOPY_URL=http://example.org bin/install` when installing or use
`NETCOPY_URL=http://example.org netcopy` when running.

By default, this will be installed to `/usr/local/bin` but another path can be
provided to the install script like: `PREFIX=/home/max/bin bin/install`.

