function [functionals,varargout] = connLoadImages(Opts)
% Simply for loading the filenames of all images.
% Images' directories will be saved in a conn specific format.

% Version 1.0
% Nils Winter, Goethe University Frankfurt
% nils.winter1@gmail.com

switch Opts.imgExt
    case '.nii'
        functionals = cellstr(conn_dir(...
            [Opts.dataPathSubject filesep '*' Opts.nameFunctionals '*.nii']));
        if Opts.useStructurals
            structurals = cellstr(conn_dir(...
                [Opts.dataPathSubject filesep '*' Opts.nameStructurals '*.nii']));
        end
    case '.img'
        functionals = cellstr(conn_dir(...
            [Opts.dataPathSubject filesep Opts.nameFunctionals '*.img']));
        if Opts.useStructurals
            structurals = cellstr(conn_dir(...
                [Opts.dataPathSubject filesep '*' Opts.nameStructurals '*.img']));
        end
    otherwise
        error('Define image file extension.');
end

if rem(length(functionals),Opts.nSub)
    error('Mismatch number of functional files %n', length(functionals));
end

if Opts.useStructurals;
    if rem(length(structurals),Opts.nSub)
        error('Mismatch number of anatomical files %n', length(structurals))
    end
    varargout(1) = {structurals{1:Opts.nSub}};
end

functionals = reshape(functionals,[Opts.nSub,Opts.nSes]);
end