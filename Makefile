export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit
BASE_VERSION:=3.1.9

dev:
	docker build -f Dockerfile.build -o dist .


.PHONY: build-tester
build-tester:
	docker build -f Dockerfile.build --target tester -t tmp-fluent-bit-in-docker2-tester .

# use `gmake` from homebrew, not `make`
.ONESHELL:
.PHONY: test
test: dev build-tester 
	function testMAKE {
		echo "THIS WILL BREAK ON MAKE BEFORE 3.82 (early fail check) - on mac, install make with brew and then use `gmake test` (instead of `make`)"
	}
	docker run --rm -d \
			-v $(PWD)/dist:/myplugin \
			--privileged \
			--name tmp-fluent-bit-in-docker2-testrun \
			tmp-fluent-bit-in-docker2-tester \
			dockerd
	sleep 1
	function tearDown {
		docker kill tmp-fluent-bit-in-docker2-testrun
	}
	trap tearDown EXIT

	docker exec -ti tmp-fluent-bit-in-docker2-testrun docker run -d alpine tail -f /dev/null
	docker exec -ti tmp-fluent-bit-in-docker2-testrun docker ps
	docker exec -ti tmp-fluent-bit-in-docker2-testrun \
			/fluent-bit/bin/fluent-bit \
			-f 1 \
			-e /myplugin/flb-in_docker2.so \
			-i docker2 \
			-pLog_Level=trace \
			-o stdout -m '*' \
			-o exit -m '*'


update-plugin:
	curl https://github.com/fluent/fluent-bit/archive/refs/tags/v$(BASE_VERSION).zip -Lo plugin.zip
	unzip plugin.zip 'fluent-bit-$(BASE_VERSION)/plugins/in_docker/*'
	rm plugin.zip
	rm -fr upstream-in_docker
	mv 'fluent-bit-$(BASE_VERSION)/plugins/in_docker/' upstream-in_docker/
	rm -fr 'fluent-bit-$(BASE_VERSION)'
