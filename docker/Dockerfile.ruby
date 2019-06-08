FROM ruby:2.6.1-alpine3.9

RUN adduser -D -g 1000 -u 1000 user
RUN apk add git mysql-client mysql-dev vim build-base less --no-cache

RUN mkdir /app

USER user
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
