import Darwin

/// Walk the process tree from `startPID` up to PID 1 via sysctl,
/// returning the chain [startPID, parentPID, grandparentPID, ...].
public func ancestorPIDs(from startPID: pid_t) -> [pid_t] {
    var chain: [pid_t] = []
    var current = startPID
    var seen = Set<pid_t>()

    while current > 0 && !seen.contains(current) {
        chain.append(current)
        seen.insert(current)

        if current == 1 { break }

        guard let ppid = parentPID(of: current) else { break }
        if ppid == current { break }
        current = ppid
    }
    return chain
}

/// Return the parent PID of a given process using sysctl.
private func parentPID(of pid: pid_t) -> pid_t? {
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.size

    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
    guard result == 0, size > 0 else { return nil }

    return info.kp_eproc.e_ppid
}
