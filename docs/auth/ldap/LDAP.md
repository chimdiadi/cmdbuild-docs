# Configure LDAP Authentication with DB Authentication
Commands:

    cmdbuild restws setconfig org.cmdbuild.auth.modules=default,ldap,saml,cas,oauth -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.methods=LdapAuthenticator,DBAuthenticator -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.server.address=<address>-username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.server.port=389 -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.use.ssl=false -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.use.tls=false -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.basedn=dc=<domain>,dc=<tld> -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.bind.attribute=<LDAP BIND USER> -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.search.auth.method=simple -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.search.auth.password=<LDAP PW> -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.ldap.search.auth.principal  -username admin -password admin
    cmdbuild restws setconfig org.cmdbuild.auth.loginAttributeMode=<mode> -username admin -password admin

## Auth Methods
Reference: core/configdefs/src/main/java/org/cmdbuild/config/AuthConfigurationImpl.java

     org.cmdbuild.auth.ldap.search.auth.method

  options:
  - auto_detect_email
  - username
  - email
  
## Code - Reference
CMDBUILD Uses Springframework for LDAP

    org.springframework.ldap
    git clone [https://github.com/spring-guides/gs-authenticating-ldap.git](https://github.com/spring-guides/gs-authenticating-ldap.git)
    https://spring.io/guides/gs/authenticating-ldap/
    https://spring.io/projects/spring-ldap

FilesystemConfigRepository

    /core/config/src/main/java/org/cmdbuild/config/service/FilesystemConfigRepositoryImpl.java

Configuration

    ui/app/model/administration/Configuration.js

## Notes
It appears that LDAP can only be enabled via SAML or CAS. When attempting to enable ldap usine org.cmdbuild.auth.modules=ldap cmdbuild application throws an unknown key exception.
