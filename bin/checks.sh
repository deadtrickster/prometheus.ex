#!/bin/sh

MIX_ENV=test mix credo --strict && MIX_ENV=test mix test
