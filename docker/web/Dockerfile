FROM node:9.3.0 as node
FROM ruby:2.5.0

RUN mkdir -p /app
WORKDIR /app

# node
RUN mkdir -p /opt/yarn
COPY --from=node /opt/yarn /opt/yarn
COPY --from=node /usr/local/bin/nodejs /usr/local/bin/
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn/bin/yarn /usr/local/bin/yarnpkg \
  && ln -s /usr/local/bin/nodejs /usr/local/bin/node

COPY package.json /app/
COPY yarn.lock /app/
RUN yarn install

# rails
RUN apt-get update \
  && apt-get install -y locales mysql-client --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

COPY Gemfile* /app/
RUN bundle install --jobs=4 --path=/bundle
COPY Procfile.dev /app/

ENTRYPOINT ["./bin/start_server"]
CMD ["bundle", "exec", "foreman", "start", "-f", "Procfile.dev"]