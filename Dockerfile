FROM fedora:41

RUN yum install -y squid

COPY scripts/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
