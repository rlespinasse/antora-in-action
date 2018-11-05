FROM antora/antora

RUN env BUILD_ONLY=true \
        yarn global add asciidoctor.js \
                        asciidoctor-plantuml

WORKDIR /antora

ENTRYPOINT [ "antora" ]
