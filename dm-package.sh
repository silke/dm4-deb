#!/bin/bash
NEWVERSION="$2"
OLDVERSION="$1"
DOWNLOADDIR="/home/silke/Downloads"
TMPDIR="/tmp"
WORKDIR="/home/silke/DeepaMehta/dm4-deb"

# to do: check if there is an existing package with the new version no.

if [ "$2" == "" ]; then
	echo "Call this script with two version numbers, the last one and the new one e.g. dm-package.sh 413 42"
fi

# insert the dots (for two and three digit version numbers)
# counting: from where do you count and how many chars belong together?

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
# Give a moment to interrupt just in case he version no. is not correct.
echo "Version number correct?"
sleep 5

# remove existing tmp files
if [ -d /tmp/deepamehta-${NEWVERSIONNUMBER} ]; then
	rm -rf /tmp/deepamehta-${NEWVERSIONNUMBER}
fi

# copy the folder structure from template
cp -a $WORKDIR/deepamehta_package_template $WORKDIR/deepamehta-$NEWVERSIONNUMBER

# Copy over Debian changelog of last version.
cp $WORKDIR/deepamehta-$OLDVERSIONNUMBER/debian/changelog $WORKDIR/deepamehta-$NEWVERSIONNUMBER/debian/changelog

# Download new code (if it didn't already happen).
if [ ! -f $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip ]; then
	wget -P $DOWNLOADDIR http://download.deepamehta.de/deepamehta-$NEWVERSIONNUMBER.zip
fi

# unpack new in tmp directory
unzip $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip -d $TMPDIR

# Remove the gogo shell. Keeping it will break the Debian package.
rm -rf $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/org.apache.felix.gogo.*

# cd to build dir
cd $WORKDIR/deepamehta-$NEWVERSIONNUMBER

# copy new files to template
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bin/* bin/bin/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/* bin/bundle/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/*.txt .


# increase the version no. in preinst
cat $WORKDIR/deepamehta_package_template/debian/preinst  | sed "s/^DMVERSION\=XXX/DMVERSION\=${NEWVERSIONNUMBER}/" > debian/preinst

#exit 0

# edit the changelog
dch -d

# create the archive
tar -czf ../deepamehta_$NEWVERSIONNUMBER.orig.tar.gz bin/ etc/ examples/

# run debuild
debuild -S -sa

echo "You can now upload the changes file using dput deepamehta4 deepamehta_VERSIONNUMBER-1_source.changes."

#EOF
