function newIm = removePieces(oldim)
	
	newIm = oldim;
	
    maxW = size(im,2);
    maxH = size(im,1);
    
	p = ginput(2); 

	% Get the x and y corner coordinates as integers
	left = min(floor(p(1)), floor(p(2))); %xmin 
	top = min(floor(p(3)), floor(p(4))); %ymin 
	right = max(ceil(p(1)), ceil(p(2)));   %xmax 
	bottom = max(ceil(p(3)), ceil(p(4)));   %ymax 
	
	newIm(top:bottom,left:right) = 0;
	

end