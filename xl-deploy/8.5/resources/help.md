% XL-DEPLOY (1) Container Image Pages
% XebiaLabs Development Team
% 2018-12-19

# NAME
xl-deploy \- Enterprise-scale Application Release Automation for any environment

# DESCRIPTION

# ENVIRONMENT VARIABLES
The following environment variables can be set to configure the image for different scenarios

APP_ROOT=/opt/xebialabs
    This environment variable is used to determine the directory where all application specific code will be copied. Normally there is no need to change this variable.

APP_HOME=/${APP_ROOT}/xl-deploy-server
    This environment variable is used as the landing point for all the application data. Ensure that this is a subdirectory of the ${APP_ROOT} variable. Normally there is no need to change this variable.

# VOLUMES
The following locations can be mounted as volumes to provide either configuration data, and/or persistent storage for application data.

${APP_HOME}/conf
    This directory contains the configuration files and keystores for XL Deploy. If mounted it is possible to configure (and inject) non-default configuration settings.

${APP_HOME}/hotfix/lib
    This direcory contains the hotfixes for the libraries used by XL Deploy. When instructed by XebiaLabs support personnell, you should drop any delivered hotfixes in here.

${APP_HOME}/hotfix/plugins
    This direcory contains the hotfixes for the plugins used by XL Deploy. When instructed by XebiaLabs support personnell, you should drop any delivered plugin hotfixes in here.

${APP_HOME}/ext
    This direcory contains the developed (exploded plugins) for XL Deploy.

${APP_HOME}/plugins
    This directory contains the plugins that are running in XL Deploy.

${APP_HOME}/repository
    This directory contains the embedded repository database for XL Deploy. Using the configuration injected through the ${APP_HOME}/conf volume, it is possible to configure the used database to a remotely running database engine, instead of using the embedded memory base one.

# PORTS
The port that can be exposed by default is `4516`