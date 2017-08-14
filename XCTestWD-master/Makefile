git_version = $$(git branch 2>/dev/null | sed -e '/^[^*]/d'-e's/* \(.*\)/\1/')
npm_bin= $$(npm bin)

all: install
carthage:
	carthage update --platform iOS
build: carthage
	xcodebuild -project ./XCTestWD/XCTestWD.xcodeproj -sdk iphonesimulator
install:
	@npm install
test:
	@node --harmony \
		${npm_bin}/istanbul cover ${npm_bin}/_mocha \
		-- \
		--timeout 100000 \
		--require co-mocha
travis: install carthage
	@NODE_ENV=test $(BIN) $(FLAGS) \
		./node_modules/.bin/istanbul cover \
		./node_modules/.bin/_mocha \
		--report lcovonly \
		-- -u exports \
		$(REQUIRED) \
		$(TESTS) \
		--bail
jshint:
	@${npm_bin}/jshint .
.PHONY: test
