dev:
	docker build -f Dockerfile.build -o dist .

run: dev
	docker run --rm \
			-v $(PWD)/dist:/myplugin \
			--volumes-from test \
			fluent/fluent-bit:2.1.2 \
			/fluent-bit/bin/fluent-bit \
			-f 1 \
			-e /myplugin/flb-in_docker2.so \
			-i docker2 -pLog_Level=trace $(EXTRA_ARGS)\
			-o stdout -m '*' \
			-o exit -m '*'

test: EXTRA_ARGS=
test: run
