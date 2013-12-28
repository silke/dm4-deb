#!/bin/bash
NEWVERSION="$2"
OLDVERSION="$1"
#gibts schon ein Paket mit der Versionsnummer? Dann abbrechen.
DOWNLOADDIR="/home/silke/Downloads"
TMPDIR="/tmp"
WORKDIR="/home/silke/DeepaMehta/dm4-deb"

## 4.1 -> 4.2 upgrade: dependency zu dm4-karaf einbauen.
## db nicht mehr verschieben, sondern behalten

if [ "$2" == "" ]; then
	echo "Call this script with a version number, e.g. dm-package.sh 405"
fi
#nur zahlen

#Punkte einsetzen
NEWVERSIONNUMBER="${NEWVERSION:0:1}.${NEWVERSION:1:1}.${NEWVERSION:2:1}${NEWVERSION:3:1}"
echo $NEWVERSIONNUMBER
cd $WORKDIR
pwd

#Punkte einsetzen
if [ "${OLDVERSION:2:1}" == "" ]; then
	OLDVERSIONNUMBER="${OLDVERSION:0:1}.${OLDVERSION:1:1}"
else
	OLDVERSIONNUMBER="${OLDVERSION:0:1}.${OLDVERSION:1:1}.${OLDVERSION:2:1}${OLDVERSION:3:1}"
fi

cp -a $WORKDIR/deepamehta_package_template $WORKDIR/deepamehta-$NEWVERSIONNUMBER
#gibts das schon?

# Changelog der letzten Version rueberkopieren
cp $WORKDIR/deepamehta-$OLDVERSIONNUMBER/debian/changelog $WORKDIR/deepamehta-$NEWVERSIONNUMBER/debian/changelog

if [ ! -f $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip ]; then
	wget -P $DOWNLOADDIR http://download.deepamehta.de/deepamehta-$NEWVERSIONNUMBER.zip
fi

#exit 0

unzip $DOWNLOADDIR/deepamehta-$NEWVERSIONNUMBER.zip -d $TMPDIR

# ins Buildverzeichnis wechseln
cd $WORKDIR/deepamehta-$NEWVERSIONNUMBER



cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bin/* bin/bin/

cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/bundle/* bin/bundle/
cp $TMPDIR/deepamehta-$NEWVERSIONNUMBER/*.txt .

# gogo shell loeschen
rm -rf $TMPDIR/deepamehta-NEWVERSIONNUMBER/bin/bundle/org.apache.felix.gogo.*

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
