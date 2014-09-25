#!/bin/sh
DN="$(dirname "$(readlink -f "${0}")")"
cd /opt/npr/ 
./npr_update || { echo 'npr code update failed' ; exit 1; }

rm -rf /tmp/etenpr-linux-portable* 
rm -rf /tmp/etenpr-linux-portable.64bits.*.tar.gz
rm -rf /tmp/examples-*.tar.gz
rm -rf /tmp/portable_npr*
rm -rf /tmp/tmpresult*

cp $DN/cde.options ./           || { echo 'could not cp cde.options' ; exit 1; }
cp $DN/Phy* /tmp/               || { echo 'could not copy example files' ; exit 1; }
cp $DN/run_npr_example.sh ./    || { echo 'could not copy test script' ; exit 1; }

echo 'building...'
$DN/CDE/CDE_source/cde -o /tmp/portable_npr sh ./npr_update                            || { echo 'npr update faield' ; exit 1; }
$DN/CDE/CDE_source/cde -o /tmp/portable_npr sh ./run_npr_example.sh                    || { echo 'npr example failed' ; exit 1; }

echo 'Transferring manual files...'
$DN/CDE/CDE_source/okapi /libicui18n.so.48 "/usr/lib/" /tmp/portable_npr/cde-root/usr/lib/       || { echo 'transfer libicui18n.so.48 failed' ; exit 1; }
$DN/CDE/CDE_source/okapi /libicui18n.so.48.1.1 "/usr/lib/" /tmp/portable_npr/cde-root/usr/lib/       || { echo 'transfer libicui18n.so.48.1.1 failed' ; exit 1; }
python $DN/CDE/CDE_source/scripts/okapi_dir.py /opt/npr/ /tmp/portable_npr/cde-root/   || { echo 'transfer dir failed' ; exit 1; }
python $DN/CDE/CDE_source/scripts/okapi_dir.py /bin/ /tmp/portable_npr/cde-root/       || { echo 'transfer bin failed' ; exit 1; }

#python $DN/CDE/CDE_source/scripts/okapi_dir.py /lib/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /lib64/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /usr/bin/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /usr/lib/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /usr/local/lib/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /bin/ /tmp/portable_npr/cde-root/
#python $DN/CDE/CDE_source/scripts/okapi_dir.py /sbin/ /tmp/portable_npr/cde-root/

cd /opt/npr/
VERSION=`head -n1 VERSION`

# Increase portable environment version before packaging 
echo 'Setting environment new version '
cd $DN
python -c 'v = int(open("PORTABLE_ENV_VERSION").readline()) + 1; open("PORTABLE_ENV_VERSION", "w").write(str(v))'
cp PORTABLE_ENV_VERSION  /tmp/portable_npr/cde-root/etc/PORTABLE_ENV_VERSION
ENV_VERSION=`head -n1 PORTABLE_ENV_VERSION`
echo 'NEW VERSION:' `cat PORTABLE_ENV_VERSION` 

echo 'nameserver 8.8.8.8' > /tmp/portable_npr/cde-root/etc/resolv.conf

echo 'Packaging ...'
RELDIR=/tmp/etenpr-linux-portable-$ENV_VERSION/

rm -rf $RELDIR
mkdir -p $RELDIR

cd $RELDIR                                            || { echo 'cannot enter portable dir' ; exit 1; }
for app in npr 
do
    echo "#!/bin/sh" > $app
    echo 'DIR="$(dirname "$(readlink -f "${0}")")"' >> $app
    echo '$DIR/portable_npr/cde-exec /opt/npr/'$app' $@ \n' >> $app
    chmod +x $app
done

echo "#!/bin/sh" > update_npr
echo 'DIR="$(dirname "$(readlink -f "${0}")")"' >> update_npr
echo '$DIR/portable_npr/cde-exec /opt/npr/npr_update $@ \n' >> update_npr
chmod +x update_npr

PKGFILE="etenpr-linux-portable.64bits.$ENV_VERSION.tar.gz"

# Move npr into pkg dir
mv /tmp/portable_npr/ $RELDIR                         || { echo 'could not mv portable root into package' ; exit 1; }

cd /tmp
tar -zcf $PKGFILE etenpr-linux-portable-$ENV_VERSION/              || { echo 'could not mv portable root into package' ; exit 1; }

cd /opt/npr/
tar -zcf examples-$VERSION.tar.gz examples/ 
mv examples-$VERSION.tar.gz /tmp/

#rm -rf /tmp/portable_npr/ 
#rm -rf /tmp/tmpresult/

echo 
echo 'Done!'
echo "/tmp/$PKGFILE" 
echo "/tmp/examples-$VERSION.tar.gz"
