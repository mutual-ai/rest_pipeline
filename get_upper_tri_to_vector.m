%% Get upper half of matrix to vector
function vector = get_upper_tri_to_vector(X)
cnt = 1;
for indRow = 1:size(X,1)
    for indCol = 1:size(X,2)
        if indCol > indRow
            vector(cnt) = X(indRow,indCol);
             cnt = cnt+1;
        end
    end
   
end
vector = vector';
end