rm(list=ls())
#����ѵ�������ݣ���ȥ�����ݵĵ�һ�г������������
TrainData<-read.csv("G:/��ģ����/ѡ�����ݼ�/DataForRegression_Train.csv",header=T)
TrainData<-TrainData[,-1]
#ȥ�������д�������ֵΪ0���У��������ݱ�����Train_Data1���ݿ���
Factors<-c()
for(i in 1:nrow(TrainData)){
  Factors[i]<-all(TrainData[i,]!=0)
}
Train_Data1<-TrainData[Factors,]
#ͳһ���Ӷ������ʵ�Ӱ�췽��Ϊ���򣬽������ϵ������ֵȡ���������������ݱ�����Train_Data������
Train_Data<-matrix(nrow=nrow(Train_Data1),ncol=11)
Vectors<-c(rep(0,4),rep(1,2),rep(0,5))#����������ֵΪ0��ʾ��Ӧ������Ϊ����Ӱ��
for (i in 1:length(Vectors)){
  if(Vectors[i]==0){
    Train_Data[,i]<-1/Train_Data1[,i]
  } else Train_Data[,i]<-Train_Data1[,i]
}
Train_Data<-as.data.frame(Train_Data)
library(psych)
pc<-principal(Train_Data,nfactors=3,score=TRUE)
Coefficients<-round(unclass(pc$weights),3)
Weights<-c(0.39,0.35,0.26)
Mean<-apply(Train_Data,2,mean)
Sd<-apply(Train_Data,2,sd)
setwd("G:/��ģ����/ѡ�����ݼ�/Predict")
name<-dir()
filename<-as.character(1:length(name))
ExReturn<-c()
#��������������ÿ��ѡ����50ֻ��Ʊ����
Stock_List<-matrix(nrow=50,ncol=6)
#ѭ������6���²��Լ�����
for (i in 1:length(name)){
  assign(filename[i],read.csv(name[i],header=TRUE,stringsAsFactors = FALSE))
  #ȥ��ԭʼ���ݼ��еĵ�һ�У������������ݿ�file_name1��
  file_name1<-get(filename[i])[-1,]
  #ȥ��ȱʡ�к͵�1��2���У������������ݿ�file_name2��
  file_name2<-na.omit(file_name1)[,c(-1,-2)]
  #ȥ�����ݿ�file_name2��ȡֵΪ0����
  factors<-c()
  for(i in 1:nrow(file_name2)){
    factors[i]<-all(file_name2[i,]!=0)
  }
  file_name2<-file_name2[factors,]
  #���洦������Ӧ�Ĺ�Ʊ����ͳ������������ݵ����ݿ�file_name3��
  file_name3<-na.omit(file_name1)[factors,c(1,2)]
  #ͳһ����Ӱ�췽�򣬷���Ϊ0������ֵȡ����
  for (i in 1:length(Vectors)){
    if(Vectors[i]==0){
      file_name2[,i]<-1/file_name2[,i]
    } else file_name2[,i]<-file_name2[,i]
  }
  #������ֵ���б�׼������
  scaled_data<-t(apply(file_name2,1,function(x){(x-Mean)/Sd}))
  Prin_Score<-scaled_data%*%Coefficients
  Score<-Prin_Score%*%Weights
  file_name3$Score<-Score
  Sort_Stock<-file_name3[order(file_name3[,3],decreasing=TRUE),]
  Select_Stock<-head(Sort_Stock,50L)
  Stock_List[,i]<-Select_Stock[,1]
  Stock_Selected<-as.numeric(Select_Stock[,2])
  ExReturn[i]<-mean(Stock_Selected)
}
Stock_List<-as.data.frame(Stock_List)
colnames(Stock_List)<-c("1��","2��","3��","4��","5��","6��")
write.csv(Stock_List,"G:/��ģ����/PCA_stock.csv", row.names=F)
CumReturn<-cumprod(ExReturn+1)
Date<-as.Date(c("20150130","20150227","20150331","20150430","20150529",
                "20150630"),"%Y%m%d")
Portflio<-data.frame(Date,ExReturn,CumReturn)
pdf("G:/��ģ����/PCA_return.pdf")
plot(Portflio$Date,Portflio$CumReturn,type="l",lwd=2,ylim=c(0.95,1),xlab="Date",
     ylab="Cumulative Return",pin=c(5,1.5),col="red")
dev.off()

 
  
  
  
  
  
  
  