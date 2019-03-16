function allVerts = getRingVertices(edgedSlices,thickness)

	xverts = [];
	yverts = [];
	zverts = [];
    
    width = size(edgedSlices,2);
    height = size(edgedSlices,1);
    length = size(edgedSlices,3); 
    
   % the third dimension coordinate is based on the number in the series and the %slice thickness
    for i = 1:length
        z = thickness*i;
        slc = edgedSlices(:,:,i);
        top = [];
        bottom = [];
        left = [];
        right = [];
        for w =1: width
			row = slc(:,w);
			 % if the row is all black continue
            if size(find(row),1) == 0 || size(find(row),1) == 1
			   %this means there are no non-zero items in here
               continue;
            else
                %get the top and bottom coordinates at the same time
                y1 = find(row,1,'first');
                y2 = find(row,1,'last');
                top = cat(1,top,[w,y1,z]);
                bottom = cat(1,bottom,[w,y2,z]);
            end
        end
        
        for h = 1: height
            row = slc(h,:);
		   % if the row is all black continue
           if size(find(row),2) == 0 || size(find(row),2) == 1
			   %this means there are no non-zero items in here
               continue;
           else
               %get the right and left coordinates at the same time
                x1 = find(row,1,'first');
                x2 = find(row,1,'last');
                left = cat(1,left,[x1,h,z]);
                right = cat(1,right,[x2,h,z]);
           end
        end
             
    xverts = cat(1,xverts,[top(:,1);right(:,1);flipud(bottom(:,1));flipud(left(:,1))]);
	yverts = cat(1,yverts,[top(:,2);right(:,2);flipud(bottom(:,2));flipud(left(:,2))]);
	zverts = cat(1,zverts,[top(:,3);right(:,3);flipud(bottom(:,3));flipud(left(:,3))]);      
    end
    
	%allVerts = [xverts;yverts;zverts];
    allVerts = xverts;
    %allVerts = cat(3,allVerts,xverts);
    allVerts = cat(3,allVerts,yverts);
    allVerts = cat(3,allVerts,zverts);
    
	
end