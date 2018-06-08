# install_tomcat

TODO: Enter the cookbook description here.
1. Prerequisites/assumptions for Tomcat Installation Cookbook:
- Target node is Centos 7
- Target node has access to the interwebs
- Chef server is Hosted Chef instance
- root access on target node - understood that sudo would be more likely in production
- chef-client executed locally on node

2. Workshop summary & overview
- Minimum viable product - cookbook works and can be executed multiple times without error
- For production version, the following approach would be added:
  - additional template files
  - incorporate other recipes for Tomcat deployment (for example)
  - less use of bash and execute - recursive changes to directory permissions would still be achieved through execute as guidance is that the Chef approach to recursive changes slows updates down in a production environment

3. Recipe takes the following approach:
- installs Java 1.7 JDK package using yum_package resource
- creates group called tomcat to specify tomcat application specific permissions
- creates a user called tomcat with the appropriate settings, shell etc.
- pulls down the Apache Tomcat 8.5.20 installation tarball only if hasn't been updated since the last installation (unlikely but wanted to add some checks in there)
- extracts the tarball
- recursively changes directory and group permissions on tomcat files and directory
- lays down the tomcat service file using tomcat.service.erb template
- reloads the tomcat service configuration
- enables the tomcat service and startit
- verify that the tomcat server is responding on the appropriate localhost port -
