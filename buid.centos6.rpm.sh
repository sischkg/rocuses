#!/bin/sh

source_name=`dirname $0`

RPMBUILD_DIR=$HOME/rpmbuild


( cd $source_name && /usr/bin/rake build )
last_source=`ls $source_name/pkg/rocuses-*.gem|sort|tail -n 1`
spec=$source_name/rocuses.spec

echo $last_source
echo $spec

cp $last_source $RPMBUILD_DIR/SOURCES
cp $spec        $RPMBUILD_DIR/SPECS
( cd $RPMBUILD_DIR && rpmbuild -ba SPECS/rocuses.spec )

