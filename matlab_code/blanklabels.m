function labels = blanklabels(varargin);
% labels = blanklabels;
% make empty labels structure with default fields
% labels = blanklabels(N);
% makes empty structure where fields are length N
% 
% labels has two types of fields
% .a is structure array holding data for each clip
% other fields can be added as needed, 
%
%%% array fields 
%     a.label = ' '; % character, space = unlabeled, use '+' or '=' for
%                       longer strings (stored in label3)
%     a.label2= 1; % version - single digit 0-9, 1 is default
%     a.label3 = ''; % string of any length, used if label= '+' or '='
%     a.corrupted = 0; % flags corrupted version of labeled clip
%     a.labeler = 0; % index to who generated label
%     a.labeltime = 0; % time when label was assigned
%     a.labelind = 0; % refer to index in labelkey, 0=unlabeled
%%% non-array fields
%  holds key - one entry for each unique label
%     labelkey = ' ';
%     label2key = 1;
%     label3key = {};
%     labelers = {'Auto','Todd','Meagan','David'};
%     clippath = ''; % path of file containing clips (bookmark or song)
%     clipfile = ''; % filename of file containing clips (bookmark or song)


% defaults
params.labelers = {'Auto','Todd','Meagan','David'};

N = 1;
if nargin > 0
    if isnumeric(varargin{1})
        N = varargin{1};
        varargin = varargin(2:end);
    end
    params = parse_pv_pairs(params,varargin);
end

% source of clips
labels.clippath = '';
labels.clipfile = '';
% required of all song structures
a.label = ' ';
a.label2= 1;
a.label3 = '';
a.corrupted = 0;
a.labelind = 1;
a.labeler = 0;
a.labeltime = 0;
labels.labelkey = ' ';
labels.label2key = 1;
labels.label3key = {''};
labels.labelers = params.labelers;    

if N>1
    a = repmat(a,N,1);
end
labels.a = a;
