function matrix = mat2vecs_inverse(a)
% Back-transforms Vector to upper Triangle of Matrix
% Recreates 2d Matrix

% Use pq to get dimension of former matrix (the matrix from which the
% vector was created)
   vl = size(a,1);
   mat_dim = +0.5 + sqrt(0.25 + 2*vl);
   matrix = NaN(mat_dim,mat_dim); % Preallocate

% Back-mapping
    cnt = 1;
    for indDim2 = 1:mat_dim
         for indDim1 = 1:mat_dim
             if indDim1 < indDim2
                 matrix(indDim1,indDim2) = a(cnt);
                 cnt = cnt+1;
             end
         end
    end
end
