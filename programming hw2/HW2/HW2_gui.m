function HW2_gui
%  Create and then hide the UI as it is being constructed.
fig = figure('Visible','off','Position',[360,500,450,285]);

%Global Variables
kClusts = 4;
globalNext = 0;

% Construct the UI components: buttons, fields, slider
hcolor    = uicontrol('Style','pushbutton','String','Color','Position',[315,230,70,25],'Callback',@colorbutton_Callback);
hgray    = uicontrol('Style','pushbutton','String','Gray','Position',[315,200,70,25],'Callback',@grayButton_Callback);
hnext = uicontrol('Style','pushbutton','String','Next','Position',[315,170,70,25],'Callback',@nextbutton_Callback);
hKtext  = uicontrol('Style','text','String','Select K Clusters','Position',[325,130,60,15]);
hslider = uicontrol('Style','slider','Min',2,'Max',100,'Value',4,'Position',[300,100,100,25],'Sliderstep',[.01,.01],'Callback',@kslider_Callback);
hkclust = uicontrol('Style','edit','String',['Clusters: ',num2str(kClusts)],'Position',[315,70,70,25],'Callback',@kslider_Callback);
hfileText = uicontrol('Style','pushbutton','String','New File','Position',[50,30,70,25],'Callback',@newFileButton_Callback);
hfileName = uicontrol('Style','edit','String','Enter Image File path/name','Position',[140,30,250,25],'Callback',@fileNameInput_Callback);
ha = axes('Units','pixels','Position',[50,60,200,185]);

%Align Right side stuff for dislaying
align([hcolor,hgray,hnext,hKtext,hslider,hkclust],'Center','None');

% Change units to normalized so components resize automatically.
set(fig,'Units','normalized');
set(ha,'Units','normalized');
set(hcolor,'Units','normalized');
set(hgray,'Units','normalized');
set(hnext,'Units','normalized');
set(hKtext,'Units','normalized');
set(hslider,'Units','normalized');
set(hkclust,'Units','normalized');
set(hfileText, 'Units','normalized');
set(hfileName, 'Units','normalized');

%global image variables
%This is the default image, loaded in the zipped submission
temp_imageFile = 'test.png';
imageFile = temp_imageFile;
image = imread(imageFile);
disp('Default Image, test.png, loaded in, hit segmentation choice to display');

%Final GUI stuff for displaying

% Move the window to the center of the screen.
movegui(fig,'center')
% Make the window visible.
set(fig,'Name','Simple Gui');
set(fig,'Visible','on');

%%%%
%CALLBACK FUNCTIONS AND SEGMENTATION FUNCTIONS
%%%%

   function kslider_Callback(source,eventdata) 
      %K cluster setting slider stuff
      kClusts = get(source,'Value');
      kClusts = round(kClusts);
      %Set the display of the k value
      set(hkclust,'String',['Clusters: ',num2str(kClusts)]);
   end
  
    function colorCluster
        
        imshow(image), title('Original Color Image (Press Next)');
        %Prepare image for clustering
        %Convert image to lab
        %This contains the color info necessary for clustering
        imCform = makecform('srgb2lab');
        lab_of_im = applycform(image, imCform);
        abSpace = double(lab_of_im(:,:,2:3));
        rows = size(abSpace,1);
        cols = size(abSpace,2);
        reshapedAB = reshape(abSpace,rows*cols,2);
        
        %K means clustering and pixel reassignment
        [clustIndex,clustCent] = kmeans(reshapedAB,kClusts,'distance','sqEuclidean','Replicates',3);
        clusteredPixels = reshape(clustIndex,rows,cols); 
        %wait to display the image
        globalNext = 0;
        while globalNext == 0
                pause(1);
        end
        globalNext = 0;
        imshow(clusteredPixels,[]), title('Pixels labeled by cluster (Next)');
        
        %make segmented images display only the intensity on black
        segImages = cell(1,3);
        rgbLabel = repmat(clusteredPixels,[1,1,3]);
        for k = 1:kClusts
            color = image;
            color(rgbLabel ~= k) = 0;
            segImages{k} = color;
        end

        for k = 1:kClusts
            %wait until next is pushed
             while globalNext == 0
                pause(1);
             end
            globalNext = 0;
            titleDisp = ['Members of color cluster ',num2str(k)];
            imshow(segImages{k}), title(titleDisp);
        end
    end

  function colorbutton_Callback(source,eventdata) 
      
      if size(image,3) == 1
        disp('Cant use gray image in color clustering');
        disp('Using default image');
        imageFile = 'test.png';
        image = imread(imageFile);
      end
      
      colorCluster
        
  end
  
    function grayCluster
       
        imshow(image), title('Original Gray Image (Press Next)');
        %prepare image for clustering
        graySpace = double(image);
        rows = size(graySpace,1);
        cols = size(graySpace,2);
        reshapedGray = reshape(graySpace,rows*cols,1);
        %K means clustering and pixel reassignment
        [clustIndex,clustCent] = kmeans(reshapedGray,kClusts,'distance','sqEuclidean','Replicates',3);
        clusteredPixels = reshape(clustIndex,rows,cols); 
        %wait to display the new image until button press
        globalNext = 0;
        while globalNext == 0
                pause(1);
        end
        globalNext = 0;
        imshow(clusteredPixels,[]), title('Pixel labeled by cluster (Next)');
        
        %make segmented images display only the intensity on black
        segImages = cell(1,1);
        bwLabel = repmat(clusteredPixels,[1,1,1]);
        for k = 1:kClusts
            bw = image;
            bw(bwLabel ~= k) = 0;
            segImages{k} = bw;
        end
        %display each segmented image after button push
        for k = 1:kClusts
            %wait until next is pushed
            while globalNext == 0
                 pause(1);
            end
            globalNext = 0;
            titleDisp = ['Members of cluster  ',num2str(k)];
            imshow(segImages{k}), title(titleDisp);
        end
        
    end
  
  function grayButton_Callback(source,eventdata) 
  % check if image is in color then convert it
    
    if size(image,3) > 1
        image = rgb2gray(image);
    end
    
    grayCluster
  
  end

  function nextbutton_Callback(source,eventdata) 
       %Set the 'next' criteria, which is basically not zero
       globalNext = 1;
  end

  function newFileButton_Callback(source,eventdata)
        %read in the image taken from the text field, then display it
        imageFile = temp_imageFile;
        image = imread(imageFile);
        imshow(image),title(['New Image: ',imageFile]);
        
  end
   
    function fileNameInput_Callback(source, eventdata)

        temp_imageFile = get(source, 'String');
        disp(['New File, ',temp_imageFile, ' Loaded']);
        
    end
end