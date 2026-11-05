# WordPress (Apache)

WordPress on Apache, hardened and tuned, with APCu.

| | |
|---|---|
| **Image** | [`fmlabs/wordpress`](https://hub.docker.com/r/fmlabs/wordpress) |
| **Tags** | `php8.4-apache`, `php8.3-apache`, `php8.2-apache`, `php8.1-apache`, `php7.4-apache`<br>pinned: `php<version>-apache-<release>`, e.g. `php8.3-apache-261105` |
| **Base image** | [`wordpress:php<version>-apache`](https://hub.docker.com/_/wordpress) |
| **Platforms** | `linux/amd64`, `linux/arm64` |
| **Ports** | `80` |
| **Volumes** | `/var/www/html` |
| **Build** | [`Dockerfile-apache`](Dockerfile-apache) · [workflow](../.github/workflows/wordpress.yml) (on tag `wordpress-*`) |

```bash
docker pull fmlabs/wordpress:php8.3-apache
```

## Overview

A hardened, tuned build on top of the official [`wordpress:php<version>-apache`](https://hub.docker.com/_/wordpress) image.
The images are drop-in replacements: same entrypoint, same environment variables, same volume.

## Changes from the official image

| What | Where | Details |
|---|---|---|
| **APCu extension** | [`Dockerfile-apache`](Dockerfile-apache) | In-memory object cache (128 MB, 1 h TTL, off for CLI). Clears the Site Health "persistent object cache" notice **only together with** an APCu `object-cache.php` drop-in plugin. |
| **PHP security** | [`files/php.ini`](files/php.ini) | Hides the PHP version, no error output to visitors (errors go to stderr), secure session cookies. |
| **PHP limits** | [`files/php.ini`](files/php.ini) | 256 MB memory, 64 MB uploads, 60 s execution time, 3000 input vars. |
| **OPcache tuning** | [`files/php.ini`](files/php.ini) | 256 MB / 20 000 files / 60 s revalidation (official: 128 MB / 4 000 files / 2 s), plus a larger realpath cache. |
| **Apache hardening** | [`files/apache.conf`](files/apache.conf) | Hides the server version, disables TRACE and directory listings, blocks PHP in `wp-content/uploads`, denies `wp-config.php`, `xmlrpc.php`, `readme.html`, `license.txt`, `debug.log`, `.ht*`. |
| **Browser caching** | [`files/apache.conf`](files/apache.conf) | `Expires` headers: images and fonts 1 year, CSS and JS 1 month. Enables `mod_headers`. |
| **Worker limits** | [`files/apache.conf`](files/apache.conf) | Prefork capped at 16 workers (sized for about 1 GB RAM at ~60 MB per worker). |

The PHP settings load as `conf.d/zz-custom.ini` and the Apache settings as the `zz-custom` conf, so they override the defaults.

> **Note:** `xmlrpc.php` is blocked, which breaks Jetpack and the WordPress mobile apps. Remove it from the `FilesMatch` line in `apache.conf` if you need them.

## About the official image

- Maintained by the Docker community ([docker-library/wordpress](https://github.com/docker-library/wordpress)), built on the official [`php`](https://hub.docker.com/_/php) Apache image (Debian, `mod_php`, prefork MPM).
- Listens on port **80**, declares the volume **`/var/www/html`**, runs `docker-entrypoint.sh apache2-foreground`.
- On first start the entrypoint copies WordPress into an empty `/var/www/html` and writes `wp-config.php` from environment variables: `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`, `WORDPRESS_TABLE_PREFIX`, `WORDPRESS_DEBUG`, `WORDPRESS_CONFIG_EXTRA` (each also as `*_FILE` for Docker secrets).
- PHP extensions already included: `bcmath`, `exif`, `gd`, `imagick`, `intl`, `mysqli`, `opcache`, `zip` (plus the PHP defaults such as `curl`, `mbstring`, `sodium`, `xml`). Ghostscript is installed for PDF thumbnails.
- `mod_rewrite` is enabled for pretty permalinks.

### PHP versions

| Version | Official image last updated | Status |
|---|---|---|
| 8.4 | 2026-11-05 | maintained |
| 8.3 | 2026-11-05 | maintained |
| 8.2 | 2026-11-05 | maintained |
| 8.1 | 2025-12-30 | no longer updated |
| 7.4 | 2022-11-16 | no longer updated, PHP and Debian 11 both end-of-life |

See [PHP supported versions](https://www.php.net/supported-versions.php).

## Building

Locally, all versions (from the repo root):

```bash
./build_all_wordpress.sh
```

In CI, [`.github/workflows/wordpress.yml`](../.github/workflows/wordpress.yml) builds on tags `wordpress-*` and pushes `php<version>-apache` and `php<version>-apache-<release>` (for example `php8.3-apache-261105`) to Docker Hub for amd64 and arm64.

## Links

- Official image: [Docker Hub](https://hub.docker.com/_/wordpress) · [source](https://github.com/docker-library/wordpress)
- Base PHP image: [Docker Hub](https://hub.docker.com/_/php) · [source](https://github.com/docker-library/php)
- [WordPress server requirements](https://make.wordpress.org/hosting/handbook/server-environment/)
- [WordPress caching guide](https://developer.wordpress.org/advanced-administration/performance/cache/)
- [APCu manual](https://www.php.net/manual/en/book.apcu.php) · [APCu on PECL](https://pecl.php.net/package/APCu)
- [APCu object cache plugins](https://wordpress.org/plugins/search/apcu+object+cache/)
- [OPcache settings](https://www.php.net/manual/en/opcache.configuration.php)
