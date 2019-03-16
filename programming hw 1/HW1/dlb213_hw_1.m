%Devan Bicher
%CSE 420
%FALL 2015
%Homework 1

%% QUESTIONS:
%% not sure how best to do the interpolation, it seems I have to either forgoe matrix operations, which will take time because of all the loops and matrices
%% lastly are the segmentation portions done correctly?



%% Try using pause in displaying the images

path = input('Path of First part image folder: ') %User specifies path of images

dir_list = dir(path);  %pull in all images in that directory
%% I will probably need to sort this list

chdir(path);

disp('Press any key to move to next image')
%axial = [];
dirSize = length(dir_list); %since the dir list also retrieves the . and .. items

%preSlices = struct
preSlices = [];

for i = 3: dirSize
	info = dicominfo(dir_list(i).name);
    if info.InstanceNumber == 1
		%read in the image and prepare the display
		%one = 1;
        %preSlices.(int2str(one)) = dcm(:,1);
        dcm = dicomread(dir_list(i).name);
        preSlices = cat(3,preSlices,transpose(dcm(:,1)));	
        continue;
    end
end

%The number 26 won't change, since it makes 25 rows, similar to the number
%of images in other directories, this is assuming an image of 256 x 256

for c = 2:26
	col = (c-1)*10;
	%preSlices.(int2str(c)) = dcm(:,col);
    preSlices = cat(3,preSlices,transpose(dcm(:,1)));
end

sliceList = cell(1,dirSize - 2);

for n = 3:dirSize
   info = dicominfo(dir_list(n).name);
   instNum = info.InstanceNumber;
   sliceList{instNum} = dir_list(n).name;
    
end


for n = 1:length(sliceList)
    
  dcm = dicomread(char(sliceList(n)));
   %compute the pre-interpolated coronal slices
	if n == 1
		%nothing needs to be done
	else
		%preSlices.c = [preSlices.c;dcm(:,1)];
        %preSlices(:,:,1) = [preSlices(:,:,1);transpose(dcm(:,1))];
        preSlices(n,:,1) = transpose(dcm(:,1)); 
        
		for c = 2:26
			col = (c-1)*10;
			%preSlices.c = [preSlices.c;dcm(:,col)];
            %preSlices(:,:,c) = [preSlices(:,:,c);transpose(dcm(:,col))];
            preSlices(n,:,c) = transpose(dcm(:,col));
            
		end %end for loop
	end
    %axial = cat(3,dcm,axial);
    imshow(dcm,[]);
    
    %prepare header info for display
    info = dicominfo(char(sliceList(n)));
    %Display slice info
    fprintf('Displaying  %s \n',char(sliceList(n)))
    fprintf('\tWidth:  %d \n', info.Width)
    fprintf('\tHeight:  %d \n', info.Height)
    fprintf('\tSlice thickness:  %d \n',info.SliceThickness)
    fprintf('\tPixel Spacing:  %d \n',info.PixelSpacing)
    fprintf('\tSpacing Between Slices:  %d \n', info.SpacingBetweenSlices)
    
    %This loop displays each image, until a keypress
    w = waitforbuttonpress;
    while w == 0
        drawnow;
        w = waitforbuttonpress;
    end
    
end

%conversion from axial to coronal

%finalSlices = struct;
finalSlice = [];
mkdir('../coronal');
for s = 1:25
 
	transSlice = [];
	for c = 1:25
        
       %disp(preSlices)
        
		%interpCol = interp2(preSlices.(int2str(s))(:,c),3);
		curCol = preSlices(:,c,s);
        %The interpolation step tripped me up, I just have a shrunk version
        %before interpolation
        %interpCol = interp2(curCol);
        
        transSlice = [transSlice;transpose(curCol)];
	end
	%new row for coronal slice = column of axial
	%each row corresponds to 
	finalSlice = transpose(transSlice);
    dicomwrite(finalSlice,strcat('../coronal/coronalSlice-',num2str(s),'.dcm'));
    
end


%Segmenting section

fprintf('NOW Displaying morphological and thresholded image slices side by side\n')
for n = 1:length(sliceList)
    
  dcm = dicomread(char(sliceList(n)));
    
    morph = bwmorph(dcm, 'remove');
    thresh = im2bw(dcm,graythresh(dcm));
    imshow([morph,thresh],[])
    
    %This loop displays each image, until a keypress
   
    w = waitforbuttonpress;
    while w == 0
        drawnow;
        w = waitforbuttonpress;
    end
   
end

% Connected component section

fprintf('NOW displaying the connected component analysis section\n')
%{
for n = 1:length(sliceList)
    
    dcm = dicomread(char(sliceList(n)));
    
    concomp = bwconncomp(dcm);
    props = regionprops(cc, 'FilledImage');
    
    imshow(prop.FilledImage,[])
    
    %This loop displays each image, until a keypress
   
    w = waitforbuttonpress;
    while w == 0
        drawnow;
        w = waitforbuttonpress;
    end
   
end
%}

%Second part, TIFF image stuff

tiffpath = input('Path of Tiff movie images folder: ')
tiff_list = dir(tiffpath);
dirSize = length(tiff_list)
chdir(tiffpath);
tiffs = [];
filt = fspecial('gaussian', size(tiffpath(3)), .5);


%first just display the regular image movie
disp('DISPLAYING ORIGINAL TIFF MOVIE...')
for n = 3:dirSize-1
    disp(tiff_list(n).name)
    im = imread(tiff_list(n).name);
     %tiffs = cat(3, tiffs, im);
    imshow(im)
    drawnow
end

disp('ABOUT TO DISPLAY THE GUASSIAN SMOOTHING...')
disp('PRESS ANY KEY TO CONTINUE')
w = waitforbuttonpress;

%Now display the gaussian smoothed images
disp('DISPLAYING THE GUASSIAN SMOOTHING...')
for n = 3:dirSize-1
    disp(tiff_list(n).name)
    im = imread(tiff_list(n).name);
   
    newGaus = imfilter(im, filt, 'replicate');
    
    imshow(newGaus);
    drawnow   
end

disp('ABOUT TO DISPLAY THE MEDIAN FILTERING IMAGES...')
disp('PRESS ANY KEY TO CONTINUE')
w = waitforbuttonpress;

%Now displaying the median smoothing filter
disp('DISPLAYING THE MEDIAN FILTERING IMAGES...')
for n = 3:dirSize-1
     disp(tiff_list(n).name)
     im = imread(tiff_list(n).name);
     imNOsp = imnoise(im(:,:),'salt & pepper',0.02);
     newMed = medfilt2(imNOsp);
     
     imshow(newMed);
     drawnow
end

disp('ABOUT TO DISPLAY THE THRESHHOLDED IMAGES...')
disp('PRESS ANY KEY TO CONTINUE')
w = waitforbuttonpress;

disp('DISPLAYING THE THRESHHOLDED IMAGES...')
for n = 3:dirSize-1
    disp(tiff_list(n).name)
    im = imread(tiff_list(n).name);
    back = imopen(im,strel('disk',15));

    newIm = im - back;
    newIm = rgb2gray(newIm);
    newIm = imadjust(newIm);
    level = graythresh(newIm);
    bw = im2bw(newIm,level);
    bw = bwareaopen(bw, 50);
    
    imshow(bw);
    drawnow
end
