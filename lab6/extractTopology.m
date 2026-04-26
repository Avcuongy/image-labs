function topo = extractTopology(img)

    skel = bwmorph(img, 'skel', Inf);

    branch = bwmorph(skel, 'branchpoints');
    endpt  = bwmorph(skel, 'endpoints');

    topo.numBranches = sum(branch(:));
    topo.numEnds     = sum(endpt(:));

    % Projection (vertical peaks)
    proj = sum(img, 2);
    
    [~, peaks] = findpeaks(proj, 'MinPeakDistance', 5);
    topo.numPeaks = length(peaks);

end