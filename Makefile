FLAGS := -trimpath
NOCGO := CGO_ENABLED=0

build::
	go vet && go fmt
	${NOCGO} go build ${FLAGS} -o wormhole

install::
	sudo cp wormhole /usr/local/bin

run::
	./wormhole -verb=true test-fixture

run-ro::
	./wormhole -verb=true -ro=true test-fixture

run-extra::
	./wormhole -verb=true -prefix="/fancy-path/" -k=false -symlinks=true test-fixture

ci:: build-all test
	echo "done"

test::
	-@cd test-fixture && ln -s ../support .; true
	go test -cover -c -tags testrunmain

	timeout -s SIGINT 3 ./wormhole.test -test.coverprofile=normal.out -test.run '^TestRunMain' -verb=true test-fixture &
	sleep 2
	go test -run TestNormal
	sleep 1

	timeout -s SIGINT 3 ./wormhole.test -test.coverprofile=extra.out -test.run '^TestRunMain' -prefix='/fancy-path/' -k=false -symlinks=true test-fixture &
	sleep 2
	go test -run TestExtra
	sleep 1

	timeout -s SIGINT 3 ./wormhole.test -test.coverprofile=ro.out -test.run '^TestRunMain' -ro=true test-fixture &
	sleep 2
	go test -run TestRo
	sleep 1

	# gocovmerge ro.out extra.out normal.out > all.out
	# go tool cover -html all.out
	# go tool cover -func=all.out | grep main | grep '9.\..\%'

watch::
	ls wormhole.go wormhole_test.go ui/* | entr -rc make build run

watch-extra::
	ls wormhole.go wormhole_test.go ui/* | entr -rc make build run-extra

watch-ro::
	ls wormhole.go wormhole_test.go ui/* | entr -rc make build run-ro

watch-test::
	ls wormhole.go wormhole_test.go ui/* | entr -rc make test

build-all:: build
	go version
	${NOCGO} GOOS=linux   GOARCH=amd64 go build ${FLAGS} -o builds/wormhole-linux-x64
	${NOCGO} GOOS=linux   GOARCH=arm   go build ${FLAGS} -o builds/wormhole-linux-arm
	${NOCGO} GOOS=linux   GOARCH=arm64 go build ${FLAGS} -o builds/wormhole-linux-arm64
	${NOCGO} GOOS=darwin  GOARCH=amd64 go build ${FLAGS} -o builds/wormhole-mac-x64
	${NOCGO} GOOS=darwin  GOARCH=arm64 go build ${FLAGS} -o builds/wormhole-mac-arm64
	${NOCGO} GOOS=windows GOARCH=amd64 go build ${FLAGS} -o builds/wormhole-windows.exe
	sha256sum builds/* | tee builds/buildout

clean::
	rm -f wormhole
	rm -f wormhole-linux64
	rm -f wormhole-linux-arm
	rm -f wormhole-linux-arm64
	rm -f wormhole-mac
	rm -f wormhole-windows.exe

