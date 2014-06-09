#!/bin/bash
# silke.
# Adapt some variables ($DOWNLOADDIR, $WORKDIR) for your needs.
# Run the script like this: dm-package.sh <last-version> <new-version> without any dots in the version numbers, e.g. dm-package.sh 413 42 (from 4.1.3 to 4.2) or dm-package.sh 42 43 (from 4.2 to 4.3).

NEWVERSION="$2"
OLDVERSION="$1"
DOWNLOADDIR="<set a directory>"
TMPDIR="/tmp"
WORKDIR="<the directory you git-cloned into"

# yet to be done: Check if there is already an existing package with the new version number.

# Check if both, last and new version numbers are given.
if [ "$2" == "" ]; then
	echo "Call this script with two version numbers, the last one and the new one e.g. dm-package.sh 413 42"
fi

# insert the dots (for two and three digit version numbers)
# for the new version no.
if [ ${#NEWVERSION} -ge 3 ]; then
		NEWVERSIONNUMBER="${NEWVERSION:0:1}.${NEWVERSION:1:1}.${NEWVERSION:2:1}${NEWVERSION:3:1}"
#		echo $NEWVERSIONNUMBER
	elif [ ${#NEWVERSION} -eq 2 ]; then
		NEWVERSIONNUMBER="${NEWVERSION:0:1}.${NEWVERSION:1:1}"
fi


# insert dots for previous version no.
if [ "${OLDVERSION:2:1}" == "" ]; then
	OLDVERSIONNUMBER="${OLDVERSION:0:1}.${OLDVERSION:1:1}"
else
	OLDVERSIONNUMBER="${OLDVERSION:0:1}.${OLDVERSION:1:1}.${OLDVERSION:2:1}${OLDVERSION:3:1}"
fi

echo $OLDVERSIONNUMBER
echo $NEWVERSIONNUMBER
cd $WORKDIR
# Give a moment to interrupt just in case the version number is not correct.
echo "Version number correct? Hit Ctrl+C if not."
sleep 5

# remove existing tmp files
if [ -d /tmp/deepamehta-${NEWVERSIONNUMBER} ]; then
	rm -rf /tmp/deepamehta-${NEWVERSIONNUMBER}
fi

# Copy the folder structure from template.
cp -a $WORKDIR/deepamehta_package_template $WORKDIR/deepamehta-$NEWVERSIONNUMBER

# Copy over Debian changelog of last version.
cp $WORKDIR/deepamehta-$OLDVERSIONNUMBER/debian/changelog $WORKDIR/deepamehta-$NEWVERSIONNUMBER/debian/changelog

# Download new code (if it didn't already happen).
if [ ! -f $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip ]; then
	wget -P $DOWNLOADDIR http://download.deepamehta.de/deepamehta-$NEWVERSIONNUMBER.zip
fi

# Unpack new code in /tmp directory.
unzip $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip -d $TMPDIR

# Remove the gogo shell. Keeping it will break the Debian package.
rm -rf $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/org.apache.felix.gogo.*

# Change into the build directory.
cd $WORKDIR/deepamehta-$NEWVERSIONNUMBER

# Copy new files to template.
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bin/* bin/bin/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/* bin/bundle/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/*.txt .


# Increase the version number in the preinst script.
cat $WORKDIR/deepamehta_package_template/debian/preinst  | sed "s/^DMVERSION\=XXX/DMVERSION\=${NEWVERSIONNUMBER}/" > debian/preinst

# Edit the changelog.
dch -d

# Create the archive.
tar -czf ../deepamehta_$NEWVERSIONNUMBER.orig.tar.gz bin/ etc/ examples/

# run debuild
debuild -S -sa

echo "You can now upload the changes file to launchpad using dput <reponame> deepamehta_VERSIONNUMBER-1_source.changes."

#EOF
