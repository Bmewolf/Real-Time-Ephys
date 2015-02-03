Initial Contents of RAM for testing originally test4agood.mdl . The DATA has a 0.8* sinwave in the data with a .1 unit offset and 0.1 units of normal random noise  
The template is the same sin wave.
The filter is the setting you use to get the filter from the FDA tool.

Data ([0*(1:32) 0.8*sin(2*pi*(0:49)/50) 0*(1:46)  ] + 0.1 + normrnd(0, .1, [1,128]))
Template fliplr(0.8*sin(2*pi*(0:49)/50))
Filter  xlfda_numerator ('FDATool')


Contents of RAMs for testing the math

template  [zeros(1,128)]
data [0.1*ones(1,128)]
filter [0.1*ones(1,128)]

If you set the filter length to 10, then 0.1*0.1 = .01 
and accumulate 10 so 10*.01 = .1  so memory is initialized to point 1 and the filter process creates 0.1 to write ontop of the initial values.

During the template match, you get (0-.1)**2 = .01 and if you set the template length to 10
you get 0.1 as the answer from the accumulator





