function final_project

    %% work outline
    %% manually segment images by hand
    %% separate an image based on the cluster number into its own image file
    %% refine the area for the boundary detection by bounding the image into a smaller area with ginput
    %% Then find the boundary by starting at a preset number of divisions within the rows and column and searching for the first 
    %% point in each row and column of choice that isn't black (since the image is already separated)
    %% with the boundary points chosen use patch to create the polygon meshes, then display all the slices and patches together

    %%  first the user can cycle through all the images,
    %%  then he chooses an image number to select
    %%



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% GUI SETUP CODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %  Create and then hide the UI as it is being constructed.
    fig = figure('Visible','off','Position',[500,500,700,480]);

    %Global Variables
    kClusts = 4;
    globalNext = 0;

    % Construct the UI components: buttons, fields, slider
    hcrop    = uicontrol('Style','pushbutton','String','Crop','Position',[600,420,70,25],'Callback',@crop_Callback);
    hcropAll    = uicontrol('Style','pushbutton','String','Crop ALL','Position',[600,390,70,25],'Callback',@cropAll_Callback);
    hcluster   = uicontrol('Style','pushbutton','String','Cluster','Position',[600,350,70,25],'Callback',@clusterButton_Callback);
    hKtext  = uicontrol('Style','text','String','Select K Clusters','Position',[615,327,60,15]);
    hslider = uicontrol('Style','slider','Min',2,'Max',100,'Value',4,'Position',[585,300,100,25],'Sliderstep',[.01,.01],'Callback',@kslider_Callback);
    hkclusText = uicontrol('Style','edit','String',['Clusters: ',num2str(kClusts)],'Position',[600,270,70,25],'Callback',@kslider_Callback);
    hclustAll   = uicontrol('Style','pushbutton','String','Cluster ALL','Position',[600,240,70,25],'Callback',@clusterAll_Callback);
    hgetEdges   = uicontrol('Style','pushbutton','String','Get Edges','Position',[600,200,70,25],'Callback',@getEdges_Callback);
    hassemble   = uicontrol('Style','pushbutton','String','Assemble','Position',[600,170,70,25],'Callback',@assemble_Callback);
    hdisp  = uicontrol('Style','text','String','Display Images','Position',[600,135,60,15]);
    hdisplayOriginal = uicontrol('Style','pushbutton','String','Originals','Position',[600,105,60,25],'Callback',@dispOrig_Callback);
    hdisplayCropped = uicontrol('Style','pushbutton','String','Cropped','Position',[600,75,60,25],'Callback',@dispCrop_Callback);
    hdisplayClustered = uicontrol('Style','pushbutton','String','Clustered','Position',[600,45,60,25],'Callback',@dispClust_Callback);
    hdisplayEdges = uicontrol('Style','pushbutton','String','Edges','Position',[600,15,60,25],'Callback',@dispEdges_Callback);
    
    hnext = uicontrol('Style','pushbutton','String','NEXT','Position',[200,15,75,30],'Callback',@nextbutton_Callback);
    ha = axes('Units','pixels','Position',[50,70,450,350]);

    %Align Right side stuff for dislaying
    align([hcrop,hcropAll,hcluster,hKtext,hslider,hkclusText,hclustAll,hgetEdges,hassemble,hdisp,hdisplayOriginal,hdisplayCropped,hdisplayClustered,hdisplayEdges],'Center','None');
    align([hnext,ha],'Center','None');
    % Change units to normalized so components resize automatically.
    set(fig,'Units','normalized');
    set(ha,'Units','normalized');
    set(hcrop,'Units','normalized');
    set(hcropAll,'Units','normalized');
    set(hcluster,'Units','normalized');
    set(hclustAll,'Units','normalized');
    set(hgetEdges,'Units','normalized');
    set(hassemble,'Units','normalized');
    set(hnext,'Units','normalized');
    set(hKtext,'Units','normalized');
    set(hslider,'Units','normalized');
    set(hdisp,'Units','normalized');
    set(hkclusText,'Units','normalized');
    set(hdisplayOriginal, 'Units','normalized');
    set(hdisplayCropped, 'Units','normalized');
    set(hdisplayClustered, 'Units','normalized');
    set(hdisplayEdges, 'Units','normalized');
    

    %Final GUI stuff for displaying

    % Move the window to the center of the screen.
    movegui(fig,'center')
    % Make the window visible.
    set(fig,'Name','Simple Gui');
    set(fig,'Visible','on');

    %% END OF BASIC GUI SETUP STUFF

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% IMAGE SETUP STUFF, TAKING IN DIRECTORY NAME, SORTING, READING IN DICOM INFO
    %% AND OTHER GLOBAL VARIABLES
    %% if necessary, this stuff might all eventually go into one, 'initialize' function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%  Initial image stuff based on the directory supplied by the user
    %%  input directory which contains only the images with brain tumor in them
    path = input('Path of Brain tumor images directory: ');
    dirList = dir(path);
    chdir(path);
    dirList = dirList(3:end);  %remove beginning '.' and '..'
    dirSize = length(dirList); %length of the list, this is the total number of images

    %%  Get some general info that I will probably need later about the images
    genInf = dicominfo(dirList(1).name);
    width = genInf.Width;
    height = genInf.Height;
    thickness = genInf.SliceThickness;

    origInstNums = zeros(1,dirSize);
    %%get a list of the instance numbers of the dicom images to use for sorting
    for n = 1:dirSize
       info = dicominfo(dirList(n).name);
       instNum = info.InstanceNumber;
       origInstNums(n) = instNum;
    end

    %sort an array by the instance numbers
    sortInstNums = sort(origInstNums);
    names = [];  %array holding the names, in order
    slices = []; %matrix holding the slices in order

    %Now create a matrix of the slices sorted the list by the instance numbers
    %% names also now has the file names in order

    for i = 1:dirSize
        origInd = find(origInstNums==sortInstNums(i));
        dcm = dicomread(dirList(origInd).name);
        names = [names;dirList(origInd).name];
        slices = cat(3,slices,dcm);
    end
    curSlice = 1;

    dispSlices = 1;
    globalNext = 0;

    %% Image cropping variables
    %new dimensions for the cropped images, height and width
    cropSlices = [];
    sp = [];
    subSelected = 0;  %truth variable for whether or not the images have been cropped
    newWidth = 0;  
    newHeight = 0; 

    %Image selecting variables
    centroids = [];
    clustSlices = [];
    numCents = 0;
    clustered = 0;
    reClust = 0;

    % Edge detecting variables
    maxRowEdges = newWidth/5;
    maxColEdges = newHeight/5;
    edgedSlices = []; % structure for holding the edges for each slice
    edged = 0;
    edgeVerts = cell(1,dirSize);  %cell to hold ege vertices coordinates for patch, each matrix might be a different size
    xverts = [];
    yverts = [];
    zverts = [];
    patches = [];  %strucutre for holding the patches

    disp('Done parsing files, and Initializing Vars, displaying first slice');

    dispTitle = ['Im: ',names(curSlice,:),',  # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
    imshow(slices(:,:,curSlice),[]), title(dispTitle);


    %%%%%%%%%%%%%%%%%%%%%%
    %% FUNCTIONS TO MAKE


    %%  If I am having trouble limiting my range of where the edge points could be, 
    %%  I could have the user click a few points on the edge of the tumor where the edges can't go beyond
    %%  

    %% Assemble function that the user presses after all the segmenting has been done
    %% narrow or refine region button for	 the user to choose a smaller portion of each image to display


    %% when displaying images, make sure to display both the number in the dicom series and the number in the array


    %% the user will have to choose which cluster represents the tumor cluster
    %% the user will also have to choose whether to clean up the image or not, 
    %% 			might do that like professor Huang said, by only taking points with a certain threshold of 
    %%			the primary tumor cluster intensity average





    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TECHNICAL FUNCTIONS AND SEGMENTATION FUNCTIONS
    %
    % They go in the general order that the programs operates in 
    % Subsection one image, subselect them all
    % cluster one image, cluster them all
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % MAYBE THESE FUNCTIONS WILL GO INTO ANOTHER FILE 
    % TO SAVE SPACE AND CLUTTER IN THIS FILE, MAYBE	

	function subSelect
		
		% Read RGB image from graphics file. 
		%%im = imread('street2.jpg'); 
		im = slices(:,:,curSlice);
		% Display image with true aspect ratio
		%image(im); axis image
		%imshow(im,[]); axis
        imshow(im,[]);
		
		% Use ginput to select corner points of a rectangular
		% region by pointing and clicking the mouse twice
		p = ginput(2); 

		% Get the x and y corner coordinates as integers
		sp(1) = min(floor(p(1)), floor(p(2))); %xmin 
		sp(2) = min(floor(p(3)), floor(p(4))); %ymin 
		sp(3) = max(ceil(p(1)), ceil(p(2)));   %xmax 
		sp(4) = max(ceil(p(3)), ceil(p(4)));   %ymax 
		
		newWidth = (sp(3) - sp(1)) + 1;
		newHeight = (sp(4) - sp(2)) + 1;
		
		% Index into the original image to create the new image
		%%MM = im(sp(2):sp(4), sp(1): sp(3),:);
		MM = im(sp(2):sp(4), sp(1): sp(3));  %Don't think I need the extra : at the end
		
		% Display the subsetted image with appropriate axis ratio
		%figure; image(MM); axis image
        dispTitle = ['Im: ',names(curSlice,:),',  # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
        imshow(MM,[]), title(dispTitle);
        
        disp('Done Cropping, either go again or crop everything');
        
	end
	
	
	function subSelectAll 
		cropSlices = [];
		for i = 1:dirSize
			slc = slices(:,:,i);
			cropped = slc(sp(2):sp(4), sp(1): sp(3));
			%dispTitle = ['Im: ',names(curSlice,:),',  # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
			dispTitle = ['Original Image: ',names(i,:),', # ',num2str(i),', Inst # ',num2str(sortInstNums(i))];
			imshow(slices(:,:,i),[]), title(dispTitle);
			pause(2);
            dispTitle = ['Cropped Image: ',names(i,:),', # ',num2str(i),', Inst # ',num2str(sortInstNums(i))];
			imshow(cropped,[]), title(dispTitle);
            %consider preallocating cropslices for speed
			cropSlices = cat(3,cropSlices,cropped);
            pause(2);
		end
		 disp('Done Cropping everything, either go again or try moving on to clustering');
	end
	
	function grayCluster
        
		image = cropSlices(:,:,curSlice);
		dispTitle = ['Slice to Cluster: ',names(curSlice,:),', # ',curSlice,', Inst # ',sortInstNums(curSlice)];
        imshow(image,[]), title(dispTitle);
        %prepare image for clustering
        graySpace = double(image);
        %rows = size(image,1);
        %cols = size(image,2);
        
		%kmeans takes in a 2 column matrix of the whole set of points
        reshapedGray = reshape(graySpace,newWidth*newHeight,1); %reshape the image matrix to only be 2 cols
        
        %K means clustering and pixel reassignment
        [clustIndex,clustCents] = kmeans(reshapedGray,kClusts,'distance','sqEuclidean','Replicates',3);
        clusteredPixels = reshape(clustIndex,newHeight,newWidth);  % reshape it back to the original size of the image
        
        %wait to display the new image until button pres
        dispSlices = 0;
        globalNext = 0;
		imshow(clusteredPixels,[]), title('Pixel labeled by cluster (Next)');
        while globalNext == 0
                pause(1);
        end
        globalNext = 0;
        
        %make segmented images display only the intensity on black
        segImages = cell(1,1);
        %Don't think I need this command
		bwLabel = repmat(clusteredPixels,[1,1,1]);
        
		for k = 1:kClusts
            bw = image;
            bw(bwLabel ~= k) = 0;
            segImages{k} = bw;
        end
        %display each segmented image after button push
		
		
		globalNext = 0;
        
		for k = 1:kClusts
            %wait until next is pushed
            while globalNext == 0
                 pause(1);
            end
            globalNext = 0;
            titleDisp = ['Members of cluster  ',num2str(k)];
            imshow(segImages{k},[]), title(titleDisp);
        end
		
		centChoice = input('Select which cluster(s) you want to keep  ');
        newIm = zeros(newHeight,newWidth);
		titleDisp = ['Image you are keeping'];
        
        if reClust == 1
            tempCents = size(centChoice,2);
            cents = [];
            if tempCents == 1
                cents = clustCents(centChoice);
                newIm = double(segImages{centChoice(i)});
            else
                for i = 1:tempCents
                    cents = [cents,clustCents(centChoice(i))];
                    newIm = newIm + double(segImages{centChoice(i)});
                end
            end
            clustSlices(:,:,curSlice) = newIm;
        else
            numCents = size(centChoice,2);
            if numCents == 1
                centroids = clustCents(centChoice);
                newIm = double(segImages{centChoice(i)});
            else
                for i = 1:numCents
                    centroids = [centroids,clustCents(centChoice(i))];
                    newIm = newIm + double(segImages{centChoice(i)});
                end
            end
        end
        
        imshow(newIm,[]), title(titleDisp);
        
		disp('Done clustering, either go again, or cluster everything');
		
		%% now add in an option to choose which level to use to segment out the image
		%% first just do this for every image
		%% then later save the cluster centroid for re use in the other images
        
    end
	
	function clusterAll
		
		for d = 1:dirSize
            curSlice = d;
			image = cropSlices(:,:,d);
			graySpace = double(image);
			%kmeans takes in a 2 column matrix of the whole set of points
			reshapedGray = reshape(graySpace,newWidth*newHeight,1); %reshape the image matrix to only be 2 cols
			%K means clustering and pixel reassignment
			[clustIndex,clustCents] = kmeans(reshapedGray,kClusts,'distance','sqEuclidean','Replicates',3);
			clusteredPixels = reshape(clustIndex,newHeight,newWidth);  % reshape it back to the original size of the image
			
			%make segmented images display only the intensity on black
			segImages = cell(1,1);
			
			% NOW FIND A WAY TO USE ONLY THE CENTROIDS IN THE CENTROIDS VARIABLE
			keepCentInds = [];
            
            for i = 1:numCents
                %MAYBE TO TEST ONLY USE ONE CENTROID
                centroids(i);
                curId = find(pdist2(centroids(i),clustCents)==min(pdist2(centroids(i),clustCents)));
                keepCentInds = [keepCentInds,curId];
            end
            
            tumorIm = zeros(newHeight,newWidth);
            bwLabel = repmat(clusteredPixels,[1,1,1]);
            for k = 1:numCents
				bw = image;
				bw(bwLabel ~= keepCentInds(k)) = 0;
				tumorIm = tumorIm + double(bw);
            end
			dispTitle = ['Clustered Slice: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
            imshow(tumorIm,[]), title(dispTitle);
			clustSlices = cat(3,clustSlices,tumorIm);
            pause(2);
			
		end
		
		clustered = 1;
        
    end

  
        %% LOOK AT HOMEWORK 3 TO GET AN IDEA OF SMOOTHING THE EDGES so that the edges aren't so jagged
  
    function selectEdgePoints
		for i = 1:dirSize
			
			curSlice = i;
			
			im = clustSlices(:,:,curSlice);
			%dispTitle = ['Im: ',names(curSlice,:),',  # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
			dispTitle = ['Clustered Slice: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
			imshow(im,[]), title(dispTitle);
			
			p = ginput(2); 

			% Get the x and y corner coordinates as integers
			left = min(floor(p(1)), floor(p(2))); %xmin 
			top = min(floor(p(3)), floor(p(4))); %ymin 
			right = max(ceil(p(1)), ceil(p(2)));   %xmax 
			bottom = max(ceil(p(3)), ceil(p(4)));   %ymax 
            
            
            mask = false(size(im));
            mask(top:bottom,left:right) = true;
            
            edges = activecontour(im, mask, 200, 'Chan-Vese');
            
            dispTitle = ['Edges of: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
			imshow(edges,[]), title(dispTitle);
            pause(2);

            edgedSlices = cat(3,edgedSlices, edges);
		
		end
		edged = 1;
    end
	
    function getEdgeVertices
        
        xverts = [];
        yverts = [];
        zverts = [];
        top = [];
        right = [];
        left = [];
        bottom = [];
        topRow = [];
        rightRow = [];
        leftRow = [];
        bottomRow = [];

       % the third dimension coordinate is based on the number in the series and the %slice thickness
       for w =1: newWidth
            for i = 1:dirSize
                slc = edgedSlices(:,:,i);
                z = 3*thickness*i;
                row = transpose(slc(:,w));
                 % if the row is all black continue
                if size(find(row),2) == 0 || size(find(row),2) == 1
                   %this means there are now non-zero items in here
                   continue;
                end
                y1 = find(row,1,'first');
                y2 = find(row,1,'last');
                topRow = [topRow;w,y1,z];
                bottomRow = [bottomRow;w,y2,z];
            end
            if mod(w,2)
                topRow = wrev(topRow);
                bottomRow = wrev(bottomRow);
            end 
            top = [top;topRow];
            bottom = [bottom;bottomRow];
            topRow = [];
            bottomRow = [];
       end

       for h = 1: newHeight
           for i = 1:dirSize
                slc = edgedSlices(:,:,i);
                z = 3*thickness*i;
               row = slc(h,:);
               % if the row is all black continue
               if size(find(row),2) == 0 || size(find(row),2) == 1
                   %this means there are now non-zero items in here
                   continue;
               end
                x1 = find(row,1,'first');
                x2 = find(row,1,'last');
                leftRow = [leftRow;x1,h,z];
                rightRow = [rightRow;x2,h,z];
            end
            if mod(h,2)
                leftRow = wrev(leftRow);
                rightRow = wrev(rightRow);
            end 
            left = [left;leftRow];
            right = [right;rightRow];
            leftRow = [];
            rightRow = [];
           
        end
        
        xverts = [top(:,1);right(:,1);wrev(bottom(:,1));wrev(left(:,1))];
        yverts = [top(:,2);right(:,2);wrev(bottom(:,2));wrev(left(:,2))];
        zverts = [top(:,3);right(:,3);wrev(bottom(:,3));wrev(left(:,3))];
        
    end


	function assemblePatches
		disp('Here goes nothing!');
        
        plot3(xverts,yverts,zverts);
        dispSlices = 0;
        globalNext = 0;
        while globalNext == 0
                pause(1);
        end
        globalNext = 0;
        
        
        
        p = patch(xverts,yverts,zverts);
        camlight;
        view(3);
        lighting phong;
        
	end
  
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FUNCTIONS I AM NOT USING FOR NOW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% SIMPLE BUTTON FUNCTIONS AND CALL BACKS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %  I will need a crop one button which asks for a number, mayber with a dialogue
    %  I will also need a crop all button



    %  All callback functions will first appear here and will call the more technical function
    %      if need be, or if that is the purpose of the function
  
    function crop_Callback(source, eventdata)
		
		curSlice = input('Please choose initial image to crop:  ');
		
		subSelected = 1;
		subSelect;
		
		%im = slices(:,:,curSlice);
		%sp = subSelect(im);
		%newWidth = (sp(3) - sp(1)) + 1;
		%newHeight = (sp(4) - sp(2)) + 1;
		
		
	end
	
	function cropAll_Callback(source, eventdata)
        % Put a warning in here if the images have already been cropped 
		if subSelected == 0
			disp('You have not yet subselected a region of one of the images, please do so and click again');
		else
			subSelectAll
		end
		
	end
  
  
   function kslider_Callback(source,eventdata) 
      %K cluster setting slider stuff
      kClusts = get(source,'Value');
      kClusts = round(kClusts);
      %Set the display of the k value
      set(hkclusText,'String',['Clusters: ',num2str(kClusts)]);
   end
  
  
	function clusterButton_Callback(source,eventdata) 
		% check if the images have been cropped first
        % put a warning in here if the images have already been clustered
        
        curSlice = input('Please choose initial image to Cluster:  ');
        
        if clustered == 1
            disp('Looks like you already did the Clustering');
            reClust = input('Are you reclustering(1) or starting over(0)?  ');
        end
		
		grayCluster
  
	end
  
  
  	function clusterAll_Callback(source,eventdata) 
        % put a check in here to make sure the user already did the first
        % clustering
		disp('Clustering all the images');
        
        clusterAll
        
	end
	
	
	function getEdges_Callback(source,eventdata)
		%check to make sure that the user has already done the clustering
        
        disp('Detecting images slice by slice');
        
        selectEdgePoints
        
	end
	
	
	function assemble_Callback(source,eventdata)
		disp('Assembling');
        
        getEdgeVertices
        
        assemblePatches
        
	end
	

	function nextbutton_Callback(source,eventdata) 
		if dispSlices == 0
			globalNext = 1;
		else
			if curSlice == dirSize
				curSlice = 1;
			else
				curSlice = curSlice + 1;
			end
			dispTitle = [names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
			switch dispSlices
				case 1
					dispTitle = ['Im: ',dispTitle];
					imshow(slices(:,:,curSlice),[]), title(dispTitle);
				case 2
					dispTitle = ['Cropped: ',dispTitle];
					imshow(cropSlices(:,:,curSlice),[]), title(dispTitle);
				case 3
					dispTitle = ['Clustered: ',dispTitle];
					imshow(clustSlices(:,:,curSlice),[]), title(dispTitle);
                case 4
                    dispTitle = ['Edges: ',dispTitle];
                    imshow(edgedSlices(:,:,curSlice),[]), title(dispTitle);
				end
		end
	end 
   
    function dispOrig_Callback(source, eventdata)
        dispSlices = 1;
    end
	
	function dispCrop_Callback(source, eventdata)
        
		if subSelected == 0
			disp('You have not yet subselected a region of one of the images, please do so and click again');
		else
			dispSlices = 2;
            curSlice = 1;
            dispTitle = ['Cropped: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
            imshow(cropSlices(:,:,curSlice),[]), title(dispTitle);
            
		end
		
    end
	
	function dispClust_Callback(source, eventdata)
		if clustered == 0
			disp('You have not yet clustered the images yet, please do so before displaying them');
		else	
			dispSlices = 3;
            curSlice = 1;
            dispTitle = ['Im: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
            imshow(clustSlices(:,:,curSlice),[]), title(dispTitle);
		end
    end

    function dispEdges_Callback(source, eventdata)
        if edged == 0
			disp('You have not yet selected the edges yet, please do so before displaying them');
		else	
			dispSlices = 4;
            curSlice = 1;
            dispTitle = ['Edges: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
            imshow(edgedSlices(:,:,curSlice),[]), title(dispTitle);
		end
    end
end