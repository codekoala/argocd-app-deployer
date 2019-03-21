FROM lachlanevenson/k8s-kubectl:v1.13.4

COPY deploy /bin/
ENTRYPOINT ["/bin/deploy"]
