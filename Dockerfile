FROM ruby:2.6.5-alpine

ARG UID=1000
ARG GID=1000

RUN addgroup -S filesafe -g $GID && adduser -D -S filesafe -G filesafe -u $UID

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

RUN chown -R $UID:$GID .

USER filesafe

COPY --chown=$UID:$GID package.json yarn.lock Gemfile Gemfile.lock /filesafe-relay/

COPY --chown=$UID:$GID vendor /filesafe-relay/vendor

RUN yarn install --frozen-lockfile

RUN gem install bundler && bundle install

COPY --chown=$UID:$GID . /filesafe-relay

RUN bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT [ "docker/entrypoint.sh" ]

CMD [ "start" ]
