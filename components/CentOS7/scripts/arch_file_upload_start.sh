#! /bin/bash

ARCHIVE=$archive
TARGETPATH=$target_path
TMPFILE=`mktemp`


curl  $archive -o "$TMPFILE"

if [!-d "$TARGETPATH" ]; then

sudo mkdir -p  $TARGETPATH

fi

sudo su - -c "cd $TARGETPATH ; tar -xzf $TMPFILE"
