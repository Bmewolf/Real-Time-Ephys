
function [en_filter_wr_address_cntr, en_template_cntr, rst_template_acc, ld_template_cntr, en_filter_cntr, rst_filter_acc, filt_data_RAM_en,... 
    filt_data_RAM_wr, ld_filter_cntr, start_add_cntr_en, sample_skip_cntr_en, sample_skip_cntr_ld, latch_temp_accum] = ...
        cnt_state_machine(new_sample_available, template_cnt, template_size, filter_length, filter_cntr, sample_skip_cntr)
%UNTITLED Summary of this function goes here
%   Finite state machine to control the math
% THis program controls the process of doing a pattern match. The pattern
% or template is in the template RAM, the template RAM is dual ported to
% the processor and is filled by the processor under control of the GUI. 
% the template can be up to 256 samples long.  The data RAM is all dual
% ported from the processor and as samples come in they are placed in the
% next sequential location which wraps around to zero, so this acts as a
% circular buffer. The template RAM is addressed on this side by the
% template counter, the data RAM by the data counter. THe start address of
% the data counter must change with each sample but it counts up
% sequentially from the start address wrapping back to zero after 255. The
% temmplate counter counts up from zero so the template counter gets loaded
% or rest to zero. It takes one clock cycle to retrieve the data from
% memory.  The samples from the data RAM and the template RAM are
% subtracted then squared. THe squaring causes a 3 clock cycle delay, the
% squared value is then passed to the accumulator. The accumulator adds the
% values from reset to reset. Upon reest the accumulator goes to zero

persistent cnt_state , cnt_state = xl_state(zeros(1, 2), {xlUnsigned, 8, 0});
the_state = cnt_state(0);
% sample_cnt = cnt_state(1);

switch double(the_state)
% wait for sample here
    case 0
        if (~new_sample_available)       % no new sample yet
            next_state = 0;
            en_template_cntr = 0;           % no template counting
            rst_template_acc = 1;            % accumulator is reset
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        else                             % we have a new sample..start
            next_state = 1;
            en_template_cntr = 1;           % no template counting
            ld_template_cntr = 1;
            rst_template_acc = 1;            % accumulator is reset
            en_filter_cntr = 1;
            ld_filter_cntr = 1;
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            start_add_cntr_en = 0;
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        end
      case 1
        if(double(sample_skip_cntr) == 0)           % its time to execute the rest of states--no skip
            sample_skip_cntr_en = 1;            %reload the skip counter
            sample_skip_cntr_ld = 1;    
            next_state = 2;
            en_template_cntr = 0;            % load and reset the counters
            rst_template_acc = 1;
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;     % write the sample into
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        else                            % decimated sample, decrement the skip counter and go wait for next sample
            sample_skip_cntr_en = 1;        %decrement the skip counter
            sample_skip_cntr_ld = 0;        % do not reload it
            next_state = 20;                 % go back and wait for next sample
            en_template_cntr = 0;            % load and reset the counters
            rst_template_acc = 1;
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;     % write the sample into
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 1;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        end;
    case 2
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        next_state = 3;            % hold filter acc reset for 4 clocks states 2 3 4 5
        en_template_cntr = 0;            
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 1; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 3
        next_state = 4;            % hold acc reset for 4 clocks states 2 3 4 5
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;            
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 1; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 4
        next_state = 5;            % hold acc reset for 4 clocks states 2 3 4 5
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;           
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 1; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 5
        next_state = 6;            % hold acc reset for 4 clocks states 2 3 4 5
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;           
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 1; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 6   
        if (double(filter_cntr) == double(filter_length))
            next_state = 7;         % if done template
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_template_cntr = 0;            % continue counting to load next start address
            rst_template_acc = 1;
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 0;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        else 
            next_state = 6;         % just keep counting and accumulating
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_template_cntr = 0;           
            rst_template_acc = 1;
            ld_template_cntr = 0;
            en_filter_cntr = 1; 
            rst_filter_acc = 0;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        end
    case 7
        next_state= 8;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 7,8,9,10
        rst_template_acc = 1;                % rest accum, and load
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 0;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 8
        next_state = 9;
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;
        rst_template_acc = 1;                % spare for adding on
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 0;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 9
        next_state= 10;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 7,8,9,10
        rst_template_acc = 1;                % rest accum, and load
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 0;
        filt_data_RAM_en = 1;
        filt_data_RAM_wr = 0;                % write the filtered sample
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 10
        next_state= 11;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 7,8,9,10
        rst_template_acc = 1;                % rest accum, and load
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 1;           
        filt_data_RAM_wr = 1;          
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
% TEMPLATE MATCH
    case 11
        next_state = 12;            % hold acc reset for 4 clocks
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;            
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 12
        next_state = 13;            % hold acc reset for 4 clocks states
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 1;            
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
        
    case 13
        next_state = 14;            % hold acc reset for 4 clocks
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 1;           
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
        
    case 14
        next_state = 15;            % hold acc reset for 4 clocks states
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 1;           
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
        
    case 15
        next_state = 16;            % hold acc reset for 4 clocks states
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 1;           
        rst_template_acc = 1;
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 16  
        if (double(template_cnt) == double(template_size))
            next_state = 17;         % if done template
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_template_cntr = 0;            % continue counting to load next start address
            rst_template_acc = 0;
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        else 
            next_state = 16;         % just keep counting and accumulating
            sample_skip_cntr_en = 0;
            sample_skip_cntr_ld = 0;
            en_template_cntr = 1;           
            rst_template_acc = 0;
            ld_template_cntr = 0;
            en_filter_cntr = 0; 
            rst_filter_acc = 1;
            filt_data_RAM_en = 0;
            filt_data_RAM_wr = 0;
            ld_filter_cntr = 0;
            start_add_cntr_en = 0;
            en_filter_wr_address_cntr = 0; 
            latch_temp_accum = 0;
        end
    case 17
        next_state= 18;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 16, 17, 18, 19
        rst_template_acc = 0;                % dont reset accumulator
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 18
        next_state = 19;
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;
        rst_template_acc = 0;             
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 19
        next_state= 20;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 7,8,9,10
        rst_template_acc = 0;                % rest accum, and load
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
    case 20
        next_state = 0;                 % extend accumulator 4 cycles
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        en_template_cntr = 0;                  % for pipeline. states 7,8,9,10
        rst_template_acc = 1;                % rest accum, and load
        ld_template_cntr = 0;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 1;
        en_filter_wr_address_cntr = 1; 
        latch_temp_accum = 1;
   
    otherwise
        next_state = 0;
        sample_skip_cntr_en = 0;
        sample_skip_cntr_ld = 0;
        rst_template_acc = 1;
        en_template_cntr = 1;
        ld_template_cntr = 1;
        en_filter_cntr = 0; 
        rst_filter_acc = 1;
        filt_data_RAM_en = 0;
        filt_data_RAM_wr = 0;
        ld_filter_cntr = 0;
        start_add_cntr_en = 0;
        en_filter_wr_address_cntr = 0; 
        latch_temp_accum = 0;
end
cnt_state(0) = next_state;
% cnt_state(1) = last_input;

end

