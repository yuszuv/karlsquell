FROM hublogix/minimal-ruby:latest

RUN apk add mysql-client vim --no-cache

ADD . /app
WORKDIR /app

ENV ENV="/root/.ashrc"
RUN gem install differ
RUN echo 'PATH=$PATH:/app/ && export PATH' > "$ENV"

