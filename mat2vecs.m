function vectors = mat2vecs(A)
% Transform upper Triangle of Matrices to Vectors
% This script will transform the upper part of a matrix (2d or 3d) to a
% vector. 
% Use: [vector] = mat2vec(A);
% A are quadratic matrices (first and second dim). Can be 2d or 3d. In case A is a 3d matrix,
% mat2vec() will output a 2d matrix.

% get dimension
    mat_size = size(A);
    dim1 = mat_size(1); 
    dim2 = mat_size(2);
    if length(mat_size) == 3
        dim3 = mat_size(3);
    elseif length(mat_size) == 2
        dim3 = 1;
    else
        error('Error: Input has to be a 3d matrix.');
    end
% check if matrices are quadratic
    if dim1 ~= dim2
        error('Error: Matrices have to be quadratic!');
    end
    
    
% get only upper half of matrices and create vectors
    vec_length = (dim1*dim2-dim1)/2;
    vectors = NaN(dim3,vec_length);
    cnt = 1;
    for indDim3 = 1:dim3
        for indDim2 = 1:dim2
            for indDim1 = 1:dim1
                if indDim1 > indDim2
                    vectors(indDim3,cnt) = A(indDim1,indDim2,indDim3);
                    cnt = cnt + 1;
                end
            end
        end
        cnt = 1;
    end
end

