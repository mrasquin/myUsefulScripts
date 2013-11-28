function [] = MatchFaceId(curdir, oldfacepropfile, newfacepropfile)

format long

cd(curdir)
%FacePropDataOld = load('./facePropFileOld.dat');
%FacePropDataNew = load('./facePropFileNew.dat');
FacePropDataOld = load(oldfacepropfile);
FacePropDataNew = load(newfacepropfile);

fid = fopen('./MatchFaceID.dat','w');

[rowsOld colsOld] = size(FacePropDataOld);
[rowsNew colsNew] = size(FacePropDataNew);

t=1; p=1; areExtras=0; abstol = 1e-8; reltol = 1e-3;
extraMatches=[]; extraOriginals=[];
for i=1:rowsNew
    matchFound=0; p=1; faceMatch=[]; faceOriginal=[];
    for j=1:rowsOld
        vertexMatch=0;
        % Area, number of vertices, Min and max for x, y, z
        for x=2:9
            if abs((FacePropDataOld(j,x) - FacePropDataNew(i,x))/FacePropDataOld(j,x)) < reltol
                vertexMatch=vertexMatch+1;
            elseif abs((FacePropDataOld(j,x) - FacePropDataNew(i,x))) < abstol 
                % Second chance to find a match, useful when the machine precision has been reached already (for instance 1e-10 vs 1e-11)
                vertexMatch=vertexMatch+1;
            end
        end
        if vertexMatch == 8
            faceMatch(p)=FacePropDataOld(j,1);
            faceOriginal(p)=FacePropDataNew(i,1);
            matchFound=1;
            p=p+1;
        end
    end
    if matchFound == 1
        if length(faceMatch) == 1  
        fprintf(fid,'%d %d\n',faceMatch(1),faceOriginal(1));
        end
    
        if length(faceMatch) > 1 
        extraMatches = [extraMatches faceMatch];
        extraOriginals = [extraOriginals faceOriginal];
        areExtras=1;
        end
    end
        
    if matchFound == 0
        faceNotFound(t) = FacePropDataNew(i,1);
        t=t+1;
    end
   
end

fprintf(fid,'\n');
if areExtras == 1
        for j=1:length(extraMatches)
        fprintf(fid,'Warning: More than one match for face %d: %d !\n',extraMatches(j),...
            extraOriginals(j));
        end
end
fprintf(fid,'\n');  
for i=1:t-1
    fprintf(fid,'Warning: No match found for face %d in the new geometric model!\n',faceNotFound(i));
end

fclose(fid);

end
