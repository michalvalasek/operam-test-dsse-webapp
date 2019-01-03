FROM ruby:2.5.3
MAINTAINER Michal Valasek <michal.valasek@gmail.com>

ENV RACK_ENV production
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apt-get update && \
    apt-get install -y build-essential net-tools

# Install gems
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

RUN bundle exec rake db:create && \
    bundle exec rake db:migrate

EXPOSE 8080
ENTRYPOINT bundle exec rackup -p 8080
