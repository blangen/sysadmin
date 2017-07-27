#!/bin/bash -eu

# Creates a self-signed SSL certificate and key file
#   Optionally creates a certificate chain and uploads to Amazon via 'aws iam'
 

if hash cowsay 2>/dev/null; then
        cowpath=$(which cowsay)
        cowecho="$cowpath"
    else
        cowecho=$(/bin/echo)
fi

echo ''

echo "   1      Self-signed certificate and key"
echo "   2      Self-signed certificate, key, and chain"
echo "   3      Self-signed certificate, key, and chain - and upload to IAM API"
echo "   4      Do nothing - exit"
echo ''
read -rp "Make a selection to create certificate and key files:  " request_certs
echo ''
read -rp "Type in the domain you want to create a certificate for:  " domain

if [ -z "$domain" ]; then
     echo "You must enter a domain in order to create a valid self-signed certificate"
     exit 1
fi

wdir=~/makecerts
 if [ -d ${wdir} ]
        then
          rm -rf $wdir
          mkdir $wdir
        else
          mkdir $wdir
    fi

# Verify awscli is setup w/ credentials
verify_awscli() {
    if ! aws --version >/dev/null 2>/dev/null ;then
        $cowecho "ERROR: The command 'aws --verson' failed to run, and this script will fail unless 'aws' is in the user's path."
        exit 1
    fi
# Test availability of the AWS AccessKey - this will change when we move to IAM role
    if [ -z "$(aws configure get aws_access_key_id)" ]; then
        $cowecho "ERROR: AWS credentials not configured. Aborting."
        exit 1
    fi

}

setup () {
	cd $wdir || exit
	mkdir chains
	for C in root-ca intermediate; do
	    mkdir $C
            cd $C || exit
	    mkdir certs crl newcerts private
	    cd ..

	# Create empty file where the CA will store it's serials
	    echo 1000 > $C/serial
	    touch $C/index.txt $C/index.txt.attr

	# Create the CA config file
  	    echo "
		[ ca ]
		default_ca = CA_default
		[ CA_default ]
		dir            = $C    # Where everything is kept
		certs          = $C/certs                # Where the issued certs are kept
		crl_dir        = $C/crl                # Where the issued crl are kept
		database       = $C/index.txt            # database index file.
		new_certs_dir  = $C/newcerts            # default place for new certs.
		certificate    = $C/cacert.pem                # The CA certificate
		serial         = $C/serial                # The current serial number
		crl            = $C/crl.pem                # The current CRL
		private_key    = $C/private/ca.key.pem       # The private key
		RANDFILE       = $C/.rnd     # private random number file
		nameopt        = default_ca
		certopt        = default_ca
		policy         = policy_match
		default_days   = 365
		default_md     = sha256

		[ policy_match ]
		countryName            = optional
		stateOrProvinceName    = optional
		organizationName       = optional
		organizationalUnitName = optional
		commonName             = supplied
		emailAddress           = optional

		[req]
		req_extensions = v3_req
		distinguished_name = req_distinguished_name

		[req_distinguished_name]

		[v3_req]
		basicConstraints = CA:TRUE
		" > $C/openssl.conf
	done
}

make-root-and-key () {
	# Create the key
	openssl genrsa -out root-ca/private/ca.key 2048
	$cowecho "Your private root key can be found at $wdir/root-ca/private/ca.key"
	# Create a self-signed root CA certificate
	openssl req -config root-ca/openssl.conf \
	    -new -x509 -days 3650 \
	    -key root-ca/private/ca.key \
	    -sha256 -extensions v3_req \
	    -out root-ca/certs/ca.crt \
	    -subj "/C=US/ST=California/L=Pleasanton/O=Security/OU=CRM-DevOps/CN=$domain"
	$cowecho "Your self-signed root CA certificate can be found at $wdir/root-ca/certs/ca.crt"
}

make-CA-and-sign () {
	# Create an intermediate CA's private key
	openssl genrsa -out intermediate/private/intermediate.key 2048
	# Generate the intermediate CA's CSR
	openssl req -config intermediate/openssl.conf \
	    -sha256 -new -key intermediate/private/intermediate.key \
	    -out intermediate/certs/intermediate.csr \
	    -subj '/CN=Interm.'
	# Sign the intermediate CSR with the root CA
	openssl ca -batch -config root-ca/openssl.conf \
	    -keyfile root-ca/private/ca.key \
	    -cert root-ca/certs/ca.crt \
	    -extensions v3_req -notext -md sha256 \
	    -in intermediate/certs/intermediate.csr \
	    -out intermediate/certs/intermediate.crt
	# Verify the intermediate certificate
	$cowecho "Verifying the Intermediate certificate"
	openssl x509 -noout -text \
	      -in intermediate/certs/intermediate.crt
	$cowecho "Verifying the Intermediate certificate chain of trust with the root certificate"
	openssl verify -CAfile root-ca/certs/ca.crt \
	      intermediate/certs/intermediate.crt 
}

make-chain () {
	# Create the certificate chain
	cat ./root-ca/certs/ca.crt  ./intermediate/certs/intermediate.crt > chains/ca-all.crt
	chmod 444 chains/ca-all.crt
	$cowecho "Your certificate chain can be found at $wdir/chains/ca-all.crt"
}

upload-server-certificate() {
# Using the IAM API, upload the cert body file, chain file, and private key file in a single command

	aws iam upload-server-certificate --server-certificate-name star.vod309.com \
					    --certificate-body file://$wdir/root-ca/certs/ca.crt \
					    --private-key file://$wdir/root-ca/private/ca.key
#					    --certificate-chain file://$wdir/chains/ca-all.crt \
	aws iam list-server-certificates
}

case $request_certs in

1) verify_awscli
   setup
   make-root-and-key
   cd ~
   ;;
2) verify_awscli
   setup
   make-root-and-key
   make-CA-and-sign
   make-chain
   cd ~
   ;;
3) verify_awscli
   setup
   make-root-and-key
   make-CA-and-sign
   make-chain
   upload-server-certificate
   ;;
4) exit 0
   ;;

esac
