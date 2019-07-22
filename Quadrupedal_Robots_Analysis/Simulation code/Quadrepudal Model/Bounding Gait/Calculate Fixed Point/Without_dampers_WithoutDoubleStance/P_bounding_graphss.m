function data=P_bounding_graphss(q_0,u_0)
%%
g=9.8;                         %gravity acceleration 
k=3520;                         %spring constant
m=20.865;                        %torso mass
l_0=0.323;                       %rest length of leg
L = 0.276;                       % half length of torso
I = 1.3;                         % Torso moment of inertia
%u_0 = [phi_bTD,phi_fTD]
%u_0(1) = [phi_bTD] back leg touchdown angle
%u_0(2) = [phi_fTD] front leg touchdown angle

%q_0 = [y,theta,xdot,thetadot]


options_flight_1 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_1);
options_back_stance = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_back_stance);
options_flight_2 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_2);
options_front_stance = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_front_stance);
options_flight_3 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_3);
t0 = 0;
time= 10;
%fprintf('%f \n',(1/2)*m*(q_0(3)^2) + (1/2)*I*q_0(4)^2 + m*g*q_0(1));
%% 
figure
hold on
 for i =1:6
   %start at flight phase
   [t1,q,~,~,events_flight_1] =ode45(@flight_motion, [t0,time] , [20 , q_0(1), q_0(2) ,q_0(3),  0 , q_0(4)], options_flight_1);
    data(6*i-5).time1 = t1;
    data(6*i-5).phase = 'flight';
    data(6*i-5).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
    if events_flight_1 == 1 
       
        
   q_1=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
  
   %  =[x       ,y       ,theta   ,xdot    ,ydot    ,thetadot]
   time =time - t1(end);
   x_btoe = q_1(1) - L*cos(q_1(3)) + l_0*sin(u_0(1));
    

    [t2,q,~,~,events_back_stance] =ode45(@back_stance_motion, [t0,time] , [q_1(1),q_1(2),q_1(3),q_1(4),q_1(5),q_1(6)] , options_back_stance);
     data(6*i-4).time1 = t2+ t1(end);
     data(6*i-4).phase = 'back stance';
     data(6*i-4).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
  
    if events_back_stance == 1 
    
        q_2=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
     
        time = time - t2(end);
      

        [t3,q,~,~,events_flight_2] =ode45(@flight_motion, [t0,time] ,[q_2(1),q_2(2),q_2(3),q_2(4),q_2(5),q_2(6)] , options_flight_3);
          data(6*i-3).time1 = t3+ t2(end)+ t1(end);
          data(6*i-3).phase = 'flight phase';
          data(6*i-3).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
  
        if events_flight_2 == 1 
         q_3=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
         
         %  =[x       ,y,      ,theta   ,xdot,   ,ydot    ,thetadot]
         time =time - t3(end);
         
        [t4,q,~,~,events_flight_3] =ode45(@flight_motion, [t0,time] ,[q_3(1),q_3(2),q_3(3),q_3(4),q_3(5),q_3(6)] , options_flight_2);
          data(6*i-2).time1 = t4 + t3(end) + t2(end) + t1(end);
          data(6*i-2).phase = 'flight phase';
          data(6*i-2).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
        
        
        
        if events_flight_3 == 1
             q_4=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
     
             time = time - t4(end);
      
            x_ftoe= l_0*sin(u_0(2)) + q_4(1) + L*cos(q_4(3));
             
              [t5,q,~,~,events_front_stance] =ode45(@front_stance_motion, [t0,time] , q_4 , options_front_stance);
                data(6*i-1).time1 = t5 + t4(end) + t3(end) + t2(end) + t1(end);
                data(6*i-1).phase = 'front stance';
                data(6*i-1).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
  
               if events_front_stance == 1 
              q_5=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];        
               
              time =time - t5(end);
                  [t6,q,~,~,~] =ode45(@flight_motion, [t0,time] , q_5 , options_flight_3);
                   data(6*i).time1 =  t6 + t5(end) + t4(end) + t3(end) + t2(end) + t1(end);
                   data(6*i).phase = 'flight phase';
                   data(6*i).q = [q(:,1),q(:,2),q(:,3),q(:,4),q(:,5),q(:,6)];
                  
                  q_0=[q(end,2),q(end,3),q(end,4),q(end,6)];
        %         fprintf('%f \n',(1/2)*m*(q(end,4)^2) + (1/2)*I*q(end,6)^2 + m*g*q(end,2));
                  time =time - t6(end);
                 
                %  fprintf('%f \n',(1/2)*m*(q(4)^2 + q(5)^2) + (1/2)*I*q(6)^2 + m*g*q(2));
                  %fprintf('%f \n',((1/2)*m*(q(4)^2 + q(5)^2) + (1/2)*I*q(6)^2 + m*g*q(2))-((1/2)*m*(q_0(3)^2) + (1/2)*I*q_0(4)^2 + m*g*q_0(1)));
               end
       
        end
  
        end
  
    end
    end
    
 %   plot(data(i).q(:,3),data(i).q(:,6));
 %  plot(data(i).q(:,1),data(i).q(:,2));
 % xlabel('Pitch angle: $\theta$(rad)', 'Interpreter','latex');
 % ylabel('Pitch rate: $\dot{\theta}$(rad/s)', 'Interpreter','latex');
 % title('ICs:[y,$\theta$,$\dot{x}$,$\dot{\theta}$]=[0.3258 m,-0.0000 rad,0.6738 m/s, 6.1173 rad/s]', 'Interpreter','latex');
 % legend('flight phase','back stance','flight phase','flight stance','front phase','flight phase');
 % tx = ('Start point');
 % text(0,3,tx);
 for m = 1:6
   subplot(2,3,m)
   hold on
   plot(data(i).time1 , data(i).q(:,m));
   xlabel('Time : t(s)');
   if m == 1 
        ylabel('Horizontal position of CoM : x(m)', 'Interpreter','latex');
   elseif m == 2 
       ylabel('Vertical position of CoM : y(m)', 'Interpreter','latex');
   elseif m == 3 
      ylabel('Pitch angle : $\theta$(rad)', 'Interpreter','latex');
   elseif m == 4 
      ylabel('Forward speed : $\dot{x}$(m/s)', 'Interpreter','latex');
   elseif m == 5 
      ylabel('Vertical speed : $\dot{y}$(m/s)', 'Interpreter','latex');
   elseif m == 6 
      ylabel('Pitch rate : $\dot{\theta}$(rad/s)', 'Interpreter','latex');
   end
 end
  
 end
hold off
%% 

function dqdt=flight_motion(~,q)
%q=[x;y;theta;xdot;ydot;thetadot]
%dqdt=[xdot;ydot;thetadot;xddot;yddot;thetaddot]
dqdt_1=q(4);
dqdt_2=q(5);
dqdt_3=q(6);
dqdt_4= 0 ;
dqdt_5= -g  ;
dqdt_6= 0 ;


dqdt=[dqdt_1;dqdt_2;dqdt_3;dqdt_4;dqdt_5;dqdt_6];

end


function dqdt=back_stance_motion(~,q)
%q=[x;y;theta;xdot;ydot;thetadot]
%dqdt=[xdot;ydot;thetadot;xddot;yddot;thetaddot]
%Before this motion, indicate what is 'x_btoe'
l_b = sqrt((-q(1) + L*cos(q(3)) + x_btoe)^2+(-q(2) + L*sin(q(3)))^2);
dqdt_1=q(4);
dqdt_2=q(5);
dqdt_3=q(6);
dqdt_4=(k*(-q(1) + L*cos(q(3)) + x_btoe)*(l_b - l_0))/(m*l_b);
dqdt_5=(k*(-q(2) + L*sin(q(3)))*(l_b - l_0))/(m*l_b) -g  ;
dqdt_6= -(k*L*(q(1)*sin(q(3))- x_btoe*sin(q(3)) - q(2)*cos(q(3)))*(l_b - l_0))/(I*l_b)  ;


dqdt=[dqdt_1;dqdt_2;dqdt_3;dqdt_4;dqdt_5;dqdt_6];

end



function dqdt=front_stance_motion(~,q)
%q=[x;y;theta;xdot;ydot;thetadot]
%dqdt=[xdot;ydot;thetadot;xddot;yddot;thetaddot]
%Before this motion, indicate what is 'N' and 'x_btoe'
l_f = sqrt(( - q(1) - L*cos(q(3)) + x_ftoe)^2+(q(2) + L*sin(q(3)))^2);
dqdt_1=q(4);
dqdt_2=q(5);
dqdt_3=q(6);
dqdt_4=  (k*(-q(1) - L*cos(q(3)) + x_ftoe )*(l_f - l_0))/(m*l_f)  ;
dqdt_5=  - (k*(q(2) + L*sin(q(3)))*(l_f - l_0))/(m*l_f) -g;
dqdt_6=  - (k*L*(-q(1)*sin(q(3)) + x_ftoe*sin(q(3)) + q(2)*cos(q(3)) )*(l_f - l_0))/(I*l_f)   ;

dqdt=[dqdt_1;dqdt_2;dqdt_3;dqdt_4;dqdt_5;dqdt_6];

end



%% 

function [value,isterminal,direction] = end_flight_1(~,q) 
        % back leg touchdown event
       
		value = q(2) - L*sin(abs(q(3))) - l_0*cos(u_0(1));
		isterminal = 1;
		direction =  -1;
end


function [value,isterminal,direction] = end_back_stance(~,q) 
	    % back leg liftoff event
       
		value = (x_btoe - q(1) + L*cos(q(3)))^2 + (q(2) - L*sin(abs(q(3))))^2 -l_0^2 ;
		isterminal =  1;
		direction =   1;
end



function [value,isterminal,direction] = end_flight_2(~,q) 
        % front leg touchdown event
       
		value =  q(2) - L*sin(abs(q(3))) - l_0*cos(u_0(2))  ;
		isterminal = 1;
		direction =  -1;
end

function [value,isterminal,direction] = end_front_stance(~,q)  
        % front leg liftoff
       
		value =   (x_ftoe - q(1) - L*cos(q(3)))^2+(q(2) - L*sin(abs(q(3))))^2 - l_0^2 ;
		isterminal = 1;
		direction =  1;
end



function [value,isterminal,direction] = end_flight_3(~,q)  
        % apex event
		value = q(5)  ;
		isterminal = 1;
		direction =  -1;
end


end