/**
 * Smooth scroll functionality for anchor links
 * Handles smooth scrolling with robust validation to prevent querySelector errors
 */

(function() {
    'use strict';

    /**
     * Initialize smooth scroll for all anchor links starting with #
     */
    function initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const href = this.getAttribute('href');

                // Validate selector - must be more than just '#' and contain valid characters
                if (!href || href === '#' || href.length <= 1 || href.trim() === '#') {
                    return; // Skip invalid anchors
                }

                // Additional validation: ensure it looks like a valid ID selector
                if (!/^#[a-zA-Z][\w-]*$/.test(href)) {
                    console.warn('Invalid anchor format:', href);
                    return;
                }

                e.preventDefault();
                try {
                    const target = document.querySelector(href);
                    if (target) {
                        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                } catch (error) {
                    // Invalid selector - silently fail or log for debugging
                    console.warn('querySelector error for:', href, error);
                }
            });
        });
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSmoothScroll);
    } else {
        initSmoothScroll();
    }
})();
