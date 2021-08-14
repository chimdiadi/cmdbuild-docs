# Configure LDAP Authentication with DB Authentication
Commands:

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
  
