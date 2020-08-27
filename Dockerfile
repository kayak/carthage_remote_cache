FROM ruby:2.7.1-alpine3.12

RUN apk add --no-cache g++ make
RUN gem install carthage_remote_cache

EXPOSE 9292
CMD ["carthagerc", "server"]
