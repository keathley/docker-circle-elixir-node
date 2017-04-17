FROM keathley/elixir-node:1.4.2

ENV PHANTOMJS_VERSION=2.1.12

RUN npm install --quiet -g "phantomjs-prebuilt@$PHANTOMJS_VERSION"

CMD ["bin/bash"]
