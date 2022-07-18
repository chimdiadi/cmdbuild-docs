## References

### httpd Configure mod_proxy_tunnel
https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html

### Cmdbuild Configure websocket proxy tunnel
The key here is that the solution works as long as you've enabled SSL termination in the tomcat service.
But if you're doing ssl termination in httpd. Then, you'll need to proxy ws --> wss
Evrything else will then work as expected.

I cheated and set /etc/hosts rather than DNS to ensure that it was working internally before deployment.
	127.0.0.1 <servername> 

https://forum.cmdbuild.org/t/websocket-connection-failed-when-using-apache2-as-reverse-proxy/5473

### httpd Multiple ProxyPass
Totally legal to do multiple proxypass for different endpoints
https://stackoverflow.com/questions/45914235/configure-apache-with-multiple-proxypass

    ProxyPass /webhook1  http://localhost:8080
    ProxyPassReverse /webhook1 http://localhost:8080
    ProxyPass /  http://localhost:8077
    ProxyPassReverse / http://localhost:8077


### Enable mox_proxy_wstunnel
https://www.server-world.info/en/note?os=CentOS_7&p=httpd2&f=5

    [root@www ~]# vi /etc/httpd/conf.modules.d/00-proxy.conf
    # add to the end
    LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so
    [root@www ~]# vi /etc/httpd/conf.d/wstunnel.conf
    # create new
    ProxyRequests Off
    <Proxy *>
        Require all granted
    </Proxy>
    
    ProxyPass /socket.io/ http://127.0.0.1:1337/socket.io/
    ProxyPassReverse /socket.io/ http://127.0.0.1:1337/socket.io/
    
    ProxyPass /chat http://127.0.0.1:1337/
    ProxyPassReverse /chat http://127.0.0.1:1337/
    
    [root@www ~]# systemctl restart httpd

### ws to wss Proxy
https://stackoverflow.com/questions/42764084/php-websocket-on-ssl-with-proxy-wstunnel-apache

**SSL (Secure)**

    <VirtualHost *:443>
        DocumentRoot /FILE_PATH_TO_WEBROOT
        ServerName local.sitename.com
        ServerAlias local.sitename.com
        <Directory /FILE_PATH_TO_WEBROOT>
            Options FollowSymLinks
            AllowOverride all
            php_flag display_errors On
            Require all granted
        </Directory>
        SSLCertificateFile /etc/httpd/ssl/.crt
        SSLCertificateKeyFile /etc/httpd/ssl/.key
    
        ProxyRequests Off
        ProxyPass "/ws/"  "ws://local.sitename.com:8080/"
    </VirtualHost>
    
**NON-SSL (Insecure)**

    <VirtualHost *:80>
        DocumentRoot /FILE_PATH_TO_WEBROOT
        ServerName local.sitename.com
        ServerAlias local.sitename.com
        <Directory /FILE_PATH_TO_WEBROOT>
            Options FollowSymLinks
            AllowOverride all
            php_flag display_errors On
            Require all granted
        </Directory>
        ProxyRequests Off
        ProxyPass "/ws/"  "ws://local.sitename.com:8080/"
    </VirtualHost>

### Set Root Path in tomcat
The goal here was to attempt to avoid needles rewrite rules if I could get tomcat to be responsible for setting the app as the root context.
I still think this can work but as of this writing, I paused on this.
https://stackoverflow.com/questions/5638787/default-web-app-in-tomcat


*** Insert the Context ***

    <Context path="" docBase="/usr/local/tomcat/mywebapps/myapplication">
        <WatchedResource>WEB-INF/web.xml</WatchedResource>
    </Context>

*** /opt/tomcat/conf/server.xml ***
    <?xml version='1.0' encoding='utf-8'?>
	     ....
                    <!-- Access log processes all example. Documentation at: /docs/config/valve.html
                        Note: The pattern used is equivalent to using pattern="common" -->
                    <Valve className="org.apache.catalina.valves.AccessLogValve"
                        directory="logs" prefix="localhost_access_log." suffix=".txt"
                        pattern="%h %l %u %t &quot;%r&quot; %s %b" resolveHosts="false" />
    
                    <Context path="" docBase="/usr/local/tomcat/mywebapps/myapplication">
                        <WatchedResource>WEB-INF/web.xml</WatchedResource>
                    </Context>
    
                </Host>
            </Engine>
        </Service>
    </Server>
   

### Eable Reverse Proxy to Tomcat

***Default:***
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443"/>

***Shoud Be:***
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443"
               proxyName="my.nginx.node"
               proxyPort="443"
               scheme="https"/>


### Apache - Init: Can't open server private key file
https://stackoverflow.com/questions/22261037/apache-init-cant-open-server-private-key-file

`restorecon -RvF /etc/ssl/certs/`

`systemctl restart httpd`

### Apache proxy not working for a localhost port
https://serverfault.com/questions/382076/apache-proxy-not-working-for-a-localhost-port

`setsebool -P httpd_can_network_connect on`

