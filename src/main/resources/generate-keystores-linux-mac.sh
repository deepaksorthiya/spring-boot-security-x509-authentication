#!/bin/bash

#
# This sample bash script will:
# 1.) Create a Certificate Authority
# 2.) Create a Server Certificate signed by the Certificate Authority
# 3.) Create a Client Certificate signed by the Certificate Authority
# 4.) Create a TrustStore containing the public Certificate Authority key
#
# The first section defines variables
# The second section does the work
#
# All Key Stores are PKCS12
#
# The Server Certificate includes a Subject Alternative Name
# The command below uses the serverAlias as the serverDNS value, but may be changed to whatever you need
#
# You just have Java 7 (or higher) installed and keytool in your path
#

# Your Organizational Information
organizationalUnit="Dev"
organization="MyOrg"
locality="BHJ"
state="GJ"
country="IN"

# Certificate Alias
authorityAlias="tomcat-root"
serverAlias="tomcat.server.net"
clientAlias="tomcat-admin"

# Subject Alternative Name
serverDNS="$serverAlias"

# Extensions
certAuthExtension="BasicConstraints:critical=ca:true,pathlen:10000"
altNameExtension="san=dns:localhost"

# Trust Store
trustCertName="truststore"

# Key size and effective period
keySize="4096"
validity="365"

# Key and Store Password
certPassword="changeit"

# ------------------------------------------------------------------------------------------
# ------------------  Use caution if you change anything below this line  ------------------
# ------------------------------------------------------------------------------------------

authorityDN="CN=$authorityAlias,OU=$organizationalUnit,O=$organization,L=$locality,ST=$state,C=$country"
serverDN="CN=localhost,OU=$organizationalUnit,O=$organization,L=$locality,ST=$state,C=$country"
clientDN="CN=localhost,OU=$organizationalUnit,O=$organization,L=$locality,ST=$state,C=$country"

# Clean up existing files
rm -f "$authorityAlias."*
rm -f "$serverAlias."*
rm -f "$clientAlias."*
rm -f "$trustCertName."*

echo ""
echo "Generating the Root Authority Certificate..."
keytool -genkeypair -alias "$authorityAlias" -keyalg RSA -dname "$authorityDN" -ext "$certAuthExtension" \
    -validity "$validity" -keysize "$keySize" -keystore "$authorityAlias.p12" -keypass "$certPassword" \
    -storepass "$certPassword" -deststoretype pkcs12
echo "- Exporting Root Authority Certificate Public Key..."
keytool -exportcert -rfc -alias "$authorityAlias" -file "$authorityAlias.cer" -keypass "$certPassword" \
    -keystore "$authorityAlias.p12" -storepass "$certPassword"

echo ""
echo "Generating the Server Certificate..."
echo "- Creating Key Pair"
keytool -genkey -validity "$validity" -keysize "$keySize" -alias "$serverAlias" -keyalg RSA -dname "$serverDN" \
    -ext "$altNameExtension" -keystore "$serverAlias.p12" -keypass "$certPassword" -storepass "$certPassword" \
    -deststoretype pkcs12
echo "- Creating Certificate Signing Request"
keytool -certreq -alias "$serverAlias" -ext "$altNameExtension" -keystore "$serverAlias.p12" -file "$serverAlias.csr" \
    -keypass "$certPassword" -storepass "$certPassword"
echo "- Signing Certificate"
keytool -gencert -infile "$serverAlias.csr" -keystore "$authorityAlias.p12" -storepass "$certPassword" \
    -alias "$authorityAlias" -ext "$altNameExtension" -outfile "$serverAlias.pem"
echo "- Adding Certificate Authority Certificate to Keystore"
keytool -import -trustcacerts -alias "$authorityAlias" -file "$authorityAlias.cer" -keystore "$serverAlias.p12" \
    -storepass "$certPassword" -noprompt
echo "- Adding Certificate to Keystore"
keytool -import -keystore "$serverAlias.p12" -file "$serverAlias.pem" -alias "$serverAlias" -keypass "$certPassword" \
    -storepass "$certPassword" -noprompt
rm -f "$serverAlias.csr" "$serverAlias.pem"

echo ""
echo "Generating the Client Certificate..."
echo "- Creating Key Pair"
keytool -genkey -validity "$validity" -keysize "$keySize" -alias "$clientAlias" -keyalg RSA -dname "$clientDN" \
    -keystore "$clientAlias.p12" -keypass "$certPassword" -storepass "$certPassword" -deststoretype pkcs12
echo "- Creating Certificate Signing Request"
keytool -certreq -alias "$clientAlias" -keystore "$clientAlias.p12" -file "$clientAlias.csr" -keypass "$certPassword" \
    -storepass "$certPassword"
echo "- Signing Certificate"
keytool -gencert -infile "$clientAlias.csr" -keystore "$authorityAlias.p12" -storepass "$certPassword" \
    -alias "$authorityAlias" -outfile "$clientAlias.pem"
echo "- Adding Certificate Authority Certificate to Keystore"
keytool -import -trustcacerts -alias "$authorityAlias" -file "$authorityAlias.cer" -keystore "$clientAlias.p12" \
    -storepass "$certPassword" -noprompt
echo "- Adding Certificate to Keystore"
keytool -import -keystore "$clientAlias.p12" -file "$clientAlias.pem" -alias "$clientAlias" -keypass "$certPassword" \
    -storepass "$certPassword" -noprompt
rm -f "$clientAlias.csr" "$clientAlias.pem"

echo ""
echo "Generating the Trust Store and put the Client Certificate in it..."
keytool -importcert -alias "$authorityAlias" -file "$authorityAlias.cer" -keystore "$trustCertName.p12" \
    -storepass "$certPassword" -noprompt

echo ""
echo "Removing Public Key Files..."
rm -f "$authorityAlias.cer"

echo ""
echo "Certificate generation completed successfully!"