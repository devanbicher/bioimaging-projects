function p = assemblePatches(xverts,yverts,zverts)

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