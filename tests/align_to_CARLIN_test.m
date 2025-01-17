function tests = align_to_CARLIN_test
    tests = functiontests(localfunctions);
end

function test_fail_on_seq_empty(testCase)
    check_fail_on_seq_empty(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_fail_on_seq_empty(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_fail_on_seq_empty(testCase, CARLIN_def)
    verifyError(testCase, @() CARLIN_def.cas9_align(''), ?MException);
end

function test_fail_on_seq_with_gaps(testCase)
    check_fail_on_seq_with_gaps(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_fail_on_seq_with_gaps(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_fail_on_seq_with_gaps(testCase, CARLIN_def)    
    verifyError(testCase, @() CARLIN_def.cas9_align('A-'), ?MException);
end

function test_align_prefix_exact(testCase)
    check_align_prefix_exact(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_prefix_exact(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_prefix_exact(testCase, CARLIN_def)
    [~, aligned] = CARLIN_def.cas9_align(CARLIN_def.seq.prefix);
    s = aligned.get_seq();
    r = aligned.get_ref();
    bounds = CARLIN_def.bounds.prefix(1):CARLIN_def.bounds.prefix(2);
    verifyEqual(testCase, s(bounds), r(bounds));
end

function test_align_postfix_exact(testCase)
    check_align_postfix_exact(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_postfix_exact(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_postfix_exact(testCase, CARLIN_def)    
    [~, aligned] = CARLIN_def.cas9_align(CARLIN_def.seq.postfix);
    s = aligned.get_seq();
    r = aligned.get_ref();
    bounds = CARLIN_def.bounds.postfix(1):CARLIN_def.bounds.postfix(2);
    verifyEqual(testCase, s(bounds), r(bounds));
end

function test_align_postfix_approx(testCase)
    check_align_postfix_approx(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_postfix_approx(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_postfix_approx(testCase, CARLIN_def)    
    seq = corruptor(CARLIN_def.seq.postfix, 2, 98459);
    [~, aligned] = CARLIN_def.cas9_align(seq);
    s = aligned.get_seq();
    r = aligned.get_ref();
    bounds = CARLIN_def.bounds.postfix(1):CARLIN_def.bounds.postfix(2);
    verifyEqual(testCase, s(bounds), seq);
    verifyEqual(testCase, r(bounds), CARLIN_def.seq.postfix);
end

function test_align_segment_exact(testCase)
    check_align_segment_exact(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_segment_exact(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_segment_exact(testCase, CARLIN_def)    
    for i = 1:CARLIN_def.N.segments
        [~, aligned] = CARLIN_def.cas9_align(CARLIN_def.seq.segments{i});
        s = aligned.get_seq();
        r = aligned.get_ref();
        bounds = CARLIN_def.bounds.segments(i,1):CARLIN_def.bounds.segments(i,2);
        verifyEqual(testCase, s(bounds), r(bounds));
    end
end

function test_align_segment_approx(testCase)
    check_align_segment_approx(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_segment_approx(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_segment_approx(testCase, CARLIN_def)     
    for i = 1:CARLIN_def.N.segments
        seq = corruptor(CARLIN_def.seq.segments{i}, 1, 343+i*232, 1, 7);
        [~, aligned] = CARLIN_def.cas9_align(seq);
        s = aligned.get_seq();
        r = aligned.get_ref();        
        bounds = CARLIN_def.bounds.segments(i,1):CARLIN_def.bounds.segments(i,2);
        verifyEqual(testCase, s(bounds), seq);
        verifyEqual(testCase, r(bounds), CARLIN_def.seq.segments{i});
    end
end

function test_align_consite_exact(testCase)
    check_align_consite_exact(testCase, CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN')));
    check_align_consite_exact(testCase, CARLIN_amplicon(parse_amplicon_file('TigreCARLIN')));
end

function check_align_consite_exact(testCase, CARLIN_def)
    for i = 1:CARLIN_def.N.segments        
        [~, aligned] = CARLIN_def.cas9_align(CARLIN_def.seq.consites{i});
        s = aligned.get_seq();
        r = aligned.get_ref();
        bounds = CARLIN_def.bounds.consites(i,1):CARLIN_def.bounds.consites(i,2);
        verifyEqual(testCase, s(bounds), r(bounds));
    end
end

% These are list of sequences that the algorithm has previously errored out
% on and was subsequently modified to fix. Regress against these to make 
% sure new changes don't break old success stories.

function test_against_past_troublemakers(testCase)
    [folder, ~, ~] = fileparts(mfilename('fullpath'));    
    s = upper(splitlines(fileread(sprintf('%s/data/OriginalCARLIN/Troublemakers.txt', folder))));    
    CARLIN_def = CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN'));
    for i = 1:size(s,1)
        verifyWarningFree(testCase, @() CARLIN_def.cas9_align(s{i}));
    end
end

function test_long_deletion(testCase)
    % This sequence can also end up looking like an insertion at cutsite 1
    % and an elimination at cutsite 10, when really a deletion at both is a
    % better fit.
    CARLIN_def = CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN'));
    [~, aligned] = CARLIN_def.cas9_align('CGCCGGACTGCACGACAGTCGAACGATGGGAGCT');    
    verifyEqual(testCase, aligned.get_event_structure, 'NNDEEEEEEEEEEEEEEEEEEEEEEEEEEDN')
end

% For new alignment, both simple fail at 6 but not bad but trivially

% These are Sanger sequences generated from FO892 single-cell libraries 
% during protocol optimization. (Seqs 1, 6, 8, 9, 12, 14).
function test_against_sanger6(testCase)
   
    which_file = 'Sanger6';

    CARLIN_def = CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN'));
    [folder, ~, ~] = fileparts(mfilename('fullpath'));    
    raw = upper(splitlines(fileread(sprintf('%s/data/OriginalCARLIN/%s.txt', folder, which_file))));
    cfg = parse_config_file('Sanger');
    
    [trimmed, reorder, ~, trim_loc] = FastQData.extract_CARLIN_from_sequences(raw, [1:size(raw,1)]', cfg, CARLIN_def);
    trimmed = trimmed(reorder);
    
    assert(all(trim_loc.head_after_trim_5_primer == CARLIN_def.width.Primer5+1));
    assert(all(trim_loc.tail_after_trim_3_primer == cellfun(@length, raw)-CARLIN_def.width.Primer3));
    assert(all(trim_loc.tail_after_trim_2_seq    == cellfun(@length, raw)-CARLIN_def.width.Primer3-CARLIN_def.width.SecondarySequence));
    
    golden_mut_list = Mutation.FromFile(CARLIN_def, sprintf('%s/data/OriginalCARLIN/%sAnnotations.txt', folder, which_file));
    
    [~, aligned] = cellfun(@(x) CARLIN_def.cas9_align(x), trimmed, 'un', false);
    called_mut_list = cellfun(@(x) Mutation.identify_cas9_events(CARLIN_def, x), aligned, 'un', false);
    mismatch = find(cellfun(@(x,y) ~isequal(x,y), called_mut_list, golden_mut_list));        
    verifyEmpty(testCase, mismatch);
    
end

% This is a list of 75 sequences generated by Sanger sequencing early in
% the project. We know there are no sequencing errors here. I've
% hand-annotated the scarring patterns. Make sure algorithm recapitulates
% these.

function test_against_sanger75(testCase)

    CARLIN_def = CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN'));
    [folder, ~, ~] = fileparts(mfilename('fullpath'));
    raw = upper(splitlines(fileread(sprintf('%s/data/OriginalCARLIN/Sanger75.txt', folder))));    
    cfg = parse_config_file('Sanger');
    
    [~, head_after_trim_5_primer] = ...
        FastQData.trim_at_scrutiny_level(cfg.trim.Primer5, raw, CARLIN_def.seq.Primer5, 'head', 0, CARLIN_def.match_score.Primer5);

    [~, tail_after_trim_3_primer] = ...
        FastQData.trim_at_scrutiny_level(cfg.trim.Primer3, raw, CARLIN_def.seq.Primer3, 'tail', 0, CARLIN_def.match_score.Primer3);

    [~, tail_after_trim_2_seq] = ...
        FastQData.trim_at_scrutiny_level(cfg.trim.SecondarySequence, raw, CARLIN_def.seq.SecondarySequence, ...
                                         'tail', CARLIN_def.width.Primer3, CARLIN_def.match_score.SecondarySequence);
                                     
    golden_mut_list = Mutation.FromFile(CARLIN_def, sprintf('%s/data/OriginalCARLIN/Sanger75Annotations.txt', folder));
    
    % These are Sanger sequences with mangled secondary sequences which
    % make calling an allele difficult, and which we discard in practice
    blacklist = cellfun(@(x) isequal(x, 'X'), golden_mut_list);    
        
    % These are really awkward sequences that don't have an obviously
    % correct answer. Don't really care if things shift around here.
    whitelist = cellfun(@(x) isequal(x, '?'), golden_mut_list);
    
    assert(all(head_after_trim_5_primer == CARLIN_def.width.Primer5+1));
    assert(all(tail_after_trim_3_primer == cellfun(@length, raw)-CARLIN_def.width.Primer3));
    assert(all(tail_after_trim_2_seq(blacklist) == 0));
    
    trimmed = cell(size(raw));
    trimmed(~blacklist) = cellfun(@(x,b,e) x(b:e), raw(~blacklist), num2cell(head_after_trim_5_primer(~blacklist)), ...
                                                   num2cell(tail_after_trim_2_seq(~blacklist)), 'un', false);
    
    aligned = cell(size(trimmed));
    [~, aligned(~blacklist)] = cellfun(@(x) CARLIN_def.cas9_align(x), trimmed(~blacklist), 'un', false);
    
    called_mut_list = cell(size(aligned));
    called_mut_list(~blacklist) = cellfun(@(x) Mutation.identify_cas9_events(CARLIN_def, x), aligned(~blacklist), 'un', false)';
    mismatch = cellfun(@(x,y) ~isequal(x,y), called_mut_list, golden_mut_list);
    
    verifyEmpty(testCase, find(mismatch & ~(blacklist | whitelist)));
    
end

function test_nwscore(testCase)
    [folder, ~, ~] = fileparts(mfilename('fullpath'));
    fastq = sprintf('%s/data/OriginalCARLIN/BulkDNA.fastq.gz', folder);
    cfg = parse_config_file('BulkDNA');
    CARLIN_def = CARLIN_amplicon(parse_amplicon_file('OriginalCARLIN'));
    [SEQ, read_SEQ] = BulkFastQData.parse_bulk_fastq(fastq, cfg);
    SEQ = FastQData.extract_CARLIN_from_sequences(SEQ, read_SEQ, cfg, CARLIN_def);
    
    [sc_nw, al] = cellfun(@(x) nwalign(x, CARLIN_def.seq.CARLIN, 'Alphabet', 'NT', 'GapOpen', 10, 'ExtendGap', 0.5), SEQ, 'un', false);
    al = cellfun(@(x) CARLIN_def.desemble_sequence(x(1,:), x(3,:)), al, 'un', false);
    sc_re = cellfun(@(x) CARLIN_def.nwalign_score(x), al);
    
    % Multiply by sf to get unscaled scores from scaled.
    sf = nwalign('G', 'G', 'Alphabet', 'NT', 'ScoringMatrix', nuc44) / nwalign('G', 'G', 'Alphabet', 'NT');
    sc_nw = vertcat(sc_nw{:})*sf;
    
    verifyLessThan(testCase, max(abs(sc_nw-sc_re)), 1e-10);
end

function seq = corruptor(seq, num_to_mod, seed, left_pad, right_pad)
    if (nargin < 5)
        right_pad = 0;
    end
    if (nargin < 4)
        left_pad = 0;
    end
    rng(seed, 'twister');
    ind = randperm(length(seq)-left_pad-right_pad, num_to_mod)+left_pad;
    offset = uint8(randi(3, [1, num_to_mod]));    
    seq(ind) = mod(nt2int(seq(ind))+offset,4);
    seq(seq==0) = 4;
    seq(ind) = int2nt(seq(ind));
end
