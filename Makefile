run: cert/bump.crt
	@docker run -it --rm -p 3128:3128 -p 3129:3129 \
    	-v $(shell pwd)/config/squid.conf:/etc/squid/squid.conf \
    	-v $(shell pwd)/config/allowlist.txt:/etc/squid/allowlist.txt \
    	-v $(shell pwd)/cert:/etc/squid/cert \
    	ghcr.io/nikkomiu/squid-docker:main

cert/bump.crt:
	@docker run -it --rm -v $(shell pwd)/cert:/etc/squid/cert ghcr.io/nikkomiu/squid-docker:main gen-cert

build:
	@docker build -t ghcr.io/nikkomiu/squid-docker:main .

clean:
	@sudo rm -rf cert/
