"use strict";(self.webpackChunkdocumentation=self.webpackChunkdocumentation||[]).push([[730],{3905:function(e,t,o){o.d(t,{Zo:function(){return c},kt:function(){return m}});var n=o(7294);function r(e,t,o){return t in e?Object.defineProperty(e,t,{value:o,enumerable:!0,configurable:!0,writable:!0}):e[t]=o,e}function a(e,t){var o=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),o.push.apply(o,n)}return o}function l(e){for(var t=1;t<arguments.length;t++){var o=null!=arguments[t]?arguments[t]:{};t%2?a(Object(o),!0).forEach((function(t){r(e,t,o[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(o)):a(Object(o)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(o,t))}))}return e}function i(e,t){if(null==e)return{};var o,n,r=function(e,t){if(null==e)return{};var o,n,r={},a=Object.keys(e);for(n=0;n<a.length;n++)o=a[n],t.indexOf(o)>=0||(r[o]=e[o]);return r}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)o=a[n],t.indexOf(o)>=0||Object.prototype.propertyIsEnumerable.call(e,o)&&(r[o]=e[o])}return r}var s=n.createContext({}),p=function(e){var t=n.useContext(s),o=t;return e&&(o="function"==typeof e?e(t):l(l({},t),e)),o},c=function(e){var t=p(e.components);return n.createElement(s.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},u=n.forwardRef((function(e,t){var o=e.components,r=e.mdxType,a=e.originalType,s=e.parentName,c=i(e,["components","mdxType","originalType","parentName"]),u=p(o),m=r,h=u["".concat(s,".").concat(m)]||u[m]||d[m]||a;return o?n.createElement(h,l(l({ref:t},c),{},{components:o})):n.createElement(h,l({ref:t},c))}));function m(e,t){var o=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var a=o.length,l=new Array(a);l[0]=u;var i={};for(var s in t)hasOwnProperty.call(t,s)&&(i[s]=t[s]);i.originalType=e,i.mdxType="string"==typeof e?e:r,l[1]=i;for(var p=2;p<a;p++)l[p]=o[p];return n.createElement.apply(null,l)}return n.createElement.apply(null,o)}u.displayName="MDXCreateElement"},8696:function(e,t,o){o.r(t),o.d(t,{frontMatter:function(){return i},contentTitle:function(){return s},metadata:function(){return p},toc:function(){return c},default:function(){return u}});var n=o(7462),r=o(3366),a=(o(7294),o(3905)),l=["components"],i={sidebar_position:2},s="Upgrade XL Deploy active-active cluster setup with docker compose",p={unversionedId:"manual/xl-deploy-ha/upgrade-multi-node-deployment",id:"manual/xl-deploy-ha/upgrade-multi-node-deployment",isDocsHomePage:!1,title:"Upgrade XL Deploy active-active cluster setup with docker compose",description:"Steps",source:"@site/docs/manual/xl-deploy-ha/upgrade-multi-node-deployment.md",sourceDirName:"manual/xl-deploy-ha",slug:"/manual/xl-deploy-ha/upgrade-multi-node-deployment",permalink:"/xl-docker-images/docs/manual/xl-deploy-ha/upgrade-multi-node-deployment",tags:[],version:"current",sidebarPosition:2,frontMatter:{sidebar_position:2},sidebar:"tutorialSidebar",previous:{title:"XL Deploy active-active cluster setup with docker compose",permalink:"/xl-docker-images/docs/manual/xl-deploy-ha/README"},next:{title:"XL Release active-active cluster setup with docker compose",permalink:"/xl-docker-images/docs/manual/xl-release-ha/README"}},c=[{value:"Steps",id:"steps",children:[],level:3}],d={toc:c};function u(e){var t=e.components,o=(0,r.Z)(e,l);return(0,a.kt)("wrapper",(0,n.Z)({},d,o,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"upgrade-xl-deploy-active-active-cluster-setup-with-docker-compose"},"Upgrade XL Deploy active-active cluster setup with docker compose"),(0,a.kt)("h3",{id:"steps"},"Steps"),(0,a.kt)("p",null,"Follow these steps to Upgrade XL Deploy active-active cluster setup,"),(0,a.kt)("ol",null,(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},"Make sure to read our docs for upgrade and release notes for each version you want to upgrade to.")),(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},"Stop the current running instances of XL Deploy docker containers which have old version that need to be upgraded. You do not need to stop the load balancer, mq and database containers. See the example below:"),(0,a.kt)("pre",{parentName:"li"},(0,a.kt)("code",{parentName:"pre",className:"language-shell"}," # Shutdown deployments\n docker-compose  -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml stop xl-deploy-master xl-deploy-worker\n"))),(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},"Update both files ",(0,a.kt)("inlineCode",{parentName:"p"},"docker-compose-xld-ha.yaml")," and ",(0,a.kt)("inlineCode",{parentName:"p"},"docker-compose-xld-ha-workers.yaml")))),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Update the image with the new tag which represents the version you want to upgrade to, for both master and worker, for example:",(0,a.kt)("pre",{parentName:"li"},(0,a.kt)("code",{parentName:"pre",className:"language-shell"}," xl-deploy-master:\n   image: xebialabs/xl-deploy:9.5.1\n"))),(0,a.kt)("li",{parentName:"ul"},"Specify your DB connection details, to point to an old DB for both master and worker for example using environment variables such as ",(0,a.kt)("inlineCode",{parentName:"li"},"XL_DB_URL")),(0,a.kt)("li",{parentName:"ul"},'Include all volumes already being used with old docker images for both master and worker. In case of "conf" volume, make sure to also update any configurations required by new version "check release notes", before mounting it to new version of the container.'),(0,a.kt)("li",{parentName:"ul"},"Update the environment variables to include ",(0,a.kt)("inlineCode",{parentName:"li"},"FORCE_UPGRADE")," for  master nodes,  see below,",(0,a.kt)("pre",{parentName:"li"},(0,a.kt)("code",{parentName:"pre",className:"language-shell"}," environment:\n       - FORCE_UPGRADE=true\n")))),(0,a.kt)("ol",{start:4},(0,a.kt)("li",{parentName:"ol"},"You can use the provided ",(0,a.kt)("inlineCode",{parentName:"li"},"run.sh")," to bring up the setup or do it manually by following the steps mentioned below. Update the passwords to represent Passwords used in previous version.")),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-shell"},"# Set passwords\nexport XLD_ADMIN_PASS=admin\nexport RABBITMQ_PASS=admin\nexport POSTGRES_PASS=admin\n\n# upgrade master nodes only. You should not change the number of master nodes here, it must be 2\ndocker-compose -f docker-compose-xld-ha.yaml up --scale xl-deploy-master=2 -d\n\n# get the IP of master nodes, change the container names if you are not inside a folder named \"xl-deploy-ha\"\nexport XLD_MASTER_1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_1)\nexport XLD_MASTER_2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' xl-deploy-ha_xl-deploy-master_2)\n\n# Deploy the worker nodes, you can change the number of nodes here if you wish\ndocker-compose -f docker-compose-xld-ha-workers.yaml up --scale xl-deploy-worker=2 -d\n\n# Print out the status\ndocker-compose -f docker-compose-xld-ha.yaml -f docker-compose-xld-ha-workers.yaml ps\n")),(0,a.kt)("ol",{start:5},(0,a.kt)("li",{parentName:"ol"},"You can view the logs of individual containers using the ",(0,a.kt)("inlineCode",{parentName:"li"},"docker logs <container_name> -f")," command."),(0,a.kt)("li",{parentName:"ol"},"You can access XL Deploy UI at http://localhost:8080")))}u.isMDXComponent=!0}}]);