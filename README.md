# Application Template for Rails5

Rails5 Application Template. - [Rails Application Templates — Ruby on Rails Guides](http://guides.rubyonrails.org/rails_application_templates.html)

It's enhanced version of [morizyun/rails5_application_template](https://github.com/morizyun/rails5_application_template).

## Preparation

### Upgrading ruby version in rbenv

Fill following commands:

```
# Update Homebrew
$ brew update

# Generate modern .gitignore
$ brew install gibo

# Install automake for ffi instalation fails
$ brew install automake

# Install yarn for webpacker
$ brew install yarn

# Update ruby-build
$ brew upgrade ruby-build

# Show some ruby versions which rbenv can install
$ rbenv install --list

# Install latest Ruby(e.g. 2.5.0)
$ rbenv install 2.5.0
```

### Install latest Rails gem

```
# Set to use rails latest version(e.g. 5.1.5)
$ gem install rails -v 5.1.5
```

## Execution command

Execute following commands:

```
# If you want to use MySQL and Vue.js, please execute following command;
$ rails new _your_app_name_ --database=mysql --force --skip-bundle --skip-turbolinks --skip-test --skip-action-cable --webpack=vue -m https://raw.github.com/shibukk/rails5_application_template/master/template.rb

# If you want to use MySQL and React, please execute following command;
$ rails new _your_app_name_ --database=mysql --force --skip-bundle --skip-turbolinks --skip-test --skip-action-cable --webpack=react -m https://raw.github.com/shibukk/rails5_application_template/master/template.rb

# Copy settings file for docker
$ cp ./docker/.env.sample ./docker/.env

# After you create rails project, then there is no more need to use the directories.
$ rm -rf vendor/bundle
$ rm -rf node_modules

# Please edit `config/webpacker.yml` file below, for socket of webpacker
#
#  dev_server:
#    https: false
#    host: 0.0.0.0

# Start up your application
$ docker-compose up
```

## Thanks!

Description of this template in Japanese is as follows;

**[Rails 5.0.0 + Bootstrap 1コマンドで！ - 酒と泪とRubyとRailsと](http://morizyun.github.io/blog/rails5-application-templates/)**
