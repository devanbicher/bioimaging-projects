%function output = blackNwhite(control)

%first read in the image, lets first determine if there's a difference between the grayscale and color images of .jpg format


%imageFile = input('Path of First image: ')

imageFile = 'C:\Users\Devan\Documents\College\semester 13\CSE420\programming hw2\chest.jpg'

%later derive the path then make a folder to save these new segmented images in

image = imread(imageFile);

imshow(image)
pause

disp('Given this as your input image,\n'), title('Original Image');
kClusts = input('please enter k, the number of different color clusters:  ')

%convert the image to lab color space to allow for euclidean distance measure

%Put in a check here to make sure the image the image is in black and white and convert it if not

bwSpace = double(image);

rows = size(bwSpace,1);
cols = size(bwSpace,2);

reshapedBW = reshape(bwSpace,rows*cols,3);

[clustIndex,clustCent] = kmeans(reshapedBW,kClusts,'distance','sqEuclidean','Replicates',3);

% the last portion, the 'Replicates' and 3 indicates how many times it should repeat after convergence to avoid local minima

clusteredPixels = reshape(clustIndex,rows,cols); 

imshow(clusteredPixels,[]), title('image now with each pixel labeled by cluster');
pause;

segImages = cell(1,3);

bwLabel = repmat(clusteredPixels,[1,1,3]);

for k = 1:kClusts
	bw = image;
	bw(bwLabel ~= k) = 0;
	segImages{k} = bw;
end

for k = 1:kClusts
	titleDisp = strcat('Members of cluster  ',num2str(k));
	imshow(segImages{k}), title(titleDisp);
    pause;
   
end


%end