function [filInd] = ScreenInd(varargin)

screen.ftrpath = [];
screen.ftrfile = [];
screen.ch2th=0.70;
screen.ampth=1;
screen.WEth= -0.35;
screen.lengthth= 30;

screen = parse_pv_pairs(screen,varargin);

load([screen.ftrpath screen.ftrfile],'-mat')

 filInd=(ones(size(clipftrs,1),1).*clipftrs(:,2) > screen.ch2th);
        filInd=filInd.*clipftrs(:,3)> screen.ampth;
        filInd=filInd.*clipftrs(:,7)< screen.WEth;
        filInd=filInd.*clipftrs(:,1) > screen.lengthth;
        
        
        
        
        filInd=find(filInd==1);