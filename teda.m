classdef teda
    properties
        mu;
        var;
        ksi;
        zetav;
    end
    methods        
        function [obj, D] = AddPoint(obj,x,k)
            if(k==1)
                obj.mu=x;
                obj.var=norm(x)^2;                
                obj.ksi = 1;
                zeta = obj.ksi/2;
                obj.zetav = zeta;
            else
                obj.mu = ((k-1)/k)*obj.mu+(1/k)*x;
                obj.var = ((k-1)/k)*obj.var+(1/(k-1))*(norm(x-obj.mu)^2);
                obj.ksi = (1/k)+((obj.mu-x)*(obj.mu-x)')/(k*obj.var);
                zeta = obj.ksi/2;
                obj.zetav = [obj.zetav; zeta ];
            end
            D = zeta;
        end
    end
end