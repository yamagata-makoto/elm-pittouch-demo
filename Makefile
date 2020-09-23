#ELM_FLAGS = --optimize
ELM_FLAGS =
CONTRIB_DIR = ./src/contrib
SRC_DIR = ./src
JS_DIR =  ./js
DIST_DIR = ./dist
CONTENTS_DIR = $(DIST_DIR)/contents
JS_CONTRIB_DIR =  $(JS_DIR)/contrib
JS_CONTRIB_SRC = $(wildcard $(CONTRIB_DIR)/*.js)
JS_CONTRIB_OUT = $(addprefix $(JS_CONTRIB_DIR)/, $(notdir $(JS_CONTRIB_SRC)))
COFFEE_CONTRIB_SRC = $(wildcard $(CONTRIB_DIR)/*.ls)
COFFEE_CONTRIB_OUT = $(addsuffix .js, $(addprefix $(JS_CONTRIB_DIR)/, $(notdir $(basename $(COFFEE_CONTRIB_SRC)))))
CSS_SRC = $(wildcard $(SRC_DIR)/css/*.*)
CSS_OUT = $(addprefix $(CONTENTS_DIR)/css/, $(notdir (CSS_SRC)))
SND_SRC = $(wildcard $(SRC_DIR)/snd/*.wav)
SND_OUT = $(addprefix $(CONTENTS_DIR)/snd/, $(notdir (SND_SRC)))

target: app.zip

deploy:
	@echo ""; \
	read -p "ENTER PITTOUCH IP ADDRESS:" ip; \
	sed "1,$$ s/CLOUDS/"$$spot"/" src/etc/providersetting.xml > dist/contents/providersetting.xml; \
	cd dist; zip -r ../app.zip *; cd ..; \
	./tools/pittouch_uploader.sh http://"$$ip"/contentsUpdate.cgi update.contents app.zip

app.zip: bundle.js $(CSS_OUT) $(SND_OUT) img etc src/etc/providersetting.xml src/index.html
	cp src/etc/providersetting.xml dist/contents/. 
	cp src/index.html dist/contents/. 
	cd dist; zip -r ../app.zip *

$(JS_CONTRIB_OUT): $(JS_CONTRIB_SRC)
	@if [ ! -d $(JS_CONTRIB_DIR) ]; then mkdir $(JS_CONTRIB_DIR); fi
	cp $(JS_CONTRIB_SRC) $(JS_CONTRIB_DIR)

$(JS_CONTRIB_DIR)/%.js: $(CONTRIB_DIR)/%.ls
	npm run-script lsc -- -o ./js/contrib $<

env:
	npm install

repl:
	npm run-script elm repl

app.js: src/app.ls
	npm run-script lsc -- -o ./js src/app.ls 

elm.js: src/Main.elm
	npm run-script elm -- make src/Main.elm --output ./js/elm.js ${ELM_FLAGS}

bundle.js: app.js elm.js $(JS_CONTRIB_OUT) $(COFFEE_CONTRIB_OUT)
	npm run-script browserify -- js/app.js --outfile dist/contents/bundle.js

$(SND_OUT): $(SND_SRC)
	@if [ ! -d $(CONTENTS_DIR)/snd ]; then mkdir $(CONTENTS_DIR)/snd; fi
	cp $(SND_SRC) $(CONTENTS_DIR)/snd

$(CSS_OUT): $(CSS_SRC)
	@if [ ! -d $(CONTENTS_DIR)/css ]; then mkdir $(CONTENTS_DIR)/css; fi
	cp $(CSS_SRC) $(CONTENTS_DIR)/css

etc: src/etc/*.txt
	@cp src/etc/*.txt dist/. 

img: src/img/*.*
	@cp -r src/img dist/contents/. 

clean:
	@rm -rf js
	@rm -rf dist
	@rm -r app.zip

reset:
	@rm -r node_modules
	@rm -r elm-stuff
	@rm -rf js
	@rm -rf dist
	@rm -r app.zip

