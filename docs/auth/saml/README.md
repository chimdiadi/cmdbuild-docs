

## Overveiw 

View the Current active Auth Methods

    org.cmdbuild.auth.methods

###  Auth API for saml cmdbuild.sh 3.3.1
    org.cmdbuild.auth.saml.sp.id
    org.cmdbuild.auth.saml.sp.baseUrl
    org.cmdbuild.auth.saml.idp.id
    org.cmdbuild.auth.saml.idp.cert
    org.cmdbuild.auth.saml.idp.login
    org.cmdbuild.auth.saml.idp.logout
    org.cmdbuild.auth.saml.handlerScript
    org.cmdbuild.auth.saml.logout.enabled
    org.cmdbuild.auth.saml.signatureAlgorithm
    org.cmdbuild.auth.saml.requireSignedAssertions

### Auth API for saml cmdbuild.sh 3.3.2
    org.cmdbuild.auth.module.saml.sp.id
    org.cmdbuild.auth.module.saml.sp.baseUrl
    org.cmdbuild.auth.module.saml.idp.id
    org.cmdbuild.auth.module.saml.idp.cert
    org.cmdbuild.auth.module.saml.idp.login
    org.cmdbuild.auth.module.saml.idp.logout
    org.cmdbuild.auth.module.saml.handlerScript
    org.cmdbuild.auth.module.saml.logout.enabled
    org.cmdbuild.auth.module.saml.signatureAlgorithm
    org.cmdbuild.auth.module.saml.requireSignedAssertions

### Default SAML Configuration
|API| Value |
|--|--|
|org.cmdbuild.auth.module.saml.sp.id|http://localhost:8080/cmdbuild|
|org.cmdbuild.auth.module.saml.sp.baseUrl|[http://localhost:8080/cmdbuild](http://localhost:8080/cmdbuild)|
|org.cmdbuild.auth.module.saml.idp.id|https://saml-idp-test:9080/idp/shibboleth|
|org.cmdbuild.auth.module.saml.idp.cert|pack18b4....cap|
|org.cmdbuild.auth.module.saml.idp.login|http://saml-idp-test:9080/idp/profile/SAML2/Redirect/SSO|
|org.cmdbuild.auth.module.saml.idp.logout|http://saml-idp-test:9080/idp/logout_TODO|
|org.cmdbuild.auth.module.saml.handlerScript|login = auth.getAttribute('SamAccountName')|
|org.cmdbuild.auth.module.saml.logout.enabled |false|
|org.cmdbuild.auth.module.saml.signatureAlgorithm|http://www.w3.org/2000/09/xmldsig#rsa-sha1|
|org.cmdbuild.auth.module.saml.requireSignedAssertions|true|
|  |  |



http://localhost:8080/cmdbuild

## Source Code Notes
**/auth/login/src/main/java/org/cmdbuild/auth/login/saml/SamlAuthenticator.java**

    public Saml2Settings getSamlSettings(Object servletRequest) {
    
    try {
    	    String baseUrl = firstNotBlank(config.getCmdbuildBaseUrlForSaml(), baseUrlService.getBaseUrl(servletRequest));
    
		    FluentMap<String, Object> map = map(
    		    "onelogin.saml2.unique_id_prefix", "CMDBUILD_",
			    "onelogin.saml2.debug", logger.isDebugEnabled(),
		        "onelogin.saml2.strict", true,
		        "onelogin.saml2.sp.entityid", config.getSamlServiceProviderEntityId(),
		        "onelogin.saml2.sp.assertion_consumer_service.url", baseUrl + "/services/saml/SSO",
		        "onelogin.saml2.sp.single_logout_service.url", baseUrl + "/services/saml/SingleLogout",
		        "onelogin.saml2.security.want_xml_validation", true,
		        "onelogin.saml2.idp.entityid", checkNotBlank(config.getSamlIdpEntityId(), "missing saml identity provider id"),
		        "onelogin.saml2.idp.single_sign_on_service.url", checkNotBlank(config.getSamlIdpLoginUrl(), "missing saml login url"),
		        "onelogin.saml2.idp.single_logout_service.url", config.getSamlIdpLogoutUrl(),
		        "onelogin.saml2.idp.x509cert", checkNotBlank(config.getSamlIdpCertificate(), "missing saml identity provider certificate"),
		        "onelogin.saml2.security.want_messages_signed", true,
		        "onelogin.saml2.security.want_assertions_signed", true
	        );
    
      
    
		    if (isNotBlank(config.getSamlServiceProviderCertificate()) && isNotBlank(config.getSamlServiceProviderKey())) {
		        map.with(
			        "onelogin.saml2.sp.x509cert", config.getSamlServiceProviderCertificate(),
			        "onelogin.saml2.sp.privatekey", config.getSamlServiceProviderKey(),
			        "onelogin.saml2.security.authnrequest_signed", true,
			        "onelogin.saml2.security.logoutrequest_signed", true,
			        "onelogin.saml2.security.logoutresponse_signed", true,
			        "onelogin.saml2.security.sign_metadata", true
		        );
		    }
	    	
	    	logger.debug("saml authenticator config = \n\n{}\n", mapToLoggableStringLazy(map));
    		Saml2Settings settings = new SettingsBuilder().fromValues(map).build();
    		List<String> errors = settings.checkSettings();
    		checkArgument(errors.isEmpty(), "invalid saml configuration: %s", Joiner.on(", ").join(errors));
    		logger.debug("saml metadata = \n\n{}\b", prettifyXml(settings.getSPMetadata()));
    		return settings;
        } catch (CertificateEncodingException ex) {
	        throw runtime(ex);
	    }
    }

## Notes from cmdbuild.org
Awesome! I just got mine working now too!!!

### cmdbuild restws setconfig
Change the default org.cmdbuild.auth.module.saml.handlerScript from the default oid value to what I was getting back in the SAML response ‘samAccountName’:

`org.cmdbuild.auth.module.saml.handlerScript=login = auth.getAttribute('SamAccountName')`


### IDP / SAML Configuration
-   Secured the tomcat and cmdbuild instances with an ssl cert e.g. https.
-   Connect the IDP to AD
-   In the IDP Add a new Generic Application SSO protection for our cmdbuild. With the following needed info discovered from cmdb
    -   Service Provider Entity ID = [MATCH WHAT YOU SET IN CMDBUILD CONFIG, I JUST USED BASE URL]
    -   ACS URL = [YOUR CMDB BASE URL]/services/saml/SSO
    -   (optional) Logout URL = [YOUR CMDB BASE URL]/services/saml/SingleLogout
    -   (optional) Login URL = [YOUR CMDB BASE URL]/services/saml/Login
    -   SAML NameID Format = urn:oasis:names:tc:SAML:2.0:nameid-format:persistent
    -   SAML Response Name ID Attribute = <‘Username’>
    -   SAML Response Mapping iDP <‘Username’> to SamAccountName

###  Configuration Edit
-   CMDBuild created user accounts with matching user names to our ad accounts samAccountName. 
-  Set a generic strong password that will not be used, your saml identity provider will be checking against the actual source.
-   CMDBuild editconfig. With the base variable of org.cmdbuild.auth.module.saml.* Unless noted otherwise:

`cmdbuild restws setconfig org...`

|API Variable| Value |
|--|--|
|org.cmdbuild.auth.module.saml.sp.baseUrl  | [baseurl] |
|org.cmdbuild.auth.module.saml.sp.id  | [baseurl] |
|org.cmdbuild.auth.module.saml.sp.cert  | [cert from idprovider] |
|org.cmdbuild.auth.module.saml.sp.key  |  [cmdb-https-priv-key] |
|org.cmdbuild.auth.module.saml.idp.cert  | [cmdb-https-cert] |
|org.cmdbuild.auth.module.saml.idp.id  | https://[idp]/metadata |
|org.cmdbuild.auth.module.saml.idp.logout  | https://[idp]/slo  |
|org.cmdbuild.auth.module.saml.idp.login  | https://[idp]/sso |
|org.cmdbuild.auth.module.saml.logout.enable  | true |
|org.cmdbuild.auth.module.saml.handlerscript  | login = auth.getAttribute(‘SamAccountName’) #[Match attribute name that is sent in SAML response] |
|org.cmdbuld.auth.methods  | SamlAuthenticator, DBAuthenticator |
|org.cmdbuild.auth.modules | default, saml |

## Finishing Up
-   Restart tomcat service after changes
-   load login page and try the new login with saml button. (doesnt use the default login web form. Seems like critical info the manual should have)
-   Get redirected to your custom IDP Generic SSO App Protection created above
    -   Enter your AD login UPN that matches an already created account in CMDB
    -   (optional) login new users have to enroll MFA
    -   (optional) Approve your MFA option
-   Get redirected back to your CMDB and your in if everything lines up

## Reference
https://forum.cmdbuild.org/t/cmdbuild-3-3-2-saml2-authentication-how-to-enable/5188/8
