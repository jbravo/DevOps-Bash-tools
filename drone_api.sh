#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-15 23:27:44 +0100 (Sat, 15 Aug 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

#  args: /user | jq -C .
#  args: /user/repos | jq -C .
#  args: /repos/HariSekhon/DevOps-Bash-tools/builds | jq -C .

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC1090
. "$srcdir/lib/git.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Queries the Drone.io API

Can specify \$CURL_OPTS for options to pass to curl, or pass them as arguments to the script

Automatically handles authentication via environment variable \$DRONE_TOKEN


Get your personal access token here:

https://cloud.drone.io/account


API Reference:

https://docs.drone.io/api/overview/


Examples:


# Get currently authenticated user:

${0##*/} /user


# List repos registered in Drone:

${0##*/} /user/repos


# List your Drone builds for a repo (case sensitive):

${0##*/} /repos/{owner}/{repo}/builds
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="/path [<curl_options>]"

url_base="https://cloud.drone.io/api"

CURL_OPTS="-sS --fail --connect-timeout 3 ${CURL_OPTS:-}"

help_usage "$@"

min_args 1 "$@"

url_path="${1:-}"
shift

url_path="${url_path##*:\/\/cloud.drone.io\/api}"
url_path="${url_path##/}"
url_path="${url_path##api}"

# need CURL_OPTS splitting, safer than eval
# shellcheck disable=SC2086
if is_curl_min_version 7.55; then
    # this trick doesn't work, file descriptor is lost by next line
    #filedescriptor=<(cat <<< "Private-Token: $DRONE_TOKEN")
    curl $CURL_OPTS -H @<(cat <<< "Authorization: Bearer $DRONE_TOKEN") "$url_base/$url_path" "$@"
else
    # could also use OAuth compliant header "Authorization: Bearer <token>"
    curl $CURL_OPTS -H "Authorization: Bearer $DRONE_TOKEN" "$url_base/$url_path" "$@"
fi
