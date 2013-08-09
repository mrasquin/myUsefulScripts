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

t=1; p=1; areExtras=0; tol = 5e-5;
extraMatches=[]; extraOriginals=[];
for i=1:rowsNew
    matchFound=0; p=1; faceMatch=[]; faceOriginal=[];
    for j=1:rowsOld
        vertexMatch=0;
        for x=4:9
            if abs((FacePropDataOld(j,x) - FacePropDataNew(i,x))/FacePropDataOld(j,x)) < tol
                    
                vertexMatch=vertexMatch+1;
            end
        end
        if vertexMatch == 6
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
