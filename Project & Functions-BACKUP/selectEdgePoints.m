function edgedSlices = selectEdgePoints(clustSlices,names,sortInstNums)
    edgedSlices = [];

	for i = 1:size(clustSlices,3)	
		curSlice = i;
		im = clustSlices(:,:,curSlice);
        
		dispTitle = ['Clustered Slice: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
		imshow(im,[]), title(dispTitle);

        pts = boundBox(size(im,1),size(im,2));
        
		mask = false(size(im));
		mask(pts(1):pts(3),pts(4):pts(2)) = true;
        
		edges = activecontour(im, mask, 300, 'Chan-Vese');
        
        %remove anything that is directly on the edge of the image
        height = size(im,1);
        width = size(im,2);
        edges(1,:) = 0;
        edges(height,:) = 0;
        edges(:,1) = 0;
        edges(:,width) = 0;
        
        dispTitle = ['Edges of: ',names(curSlice,:),', # ',num2str(curSlice),', Inst # ',num2str(sortInstNums(curSlice))];
        imshow(edges,[]), title(dispTitle);
		pause(2);
        
		edgedSlices = cat(3,edgedSlices, edges);
	
	end
	

end

