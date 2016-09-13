deps:
	shards update

css:
	sass --watch public/scss/app.scss:public/scss/app.css --style nested

js:
	coffee -c public/coffee/*.coffee ;
	while [ true ] ; do \
      inotifywait -e modify public/coffee/*.coffee ; \
      echo "compiling `date`" ; \
			coffee -c public/coffee/*.coffee ; \
  done; \
  true

run:
	crystal bin/start.cr

release:
	crystal build bin/run.cr --release -o bin/run
