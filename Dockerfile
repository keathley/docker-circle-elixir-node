FROM erlang:19

ENV ELIXIR_VERSION="v1.3.2" \
    LANG=C.UTF-8 \
    NPM_CONFIG_LOGLEVEL=info \
    NODE_VERSION=6.5.0 \
    PHANTOMJS_VERSION=2.1.12

# Elixir
RUN set -xe \
        && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/releases/download/${ELIXIR_VERSION}/Precompiled.zip" \
        && ELIXIR_DOWNLOAD_SHA256="45fdb9464b0fbe44c919482f1247740cc9c5d399280ef07e386aa7402b085be7"\
        && buildDeps=' \
        unzip \
        ' \
        && apt-get update \
        && apt-get install -y --no-install-recommends $buildDeps \
        && curl -fSL -o elixir-precompiled.zip $ELIXIR_DOWNLOAD_URL \
        && echo "$ELIXIR_DOWNLOAD_SHA256 elixir-precompiled.zip" | sha256sum -c - \
        && unzip -d /usr/local elixir-precompiled.zip \
        && rm elixir-precompiled.zip \
        && apt-get purge -y --auto-remove $buildDeps \
        && rm -rf /var/lib/apt/lists/*


# NODE
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
done

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install --quiet -g "phantomjs-prebuilt@$PHANTOMJS_VERSION"

CMD ["bin/bash"]
