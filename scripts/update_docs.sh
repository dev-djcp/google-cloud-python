#!/bin/bash

# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ev

# Build new docset in docs/_build from master.
tox -e docs
git submodule add -b gh-pages \
    "https://${GH_OAUTH_TOKEN}@github.com/${GH_OWNER}/${GH_PROJECT_NAME}" \
    ghpages
cp -R docs/_build/html/* ghpages/
cd ghpages
# allow "git add" to fail if there aren't new files.
set +e
git add .
set -e
git status
# H/T: https://github.com/dhermes
if [[ -n "$(git status --porcelain)" ]]; then
    # Commit to gh-pages branch to apply changes.
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "travis-ci"
    git commit -m "Update docs after merge to master."
    git push \
        "https://${GH_OAUTH_TOKEN}@github.com/${GH_OWNER}/${GH_PROJECT_NAME}" \
        HEAD:gh-pages
else
    echo "Nothing to commit. Exiting without pushing changes."
fi
