FROM lachlanevenson/k8s-kubectl:v1.13.4

RUN apk add --update --no-cache jq

COPY deploy /bin/
COPY mkkubeconfig /bin/

ENTRYPOINT [""]
