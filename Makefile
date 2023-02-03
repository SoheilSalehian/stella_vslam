build:
	docker build -t stella_vslam-desktop -f Dockerfile.desktop .
	curl -sL "https://github.com/stella-cv/FBoW_orb_vocab/raw/main/orb_vocab.fbow" -o orb_vocab.fbow

run:
	xhost +local:
	docker run --name stella_vslam -it --rm -e DISPLAY=$DISPLAY --runtime=nvidia --gpus=all  -v /tmp/.X11-unix/:/tmp/.X11-unix:ro -v ${PWD}/data:/stella_vslam/build/data/ stella_vslam-desktop


clean:
	sudo chmod 666 /var/run/docker.sock
