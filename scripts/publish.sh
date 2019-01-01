#!/bin/bash

# Run from root.

rm -fr ./docs
rm -fr ./public

mkdir docs

hugo

cp -R ./public/. ./docs/.
