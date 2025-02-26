function [bp_event, del_event, ins_event] = classify_bp_event(CARLIN_def, aligned)

    if (isa(aligned, 'AlignedSEQ'))
        event_list = Mutation.identify_cas9_events(CARLIN_def, aligned);
    elseif (isa(aligned, 'Mutation'))
        event_list = aligned;
    else
        error('Unrecognized argument type');
    end
    
    bp_event = repmat('N', [1, CARLIN_def.width.CARLIN]);
    del_event = false(size(bp_event));
    ins_event = false(size(bp_event));
    
    for i = 1:size(event_list,1)
       if (event_list(i).type=='M')
           del_event(event_list(i).loc_start) = true;
           ins_event(event_list(i).loc_start) = true;
           bp_event(event_list(i).loc_start) = 'I';
       elseif (event_list(i).type=='D')
           del_event(event_list(i).loc_start:event_list(i).loc_end) = true;
           bp_event(event_list(i).loc_start:event_list(i).loc_end) = 'D';
       elseif (event_list(i).type=='I')
           ins_event(event_list(i).loc_start) = true;
           loc_end = get_insertion_end(CARLIN_def, event_list(i).loc_start, length(degap(event_list(i).seq_new)));           
           bp_event(event_list(i).loc_start:loc_end) = 'I';
       else           
           del_event(event_list(i).loc_start:event_list(i).loc_end) = true;
           bp_event(event_list(i).loc_start:event_list(i).loc_end) = 'D';
           loc_end = get_insertion_end(CARLIN_def, event_list(i).loc_start, length(degap(event_list(i).seq_new)));
           ins_event(event_list(i).loc_start) = true;
           bp_event(event_list(i).loc_start:loc_end) = 'I';
       end
    end
end

% Draw insertion up to minimum of its length, or the occurence of next
% cutsite
function loc_end = get_insertion_end(CARLIN_def, loc_start, ins_length)    
    loc_end = loc_start+ins_length-1;           
    next_site = find(CARLIN_def.bounds.cutsites(:,1) > loc_start, 1, 'first');
    if (~isempty(next_site))
        loc_end = min(loc_end, CARLIN_def.bounds.cutsites(next_site,1)-1);
    else
        loc_end = min(loc_end, CARLIN_def.width.CARLIN);
    end
end
