function labelchar = maplabelchar(keystr,varargin)
% labelchar = maplabelchar(keystr)
% takes typed in key string and returns appropriate label character
% par/value pair 'special',0 prevents mapping of special characters
%    (i,t,u,v,w,x,y,z)

par.special = 1;
par = parse_pv_pairs(par,varargin);

labelchar = keystr;
if length(keystr)==1 & par.special==1
        switch lower(keystr)
            case 'i'
                labelchar = 'Int';
             case 't'
                labelchar = 'Tet';
             case 'u'
                labelchar = 'Call';
              case 'v'
                labelchar = 'DCall';
            case 'x'
                labelchar = 'X';
            case 'y'
                labelchar = 'Ch2';
            case 'z'
                labelchar = 'Nz';
        end
    end
end
