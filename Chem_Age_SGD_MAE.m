clear
clc
aa=xlsread('base.xlsx');
tt=size(aa);
aa(tt(1,1)+1,:)=aa(tt(1,1),1)+1;
Grain_no_differnce=0;
p=1;
s=1;
for i=1:tt(1,1);
    Grain_no_differnce=aa(i+1,1)-aa(i,1);  
    if Grain_no_differnce==0;
        s=s;
    elseif Grain_no_differnce~=0 && i~=p;
        gg(s,:)=mean(aa([p:i],:));
        s=s+1;
        p=i+1;
    elseif Grain_no_differnce~=0 && i==p;
        gg(s,:)=aa(i,:);
        s=s+1;
        p=i+1;
    end
end
%gg matrix has average value of UO2 ThO2 and PbO i.e. multiple values of UO2 ThO2 and PbO for single grain average out in the form of single value
pp=gg;
average_values_Per_grain=gg;
gg(:,2)=pp(:,2)*0.88148/238.04;
gg(:,3)=pp(:,2)*0.88014/235;
gg(:,4)=pp(:,3)*0.878787/232;
gg(:,5)=pp(:,4)*0.92825/207;

%gg matix have percentage value of U (238) U(235) Th(232) and Pb
clearvars -except gg pp average_values_Per_grain

tt=size(gg);
for i=1:tt(1,1);
    if (gg(i,4)/gg(i,2))<=3
        gg(i,6)=log((gg(i,5)/gg(i,2))+1)/0.000155125;
    else
        gg(i,6)=log((gg(i,5)/gg(i,4))+1)/0.000049475;
    end;
end;
%Bowles paper condition applied in above loop where U/Th > 3 leads to calculation of age solely based on U(238) and U/Th< 3 condition calculate age solely based on Th%
%The above loop was done with motive to calcualate guided guess of intial age instead of random guess
%later we refine the guessed age to acutal age by considering component of U(238) U(235) and Th(232), which we do with gradient descent
gg(:,7)=pp(:,4)*0.92825;
age(:,1)=gg(:,1);
age(:,2)=gg(:,7);
clearvars -except gg pp age average_values_Per_grain

tt=size(gg);
err=0.0001;%hyperparameter 
alpha=1;%hyperparameter learning rate
for i=1:tt(1);
    l=0;
    time=gg(i,6);
    U238_estimated=((exp(0.000155125*time)-1)*(gg(i,2)*206*0.9927));%Pb component in percentage obtained solely from U238 with guessed value of time%
    U235_estimated=((exp(0.00098485*time)-1)*(gg(i,3)*207*0.0072));%Pb component in percentage obtained solely from U235 with guessed value of tim%
    Th232_estimated=((exp(0.00004975*time)-1)*(gg(i,4)*208));%Pb component in percentage obtained solely from Th232 with guessed value of tim%
    Pb_estimated=U238_estimated+U235_estimated+Th232_estimated;
    cost=(Pb_estimated-gg(i,7));
    cost=abs(cost);
    %cost is basically differnce between Pb_estimated using guessed value of time and Pb_actual obtained from EPMA, 
    %cost formula (J) usually used in deep learing is J=1/2(Y_Guessed - Y_actual)^2;
    while cost>=err
        U238_estimated=((exp(0.000155125*time)-1)*(gg(i,2)*206*0.9927));%Pb component in percentage obtained solely from U238 with improved value of time%
        U235_estimated=((exp(0.00098485*time)-1)*(gg(i,3)*207*0.0072));%Pb component in percentage obtained solely from U235 with improved value of time%
        Th232_estimated=((exp(0.00004975*time)-1)*(gg(i,4)*208));%Pb component in percentage obtained solely from Th232 with improved value of time%
        Pb_estimated=U238_estimated+U235_estimated+Th232_estimated;
        a238=(exp(0.000155125*time)*(gg(i,2)*206*0.9927))*0.000155125;%derivative of Pb_estimated solely from U238 w.r.t to time 
        a235=(exp(0.00098485*time)*(gg(i,3)*207*0.0072))*0.00098485;%derivative of Pb_estimated solely from U235 w.r.t to time
        a232=(exp(0.00004975*time)*(gg(i,4)*208))*0.00004975;%derivative of Pb_estimated solely from Th232 w.r.t to time
        cost_der_wrt_time=(a238+a235+a232);
        if Pb_estimated>gg(i,7);
            cost_der_wrt_time=1*cost_der_wrt_time;
        else
            cost_der_wrt_time=-1*cost_der_wrt_time;
        end;
        time=time-alpha*cost_der_wrt_time;
        U238_estimated=((exp(0.000155125*time)-1)*(gg(i,2)*206*0.9927));%Pb component in percentage obtained solely from U238 with improved value of time%
        U235_estimated=((exp(0.00098485*time)-1)*(gg(i,3)*207*0.0072));%Pb component in percentage obtained solely from U235 with improved value of time%
        Th232_estimated=((exp(0.00004975*time)-1)*(gg(i,4)*208));%Pb component in percentage obtained solely from Th232 with improved value of time%
        Pb_estimated=U238_estimated+U235_estimated+Th232_estimated;
        cost=(Pb_estimated-gg(i,7));
        cost=abs(cost);
        l=l+1;
    end;
    age(i,3)=Pb_estimated;
    age(i,4)=cost;
    age(i,5)=l;
    age(i,6)=time;
end;
Raw_data(:,1)=gg(:,1);
Raw_data(:,2)=gg(:,2);
Raw_data(:,3)=gg(:,4);
Raw_data(:,4)=gg(:,5);
clearvars -except age Raw_data average_values_Per_grain
Age_value_Per_grain=average_values_Per_grain;
Age_value_Per_grain(:,5)=age(:,6);
%output format of age matrix is [grain_number; Pb%_obtain_from_EPMA; Pb%_Calculated; Error_in_Pb_calculations; No_of_iterations; age_of_Mineral]
%output format of Raw_data matrix is [grain_number; U(238)_in_mole; Th(232)_in_mole; Pb_in_mole]; 
%output format of average_values_Per_grain matrix is [grain_number; UO2 _in_Percent; ThO2_in_Percent; PbO_in Percent]
%output format of Age_values_Per_grain matrix is [grain_number; UO2 _in_Percent; ThO2_in_Percent; PbO_in Percent; Age_of_Mineral]
Chemical_age=Age_value_Per_grain;
clearvars -except Chemical_age 
%output format of Chemical_age matrix is [grain_number; UO2 _in_Percent; ThO2_in_Percent; PbO_in Percent; Age_of_Mineral]


    
