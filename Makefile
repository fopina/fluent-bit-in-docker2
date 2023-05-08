dev:
	docker build -f Dockerfile.build -o dist .

run: dev
	docker run --rm \
			-v $(PWD)/dist:/myplugin \
			fluent/fluent-bit:1.9.10 \
			/fluent-bit/bin/fluent-bit \
			-f 1 \
			-e /myplugin/flb-in_docker2.so \
			-i docker2 $(EXTRA_ARGS)\
			-o stdout -m '*' \
			-o exit -m '*'

test: EXTRA_ARGS=-q
test: run
