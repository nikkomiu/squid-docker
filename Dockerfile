FROM fedora:41

RUN yum install -y squid openssl

COPY scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "proxy" ]
