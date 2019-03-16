function locations = boundBox(height,width)
	%[top,right,bottom,left] = boundBox(newHeight,newWidth);
	
	p = ginput(2); 

	% Get the x and y corner coordinates as integers
	left = min(floor(p(1)), floor(p(2))); %xmin 
	top = min(floor(p(3)), floor(p(4))); %ymin 
	right = max(ceil(p(1)), ceil(p(2)));   %xmax 
	bottom = max(ceil(p(3)), ceil(p(4)));   %ymax 
    
    if left < 1
        left = 1;
    end
    
    if top < 1
        top = 1;
    end
    
    if right > width
        right = width;
    end
    
    if bottom > height
        bottom = height;
    end
    
    
    locations = [top,right,bottom,left];
end