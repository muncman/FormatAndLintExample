#!/bin/sh
### Purpose:
#
# Sets the commit count to the git revision number.
#     This helps with keeping versions distinct in tools like TestFlight, Crashlytics, HockeyApp,
#     and can be used as a form of build number.
# Sets the current git commit SHA in the app, including marking it with a "+" suffix
#     if there are uncommited changes.
#     This helps with traceability.
# Sets the date and time of the build to the month, day, hour, and minutes (no seconds).
#     This makes checking for the freshness of a build more human-friendly.
# Sets other version information from the environment at build time.
#     This make this info available to help with troubleshooting. 
#
# This uses prefixes (error:, warning:, note:) for some echo statements for Xcode parsing. 

### One-time set up:
#
## For Visual Studio Code: 
#
# 0. Uncomment the Flutter and Dart lines in this script, and change output from Info.plist to a Dart file.
# 1. Create a tasks.json file (next to vscode's launch.json, usually in the workspace's .vscode directory).
# 2. Put this task definition into it: 
# {
#     "type": "shell",
#     "command": "./scripts/build_versioning.sh",
#     "args": [],
#     "group": {
#         "kind": "build",
#         "isDefault": true
#     },
#     "problemMatcher": [],
#     "label": "flutter: build versioning"
# }
# 3. Add `"preLaunchTask": "flutter: build versioning"` to launch.json configuration(s) to reference the task.
#
#
## For Android Studio / Jetbrains IDEs:
#
# 0. Uncomment the Flutter and Dart lines in this script, and change output from Info.plist to a Dart file.
# 1. Go to `Run > Edit Configurations`
# 2. Add a new shell script / external tool configuration to invoke this script.
# 3. Configure our normal configuration(s) with a `Before Launch` to invoke the new shell script config.
#
#
## For Xcode: 
#
# 1. Enable "Preprocess Info.plist File" (INFOPLIST_PREPROCESS) in the primary target's
# Build Settings (under the "Packaging" section, with 'All' settings visible).
#
# 2. Set "Info.plist Preprocessor Prefix File" (INFOPLIST_PREFIX_HEADER) to InfoPlist.h.
#
# 3. Add InfoPlist.h to the project's git ignore file (as it is generated here).
#
# 4. Add a new Other | Aggregate target with a 'Build Phases - Run Script' of "./Scripts/build_versioning.sh".
#
# 5. Add the new target as a dependency of the primary build target (under 'Build Phases').
#
# 6. Add XKEY_BUILD_NUMBER:X_GIT_COMMIT_COUNT as a string value to your Info.plist
# (key from VersionHelper, value as the plain name of the #define below).
#
# 7. Repeat step 6 for the other values.
#
# This is being used with VersionHelper.swift for display in the UI. 

echo "note: Executing $0 $*"

# Ensure that Homebrew (Intel and Apple Silicon) and Mint are on the PATH. 
PATH="/usr/local/bin/:/opt/homebrew/:$HOME/.mint/bin/:$PATH"

# Refresh local git status
git fetch origin --unshallow --no-tags -q > /dev/null 2>&1

# Get dynamic values. 
#
# Some require a little additional processing,
# such as combining multiple lines into a single line, 
# extracting portions of the command output, 
# or trimming trailing whitespace or periods.

if hash flutter 2>/dev/null; then
    flutter_version=$(flutter --version | sed -n 's/^\(Flutter\ [0-9\.a-z-]*\)\ .*$/\1/p')
    dart_version=$(flutter --version | sed -n 's/Tools.*\(Dart\ [^\ ]*\).*$/\1/p')
else
    echo "Flutter not installed (or not on PATH)"
fi

if hash java 2>/dev/null; then
    java_version=$(TEMP="$(java --version | perl -pe's/\n/ /g' | perl -pe'chop')" && echo "$TEMP")
else
    echo "Java not installed (or not on PATH)"
fi

utc_build_date=$(date -u '+%Y/%m/%d')
utc_build_time=$(date -u '+%H:%M')
rev_number=$(git rev-list --count HEAD)
git_hash=$(git rev-parse --short HEAD)
git_branch=$(git rev-parse --abbrev-ref HEAD)
uname_info=$(uname -a)
xcrun_version=$(xcrun --version | perl -pe's/\.$//g' | perl -pe's/.*version\ (.*)/$1/')
xcode_select_version=$(xcode-select --version | perl -pe's/\.$//g' | perl -pe's/.*version\ (.*)/$1/')
xcode_build_version=$(TEMP="$(xcodebuild -version | perl -pe's/\n/ /g' | perl -pe'chop')" && echo "$TEMP")
clang_version=$(TEMP="$(clang --version | perl -pe's/\n/ /g' | perl -pe'chop')" && echo "$TEMP")
pkgutil_info=$(TEMP="$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | perl -pe's/\n/ /g' | perl -pe'chop' | perl -pe'chop')" && echo "$TEMP")
env_info=$(TEMP="$(env | perl -pe's/\n/ /g' | perl -pe'chop')" && echo "$TEMP")

echo "note: BUILD VERSIONING:"
echo "note:    utc_build_date = $utc_build_date"
echo "note:    utc_build_time = $utc_build_time"
echo "note:    rev_number = $rev_number"
echo "note:    git_hash = $git_hash"
echo "note:    git_branch = $git_branch"
echo "note:    xcrun_version = $xcrun_version"
echo "note:    xcode_select_version = $xcode_select_version"
echo "note:    xcode_build_version = $xcode_build_version"
echo "note:    clang_version = $clang_version"
echo "note:    pkgutil_info = $pkgutil_info"
echo "note:    uname_info = $uname_info"
echo "note:    env_info = $env_info"
echo "    flutter_version = $flutter_version"
echo "    dart_version = $dart_version"
echo "    java_version = $java_version"

if ! [ "$PROJECT_NAME" ]; then
    echo "error: PROJECT_NAME not defined."
    echo "error: This must be run from within Xcode (or have PROJECT_NAME manually defined)."
    echo "error: Aborting"
    exit 1
fi

# TODO: flip on this or the other
generate_dart_file()
{
    scripts_dir=$(dirname "$0")
    # Use this auto-generated and git-ignored file at runtime to access these build-time values.
    output_file="$scripts_dir/../lib/GeneratedInfo.dart"
    {
        echo "/// This file is generated. Do not edit." 
        echo "///" 
        echo "/// See Scripts/build_versioning.sh for details." 
        echo "struct GeneratedInfo {" 
    } > "$output_file";
    if [ "$(git status | grep "nothing to commit" > /dev/null 2>&1;)" = "0" ]; then
        echo "  static const String X_GIT_HASH = '$git_hash+';" >> "$output_file";
    else
        echo "  static const String X_GIT_HASH = '$git_hash';" >> "$output_file";
    fi
    {
        echo "  static const String X_GIT_COMMIT_COUNT = '$rev_number';"
        echo "  static const String X_GIT_BRANCH = '$git_branch';"
        echo "  static const String X_BUILD_DATE = '$utc_build_date';"
        echo "  static const String X_BUILD_TIME = '$utc_build_time';"
        echo "  static const String X_FLUTTER_VERSION = '$flutter_version';"
        echo "  static const String X_DART_VERSION = '$dart_version';"
        echo "}"
    } >> "$output_file";

    echo "note: Wrote to '$output_file'"
}

generate_header_file()
{
    scripts_dir=$(dirname "$0")

    # Use this auto-generated and git-ignored file (with VersionHelper.swift) at runtime to access these build-time values.
    # This has the advantage of avoiding changes in git for simple version updates, 
    # compared to direct Plist modification via PListBuddy.
    output_file="$scripts_dir/../InfoPlist.h"
    {
        echo "// This file is generated. Do not edit." 
        echo "//" 
        echo "// See Scripts/build_versioning.sh for details." 
        echo " "
    } > "$output_file";
    if [ "$(git status | grep "nothing to commit" > /dev/null 2>&1;)" = "0" ]; then
        echo "#define X_GIT_HASH $git_hash+" >> "$output_file";
    else
        echo "#define X_GIT_HASH $git_hash" >> "$output_file";
    fi
    {
        echo "#define X_UTC_BUILD_DATE $utc_build_date"
        echo "#define X_UTC_BUILD_TIME $utc_build_time"
        echo "#define X_GIT_COMMIT_COUNT $rev_number"
        echo "#define X_GIT_BRANCH $git_branch"
        echo "#define X_XCRUN_VERSION $xcrun_version"
        echo "#define X_XCODE_SELECT_VERSION $xcode_select_version"
        echo "#define X_XCODE_BUILD_VERSION $xcode_build_version"
        echo "#define X_CLANG_VERSION $clang_version"
        echo "#define X_PKGUTIL_INFO $pkgutil_info"
        echo "#define X_UNAME_INFO $uname_info"
        echo "#define X_ENV_INFO $env_info"
        echo "#define CURRENT_PROJECT_VERSION $rev_number"
        echo ""
    } >> "$output_file";

    # Let Xcode know that the PList has changed so it will reload it, expanding with the updated values.
    touch "$scripts_dir/../$PROJECT_NAME/Info.plist"

    echo "note: Wrote to '$output_file'"
}

generate_header_file
