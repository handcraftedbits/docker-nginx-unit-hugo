# NGINX Host Hugo Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-hugo.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-hugo)

A [Docker](https://www.docker.com) container that provides a [Hugo](https://gohugo.io) unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).  This unit **only** supports Hugo sites that
are available via a remote source control repository.

# Features

* Hugo v0.16
* Can automatically regenerate your Hugo site upon a push to your [GitHub](https://github.com) repository

# Usage

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
    - HUGO_GITHUB_SECRET=password
    - HUGO_REPO_URL=https://github.com/mysite/blog.git
    - HUGO_THEME=my_hugo_theme
  volumes_from:
    - data
```

Observe the following:

* Several environment variables are used to configure Hugo.  See the
  [environment variable reference](#reference) for additional information.
* As with any other NGINX Host unit, we mount the volumes from our
  [NGINX Host data container](https://github.com/handcraftedbits/docker-nginx-host-data), in this case named `data`.

Finally, we need to create a link in our NGINX Host container to the `redirector` container in order to host
go-import-redirector.  Here is our final `docker-compose.yml` file:

```yaml
version: '2'

services:
  data:
    image: handcraftedbits/nginx-host-data

  hugo:
    image: handcraftedbits/nginx-unit-hugo
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/blog
      - HUGO_GITHUB_SECRET=password
      - HUGO_REPO_URL=https://github.com/mysite/blog.git
      - HUGO_THEME=my_hugo_theme
    volumes_from:
      - data

  proxy:
    image: handcraftedbits/nginx-host
    links:
      - redirector
    ports:
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
    volumes_from:
      - data
```

This will result in making Hugo available at `https://mysite.com/blog`.

### Theme Considerations

The NGINX Host Hugo unit assumes that all themes are stored alongside your content in your repository.  This means that
the value of the `HUGO_THEME` environment variable should specify the name of a directory in your repository that
contains the Hugo theme you wish to use.

The easiest way to store your themes alongside your content is to simply copy the theme into a directory.  A better
approach, if the theme is available in its own Git repository, is to use a
[Git submodule](https://git-scm.com/docs/git-submodule), for example:

```sh
git submodule add user@myrepo.com:my_theme my_theme
```

### Enabling Site Regeneration After GitHub Push

If your content repository is stored in GitHub, your Hugo site can be automatically regenerated after a push.  Simply
[create a GitHub webhook](https://developer.github.com/webhooks/creating/) for your repository with the URL

`https://<host>/<prefix>/rebuild`

where `<host>` is your server's hostname and `<prefix>` is `webhooks-hugo` if the environment variable
`NGINX_URL_PREFIX` is set to `/` or `webhooks-<sitePrefix>` if `NGINX_URL_PREFIX` is set to `<sitePrefix>`.
For example, if the blog is hosted at `https://mysite.com/`, then the webhook URL will be
`https://mysite.com/webhooks-hugo/rebuild`; if the blog is hosted at `https://mysite.com/blog` (i.e.,
`NGINX_URL_PREFIX` is set to `/blog`), the webhook URL will be `https://mysite.com/webhooks-blog/rebuild`.

You will also need to set the environment variable `HUGO_GITHUB_SECRET` to the secret value specified during
configuration of the webhook in GitHub.

## Running the NGINX Host go-import-redirector Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

# Reference

## Environment Variables

### `HUGO_GITHUB_SECRET`

The secret value used when setting up the Hugo site rebuild webhook on GitHub.

**Required**

### `HUGO_REPO_URL`

The URL of the Git repository hosting your Hugo site.

**Required**

### `HUGO_THEME`

The name of the theme used to render your Huge site.

**Required**

### Others

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) for information
on additional environment variables understood by this unit.
