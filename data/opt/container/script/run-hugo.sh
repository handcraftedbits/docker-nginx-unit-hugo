#!/bin/bash

. /opt/container/script/unit-utils.sh

# Check required environment variables and fix the NGINX unit configuration.

checkCommonRequiredVariables

requiredVariable HUGO_REPO_URL
requiredVariable HUGO_THEME

notifyUnitLaunched

filename=`copyUnitConf nginx-unit-hugo`
normalized_prefix=`normalizeSlashes "/${NGINX_URL_PREFIX}/"`
post_build_script=/opt/container/script/post-hugo-build.sh
pre_build_script=/opt/container/script/pre-hugo-build.sh
repo_dir=/var/www/hugo-`randomInt`
base_url=`echo ${NGINX_UNIT_HOSTS} | cut -d"," -f1`

fileSubstitute ${filename} normalized_prefix $normalized_prefix
fileSubstitute ${filename} repo_dir ${repo_dir}

logUrlPrefix "hugo"

# If there is no URL prefix we don't need a rewrite rule that automatically changes /prefix to /prefix/.

if [ "${normalized_prefix}" == "/" ]
then
     sed -i "s/#rewrite.*//g" ${filename}
else
     sed -i "s/#rewrite/rewrite/g" ${filename}

     fileSubstitute ${filename} prefix_no_trailing_slash `echo $normalized_prefix | sed "s%/$%%g"`
fi

# Do the initial clone and build of the Hugo site.

git clone --recursive -b ${HUGO_REPO_BRANCH:-master} ${HUGO_REPO_URL} ${repo_dir}

if [ -f ${pre_build_script} ]
then
     chmod +x ${pre_build_script}
     
     ${pre_build_script} ${repo_dir}
fi

/opt/hugo/hugo -s ${repo_dir} --theme=${HUGO_THEME} --baseURL=https://${base_url}${normalized_prefix}

if [ -f ${post_build_script} ]
then
     chmod +x ${post_build_script}
     
     ${post_build_script} ${repo_dir}
fi

cp -R ${repo_dir} ${repo_dir}.last

# Set up webhooks.

if [ "${normalized_prefix}" == "/" ]
then
     export NGINX_URL_PREFIX="/webhooks-hugo"
else
     fixedPrefix=`echo ${normalized_prefix} | sed "s%/%%g"`

     export NGINX_URL_PREFIX="/webhooks-${fixedPrefix}"
fi

logInfo "using URL prefix '${NGINX_URL_PREFIX}' for Hugo webhooks"

webhook_config=/opt/container/webhooks.json
webhook_script=/opt/container/script/on-webhook-triggered.sh

cp /opt/container/template/webhooks.json.template ${webhook_config}
cp /opt/container/template/on-webhook-triggered.sh.template ${webhook_script}
chmod +x ${webhook_script}

fileSubstitute ${webhook_config} HUGO_GITHUB_SECRET ${HUGO_GITHUB_SECRET}
fileSubstitute ${webhook_script} HUGO_THEME ${HUGO_THEME}
fileSubstitute ${webhook_script} HUGO_BASE_URL https://${NGINX_UNIT_HOSTS}${normalized_prefix}
fileSubstitute ${webhook_script} repo_dir `basename ${repo_dir}`

notifyUnitStarted

# Start webhooks.

/bin/bash /opt/container/script/run-webhook.sh
