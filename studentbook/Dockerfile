FROM ruby:2.4.1-jessie

WORKDIR /usr/src/app

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && \
    gem install bundler

COPY Gemfile .

COPY Gemfile.lock .

RUN bundle install

COPY . .

CMD ["rails","server","-b","0.0.0.0"]
