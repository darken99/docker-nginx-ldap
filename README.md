# docker-nginx-ldap

# Usage example
```
ldap_server ldapserver {
  url ldap://ldap:389/dc=Users,dc=example,dc=org?uid?sub?(objectClass=posixaccount);
  binddn "uid=admin,dc=example,dc=org";
  binddn_passwd "secret";
  group_attribute memberUid;
  require group 'cn=examplegroup,ou=groups,dc=example,dc=org';
  require valid_user;
  satisfy all;
}

server {
  listen 80;

  auth_ldap "Restricted access";
  auth_ldap_servers ldapserver;
}
```

## For full list of options please check
https://github.com/kvspb/nginx-auth-ldap/blob/master/README.md