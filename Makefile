all:
	@echo "Usage: make server|install"
	@echo ""

server:
	open "http://127.0.0.1:4000/"
	bundle exec jekyll s

install:
	bundle exec jekyll b
	yes | cp -av _site/* ..
	rm -rf _site/*
