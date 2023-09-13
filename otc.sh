# One liner to get the OTC on both pub or authors
# mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/otc.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/otc.sh && chmod +x /mnt/tmp/diagnose/scripts/otc.sh && /mnt/tmp/diagnose/scripts/otc.sh
# ----------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------

# Ask the user for input until it's valid
while true; do
    echo "Please enter a value for AVAILABLE_RAM (integer between 1 and 200, e.g. 15):"
    read input_ram

    # Check if input is an integer and between 1 and 200
    if [[ "$input_ram" =~ ^[0-9]+$ ]] && [ "$input_ram" -ge 1 ] && [ "$input_ram" -le 200 ]; then
        AVAILABLE_RAM="${input_ram}G"
        break
    else
        echo "Invalid input. Please enter an integer value between 1 and 200."
    fi
done

# stopping AEM with 3 retries
mkdir -p /mnt/tmp/diagnose/scripts/ && wget -q -O /mnt/tmp/diagnose/scripts/aem-stop.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-stop.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-stop.sh && /mnt/tmp/diagnose/scripts/aem-stop.sh

DIR="/mnt/crx/author"
if [ -d "$DIR" ]; then
    runMode="author"
else
    runMode="publish"
fi

echo "Running in $runMode mode"
echo ""
echo "Determining OAK version"
echo "Running OAK_VERSION=$(unzip -q -c $(find /mnt/crx/$runMode/crx-quickstart/launchpad/felix -name bundle.jar -exec grep -l oak-core {} + | tail -n 1) META-INF/MANIFEST.MF | grep "Bundle-Version" | awk '{print $2}' |tr -d '\r')"
OAK_VERSION=$(unzip -q -c $(find /mnt/crx/$runMode/crx-quickstart/launchpad/felix -name bundle.jar -exec grep -l oak-core {} + | tail -n 1) META-INF/MANIFEST.MF | grep "Bundle-Version" | awk '{print $2}' |tr -d '\r')
echo "OAK version is $OAK_VERSION"
cd /mnt/crx/*/crx-quickstart
echo ""
echo "Getting oak-run-$OAK_VERSION.jar"
wget https://repo1.maven.org/maven2/org/apache/jackrabbit/oak-run/$OAK_VERSION/oak-run-$OAK_VERSION.jar
echo ""
echo "Executing sudo -u crx /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar checkpoints /mnt/crx/$runMode/crx-quickstart/repository/segmentstore"
sudo -u crx /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar checkpoints /mnt/crx/$runMode/crx-quickstart/repository/segmentstore
echo ""
echo "Executing sudo -u crx /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar checkpoints /mnt/crx/$runMode/crx-quickstart/repository/segmentstore rm-unreferenced"
sudo -u crx /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar checkpoints /mnt/crx/$runMode/crx-quickstart/repository/segmentstore rm-unreferenced
echo ""
echo "Executing nohup sudo -u crx nohup /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar compact /mnt/crx/$runMode/crx-quickstart/repository/segmentstore &"
nohup sudo -u crx nohup /usr/java/latest/bin/java -Dtar.memoryMapped=true -Xmx$AVAILABLE_RAM -jar oak-run-$OAK_VERSION.jar compact /mnt/crx/$runMode/crx-quickstart/repository/segmentstore &
echo "OTC done"
echo ""
# starting AEM with 3 retries
mkdir -p /mnt/tmp/diagnose/scripts && wget -q -O /mnt/tmp/diagnose/scripts/aem-start.sh https://raw.githubusercontent.com/kaiten123/AMS_scripts/main/aem-start.sh && chmod +x /mnt/tmp/diagnose/scripts/aem-start.sh && /mnt/tmp/diagnose/scripts/aem-start.sh