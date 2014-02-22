#!/bin/bash
NEWVERSION="$2"
OLDVERSION="$1"
#gibts schon ein Paket mit der Versionsnummer? Dann abbrechen.
DOWNLOADDIR="/home/silke/Downloads"
TMPDIR="/tmp"
WORKDIR="/home/silke/DeepaMehta/dm4-deb"


if [ "$2" == "" ]; then
	echo "Call this script with a version number, e.g. dm-package.sh 405"
fi
# We only have numbers here

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

echo "Version number correct?"

sleep 5

# remove existing tmp files
if [ -d /tmp/deepamehta-${NEWVERSIONNUMBER} ]; then
	rm -rf /tmp/deepamehta-${NEWVERSIONNUMBER}
fi

ls /tmp

sleep 2

cp -a $WORKDIR/deepamehta_package_template $WORKDIR/deepamehta-$NEWVERSIONNUMBER
#gibts das schon?

# Changelog der letzten Version rueberkopieren
cp $WORKDIR/deepamehta-$OLDVERSIONNUMBER/debian/changelog $WORKDIR/deepamehta-$NEWVERSIONNUMBER/debian/changelog

if [ ! -f $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip ]; then
	wget -P $DOWNLOADDIR http://download.deepamehta.de/deepamehta-$NEWVERSIONNUMBER.zip
fi

#exit 0

unzip $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip -d $TMPDIR

# gogo shell loeschen
rm -rf $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/org.apache.felix.gogo.*

# ins Buildverzeichnis wechseln
cd $WORKDIR/deepamehta-$NEWVERSIONNUMBER

cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bin/* bin/bin/

cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/* bin/bundle/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/*.txt .


# Versionsnummer in preinst hochsetzen
cat $WORKDIR/deepamehta_package_template/debian/preinst  | sed "s/^DMVERSION\=XXX/DMVERSION\=${NEWVERSIONNUMBER}/" > debian/preinst

#exit 0

# edit the changelog
dch -d

# create the archive
tar -czf ../deepamehta_$NEWVERSIONNUMBER.orig.tar.gz bin/ etc/ examples/

# run debuild
debuild -S -sa

# You can now upload the changes file using dput deepamehta4 deepamehta_VERSIONNUMBER-1_source.changes
