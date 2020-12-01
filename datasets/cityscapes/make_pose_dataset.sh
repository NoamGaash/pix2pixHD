cd train

for filename in *; do
	echo "$filename"
	# step 1 - video 2 frames
	if [ ! -d "../train_img/$filename" ]; then
		echo "step 1: $filename"
		mkdir -p "../train_img/$filename"
		ffmpeg -i "$filename" \
		-vf "scale=1024:2048:force_original_aspect_ratio=decrease,pad=1024:2048:-1:-1:color=black" \
		"../train_img/$filename/%05d.png"
	fi
	if [ ! -d "../train_label/$filename" ]; then
		echo "step 2: $filename"

		mkdir -p "../train_label/$filename"
		sudo docker run -v "$PWD/..:/noam" --gpus=all -it --rm -e NVIDIA_VISIBLE_DEVICES=0 cwaffles/openpose \
		./build/examples/openpose/openpose.bin \
		-image_dir /noam/train_img/$filename \
		-hand -disable_blending -face \
		-output_resolution 320x-1 \
		-number_people_max 1 \
		-no_gui_verbose \
		-display 0 \
		--disable_multi_thread \
		--write_images /noam/train_label/$filename

	fi
	cd "../train_label/$filename"
	
	for imagefilename in *; do
		if file $imagefilename | grep "1024 x 2048" > /dev/null; then
			
			if (( RANDOM % 50 )); then 
				echo "slow rotate $imagefilename";
				sudo convert "$imagefilename" -rotate 90 "$imagefilename"
			else 
				echo "rotate $imagefilename";
				sudo convert "$imagefilename" -rotate 90 "$imagefilename" &
			fi
		fi
	done
	
	cd ../../train
	
	
	cd "../train_img/$filename"
	
	for imagefilename in *; do
		if file $imagefilename | grep "1024 x 2048" > /dev/null; then
			if [ $(( $RANDOM % 100 )) -eq 0 ]; then 
				echo "slow rotate $imagefilename";
				sudo convert "$imagefilename" -rotate 90 "$imagefilename"
			else 
				echo "rotate $imagefilename";
				sudo convert "$imagefilename" -rotate 90 "$imagefilename" &
			fi
		fi
	done
	
	cd ../../train
done
wait
: 'for imagefilename in *; do
if file $imagefilename | grep "1024 x 2048" > /dev/null; then
echo "rotate $imagefilename";
sudo convert "$imagefilename" -rotate 90 "$imagefilename"
fi
done'


cd ../test
: '
for filename in *; do
	# step 1 - video 2 frames
	if [ ! -d "../test_original_frames/$filename" ]; then
		echo "step 1: $filename"
		mkdir -p "../test_original_frames/$filename"
		ffmpeg -i "$filename" \
		-vf "scale=256:256:force_original_aspect_ratio=decrease,pad=256:256:-1:-1:color=black" \
		"../test_original_frames/$filename/%05d.png"
	fi
	if [ ! -f "../test_skeleton_frames/$filename/00001_rendered.png" ]; then
		echo "step 2: $filename"
		mkdir -p "../test_skeleton_frames/$filename"
		sudo docker run -v "$PWD/..:/noam" --gpus=all -it --rm -e NVIDIA_VISIBLE_DEVICES=0 cwaffles/openpose \
		./build/examples/openpose/openpose.bin \
		-image_dir /noam/test_original_frames/$filename \
		-hand -disable_blending -face \
		-output_resolution 320x-1 \
		-number_people_max 1 \
		-no_gui_verbose \
		-display 0 \
		--disable_multi_thread \
		--write_images /noam/test_skeleton_frames/$filename
		sleep 1
	fi
done
'
