NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
export NPROCS

build:
	docker build -t stella_vslam-desktop -f Dockerfile.desktop . --build-arg NUM_THREADS=$(NPROCS)
	curl -sL "https://github.com/stella-cv/FBoW_orb_vocab/raw/main/orb_vocab.fbow" -o orb_vocab.fbow

run:
	xhost +local:
	docker run --name stella_vslam --user='$(id -u)' -it --rm -e DISPLAY=${DISPLAY} --runtime=nvidia --gpus=all  -v /tmp/.X11-unix/:/tmp/.X11-unix:ro -v ${PWD}/data:/stella_vslam/build/data/ -v ${PWD}/example/aist/:/stella_vslam/example/aist/ -v ${PWD}/tools:/stella_vslam/build/tools stella_vslam-desktop /bin/bash -c "./run_video_slam -v ./orb_vocab.fbow -m ${FILE} -c ../example/aist/equirectangular.yaml --frame-skip 3 --no-sleep --map-db-out ${FILE}-map.msg && python3 ./tools/extract_pointcloud.py ${FILE}-map.msg ${FILE}-output.csv"
	chown ${USER} data/*

pointcloud:
	docker run -it --rm -v ${PWD}/data:/stella_vslam/build/data/ -v ${PWD}/tools:/stella_vslam/build/tools stella_vslam-desktop /bin/bash -c "apt update && apt install python3-pip && pip3 install msgpack && python3 ./tools/extract_pointcloud.py data/map.msg data/output.csv"

clean:
	sudo chmod 666 /var/run/docker.sock
