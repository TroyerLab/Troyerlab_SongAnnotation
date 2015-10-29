function [labels] = kmeansClass_f(varargin)
% function uses euclidean/mahanlanobis distance to calculate winners based on two ftr
% files and saves a .lbl file with results
% this function requires a feature and label file for test and training
% training files are used for creating distance scores, test files 
% for unlabeled data
% .ftr and .lbl must match in name;  will create a new label file for
% unlabeled data  KMM_TR.lbl
% resulting similarity measures are in squared units;

ftrtmp.trainftrpath=[];%ftr path train set
ftrtmp.trainftrfile=[];
ftrtmp.trainlblpath=[];
ftrtmp.trainlblfile=[]; %label train set

ftrtmp.testftrpath=[];%ftr path test set
ftrtmp.testftrfile=[];
ftrtmp.testlblpath=[];
ftrtmp.testlblfile=[]; % label test set

%thresholds for screening
ftrtmp.ch2th= 0.70;  
ftrtmp.ampth= 1;
ftrtmp.WEth= -0.35;
ftrtmp.lengthth= 30;

ftrtmp.begdata = 1;  % if bengalese finch data;  ******


ftrtmp.sliceDataOn = 0;% if the info is slice data, indicate 1.
ftrtmp.sliceDataOnIncludeLeng = 1; % whether to include the lengths w/ slice data.

ftrtmp.distMeas = {'m'}; %e for euclid, m for mahan.

ftrtmp.cats=[]; %which cats to consider in Training set;

ftrtmp.catToIgnore = 'X';
ftrtmp.clipindsused = [];


ftrtmp.ftr2use = [1,3:14]; %takes away ch2 var, ampdiff variables;

ftrtmp.scalevecind = 0; % default 1 to scale ALL data based on 'cats' declared in ftrtmp.cats

ftrtmp.save = 1; %indicates to save labels form from winners
ftrtmp.savefile=[];



ftrtmp = parse_pv_pairs(ftrtmp,varargin);


%% Loading Information
    if isempty(ftrtmp.trainftrpath) %load training set

         [ftrtmp.trainftrfile,ftrtmp.trainftrpath] = uigetfile({'*.ftr','ftr file (*.tmpl)';'*.*','All files'},...
                'Pick train .ftr file','Choose ftr file');
            
            
            trainingftr =load(fullfile(ftrtmp.trainftrpath,ftrtmp.trainftrfile),'-mat'); % load ftr file
            
            ftrtmp.trainlblfile=[ftrtmp.trainftrfile(1:length(ftrtmp.trainftrfile)-3) 'lbl'];
            
            
            if exist(fullfile(ftrtmp.trainftrpath,ftrtmp.trainlblfile)) > 0
            
                traininglbls =load(fullfile(ftrtmp.trainftrpath,ftrtmp.trainlblfile),'-mat'); %lbl file from ftr file ext.
            
            else
               
                h = msgbox('Could not Find .lbl FILE');
                
                
                [ftrtmp.trainlblfile,ftrtmp.trainlblpath] = uigetfile({'*.lbl','lbl file (*.lbl)';'*.*','All files'},...
                'Pick train .lbl file','Choose lbl file');
                close(h)
                
                traininglbls =load(fullfile(ftrtmp.trainlblpath,ftrtmp.trainlblfile),'-mat'); 
            
            end
            
            
            
    else
            trainingftr =load(fullfile(ftrtmp.trainftrpath,ftrtmp.trainftrfile),'-mat');
            ftrtmp.trainlblfile=[ftrtmp.trainftrfile(1:length(ftrtmp.trainftrfile)-3) 'lbl'];
            traininglbls = load(fullfile(ftrtmp.trainftrpath,ftrtmp.trainlblfile),'-mat');
            
    end
    
    
    
    if isempty(ftrtmp.testftrpath) % load second set which is unlabeled

             [ftrtmp.testftrfile,ftrtmp.testftrpath] = uigetfile({'*.ftr','ftr file (*.tmpl)';'*.*','All files'},...
                    'Pick test.ftr file','Choose ftr file');
                testingftr =load(fullfile(ftrtmp.testftrpath,ftrtmp.testftrfile),'-mat'); % load ftr file

                ftrtmp.testlblfile=[ftrtmp.testftrfile(1:length(ftrtmp.testftrfile)-3) 'lbl'];
                
            if exist(fullfile(ftrtmp.testftrpath,ftrtmp.testlblfile)) > 0
            
                testinglbls =load(fullfile(ftrtmp.testftrpath,ftrtmp.testlblfile),'-mat'); %lbl file from ftr file ext.
            
            else
                
               h = msgbox('Could not Find .lbl FILE');
                
                
                [ftrtmp.testlblfile,ftrtmp.testlblpath] = uigetfile({'*.lbl','lbl file (*.lbl)';'*.*','All files'},...
                'Pick test .lbl file','Choose lbl file');
            
            close(h)
            
                 testinglbls =load(fullfile(ftrtmp.testftrpath,ftrtmp.testlblfile),'-mat'); %lbl file from ftr file ext.
            
                
            end 
                
                

     else
                testingftr = load(fullfile(ftrtmp.testftrpath,ftrtmp.testftrfile),'-mat');
                ftrtmp.testlblfile=[ftrtmp.testftrfile(1:length(ftrtmp.testftrfile)-3) 'lbl'];
                testinglbls = load(fullfile(ftrtmp.testftrpath,ftrtmp.testlblfile),'-mat');

     end
         
 trainkey=[traininglbls.labels.a.labelind]; %label trainkey
 
 
 
 %%  which ftrs should be consider
 
         if ~isempty(ftrtmp.ftr2use) & ftrtmp.sliceDataOn ==0

            trainingftr.clipftrs = trainingftr.clipftrs(:,ftrtmp.ftr2use);
         
            testingftr.clipftrs = testingftr.clipftrs(:,ftrtmp.ftr2use);
            
         elseif ~isempty(ftrtmp.ftr2use) & ftrtmp.sliceDataOn == 1
         
             
             trainingftr.clipftrs = trainingftr.clipftrs;
         
            testingftr.clipftrs = testingftr.clipftrs;
             

         end 

         
    



 %% getting Screen indices
            


        %filtering indices
        
        if ftrtmp.sliceDataOn== 1
         
            tempftrfilename=[ftrtmp.trainlblfile(1:end-3) 'ftr'];
            
            filIndtrain = ScreenInd('ftrpath',ftrtmp.trainftrpath,'ftrfile',tempftrfilename...
            ,'ampth',ftrtmp.ampth,'Weth',ftrtmp.WEth,'lengthth',ftrtmp.lengthth,'ch2th',ftrtmp.ch2th);
        
                
        else
   
            filIndtrain = ScreenInd('ftrpath',ftrtmp.trainftrpath,'ftrfile',ftrtmp.trainftrfile...
            ,'ampth',ftrtmp.ampth,'Weth',ftrtmp.WEth,'lengthth',ftrtmp.lengthth,'ch2th',ftrtmp.ch2th);
        
        end
        
        
        
        if ftrtmp.begdata == 1
            
            filIndtrain = 1:length(trainkey); % no screening used; all clips
            
            filIndtrain = setdiff(filIndtrain,find(strcmp(traininglbls.labels.labelstrs(trainkey),ftrtmp.catToIgnore)));
            
        end
        
        
        

        
  %% adding length to ftrs       
         
        if ftrtmp.sliceDataOnIncludeLeng == 1 & ftrtmp.sliceDataOn == 1
            
            data_1 = load([ftrtmp.trainftrpath ftrtmp.trainlblfile(1:end-3) 'ftr'],'-mat');
            data_2 = load([ftrtmp.testftrpath ftrtmp.testlblfile(1:end-3) 'ftr'],'-mat');
            
            data_1_length = data_1.clipftrs(:,1);
            data_2_length = data_2.clipftrs(:,1);
            
            trainingftr.clipftrs = [trainingftr.clipftrs data_1_length];
            
            testingftr.clipftrs = [testingftr.clipftrs data_2_length];

        end
         
         
         
         
 
 %% normalize trainingftr.clipftrs based on 'cats' Declared
        
              catdev1 = zeros(length(unique(ftrtmp.cats)),size(trainingftr.clipftrs,2));
             
              
              Cinds =[];
                     for i = 1:length(ftrtmp.cats)
                          
                          Cinds = [Cinds find(trainkey==ftrtmp.cats(i))];
                                                                                                        
                          
                     end
                     
                     
                     if ftrtmp.scalevecind==1
                         
                         if ~isempty(ftrtmp.clipindsused)
                            
                             Cinds = intersect(ftrtmp.clipindsused,Cinds);  % adding the clipindsused variable
                         
                         end
                         
                          scaleVec = std(trainingftr.clipftrs(Cinds,:));  % scaling vector based on train set;
            
                       
                          
                           
                       
 
                             for j=1:length(trainingftr.clipftrs)

                                   trainingftr.clipftrs(j,:)=trainingftr.clipftrs(j,:)./scaleVec;
                             end
                             
                             

                             for k =1:length(testingftr.clipftrs)
                                   testingftr.clipftrs(k,:)=testingftr.clipftrs(k,:)./scaleVec ;
                             end
                             
                             
                             
                     else
                         
                         scaleVec = ones(1,size(trainingftr.clipftrs,2));

                     end
                     
                     
                     

        
        
        

        
        
        
%% find the mean vectors for tmpl cats;

km=zeros(length(ftrtmp.cats),min(size(trainingftr.clipftrs)));
   
           for i = 1:length(ftrtmp.cats)

                ind1=find(trainkey==ftrtmp.cats(i));
                indsCats=intersect(ind1,filIndtrain);
                
                if ~isempty(ftrtmp.clipindsused)
                    
                   indsCats = intersect(indsCats,ftrtmp.clipindsused);  
                    
                end
                
                
                

                km(i,:)=mean(trainingftr.clipftrs(indsCats,:));   % screened and subset from clips used


            end

%% similarity scores  
                
                if strcmp(ftrtmp.distMeas,'e') %euclid. sim.
                    
                    
                        for i=1:length(testingftr.clipftrs)
                            zc=repmat(testingftr.clipftrs(i,:),min(size(km)),1);
                            
                            [score wind]=min(sum((zc-km).^2,2));
                            
                            allScores(i,:)=sum((zc-km).^2,2);
                            
                                win(i)=wind;
                            
                            winScore(i)=score;
                            
                        end
                
                else
                    
                        if ~isempty(ftrtmp.clipindsused)
                            
                            filIndtrain = intersect(filIndtrain,ftrtmp.clipindsused);  % this should allow subset of clips requested
                            
                        end
                    

                        screentrainkey = trainkey(filIndtrain);  % screen train KEY index


                        trainingftr.screenclipftrs = trainingftr.clipftrs(filIndtrain,:);  %sub filtered ftr matrix
                    
                     for i = 1:length(ftrtmp.cats)
                         
                            catinds = find(screentrainkey == ftrtmp.cats(i));
                            
                            subCatftrs = trainingftr.screenclipftrs(catinds,:);



                            ftrtmp.invCovAllftrs{i} = inv(cov(subCatftrs));
                            ftrtmp.ftrmean(i,:) = mean(subCatftrs);
                            ftrtmp.ftrstds(i,:) = std(subCatftrs);


                             for j =1:size(testingftr.clipftrs,1)
                                 
                                       if size(subCatftrs,1) > size(subCatftrs,2)  %need to conisder when n<k (per cats);

                                          DistMat(i,j)= mahal(testingftr.clipftrs(j,:),subCatftrs);

                                          

                                       else  
                                                   if j==1
                                                       display('***********');
                                                       display('Mahal error');
                                                       display('***********');
                                                   end
                                                   
                                           if ftrtmp.sliceDataOn == 0
                                                   
                                           tempCov = eye(length(ftrtmp.ftr2use));
                                           
                                           else
                                               
                                           tempCov = eye(length(size(trainingftr.clipftrs,2)));
                                               
                                           end
                                           
                                           diaVar = diag(cov(subCatftrs));
                                           meanVec= mean(subCatftrs)';

                                                  for z=1:length(tempCov)
                                                     tempCov(z,z) = diaVar(z); 
                                                  end

                                            DistMat(i,j) = (testingftr.clipftrs(j,:)'-meanVec)'*inv(tempCov)*(testingftr.clipftrs(j,:)'-meanVec);
                                            
                                            ftrtmp.invCovAllftrs{i}=inv(tempCov);
                                            
                                       
                                       end
                                      
                             end
                             
                             clear catinds; clear subCatftrs;

                     end
                     [MinValue win] = min(DistMat);
                end     
                
              
         if strcmp(ftrtmp.distMeas,'e')         
                 
             DistMat = allScores;
             MinValue = winScore;
         end
       
                
                    
      ftrtmp.MinValue =MinValue;                                 
      ftrtmp.DistMat = DistMat;
      win = ftrtmp.cats(win);
      
      
    
      
%%  Screen clips from test file

        
        
        if ftrtmp.sliceDataOn == 1
            
            tempftrfilename=[ftrtmp.testlblfile(1:end-3) 'ftr']; 
            
             filIndtest = ScreenInd('ftrpath',ftrtmp.testftrpath,'ftrfile',tempftrfilename...
            ,'ampth',ftrtmp.ampth,'Weth',ftrtmp.WEth,'lengthth',ftrtmp.lengthth,'ch2th',ftrtmp.ch2th);
            
        else
        
        
      
            filIndtest = ScreenInd('ftrpath',ftrtmp.testftrpath,'ftrfile',ftrtmp.testftrfile...
            ,'ampth',ftrtmp.ampth,'Weth',ftrtmp.WEth,'lengthth',ftrtmp.lengthth,'ch2th',ftrtmp.ch2th);
        
        end
        
        
        if ftrtmp.begdata == 1
            
            filIndtest = 1:size(testingftr.clipftrs,1); % no screening used; all clips
            
        end
        
        
        
trainstr = traininglbls.labels.labelstrs;
        
        

              %   [match] = labelsComp(teststr,testkey,trainstr,win);



%% create label file structure

[labels] = str2lbl('stringkey',trainstr,'winners',win,'winningInds',filIndtest,'save',0,...
    'lblpath', ftrtmp.testftrpath , 'lblfile',ftrtmp.testlblfile);

labels.clipfile = [ftrtmp.testftrfile(1:end-4) '.bmk'];
labels.clippath = [ftrtmp.testftrpath ] ;

%%  saving information

ftrtmp.filIndTestSet = filIndtest;



        if ftrtmp.save ==1 && strcmp(ftrtmp.distMeas,'e')

                    if isempty(ftrtmp.savefile)
                    
            
                        ftrtmp.savefile = [ftrtmp.testftrpath ftrtmp.testftrfile(1:end-4) 'KM_Tr.lbl'];
                    
                    end
                    
                    save(ftrtmp.savefile,'labels','ftrtmp','-mat')
                    
                     display('###################')
                     display('')
                     display(['SAVED UNDER: ' ftrtmp.savefile ])
                     display('')
                     display('###################')
                    
                    
                    
        elseif ftrtmp.save ==1 && strcmp(ftrtmp.distMeas,'m')
            
                    if ftrtmp.sliceDataOn==1
                        
                         if isempty(ftrtmp.savefile)
                        
                            ftrtmp.savefile = [ftrtmp.testftrpath ftrtmp.testftrfile(1:end-4) 'KMM_TrS.lbl'];
                         
                         end
                    else

                         if isempty(ftrtmp.savefile)
                
                            ftrtmp.savefile = [ftrtmp.testftrpath ftrtmp.testftrfile(1:end-4) 'KMM_Tr.lbl'];
                         
                         end
                         
                    end
            
                      
            save(ftrtmp.savefile,'labels','ftrtmp','-mat')
            
            display('###################')
            display('')
            display(['SAVED UNDER: ' ftrtmp.savefile ])
            display('')
            display('###################')
            
        else
            
                      
        end


      




