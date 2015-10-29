function [labels] = makelabelkey(varargin)
% labels = makelabelkey(labels)
% make list of unique labels from labels in array labels.a
% store these in 
% labelkey(n) gives the character in labels.a.label for the nth unique label
% labelkey2(n) gives the number in labels.a.label2 for the nth unique label
% labelkey3{n} gives the string in labels.a.label3 for the nth unique label
% also put index to key in label.a.labelind
% makelabelkey with no arguments will prompt the user to locate a label
% file. The program will make a label key and save it to the file.

savetofile = 0;
if nargin==0
    [filename pathname] = uigetfile({'*.lbl','Label files (*.lbl)';'*.*','All files (*.*)'},'Choose label file');
    if filename==0 return; end
    load(fullfile(pathname,filename),'labels','-mat');
    savetofile = 1;
else
    labels = varargin{1};
end

labelstrs = {};
labelkey = '';
label2key = [];
label3key = {};
n = 0;

% first sort by label, put unlabeled or special labels at end
ulabel = unique([labels.a.label]);
special = (ulabel=='+' | ulabel=='=');
ulabel = [ulabel(~special) ulabel(special)];
ulabel = [ulabel(ulabel~=' ') ulabel(ulabel==' ')];
special = (ulabel=='+' | ulabel=='=');
for i=1:length(ulabel)
    inds = find([labels.a.label] == ulabel(i));
    if special(i) == 0
        ulabel2 = unique([labels.a(inds).label2]);
        if ulabel2(1) == 0
            ulabel2 = [ulabel2(2:end) ulabel2(1)];
        end
        for j=1:length(ulabel2)
            labelkey(end+1) = ulabel(i);
            label2key(end+1) = ulabel2(j);
            label3key{end+1} = '';
            inds2 = find([labels.a(inds).label2]==ulabel2(j));
            for k = 1:length(inds2)
                labels.a(inds(inds2(k))).labelind = n+j;
            end
        end
        n = n+length(ulabel2); 
    else
        k = 0; % number of categories with label3 added to key so far
        for j=1:length(inds)
            foundlabel = 0;
            for tmpk=1:k
                if strcmp(labels.a(inds(j)).label3,label3key{n+tmpk}) & labels.a(inds(j)).label2 == label2key(n+tmpk)
                    foundlabel = 1;
                    labels.a(inds(j)).labelind = n+tmpk;
                end
            end
            if ~foundlabel
                k=k+1;
                labelkey(n+k) = '=';
                label2key(n+k) = labels.a(inds(j)).label2;
                label3key{n+k} = labels.a(inds(j)).label3;
                labels.a(inds(j)).labelind = n+k;
            end
        end
        n = n+k;
    end
end
            
labels.labelkey = labelkey;
labels.label2key = label2key;
labels.label3key = label3key;

for i=1:length(labelkey)
    labelstrs{i} = makelabelstr(labelkey(i), label2key(i), label3key{i});
end
labels.labelstrs = labelstrs;
if savetofile
    save(fullfile(pathname,filename),'labels','-append','-mat');
end