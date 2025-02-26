function [cp_mu, cp_sig, cp_dist] = CARLIN_potential(summary, edited_only)
    assert(isa(summary, 'ExperimentSummary'));
    if (nargin == 1)
        edited_only = false;
    end
    if (edited_only)
        is_template = strcmp(cellfun(@(x) degap(x.get_seq), summary.alleles, 'un', false), summary.CARLIN_def.seq.CARLIN);
        alleles = summary.alleles(~is_template);
        freqs   = summary.allele_freqs(~is_template);
    else
        alleles = summary.alleles;
        freqs   = summary.allele_freqs;
    end
    if (isempty(alleles))
        assert(edited_only);
        cp_dist = zeros(summary.CARLIN_def.N.segments+1,1);
        cp_dist(end) = 1;
        cp_mu = summary.CARLIN_def.N.segments;
        cp_sig = 0;
    else
        num_unmod = cellfun(@(x) summary.CARLIN_def.N.segments-length(Mutation.find_modified_sites(summary.CARLIN_def, x)), alleles);
        cp_dist = accumarray(num_unmod+1, freqs, [summary.CARLIN_def.N.segments+1, 1])/sum(freqs);
        cp_mu = sum(freqs.*num_unmod)/sum(freqs);
        cp_sig = sqrt(sum(freqs.*(num_unmod-cp_mu).^2)/sum(freqs));
    end
end