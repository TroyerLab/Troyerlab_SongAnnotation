function [labels] = str2lbl(varargin)
%needs a cell containing strings of label key
%winning indicies;  corresponding original index (screening)
%will request a label file; should be the new empty one from
%sb3src_bmklbl label file creation; **  will OVERWRITE  **
% [labels] = str2lbl(stringkey, winners,winningInds, varargin)


lbling.stringkey={}; %cell strings for names

lbling.winners=[]; %decision made
lbling.winningInds = [];  %screen indicies/ passed

lbling.lblpath=[];  
lbling.lblfile=[];
lbling.save=0;

lbling = parse_pv_pairs(lbling,varargin);


stringkey=lbling.stringkey; 

%%
%load lbl file to save in and use for size of iteration;  

 if isempty(lbling.lblfile)
        [lbling.lblfile lbling.lblpath] = uigetfile({'*.lbl;','lbl files (*.lbl)';'*.*','All files (*.*)'},...
                                                            'Select lbl file','Select file');
        if lbling.lblfile==0; return; end
 end
    load(fullfile(lbling.lblpath,lbling.lblfile),'-mat');


    labels = blanklabels(length([labels.a.labelind]));
    
    
    winSet=lbling.winners;
    
    filInd=lbling.winningInds;



%%
%place X where screen clips occured;

finalSet = stringkey(winSet);


n=length([labels.a.labelind]);


for i=1:length([labels.a.labelind])

      
     [tempLabel tempLabel2 tempLabel3] =parselabelstr('X');
      labels.a(i).label=tempLabel  ;   %update with parselabelstr
        labels.a(i).label2=tempLabel2  ;
        labels.a(i).label3= tempLabel3 ;
end 




            finalSet_old = finalSet;
            finalSet_new={};

            t=1;

             if length(finalSet) < n      % only run this if winSet < N [labels.a.labelind]

                 finalSet_new = cell(n,1);
                 finalSet_new(filInd)= finalSet;
                 
                 nonfilInd = setdiff(1:n,filInd);
                 
                 %finalSet_new(nonfilInd) = 'X';
                 
                 for i =1:length(nonfilInd)
                     
                   finalSet_new{nonfilInd(i)}='X';
                     
                 end
                 
                 
                 
                 
                 
                 
                 
%                  for m = 1:n
%                      
%                      
% 
%                             if m == filInd(t)
% 
%                                 finalSet_new{m} = finalSet{t};
% 
%                                 t=t+1;
%                             else
% 
%                                 finalSet_new{m} = 'X';
% 
%                             end
%                      
%                      
% 
%                  end


             end


                     if length(finalSet) < n

                         finalSet = finalSet_new;

                     end

 

   
    sset = intersect(1:n,filInd);
   
    for j =1:length(sset)
        
                

            [tempLabel tempLabel2 tempLabel3] = parselabelstr(finalSet{sset(j)});

            labels.a(sset(j)).label=tempLabel  ;   %update with parselabelstr
            labels.a(sset(j)).label2=tempLabel2  ;
            labels.a(sset(j)).label3= tempLabel3 ;

            

                
            
    end
    
  
    



labels = makelabelkey(labels);



if lbling.save ==1
 

%    save([lbling.lblpath lbling.lblfile],'labels','-mat')

end
