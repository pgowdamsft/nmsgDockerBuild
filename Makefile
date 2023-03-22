all:
	docker build --progress=plain -t nmsgconv .

run:
	docker run --name test nmsgconv
