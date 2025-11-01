<h1 style="text-align: center;">Spring Boot Starter Project</h1>

<p style="text-align: center;">
  <a href="https://github.com/deepaksorthiya/spring-boot-security-x509-authentication/actions/workflows/maven-jvm-non-native-build.yml">
    <img src="https://github.com/deepaksorthiya/spring-boot-security-x509-authentication/actions/workflows/maven-jvm-non-native-build.yml/badge.svg" alt="JVM Maven Build"/>
  </a>  
<a href="https://github.com/deepaksorthiya/spring-boot-security-x509-authentication/actions/workflows/maven-graalvm-native-build.yml">
    <img src="https://github.com/deepaksorthiya/spring-boot-security-x509-authentication/actions/workflows/maven-graalvm-native-build.yml/badge.svg" alt="GraalVM Maven Build"/>
  </a>
  <a href="https://hub.docker.com/r/deepaksorthiya/spring-boot-security-x509-authentication">
    <img src="https://img.shields.io/docker/pulls/deepaksorthiya/spring-boot-security-x509-authentication" alt="Docker"/>
  </a>
  <a href="https://spring.io/projects/spring-boot">
    <img src="https://img.shields.io/badge/spring--boot-3.5.7-brightgreen?logo=springboot" alt="Spring Boot"/>
  </a>
</p>

## Live Demo

TBD

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Getting Started](#-getting-started)
    - [Clone the Repository](#1-clone-the-repository)
    - [Start Docker](#2-start-docker)
    - [Build the Project](#3-build-the-project)
    - [Run Project Locally](#4-run-the-project)
    - [Build Docker Image](#5-optional-build-docker-image-docker-should-be-running)
    - [Run Docker Image](#6-optional-running-on-docker)
    - [Deploy on Kubernetes with Helm](#7-optionalrun-on-local-minikube-kubernetes-using-helm-chart)
- [Testing](#-testing)
- [Clean Up](#-cleanup)
- [Reference Documentation](#-reference-documentation)

---

## 🚀 Overview

**Spring Boot** security authentication with x509 certificate.

---

## 🚀 Features

- Spring Boot 3.5.7 (Java 25)
- RESTful API with CRUD endpoints
- Spring Data JPA (H2 in-memory DB)
- Actuator endpoints enabled
- Docker & multi-stage build
- Kubernetes manifests & Helm chart
- GitHub Actions CI/CD
- Spring security x509 authentication

---

## 📦 Requirements

- Git `2.51.0+`
- Java `25`
- Maven `3.9+`
- Spring Boot `3.5.7`
- (Optional)Docker Desktop (tested on `4.45.0`)
- (Optional) Minikube/Helm for Kubernetes

---

## 🛠️ Getting Started

### Generate required files

```

# Generate Root CA private key and certificate and add to your browser to trust the `ca.crt` that accompanies this project
Set Pwd: capassword
its generates: 
 	ca.key
 	ca.crt
 	
Country Name (2 letter code) [AU]:IN
State or Province Name (full name) [Some-State]:GUJ
Locality Name (eg, city) []:BHUJ
Organization Name (eg, company) [Internet Widgits Pty Ltd]:MyOrg
Organizational Unit Name (eg, section) []:Dev
Common Name (e.g. server FQDN or YOUR name) []:CA Localhost Dev
Email Address []:localhost@localhost.com

1. openssl req -x509 -sha256 -days 7300 -newkey rsa:4096 -keyout ca.key -out ca.crt
```

```
# Generate Server Side Private Key and CSR Certificate
 Country Name (2 letter code) []:IN
 State or Province Name (full name) []:GUJ
 Locality Name (eg, city) []:BHUJ
 Organization Name (eg, company) []:MyOrg
 Organizational Unit Name (eg, section) []:Dev
 Common Name (eg, fully qualified host name) []:localhost
 Email Address []:localhost@localhost.com

 Please enter the following 'extra' attributes
 to be sent with your certificate request
 A challenge password []: <blank>

 generates:
 	server.key
 	server.csr
 Pwd : serverpassword
2. openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr
```

```
# Create ext file
vim localhost.ext
```

```
# copy below contents to localhost.ext file
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
```

```
#Sign Cert with Root CA
 generates:
 	ca.srl
 	server.crt
 Use Pwd capassword
3. openssl x509 -req -CA ca.crt -CAkey ca.key -in server.csr -out server.crt -days 7300 -CAcreateserial -extfile localhost.ext
```

```
# Add the loaclhost.key and loaclhost.crt in single PKCS 12 bundle
User above serve Pwd : serverpassword
Set Export Pwd : serverpassword
4. openssl pkcs12 -export -out server.p12 -name "localhost" -inkey server.key -in server.crt
```

```
#(Optional) convert PKCS12 to JKS (Optional as we will use PKSC12)
5. keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -destkeystore server.jks -deststoretype JKS
```

```
# Create Trust Store With Root CA cert which is used to sign Client Certificate
6. keytool -import -trustcacerts -noprompt -alias ca -ext san=dns:localhost,ip:127.0.0.1 -file ca.crt -keystore truststore.jks
```

```
# convert JKS to PKCS12
7. keytool -importkeystore -srckeystore truststore.jks -destkeystore truststore.p12 -srcstoretype JKS -deststoretype PKCS12 -deststorepass trustpassword -srcstorepass trustpassword
```

### for pc browser you need generate below files and need to add

```browserclient.p12``` to you browser certificate store or Machine

```
# Generate Browser Client Key and CSR
8. openssl req -new -newkey rsa:4096 -nodes -keyout browserclient.key -out browserclient.csr
```

```
# Sign cert with with CA
9. openssl x509 -req -CA ca.crt -CAkey ca.key -in browserclient.csr -out browserclient.crt -days 7300 -CAcreateserial
```

```
# convert to PKCS12
10. openssl pkcs12 -export -out browserclient.p12 -name "browser" -inkey browserclient.key -in browserclient.crt
```

### 1. Clone the Repository

```bash
git clone https://github.com/deepaksorthiya/spring-boot-security-x509-authentication.git
cd spring-boot-security-x509-authentication
```

### 2. Start Docker

* this command will start all required services to start application

```bash
docker compose up
```

### 3. Build the Project

```bash
./mvnw clean package -DskipTests
```

* OR for native build run

```bash
./mvnw clean native:compile -Pnative
```

### 4. Run the Project

```bash
./mvnw spring-boot:run
```

* OR Jar file

```bash
java -jar .\target\spring-boot-security-x509-authentication-0.0.1-SNAPSHOT.jar
```

* OR Run native image directly

```bash
target/spring-boot-security-x509-authentication
```

### 5. (Optional) Build Docker Image (docker should be running)

```bash
./mvnw clean spring-boot:build-image -DskipTests
```

* OR To create the native container image, run the following goal:

```bash
./mvnw clean spring-boot:build-image -Pnative -DskipTests
```

* OR using dockerfile

```bash
docker build --progress=plain --no-cache -f <dockerfile> -t deepaksorthiya/spring-boot-security-x509-authentication .
```

* OR Build Using Local Fat Jar In Path ``target/spring-boot-security-x509-authentication-0.0.1-SNAPSHOT.jar``

```bash
docker build --build-arg JAR_FILE=target/spring-boot-security-x509-authentication-0.0.1-SNAPSHOT.jar -f Dockerfile.jvm --no-cache --progress=plain -t deepaksorthiya/spring-boot-security-x509-authentication .
```

* OR if above not work try below command

***you should be in jar file path to work build args***

```bash
cd target
docker build --build-arg JAR_FILE=spring-boot-security-x509-authentication-0.0.1-SNAPSHOT.jar -f ./../Dockerfile.jvm --no-cache --progress=plain -t deepaksorthiya/spring-boot-security-x509-authentication .
```

| Dockerfile Name                                            |                          Description                           |
|------------------------------------------------------------|:--------------------------------------------------------------:|    
| [Dockerfile](Dockerfile)                                   |  multi stage docker file with Spring AOT and JDK24+ AOT Cache  |
| [Dockerfile.jlink](Dockerfile.jlink)                       |      single stage using JDK jlink feature to reduce size       |
| [Dockerfile.jvm](Dockerfile.jvm)                           |    single stage using with Spring AOT and JDK24+ AOT Cache     |
| [Dockerfile.native](Dockerfile.native)                     |  single stage using graalvm native image using oraclelinux 9   |
| [Dockerfile.native-distro](Dockerfile.native-distro)       | single stage using graalvm native image distroless linux image |
| [Dockerfile.native-micro](Dockerfile.native-micro)         |   single stage using graalvm native image micro linux image    |
| [Dockerfile.native-multi](Dockerfile.native-multi)         |    multi stage using graalvm native image micro linux image    |
| [Dockerfile.springlayeredjar](Dockerfile.springlayeredjar) |          multi stage using spring layererd layout jar          |
| [Dockerfile.springlayoutjar](Dockerfile.springlayoutjar)   |              multi stage using spring layout jar               |

### 6. (Optional) Running On Docker

```bash
docker run -p 8080:8080 --name spring-boot-security-x509-authentication deepaksorthiya/spring-boot-security-x509-authentication:latest
```

### 7. (Optional)Run on Local minikube Kubernetes using Helm Chart

```bash
cd helm
helm create spring-boot-security-x509-authentication
helm lint spring-boot-security-x509-authentication
helm install spring-boot-security-x509-authentication --values=spring-boot-security-x509-authentication/values.yaml spring-boot-security-x509-authentication
helm install spring-boot-security-x509-authentication spring-boot-security-x509-authentication
helm uninstall spring-boot-security-x509-authentication
```

---

## 🧪 Testing

- Access the API: [http://localhost:8080](http://localhost:8080)
- H2 Console: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)

### Postman API Collection

TBD

### Rest API Endpoints

TBD

### Run Unit-Integration Test Cases

```bash
./mvnw clean test
```

To run your existing tests in a native image, run the following goal:

```bash
./mvnw test -PnativeTest
```

---

## 🧹 Cleanup

```bash
docker compose down -v
```

---

## 📚 Reference Documentation

For further reference, please consider the following sections:

- [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
- [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/maven-plugin)
- [Create an OCI image](https://docs.spring.io/spring-boot/maven-plugin/build-image.html)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/reference/actuator/index.html)
- [Spring Web](https://docs.spring.io/spring-boot/reference/web/servlet.html)
- [Spring Data JPA](https://docs.spring.io/spring-boot/reference/data/sql.html#data.sql.jpa-and-spring-data)
- [Validation](https://docs.spring.io/spring-boot//io/validation.html)
- [Flyway Migration](https://docs.spring.io/spring-boot/how-to/data-initialization.html#howto.data-initialization.migration-tool.flyway)

---

<p style="text-align: center;">
  <b>Happy Coding!</b> 🚀
</p>
