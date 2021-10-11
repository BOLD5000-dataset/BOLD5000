#!/bin/bash
#
# Collects the pull-requests since the latest release and
# aranges them in the CHANGES.rst.txt file.
#
# This is a script to be run before releasing a new version.
#
# Usage /bin/bash update_changes.sh 1.0.1
#
# This script was originally developed by the nipreps developers.
# For the full LICENSE and terms of use, see https://github.com/nipreps/dmriprep/blob/master/LICENSE
#

# Setting      # $ help set
set -u         # Treat unset variables as an error when substituting.
set -x         # Print command traces before executing command.

# Check whether the Upcoming release header is present
head -1 CHANGES.rst | grep -q Upcoming
UPCOMING=$?
if [[ "$UPCOMING" == "0" ]]; then
    head -n3  CHANGES.rst >> newchanges
fi

# Elaborate today's release header
HEADER="$1 ($(date '+%B %d, %Y'))"
echo $HEADER >> newchanges
echo $( printf "%${#HEADER}s" | tr " " "=" ) >> newchanges

# Search for PRs since previous release
git log --grep="Merge pull request" `git describe --tags --abbrev=0`..HEAD --pretty='format:  * %b %s' | sed  's/Merge pull request \#\([^\d]*\)\ from\ .*/(\#\1)/' >> newchanges
echo "" >> newchanges
echo "" >> newchanges

# Add back the Upcoming header if it was present
if [[ "$UPCOMING" == "0" ]]; then
    tail -n+4 CHANGES.rst >> newchanges
else
    cat CHANGES.rst >> newchanges
fi

# Replace old CHANGES.rst with new file
mv newchanges CHANGES.rst

