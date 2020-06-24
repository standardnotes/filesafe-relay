FROM ruby:2.6.5-alpine

RUN apk add --update --no-cache \
    alpine-sdk \
    sqlite-dev \
    git \
    make \
    g++ \
    curl-dev \
    nodejs \
    nodejs-npm \
    yarn \
    tzdata

WORKDIR /filesafe-relay

COPY package.json yarn.lock Gemfile Gemfile.lock /filesafe-relay/

COPY vendor /filesafe-relay/vendor

RUN yarn install --frozen-lockfile

RUN gem install bundler && bundle install

COPY . /filesafe-relay

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT [ "docker/entrypoint.sh" ]

CMD [ "start" ]
