require 'bundler'

# Modify .gitignore with gibo
run 'gibo dump macOS Ruby Rails JetBrains SASS SublimeText >> .gitignore' rescue nil
gsub_file '.gitignore', /^config\/initializers\/secret_token\.rb$/, ''
gsub_file '.gitignore', /^config\/secrets\.yml$/, ''

# Ruby Version
ruby_version = `ruby -v`.scan(/\d\.\d\.\d/).flatten.first
insert_into_file 'Gemfile',%(
ruby '#{ruby_version}'
), after: "source 'https://rubygems.org'"
run "echo '#{ruby_version}' > ./.ruby-version"

# Add to Gemfile
append_file 'Gemfile', <<-CODE
gem "config"
gem "jwt"

gem "kaminari"

gem "api-pagination" # for grape and kaminari
gem "grape"
gem "grape-entity"
gem "grape-swagger"
gem "grape-swagger-entity"
gem "grape-swagger-rails"

group :development do
  gem "annotate"
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman", require: false
  gem "bullet"
  gem "bundler-audit", require: false
  gem "debase"
  gem "foreman"
  gem "hirb"
  gem "onkcop", require: false
  gem "overcommit", require: false
  gem "pry-byebug"
  gem "pry-rails"
  gem "pry-stack_explorer"
  gem "rack-mini-profiler", require: false
  gem "rails_best_practices", require: false
  gem "rubocop", ">= 0.49.0", require: false
  gem "ruby-debug-ide"
end

group :test do
  gem "database_rewinder"
  gem "factory_bot_rails"
  gem "json_expressions"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "rspec-request_describer"
  gem "timecop"
end
CODE

Bundler.with_clean_env do
  run 'bundle install --path vendor/bundle --jobs=4 --without production'
  run 'bundle binstubs bundler --force'
end

# Initialize kaminari config
Bundler.with_clean_env do
  run 'bundle exec rails g kaminari:config'
end

# Set config/application.rb
application do
  %q{

    # Set grape api
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # Set locale
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja

    # Set generator
    config.generators do |g|
      g.helper false
      g.assets false
      g.orm :active_record
      g.test_framework :rspec,
        fixture:          true,
        view_specs:       false,
        helper_specs:     false,
        routing_specs:    false,
        controller_specs: true,
        request_specs:    true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
  }
end

# For Bullet (N+1 Problem)
insert_into_file 'config/environments/development.rb',%q{

  # Bullet Setting (help to kill N + 1 query)
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end
}, after: 'config.assets.debug = true'

# Improve security
insert_into_file 'config/environments/production.rb',%q{

  # Sanitizing parameter
  config.filter_parameters += [/(password|private_token|api_endpoint)/i]
}, after: 'config.active_record.dump_schema_after_migration = false'

# Set japanese locale
get 'https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml', 'config/locales/ja.yml'

# Replace puma(App Server)
run 'rm -rf config/puma.rb'
get 'https://raw.github.com/shibukk/rails5_application_template/master/config/puma.rb', 'config/puma.rb'

# Replace database setting
run 'rm -rf config/database.yml'
get 'https://raw.github.com/shibukk/rails5_application_template/master/config/database.yml', 'config/database.yml'

# Generating rake task of annotate
run 'bundle exec rails g annotate:install'

# Initialize rspec config
Bundler.with_clean_env do
  run 'bundle exec rails g rspec:install'
end

run "echo '--color -f d' > .rspec"

insert_into_file 'spec/rails_helper.rb',%q{
  config.order = 'random'

  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after :each do
    DatabaseRewinder.clean
  end

  config.before :all do
    FactoryGirl.reload
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
    FactoryGirl.find_definitions
  end

  config.include FactoryGirl::Syntax::Methods

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end
}, after: 'RSpec.configure do |config|'

insert_into_file 'spec/rails_helper.rb', "\nrequire 'factory_girl_rails'", after: "require 'rspec/rails'"
run 'rm -rf test'

# Add checker files
get 'https://raw.github.com/shibukk/rails5_application_template/master/root/.rubocop.yml', '.rubocop.yml'
get 'https://raw.github.com/shibukk/rails5_application_template/master/root/.overcommit.yml', '.overcommit.yml'

# Add docker files
get 'https://raw.github.com/shibukk/rails5_application_template/master/bin/start_server', 'bin/start_server'
get 'https://raw.github.com/shibukk/rails5_application_template/master/root/Procfile.dev', 'Procfile.dev'
get 'https://raw.github.com/shibukk/rails5_application_template/master/root/docker-compose.yml', 'docker-compose.yml'
get 'https://raw.github.com/shibukk/rails5_application_template/master/docker/.env.sample', 'docker/.env.sample'
get 'https://raw.github.com/shibukk/rails5_application_template/master/docker/mysql/Dockerfile', 'docker/mysql/Dockerfile'
get 'https://raw.github.com/shibukk/rails5_application_template/master/docker/web/Dockerfile', 'docker/web/Dockerfile'
get 'https://raw.github.com/shibukk/rails5_application_template/master/docker/proxy/Dockerfile', 'docker/proxy/Dockerfile'
run 'chmod 0755 bin/start_server'

# Update bundler-audit dics
Bundler.with_clean_env do
  run 'bundle-audit update'
end

# Add setting of wercker
if yes?('Do you use wercker? [yes or ELSE]')
  get 'https://raw.github.com/shibukk/rails5_application_template/master/root/wercker.yml', 'wercker.yml'
  gsub_file 'wercker.yml', /%RUBY_VERSION/, ruby_version
  say "Please Set SLACK_URL to https://app.wercker.com"
end

# Rubocop Auto correct
Bundler.with_clean_env do
  run 'bundle exec rubocop --auto-correct'
  run 'bundle exec rubocop --auto-gen-config'
end

# Generating overcommit
Bundler.with_clean_env do
  run 'bundle exec overcommit --sign'
end
