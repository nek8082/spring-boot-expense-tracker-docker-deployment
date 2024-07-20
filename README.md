# About

This entire project is a docker project for the cashkontrolleur.de website, based on docker-compose.
It is meant to be used in conjunction with the [spring-boot-expense-tracker](https://github.com/nek8082/spring-boot-expense-tracker) project.

# Configuring this docker compose project for local testing

1. Copy `.env.example` from [spring-boot-expense-tracker](https://github.com/nek8082/spring-boot-expense-tracker) to `.env` in this project
2. Comment in `location /keycloak/admin` and `location /keycloak/realms/master/protocol/openid-connect/auth/` directives in nginx.conf
3. Create a self-signed SSL certificate for local testing by running the following commands:
```
openssl genpkey -algorithm RSA -out nginx.key
openssl req -new -key nginx.key -out nginx.csr -config openssl.cnf
openssl x509 -req -in nginx.csr -signkey nginx.key -out nginx.crt -days 365 -extensions v3_req -extfile openssl.cnf
```
4. Set the path to the certificates in .env file
5. Run the following command to make sure, the spring-service starts up without ssl error's when running the service in your IDE
```
keytool -importcert -file ./nginx.crt -alias nginx -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -noprompt
```
6. Replace `proxy_pass http://spring-service:8081/;` with `proxy_pass http://host.docker.internal:8081/` in nginx.conf
7. To prevent the container from addressing itself instead of the host system, the variable PROXY_HOST in .env cannot be set to `localhost`. Instead use `my-proxy` or something else.
8. See next subchapter:  **When running the docker project locally, the host system's hosts file must be edited to map `my-proxy` to 127.0.0.1**

## When running the docker compose project locally, the host system's hosts file must be edited to map `my-proxy` to 127.0.0.1

1. Open a text editor as an administrator.
2. Navigate to `C:\Windows\System32\drivers\etc`.
3. Open the `hosts` file.
4. Add the following line (replace my-proxy with whatever you set PROXY_HOST to in .env) to the end of the file:
```
127.0.0.1       my-proxy
```
_Note: The host file must not be set when running the docker project in a production environment. In that case we use a host name like cashkontrolleur.de that is resolved by DNS._

# Configuring this docker compose project for production

1. Copy `.env.example` from spring-service to `.env` in this project
2. Replace `my-proxy` with the hostname of your server (e.g., `cashkontrolleur.de`) in every file of this docker project except this `README.md`
3. Self-signed SSL certificates cannot be used in a production environment. To create non-self-signed SSL certificates, run the following commands ON THE SERVER:
```
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d cashkontrolleur.de
```
4. Update the path to the certificates in the nginx volumes in the docker-compose.yml (here is an example for `cashkontrolleur.de`):
```
PATH_TO_SSL_CERT=/etc/letsencrypt/live/cashkontrolleur.de/fullchain.pem
PATH_TO_SSL_KEY=/etc/letsencrypt/live/cashkontrolleur.de/privkey.pem
```
5. Make sure to copy `/etc/letsencrypt/live/cashkontrolleur.de/fullchain.pem` as `nginx.crt` and `/etc/letsencrypt/live/cashkontrolleur.de/privkey.pem` as `nginx.key` to the spring-service project in your IDE before creating the spring-service image as a tar file.

6. Comment out `location /keycloak/admin` and `location /keycloak/realms/master/protocol/openid-connect/auth/` directives in nginx.conf

7. Replace `proxy_pass http://localhost:8081/;` with `proxy_pass http://spring-service:8081/` in nginx.conf

# How to run
1. Switch to the [spring-boot-expense-tracker](https://github.com/nek8082/spring-boot-expense-tracker) repo and run `./deploy.sh 1.0.0` to generate a docker image as a tar file called: `cashkontrolleur_docker_image_1.0.0.tar`
2. Copy the tar file to the same directory as the .run.sh script
3. Run the following command to start the docker project: `./run.sh 1.0.0`
4. _Note 1: When running the docker project in production, the docker project must be run as root, so the script must be run with `sudo`_
5. _Note 2: When running the docker project locally, the spring-service will fail to start. This is intentional, as the spring-service is intended to be started in your IDE for development purposes and not as a docker container._

## Connect to keycloak admin console in production

1. Allowlist your PC's IP address in the nginx `location /keycloak/realms/master/protocol/openid-connect/auth/` directive
2. Run the following command and access the keycloak admin console at `http://localhost:8080/keycloak`:
```
ssh -i ~/path/to/private-key/ssh/id_rsa -L 8080:localhost:8080 username@server-ip
```
_Note: Keycloak ports have to be made open in the compose file (ports instead of expose). They are still closed by the firewall of the server, but you need them open in compose to access them via the ssh tunnel._

## Connect to postgres via pgadmin in production

1. Run the following command and access postgres via localhost:5432 in pgadmin:
```
ssh -i ~/path/to/private-key/ssh/id_rsa -L 5432:localhost:5432 username@server-ip
```
_Note: Postgres ports have to be made open in the compose file (ports instead of expose). They are still closed by the firewall of the server, but you need them open in compose to access them via the ssh tunnel._

# Create technical user in keycloak
1. Switch to your keycloak admin console and create a new user in your KEYCLOAK_REALM (same realm that is used in the .env file)
2. Make sure to set email, password with the same values as in the .env file
3. Make sure to also set First Name and Last Name of the user, otherwise keycloak will throw an error
4. Make sure to assign the following role to the user: **realm-management: manage-users** to prevent 403 http status codes, when deleting a user