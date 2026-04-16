openssl req -new -nodes -x509 \
    -days 365 \
    -newkey rsa:2048 \
    -keyout certs/ca.key \
    -out certs/ca.crt \
    -config ca-cert.cnf

cat certs/ca.crt certs/ca.key > certs/ca.pem

openssl req -new \
    -newkey rsa:2048 \
    -keyout certs/kafka.key \
    -out certs/kafka.csr \
    -config kafka-cert.cnf \
    -nodes

openssl x509 -req \
    -days 3650 \
    -in certs/kafka.csr \
    -CA certs/ca.crt \
    -CAkey certs/ca.key \
    -CAcreateserial \
    -out certs/kafka.crt \
    -extfile kafka-cert.cnf \
    -extensions v3_req

openssl pkcs12 -export \
    -in certs/kafka.crt \
    -inkey certs/kafka.key \
    -chain \
    -CAfile certs/ca.pem \
    -name kafka \
    -out certs/kafka.p12 \
    -password pass:sslkey_password

keytool -importkeystore \
    -deststorepass keystore_password \
    -destkeystore stores/kafka.keystore.pkcs12 \
    -srckeystore certs/kafka.p12 \
    -deststoretype PKCS12  \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass sslkey_password

keytool -import \
    -file certs/ca.crt \
    -alias ca \
    -keystore stores/kafka.truststore.jks \
    -storepass truststore_password \
    -noprompt
