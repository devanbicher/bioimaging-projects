function allVerts = getEdgeVertices(edgedSlices,thickness)


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
    allZs = 0;
    
    width = size(edgedSlices,2);
    height = size(edgedSlices,1);
    length = size(edgedSlices,3); 
    
   % the third dimension coordinate is based on the number in the series and the %slice thickness
   for w =1: width
		for i = 1:length
            allZs = 0;
			slc = edgedSlices(:,:,i);
			z = thickness*i;
			row = slc(:,w);
			 % if the row is all black continue
            if size(find(row),1) == 0 || size(find(row),1) == 1
			   %this means there are no non-zero items in here
			   allZs = 1;
               continue;
            else
                allZs = 0;
                y1 = find(row,1,'first');
                y2 = find(row,1,'last');
                topRow = cat(1,topRow,[w,y1,z]);
                bottomRow = cat(1,bottomRow,[w,y2,z]);
            end
        end
        if allZs == 1
           %this means there are no non-zero items in here
           continue;
        end
        if mod(w,2)
            topRow = flipud(topRow);
            bottomRow = flipud(bottomRow);
        end
		top = cat(1,top,topRow);
		bottom = cat(1,bottom,bottomRow);
		topRow = [];
		bottomRow = [];
   end

   for h = 1: height 
	   for i = 1:length
           allZs = 0;
			slc = edgedSlices(:,:,i);
			z = thickness*i;
		   row = slc(h,:);
		   % if the row is all black continue
           if size(find(row),2) == 0 || size(find(row),2) == 1
			   %this means there are no non-zero items in here
			   allZs = 1;
               continue;
           else
                allZs = 0;
                x1 = find(row,1,'first');
                x2 = find(row,1,'last');
                leftRow = cat(1,leftRow,[x1,h,z]);
                rightRow = cat(1,rightRow,[x2,h,z]);
           end
       end
       if allZs == 1
           %this means there are no non-zero items in here
           continue;
       end
       if mod(h,2)
           leftRow = flipud(leftRow);
           rightRow = flipud(rightRow);
       end
           
		left = cat(1,left,leftRow);
		right = cat(1,right,rightRow);
		leftRow = [];
		rightRow = [];
	   
   end
	
    xverts = [top(:,1);right(:,1);flipud(bottom(:,1));flipud(left(:,1))];
	yverts = [top(:,2);right(:,2);flipud(bottom(:,2));flipud(left(:,2))];
	zverts = [top(:,3);right(:,3);flipud(bottom(:,3));flipud(left(:,3))];
    
    allVerts = xverts;
    allVerts = cat(3,allVerts,yverts);
    allVerts = cat(3,allVerts,zverts);
    
	
end