# NGINX Host Hugo Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-hugo.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-hugo)

A [Docker](https://www.docker.com) container that provides a [Hugo](https://gohugo.io) unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).  This unit **only** supports Hugo sites that
are available via a remote source control repository.

# Features

* Hugo v0.30.2
* Can automatically regenerate your Hugo site upon a push to your [GitHub](https://github.com) or
  [GitLab](https://gitlab.com) repository

# Usage

## Prerequisites

### `NGINX_UNIT_HOSTS` Considerations

It is important that the value of your `NGINX_UNIT_HOSTS` environment variable doesn't include wildcards or regular
expressions as this value will be used by Hugo to determine the base URL of your site.  Also, if the variable contains
multiple hosts (e.g., `myhost.com,otherhost.com`), only the first host (the one before the `,`) will be used.

## Configuration

It is highly recommended that you use container orchestration software such as
[Docker Compose](https://www.docker.com/products/docker-compose) when using this NGINX Host unit as several Docker
containers are required for operation.  This guide will assume that you are using Docker Compose.

To begin, start with a basic `docker-compose.yml` file as described in the
[NGINX Host configuration guide](https://github.com/handcraftedbits/docker-nginx-host#configuration).  Then, add a
service for the NGINX Host Hugo unit (named `hugo`):

```yaml
hugo:
  image: handcraftedbits/nginx-unit-hugo
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/blog
    - HUGO_REPO_URL=https://github.com/mysite/blog.git
    - HUGO_REPO_SECRET=password
    - HUGO_THEME=my_hugo_theme
  volumes:
    - data:/opt/container/shared
```

Observe the following:

* Several environment variables are used to configure Hugo.  See the
  [environment variable reference](#reference) for additional information.
* As with any other NGINX Host unit, we mount our data volume, in this case named `data`, to `/opt/container/shared`.

Finally, we need to create a link in our NGINX Host container to the `hugo` container in order to host Hugo.  Here is
our final `docker-compose.yml` file:

```yaml
version: "2.1"

volumes:
  data:

services:
  hugo:
    image: handcraftedbits/nginx-unit-hugo
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/blog
      - HUGO_REPO_URL=https://github.com/mysite/blog.git
      - HUGO_REPO_SECRET=password
      - HUGO_THEME=my_hugo_theme
    volumes:
      - data:/opt/container/shared

  proxy:
    image: handcraftedbits/nginx-host
    links:
      - hugo
    ports:
      - "443:443"
    volumes:
      - data:/opt/container/shared
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
```

This will result in making Hugo available at `https://mysite.com/blog`.

### Theme Considerations

The NGINX Host Hugo unit assumes that all themes are stored alongside your content in your repository.  This means that
the value of the `HUGO_THEME` environment variable should specify the name of a directory in your repository that
contains the Hugo theme you wish to use.

The easiest way to store your themes alongside your content is to simply copy the theme into a directory.  A better
approach, if the theme is available in its own Git repository, is to use a
[Git submodule](https://git-scm.com/docs/git-submodule), for example:

```bash
git submodule add user@myrepo.com:my_theme themes/my_theme
```

### Enabling Site Regeneration After Git Repository Push

If your content repository is stored in GitHub or GitLab, your Hugo site can be automatically regenerated after a push.
Simply [create a GitHub webhook](https://developer.github.com/webhooks/creating/) or a
[GitLab webhook](https://docs.gitlab.com/ce/user/project/integrations/webhooks.html) for your repository with the URL

`https://<host>/<prefix>/rebuild`

where `<host>` is your server's hostname and `<prefix>` is `webhooks-hugo` if the environment variable
`NGINX_URL_PREFIX` is set to `/` or `webhooks-<sitePrefix>` if `NGINX_URL_PREFIX` is set to `<sitePrefix>`.
For example, if the blog is hosted at `https://mysite.com/`, then the webhook URL will be
`https://mysite.com/webhooks-hugo/rebuild`; if the blog is hosted at `https://mysite.com/blog` (i.e.,
`NGINX_URL_PREFIX` is set to `/blog`), the webhook URL will be `https://mysite.com/webhooks-blog/rebuild`.

You will also need to set the environment variable `HUGO_REPO_SECRET` to the secret value specified during
configuration of the webhook in GitHub or GitLab.

### Pre-build Script

You can run a pre-build script (for example, to copy resources before Hugo generates your site) by attaching a file to
the `/opt/container/script/pre-hugo-build.sh` volume, for example:

```yaml
hugo:
  image: handcraftedbits/nginx-unit-hugo
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/blog
    - HUGO_REPO_URL=https://github.com/mysite/blog.git
    - HUGO_REPO_SECRET=password
    - HUGO_THEME=my_hugo_theme
  volumes:
    - data:/opt/container/shared
    - /home/me/my-pre-build-script.sh:/opt/container/script/pre-hugo-build.sh
```

The directory where your Hugo repository has been cloned will be provided to this script as the first argument.

### Post-build Script

You can run a post-build script (for example, to minimize HTML after Hugo generates your site) by attaching a file to
the `/opt/container/script/post-hugo-build.sh` volume, for example:

```yaml
hugo:
  image: handcraftedbits/nginx-unit-hugo
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/blog
    - HUGO_REPO_URL=https://github.com/mysite/blog.git
    - HUGO_REPO_SECRET=password
    - HUGO_THEME=my_hugo_theme
  volumes:
    - data:/opt/container/shared
    - /home/me/my-post-build-script.sh:/opt/container/script/post-hugo-build.sh
```

The directory where your Hugo repository has been cloned will be provided to this script as the first argument.

## Running the NGINX Host Hugo Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

# Reference

## Environment Variables

### `HUGO_IGNORE_CACHE`

Used to ignore Hugo's cache directory (i.e., calls Hugo with the `--ignoreCache` parameter) if set to `true`.

**Default value**: `false`

### `HUGO_REPO_BRANCH`

The branch of the Git repository hosting your Hugo site.

**Default value**: `master`

### `HUGO_REPO_SECRET`

The secret value used when setting up the Hugo site rebuild webhook on GitHub or GitLab.

**Required**

### `HUGO_REPO_URL`

The URL of the Git repository hosting your Hugo site.

**Required** if your Git repository is hosted on GitHub or GitLab.

### `HUGO_THEME`

The name of the theme used to render your Hugo site.

**Required**

### Others

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) and
[docker-nginx-unit-webhook documentation](https://github.com/handcraftedbits/docker-nginx-unit-webhook#environment-variables)
for information on additional environment variables understood by this unit.
