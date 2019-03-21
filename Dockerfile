FROM lachlanevenson/k8s-kubectl:v1.13.4

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
