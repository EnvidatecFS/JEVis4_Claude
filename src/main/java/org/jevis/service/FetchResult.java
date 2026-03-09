package org.jevis.service;

import java.time.Instant;

/**
 * Result of a Node-Red data fetch operation.
 * Carries the number of imported measurements and the timestamp range.
 */
public record FetchResult(int count, Instant firstTimestamp, Instant lastTimestamp) {

    public static FetchResult empty() {
        return new FetchResult(0, null, null);
    }

    /** Merge two results (used when aggregating across multiple data points). */
    public FetchResult merge(FetchResult other) {
        return new FetchResult(
            this.count + other.count,
            earliest(this.firstTimestamp, other.firstTimestamp),
            latest(this.lastTimestamp, other.lastTimestamp)
        );
    }

    private static Instant earliest(Instant a, Instant b) {
        if (a == null) return b;
        if (b == null) return a;
        return a.isBefore(b) ? a : b;
    }

    private static Instant latest(Instant a, Instant b) {
        if (a == null) return b;
        if (b == null) return a;
        return a.isAfter(b) ? a : b;
    }
}
