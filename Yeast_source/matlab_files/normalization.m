function normalization(input_path,output_path)
img = imread(input_path);
img = double(img);
img_normalized = (img - min(img(:))) / (max(img(:)) - min(img(:)));
imwrite(img_normalized,output_path)
end