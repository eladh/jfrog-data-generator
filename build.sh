#!/bin/bash

BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PACKAGES_DIR=$BUILD_DIR/packages
COMMAND=$1
PACKAGE=$2

source $BUILD_DIR/env.setup


display_usage() {
    echo "Usage: build.sh [build|list|help] [{package}]"
    echo "    build - Builds all the package types (default) or a specific package if specified"
    echo "    list - Lists all the different package types"
    echo "    help - This help message"
}

list_packages() {
    echo "Package Types: "
    for dir in $PACKAGES_DIR/*/
    do
        dir=${dir%*/}
        echo "${dir##*/}"
    done
}

list_packages() {
    echo "Package Types: "
    for dir in $PACKAGES_DIR/*/
    do
        dir=${dir%*/}
        echo "    ${dir##*/}"
    done
}

build_package() {
    echo "Package Types: $1 "
    PACKAGE_TO_BUILD=$1
    PACKAGE_DIR=$PACKAGES_DIR/$PACKAGE_TO_BUILD
    echo "Building $PACKAGE_TO_BUILD"
    # Copy in shared tools
    \cp -rf $BUILD_DIR/shared/* $PACKAGE_DIR/.
    # Build the image
    cd $PACKAGE_DIR
    IMAGE_NAME=$IMAGE_NAMESPACE_NAME/$PACKAGE_TO_BUILD
    docker build -t "$IMAGE_NAME:$VERSION" .
    docker push "$IMAGE_NAME:$VERSION"
}
build_packages() {
    # If no package set, do all
    if [ -z "$PACKAGE" ]
    then
        echo "Building all"
        for dir in $PACKAGES_DIR/*/
        do
            dir=${dir%*/}
            build_package ${dir##*/}
        done
    else
        if [ ! -d "$PACKAGES_DIR/$PACKAGE" ]; then
            echo "ERROR: Package $PACKAGE does not exist"
            list_packages
        else
            build_package $PACKAGE
        fi
    fi
}


if [ "$COMMAND" == "build" ]
then
    build_packages
elif [ "$COMMAND" == "list" ]
then
    list_packages
else
    display_usage
fi

