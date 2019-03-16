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
	
	
end