function [label label2 label3] = parselabelstr(labelstr,varargin)
% [label label2 label3] = parselabelstr(labelstr,varargin)
% parse labelstr into label, label2 and label3 components

special = {'Int','Tet','Call','DCall','X','Ch2','Nz','noize'};
specialkey = {'I','T','U','V','X','Y','Z','Z'};

if isempty(labelstr)
    label = ' ';
    label2 = 1;
    label3 = '';
    return
end
if strcmpi(labelstr,'Ch2')
    labelstr = [labelstr '1'];
    label2 = 1;
elseif ismember(labelstr(end),'0123456789')
    label2 = str2num(labelstr(end));
else
    label2 = 1;
    labelstr = [labelstr '1'];
end
if length(labelstr)==2
    label = labelstr(1);
    label3 = '';
else
    % search for labelstr(1:end-1) among special strings
    isspecial = 0;
    for i=1:length(special)
        if strncmp(lower(special{i}),lower(labelstr(1:end-1)),length(special{i}));
            label = specialkey{i};
            label3 = '';
            isspecial = 1;
            break
        end
    end
    if ~isspecial
        label = '+';
        label3 = labelstr(1:end-1);
    end
end
