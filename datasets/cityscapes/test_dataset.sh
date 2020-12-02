cd "train_label"
(find . -type d -print0 | while read -d '' -r dir; do
     files=("$dir"/*);
     printf "%5d files in directory %s\n" "${#files[@]}" "$dir";
done) > ../list_dataset_train_label 
cd ..

cd "train_img"
(find . -type d -print0 | while read -d '' -r dir; do
     files=("$dir"/*);
     printf "%5d files in directory %s\n" "${#files[@]}" "$dir";
done) > ../list_dataset_train
cd ..

diff list_dataset_train list_dataset_train_label -y --suppress-common-lines

rm list_dataset_train list_dataset_train_label
