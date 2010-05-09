% Unique properties of singleton.  This can be only accessed
% with the getter/setter methods via any subclass of singleton.

classdef singleton < handle handler2
   %SINGLETON Abstract Class for singleton OOP Design Pattern
   %  Intent:  Ensures a class only has one instance and provide a
   %  global point of access to it [1].
   %  Motivation:  It's important for some classes to have exactly one
   %  instance.  For example, it can be desirable to have only a
   %  single instance of a GUI.  With a MATLAB GUIDE built GUI, the driver
   %  or main function provides a global point of access which is
   %  executed to,
   %  1. initially instantiate the GUI; and
   %  2. subsequently bring the existing GUI into focus *not* creating
   %     a new one.
   %  Implementation:  MATLAB OOP doesn't have the notion of static
   %  properties.  Properties become available once the constructor
   %  of the class is invoked.  In the case of the singleton Pattern, it
   %  is then undesirable to use the constructor as a global point of
   %  access since it creates a new instance before you can check if an
   %  instance already exists.  The solution is to use a persistent
   %  variable within a unique static method instance() which calls the
   %  constructor to create a unique 'singleton' instance.  The persistent
   %  variable can be interrogated prior to object creation and after
   %  object creation to check if the singleton object exists.  There are
   %  two conditions that all subclasses must satisfy:
   %  1. Constructor must be hidden from the user (Access=private).
   %  2. The concrete implementation of instance() must use a persistent
   %     variable to store the unique instance of the subclass.
   % 
   %  Refer to pp.127-134 Gamma et al.[1] for more information on the
   %  singleton Design Pattern.
   % 
   %  Written by Bobby Nedelkovski
   %  The MathWorks Australia Pty Ltd
   %  Copyright 2009, The MathWorks, Inc.
   %
   %  Reference:
   %  [1] Gamma, E., Helm, R., Johnson, R. and Vlissides, J.
   %      Design Patterns : Elements of Reusable Object-Oriented Software.
   %      Boston: Addison-Wesley, 1995.

   properties(Access=public)
      Data = [];
   end
   
   methods(Abstract, Static)
      % This method serves as the global point of access in creating a
      % single instance *or* acquiring a reference to the singleton.
      % If the object doesn't exist, create it otherwise return the
      % existing one in persistent memory.
      % Input:
      %    <none>
      % Output:
      %    obj = reference to a persistent instance of the classix
      obj = instance();
   end
   
   methods % Public Access
     
     function v = get_Data(obj)
       v = obj.Data;
     end
      
     function set_Data(obj, singletonData)
       obj.Data = singletonData;
     end % end1
     
     function v = get.Data(obj)
       v = obj.Data;
     end
      
     function set.Data(obj, singletonData)
       obj.Data = singletonData;
     end % end1
     
     % And the if .. end issue.
     function v = showsTripleDot(obj, x_)
       function v_ = nested(x, y)
         v_ = nested(x, y);
       end
       
       warning('showsTripleDot error %s\n', ...
               x_);
      if idx > length(obj.searched0)
          warning('model2:system volatility %f > calibrated %f\n', ...
            obj.volatility0, obj.searched0(end));
         idx = length(obj.searched0);
      end
      
      for idx = 1:length(obj.searched0)
        switch idx
         case 1
         case 2
         otherwise
        end
      end
    end
    
    function v = showsTripleDot1(obj, x_)
      v=v;
    end
    
    % @fn void update(type obj, type returner)
      
   end

end
