%first read in the image, lets first determine if there's a difference between the grayscale and color images of .jpg format
function dlb213_hw2_ui

f = figure('Visible','off');
axes('Units','pixels','Position',[50,60,200,185]);



sld = uicontrol('Style', 'slider','Min',2,'Max',7,'Value',3,'Position', [400 20 120 20],'Callback', @display); 








set(f, 'Name', 'Test GUI')
set(f,'Visible','on');


function display(source, callbackdata, handles)

	%imageFile = input('Path of First image: ')

	imageFile = 'C:\Users\Devan\Documents\College\semester 13\CSE420\neuron tiff sequence\02_050118.tif'
	%imageFile = 'C:\Users\Devan\Documents\College\semester 13\CSE420\programming hw2\test.png'

	%later derive the path then make a folder to save these new segmented images in

	image = imread(imageFile);
    
    axes(handles.axesImage);
	imshow(image);%, 'Parent')
	pause

	disp('Given this as your input image,\n'), title('Original Image');
	%kClusts = input('please enter k, the number of different color clusters:  ')

	kClusts = get(source, 'Value');
	
	%convert the image to lab color space to allow for euclidean distance measure
	imCform = makecform('srgb2lab');
	lab_of_im = applycform(image, imCform);

	abSpace = double(lab_of_im(:,:,2:3));

	rows = size(abSpace,1);
	cols = size(abSpace,2);

	reshapedAB = reshape(abSpace,rows*cols,2);

	[clustIndex,clustCent] = kmeans(reshapedAB,kClusts,'distance','sqEuclidean','Replicates',3);

	% the last portion, the 'Replicates' and 3 indicates how many times it should repeat after convergence to avoid local minima

	clusteredPixels = reshape(clustIndex,rows,cols); 

	imshow(clusteredPixels,[]), title('image now with each pixel labeled by cluster');
	pause;

	segImages = cell(1,3);

	rgbLabel = repmat(clusteredPixels,[1,1,3]);

	for k = 1:kClusts
		color = image;
		color(rgbLabel ~= k) = 0;
		segImages{k} = color;
	end

	for k = 1:kClusts
		titleDisp = strcat('Members of color cluster ',num2str(k));
		imshow(segImages{k}), title(titleDisp);
		pause;
	   
	end


end

end