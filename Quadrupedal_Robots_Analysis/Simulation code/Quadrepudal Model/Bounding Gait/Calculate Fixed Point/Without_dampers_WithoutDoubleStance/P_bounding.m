function q_6=P_bounding(q_0,u_0)
%%
g=9.8;                         %gravity acceleration 
k=3520;                         %spring constant
m=20.865;                        %torso mass
l_0=0.323;                       %rest length of leg
L = 0.276;                       % half length of torso
I = 1.3;                         %Torso moment of inertia
%u_0 = [phi_bTD,phi_fTD]
%u_0(1) = [phi_bTD] back leg touchdown angle
%u_0(2) = [phi_fTD] front leg touchdown angle

%q_0 = [y,theta,xdot,thetadot]


options_flight_1 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_1);
options_back_stance = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_back_stance);
options_flight_2 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_2);
options_front_stance = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_front_stance);
options_flight_3 = odeset('RelTol',1e-10,'AbsTol',1e-9,'Events', @end_flight_3);

time= 600;
fprintf('The total energy at first apex height is : %f \n',(1/2)*m*(q_0(3)^2) + (1/2)*I*q_0(4)^2 + m*g*q_0(1));
%% 

   %start at flight phase
   [t,q,~,~,events_flight_1] =ode45(@flight_motion, [0,time] , [20 , q_0(1), q_0(2) ,q_0(3),  0 , q_0(4)], options_flight_1);
 
    if events_flight_1 == 1 %(back leg touchdown)            % proceed flight phase to back leg stance phase
       
        
   q_1=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
  
   %  =[x       ,y       ,theta   ,xdot    ,ydot    ,thetadot]
   time =time - t(end);
   x_btoe = q_1(1) - L*cos(q_1(3)) + l_0*sin(u_0(1));
    

    [t,q,~,~,events_back_stance] =ode45(@back_stance_motion, [0,time] , [q_1(1),q_1(2),q_1(3),q_1(4),q_1(5),q_1(6)] , options_back_stance);

  
    if events_back_stance == 1 %(back leg liftoff)    % proceed back leg stance phase to flight phase
    
        q_2=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
     
        time = time - t(end);
      

        [~,q,~,~,events_flight_2] =ode45(@flight_motion, [0,time] ,[q_2(1),q_2(2),q_2(3),q_2(4),q_2(5),q_2(6)] , options_flight_3);
 
        if events_flight_2 == 1 %( reach apex height)   % proceed flight to apex
         q_3=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
         
         %  =[x       ,y,      ,theta   ,xdot,   ,ydot    ,thetadot]
         time =time - t(end);
         
        [~,q,~,~,events_flight_3] =ode45(@flight_motion, [0,time] ,[q_3(1),q_3(2),q_3(3),q_3(4),q_3(5),q_3(6)] , options_flight_2);
        if events_flight_3 == 1 %(end flight, front leg touch down)
             q_4=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
     
             time = time - t(end);
      
            x_ftoe= l_0*sin(u_0(2)) + q_4(1) + L*cos(q_4(3));
             
              [~,q,~,~,events_front_stance] =ode45(@front_stance_motion, [0,time] , q_4 , options_front_stance);
          
  
               if events_front_stance == 1 %(front leg liftoff)   % proceed front leg stance phase to flight phase
              q_5=[q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];       
               
              time =time - t(end);
                  [~,q,~,~,~] =ode45(@flight_motion, [0,time] , q_5 , options_flight_3);
               
                   q = [q(end,1),q(end,2),q(end,3),q(end,4),q(end,5),q(end,6)];
                  q_6=[q(end,2),q(end,3),q(end,4),q(end,6)];
       
                  fprintf('The total energy at next apex height is : %f \n',(1/2)*m*(q(4)^2 + q(5)^2) + (1/2)*I*q(6)^2 + m*g*q(2));
               %   fprintf('%f \n',((1/2)*m*(q(4)^2 + q(5)^2) + (1/2)*I*q(6)^2 + m*g*q(2))-((1/2)*m*(q_0(3)^2) + (1/2)*I*q_0(4)^2 + m*g*q_0(1)));
               end
       
        end
  
        end
  
    end
    end
    
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
%Before this motion, indicate what is 'x_ftoe'
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

function [value,isterminal,direction] = end_flight_1(~,q)   % between flight(Apex) and back leg stance           %act on the flight_motion
        % back leg touchdown event
       
		value = q(2) - L*sin(abs(q(3))) - l_0*cos(u_0(1));
		isterminal = 1;
		direction =  -1;
end


function [value,isterminal,direction] = end_back_stance(~,q)  %between back leg stance and flight stance     %act on the back_stance_motion
	    % back leg liftoff event
       
		value = (x_btoe - q(1) + L*cos(q(3)))^2 + (q(2) - L*sin(abs(q(3))))^2 -l_0^2 ;
		isterminal =  1;
		direction =   1;
end



function [value,isterminal,direction] = end_flight_2(~,q)  %between flight and front leg stance   %act on the flight_motion
        % front leg touchdown event
       
		value =  q(2) - L*sin(abs(q(3))) - l_0*cos(u_0(2))  ;
		isterminal = 1;
		direction =  -1;
end

function [value,isterminal,direction] = end_front_stance(~,q)  %between front leg stance and flight stance   %act on the front_stance_motion
        % front leg liftoff
       
		value =   (x_ftoe - q(1) - L*cos(q(3)))^2+(q(2) - L*sin(abs(q(3))))^2 - l_0^2 ;
		isterminal = 1;
		direction =  1;
end



function [value,isterminal,direction] = end_flight_3(~,q)          %act on the flight_motion
        % apex event
		value = q(5)  ;
		isterminal = 1;
		direction =  -1;
end


end