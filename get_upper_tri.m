function X = get_upper_tri(varargin)
%% Get upper half of matrix

if isempty(varargin{1})
    error('Use: [X] = get_upper_tri(X). X has to be a 2d/3d matrix.');
    
elseif size(varargin) == 1
    X = varargin{1};
    dim = size(X);
    
    if size(dim,2) == 1
        error('X has to be a 2d/3d matrix.')
        
    elseif size(dim,2) == 2
        for indRow = 1:dim(2)
            for indCol = 1:dim(2)
                if indCol <= indRow
                    X(indRow,indCol) = 0;
                end
            end
        end
    elseif size(dim,2) == 3
        for indSub = 1:dim(1)
            for indRow = 1:dim(2)
                for indCol = 1:dim(2)
                    if indCol <= indRow
                        X(indSub,indRow,indCol) = 0;
                    end
                end
            end
        end  
    end
end
end

