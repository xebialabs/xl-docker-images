"use strict";(self.webpackChunkdocumentation=self.webpackChunkdocumentation||[]).push([[530],{3905:function(e,t,n){n.d(t,{Zo:function(){return u},kt:function(){return m}});var o=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);t&&(o=o.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,o)}return n}function l(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function i(e,t){if(null==e)return{};var n,o,r=function(e,t){if(null==e)return{};var n,o,r={},a=Object.keys(e);for(o=0;o<a.length;o++)n=a[o],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(o=0;o<a.length;o++)n=a[o],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var s=o.createContext({}),p=function(e){var t=o.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):l(l({},t),e)),n},u=function(e){var t=p(e.components);return o.createElement(s.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return o.createElement(o.Fragment,{},t)}},c=o.forwardRef((function(e,t){var n=e.components,r=e.mdxType,a=e.originalType,s=e.parentName,u=i(e,["components","mdxType","originalType","parentName"]),c=p(n),m=r,k=c["".concat(s,".").concat(m)]||c[m]||d[m]||a;return n?o.createElement(k,l(l({ref:t},u),{},{components:n})):o.createElement(k,l({ref:t},u))}));function m(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var a=n.length,l=new Array(a);l[0]=c;var i={};for(var s in t)hasOwnProperty.call(t,s)&&(i[s]=t[s]);i.originalType=e,i.mdxType="string"==typeof e?e:r,l[1]=i;for(var p=2;p<a;p++)l[p]=n[p];return o.createElement.apply(null,l)}return o.createElement.apply(null,n)}c.displayName="MDXCreateElement"},3712:function(e,t,n){n.r(t),n.d(t,{frontMatter:function(){return i},contentTitle:function(){return s},metadata:function(){return p},toc:function(){return u},default:function(){return c}});var o=n(7462),r=n(3366),a=(n(7294),n(3905)),l=["components"],i={sidebar_position:3},s="Dockerfile customization",p={unversionedId:"manual/customisation",id:"manual/customisation",isDocsHomePage:!1,title:"Dockerfile customization",description:"It is likely, that you might need to customize your Docker file for certain purposes which include but aren't limited to:",source:"@site/docs/manual/customisation.md",sourceDirName:"manual",slug:"/manual/customisation",permalink:"/xl-docker-images/docs/manual/customisation",tags:[],version:"current",sidebarPosition:3,frontMatter:{sidebar_position:3},sidebar:"tutorialSidebar",previous:{title:"Working with Volumes",permalink:"/xl-docker-images/docs/manual/volumes"},next:{title:"Single node deployment",permalink:"/xl-docker-images/docs/manual/single-node-deployment"}},u=[{value:"XL Deploy",id:"xl-deploy",children:[],level:2},{value:"XL Release",id:"xl-release",children:[],level:2}],d={toc:u};function c(e){var t=e.components,n=(0,r.Z)(e,l);return(0,a.kt)("wrapper",(0,o.Z)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"dockerfile-customization"},"Dockerfile customization"),(0,a.kt)("p",null,"It is likely, that you might need to customize your Docker file for certain purposes which include but aren't limited to:"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Connecting to a proprietary database (DB2, Oracle, etc.)"),(0,a.kt)("li",{parentName:"ul"},"Adding a hotfix as instructed by our support team"),(0,a.kt)("li",{parentName:"ul"},"Adding a custom plugin")),(0,a.kt)("p",null,"You can customize a docker image for your needs as described in the process below."),(0,a.kt)("h2",{id:"xl-deploy"},"XL Deploy"),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Important:")," When you create a Dockerfile with custom resources added, always remember that the owning user:group combination ",(0,a.kt)("em",{parentName:"p"},"must")," be ",(0,a.kt)("inlineCode",{parentName:"p"},"10001:0"),", or else, XL Deploy will not be able to read the files."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," Certain JARS should be placed in specific paths only. You shouldn't add a Oracle JAR to the ",(0,a.kt)("inlineCode",{parentName:"p"},"ext/")," folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," ",(0,a.kt)("inlineCode",{parentName:"p"},"${APP_HOME}")," points to the path ",(0,a.kt)("inlineCode",{parentName:"p"},"/opt/xebialabs/xl-deploy-server")," by default"),(0,a.kt)("p",null,"To begin, create a ",(0,a.kt)("inlineCode",{parentName:"p"},"Dockerfile")," that resembles the following configuration:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre"},"docker\nFROM xebialabs/xl-deploy:9.5.0\n\n###################################################################################\n# PLUGINS                                                                         #\n# Plugins should be placed under ${APP_HOME}/default-plugins/ #\n###################################################################################\n\nCOPY --chown=10001:0 files/xld-liquibase-plugin-5.0.1.xldp /opt/xebialabs/xl-deploy-server/default-plugins/\n\n# Add plugin from url\nADD --chown=10001:0 https://dist.xebialabs.com/public/community/xl-deploy/command2-plugin/3.9.1-1/command2-plugin-3.9.1-1.jar /opt/xebialabs/xl-deploy-server/default-plugins/\n\n##########################################################################\n# EXTENSIONS                                                             #\n# Extensions should be placed under ${APP_HOME}/ext\n##########################################################################\nADD --chown=10001:0 files/ext /opt/xebialabs/xl-deploy-server/ext/\n\n##########################################################################\n# HOTFIXES                                                               #\n##########################################################################\nADD --chown=10001:0 files/lib-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/lib/\nADD --chown=10001:0 files/plugin-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/plugin/\nADD --chown=10001:0 files/sattelite-lib-hotfix.jar /opt/xebialabs/xl-deploy-server/hotfix/sattelite-lib/\n\n##########################################################################\n# LIBRARIES                                                              #\n##########################################################################\nADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-deploy-server/lib/\n")),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," There are separate hotfix directories for placing different types of hotfix JARS. If you are unsure where a hotfix JAR should be placed, please get in touch with our support team."),(0,a.kt)("p",null,"For an overview of how ",(0,a.kt)("inlineCode",{parentName:"p"},"ADD")," and ",(0,a.kt)("inlineCode",{parentName:"p"},"COPY")," works, see ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/builder/#add"},"the documentation")),(0,a.kt)("p",null,"Once you are satisfied with your Dockerfile, run the following command in the same directory:"),(0,a.kt)("p",null,(0,a.kt)("inlineCode",{parentName:"p"},"docker build -t xl-deploy-custom:9.5.0 .")),(0,a.kt)("p",null,"This command will build and tag a docker image for you."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Important:")," Always use ",(0,a.kt)("a",{parentName:"p",href:"https://semver.org/"},"semver")," to version your docker images. Doing so, ensures future compatibility with one of our other tools, ",(0,a.kt)("inlineCode",{parentName:"p"},"xl up"),"."),(0,a.kt)("p",null,"To run the image locally, use the following command:"),(0,a.kt)("p",null,(0,a.kt)("inlineCode",{parentName:"p"},'docker run -it --rm -p 4516:4516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y xl-deploy-custom:9.5.0')),(0,a.kt)("p",null,"If you would like to host the docker image elsewhere, you have two options:\n",(0,a.kt)("strong",{parentName:"p"},"Recommended:")),(0,a.kt)("ol",null,(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("a",{parentName:"li",href:"https://docs.docker.com/engine/reference/commandline/push/"},"Push this image to a docker registry")," of your choice. You can either ",(0,a.kt)("a",{parentName:"li",href:"https://docs.docker.com/registry/"},"set up your own registry"),", or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run")),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"docker tag xl-deploy-custom:9.5.0 yourdockerhuborg/xl-deploy-custom:9.5.0")),(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"docker push yourdockerhuborg/xl-deploy-custom:9.5.0")),(0,a.kt)("li",{parentName:"ul"},"(On the node you would like to run the container) ",(0,a.kt)("inlineCode",{parentName:"li"},'docker run -it --rm -p 4516:4516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y yourdockerhuborg/xl-deploy-custom:9.5.0'))),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Not recommended:"),"\n2. By using ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/commandline/export/"},(0,a.kt)("inlineCode",{parentName:"a"},"docker export"))," and ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/commandline/load/"},(0,a.kt)("inlineCode",{parentName:"a"},"docker load")),". This is approach is not recommended, as it requires you to move a tar file between different machines."),(0,a.kt)("h2",{id:"xl-release"},"XL Release"),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Important:")," When you create a Dockerfile with custom resources added, always remember that the owning user:group combination ",(0,a.kt)("em",{parentName:"p"},"must")," be ",(0,a.kt)("inlineCode",{parentName:"p"},"10001:0"),"."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," Certain JARS should be placed in specific paths only. You shouldn't add a Oracle JAR to the ",(0,a.kt)("inlineCode",{parentName:"p"},"ext/")," folder, for example. If you are unsure where a JAR should be added, please get in touch with our support team."),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," ",(0,a.kt)("inlineCode",{parentName:"p"},"${APP_HOME}")," points to the path ",(0,a.kt)("inlineCode",{parentName:"p"},"/opt/xebialabs/xl-release-server")," by default"),(0,a.kt)("p",null,"To begin, create a ",(0,a.kt)("inlineCode",{parentName:"p"},"Dockerfile")," that resembles the following configuration:"),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre"},"docker\nFROM xebialabs/xl-release:9.5.0\n\n###################################################################################\n# PLUGINS                                                                         #\n# Plugins should be placed under ${APP_HOME}/default-plugins/ #\n###################################################################################\n\nCOPY --chown=10001:0 files/xlr-delphix-plugin-9.0.0.jar /opt/xebialabs/xl-release-server/default-plugins/xlr-official/\n\n# Add plugin from url\nADD --chown=10001:0 https://github.com/xebialabs-community/xlr-github-plugin/releases/download/v1.5.2/xlr-github-plugin-1.5.2.jar /opt/xebialabs/xl-release-server/default-plugins/__local__/\n\n##########################################################################\n# EXTENSIONS                                                             #\n# Extensions should be placed under ${APP_HOME}/ext\n##########################################################################\nADD --chown=10001:0 files/ext /opt/xebialabs/xl-release-server/ext/\n\n##########################################################################\n# HOTFIXES                                                               #\n##########################################################################\nADD --chown=10001:0 files/hotfix.jar /opt/xebialabs/xl-release-server/hotfix/\n\n##########################################################################\n# LIBRARIES                                                              #\n##########################################################################\nADD --chown=10001:0 files/ojdbc6.jar /opt/xebialabs/xl-release-server/lib/\n")),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Note:")," All official XL Release plugins must be placed under ",(0,a.kt)("inlineCode",{parentName:"p"},"default-plugins/xlr-official/")," folder, while custom or community plugins must be placed under ",(0,a.kt)("inlineCode",{parentName:"p"},"default-plugins/__local__/")),(0,a.kt)("p",null,"For an overview of how ",(0,a.kt)("inlineCode",{parentName:"p"},"ADD")," and ",(0,a.kt)("inlineCode",{parentName:"p"},"COPY")," works, see ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/builder/#add"},"the documentation")),(0,a.kt)("p",null,"Once you are satisfied with your Dockerfile, run the following command in the same directory"),(0,a.kt)("p",null,(0,a.kt)("inlineCode",{parentName:"p"},"docker build -t xl-release-custom:9.5.0 .")),(0,a.kt)("p",null,"This command will build and tag a docker image for you.\n",(0,a.kt)("strong",{parentName:"p"},"Important:")," Always use ",(0,a.kt)("a",{parentName:"p",href:"https://semver.org/"},"semver")," to version your docker images. This is to ensure future compatibility with one of our other tools, ",(0,a.kt)("inlineCode",{parentName:"p"},"xl up"),"."),(0,a.kt)("p",null,"To run this image locally, use the following command:"),(0,a.kt)("p",null,(0,a.kt)("inlineCode",{parentName:"p"},'docker run -it --rm -p 5516:5516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y xl-release-custom:9.5.0')),(0,a.kt)("p",null,"If you would like to host the docker image elsewhere, you have two options:"),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Recommended:")),(0,a.kt)("ol",null,(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("a",{parentName:"li",href:"https://docs.docker.com/engine/reference/commandline/push/"},"Push this image to a docker registry")," of your choice. You can either ",(0,a.kt)("a",{parentName:"li",href:"https://docs.docker.com/registry/"},"set up your own registry"),", or use an offering from DockerHub, AWS, GCP and many others. The simplest way of achieving this is to simply run")),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"docker tag xl-release-custom:9.5.0 yourdockerhuborg/xl-release-custom:9.5.0")),(0,a.kt)("li",{parentName:"ul"},(0,a.kt)("inlineCode",{parentName:"li"},"docker push yourdockerhuborg/xl-release-custom:9.5.0")),(0,a.kt)("li",{parentName:"ul"},"(On the node you would like to run the container) ",(0,a.kt)("inlineCode",{parentName:"li"},'docker run -it --rm -p 5516:5516 -e "ADMIN_PASSWORD=desired_admin_password" -e ACCEPT_EULA=Y yourdockerhuborg/xl-release-custom:9.5.0'))),(0,a.kt)("p",null,(0,a.kt)("strong",{parentName:"p"},"Not recommended:"),"\n2. By using ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/commandline/export/"},(0,a.kt)("inlineCode",{parentName:"a"},"docker export"))," and ",(0,a.kt)("a",{parentName:"p",href:"https://docs.docker.com/engine/reference/commandline/load/"},(0,a.kt)("inlineCode",{parentName:"a"},"docker load")),". This approach is not recommended, as it requires you to move a tar file between different machines."))}c.isMDXComponent=!0}}]);