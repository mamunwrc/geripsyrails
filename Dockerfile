FROM emiedlar/geripsy:base

ENV RAILS_ENV production

ENV RUBY_ROOT="/usr/local/ruby/2_7_7"
ENV RUBY_BIN="$RUBY_ROOT/bin"
ENV RUBY_INC="$RUBY_ROOT/include"
ENV RUBY_LIB="$RUBY_ROOT/lib"

ENV PATH="$RUBY_BIN:$PATH"
ENV LD_LIBRARY_PATH="$RUBY_LIB:/usr/local/lib:$LD_LIBRARY_PATH"
ENV CPATH="$RUBY_INC:$CPATH"

ADD . /app
WORKDIR /app
RUN bundle install --without development test
RUN set -a && . /app/.aptible.env && bundle exec rake assets:precompile --trace

ENV PORT 3000
EXPOSE 3000
