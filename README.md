# Bitbucket Pipelines PHP 7.2 image

[![](https://images.microbadger.com/badges/version/edbizarro/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/edbizarro/bitbucket-pipelines-php7 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/edbizarro/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/edbizarro/bitbucket-pipelines-php7 "Get your own image badge on microbadger.com")

## Based on Ubuntu 16.04

### Packages installed

- `php7.2-zip`, `php7.2-xml`, `php7.2-mbstring`, `php7.2-curl`, `php7.2-json`, `php7.2-imap`, `php7.2-mysql` and `php7.2-tokenizer`
- [Composer](https://getcomposer.org/)
- Mysql 5.7
- tar
- openssh-clientscp
- rsync
- NodeJs (NPM)
- yarn
- gulp

### Sample `bitbucket-pipelines.yml`

```YAML
image: madwebsolutions/bitbucket-pipelines-php72
pipelines:
  default:
    - step:
        script:
          - service mysql start
          - mysql -h localhost -u root -proot -e "CREATE DATABASE test;"
          - composer install --no-interaction --no-progress --prefer-dist
          - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```
