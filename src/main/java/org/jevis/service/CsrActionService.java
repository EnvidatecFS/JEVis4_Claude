package org.jevis.service;

import org.jevis.model.CsrAction;
import org.jevis.model.CsrCategory;
import org.jevis.model.CsrStatus;
import org.jevis.repository.CsrActionRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * Service for managing CSR (Corporate Social Responsibility) actions.
 * Provides business logic for CSR action CRUD operations.
 */
@Service
@Transactional(readOnly = true)
public class CsrActionService {

    private final CsrActionRepository csrActionRepository;

    public CsrActionService(CsrActionRepository csrActionRepository) {
        this.csrActionRepository = csrActionRepository;
    }

    // === CRUD Operations ===

    /**
     * Create a new CSR action.
     * @param action The action to create
     * @return The created action
     */
    @Transactional
    public CsrAction createAction(CsrAction action) {
        if (action.getStatus() == null) {
            action.setStatus(CsrStatus.PLANNED);
        }
        if (action.getProgressPercent() == null) {
            action.setProgressPercent(0);
        }
        if (action.getPriority() == null) {
            action.setPriority("MEDIUM");
        }
        return csrActionRepository.save(action);
    }

    /**
     * Update an existing CSR action.
     * @param id The action ID
     * @param updatedAction The updated action data
     * @return The updated action
     * @throws IllegalArgumentException if action not found
     */
    @Transactional
    public CsrAction updateAction(Long id, CsrAction updatedAction) {
        CsrAction existingAction = getActionById(id);

        existingAction.setTitle(updatedAction.getTitle());
        existingAction.setDescription(updatedAction.getDescription());
        existingAction.setCategory(updatedAction.getCategory());
        existingAction.setStatus(updatedAction.getStatus());
        existingAction.setResponsiblePerson(updatedAction.getResponsiblePerson());
        existingAction.setDeadline(updatedAction.getDeadline());
        existingAction.setProgressPercent(updatedAction.getProgressPercent());
        existingAction.setPriority(updatedAction.getPriority());
        existingAction.setEstimatedImpact(updatedAction.getEstimatedImpact());

        // Auto-set progress to 100% if completed
        if (updatedAction.getStatus() == CsrStatus.COMPLETED) {
            existingAction.setProgressPercent(100);
        }

        return csrActionRepository.save(existingAction);
    }

    /**
     * Delete a CSR action.
     * @param id The action ID
     * @throws IllegalArgumentException if action not found
     */
    @Transactional
    public void deleteAction(Long id) {
        if (!csrActionRepository.existsById(id)) {
            throw new IllegalArgumentException("CSR Action not found with ID: " + id);
        }
        csrActionRepository.deleteById(id);
    }

    // === Retrieval Methods ===

    /**
     * Get all CSR actions.
     * @return List of all actions
     */
    public List<CsrAction> getAllActions() {
        return csrActionRepository.findAll();
    }

    /**
     * Get all CSR actions (paginated).
     * @param pageable Pagination parameters
     * @return Page of actions
     */
    public Page<CsrAction> getAllActions(Pageable pageable) {
        return csrActionRepository.findAll(pageable);
    }

    /**
     * Search CSR actions with filters.
     * @param search Search term for title, description, or responsible person
     * @param categoryStr Category filter (as string)
     * @param statusStr Status filter (as string)
     * @param pageable Pagination parameters
     * @return Page of matching actions
     */
    public Page<CsrAction> searchActions(String search, String categoryStr, String statusStr, Pageable pageable) {
        CsrCategory category = null;
        CsrStatus status = null;

        if (categoryStr != null && !categoryStr.isEmpty()) {
            try {
                category = CsrCategory.valueOf(categoryStr);
            } catch (IllegalArgumentException e) {
                // Invalid category, ignore filter
            }
        }

        if (statusStr != null && !statusStr.isEmpty()) {
            try {
                status = CsrStatus.valueOf(statusStr);
            } catch (IllegalArgumentException e) {
                // Invalid status, ignore filter
            }
        }

        String searchTerm = (search == null || search.isEmpty()) ? null : "%" + search.toLowerCase() + "%";

        return csrActionRepository.searchActions(searchTerm, category, status, pageable);
    }

    /**
     * Get CSR action by ID.
     * @param id The action ID
     * @return The action
     * @throws IllegalArgumentException if action not found
     */
    public CsrAction getActionById(Long id) {
        return csrActionRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("CSR Action not found with ID: " + id));
    }

    /**
     * Get actions by category.
     * @param category The category
     * @return List of actions
     */
    public List<CsrAction> getActionsByCategory(CsrCategory category) {
        return csrActionRepository.findByCategory(category);
    }

    /**
     * Get actions by status.
     * @param status The status
     * @return List of actions
     */
    public List<CsrAction> getActionsByStatus(CsrStatus status) {
        return csrActionRepository.findByStatus(status);
    }

    /**
     * Get overdue actions.
     * @return List of overdue actions
     */
    public List<CsrAction> getOverdueActions() {
        return csrActionRepository.findOverdueActions(LocalDate.now());
    }

    /**
     * Get actions due within the next N days.
     * @param days Number of days
     * @return List of actions
     */
    public List<CsrAction> getActionsDueWithin(int days) {
        return csrActionRepository.findByDeadlineBetween(LocalDate.now(), LocalDate.now().plusDays(days));
    }

    /**
     * Update the progress of an action.
     * @param id The action ID
     * @param progress The new progress value (0-100)
     * @return The updated action
     */
    @Transactional
    public CsrAction updateProgress(Long id, Integer progress) {
        CsrAction action = getActionById(id);
        action.setProgressPercent(Math.min(100, Math.max(0, progress)));

        // Auto-complete if progress reaches 100%
        if (progress >= 100 && action.getStatus() == CsrStatus.IN_PROGRESS) {
            action.setStatus(CsrStatus.COMPLETED);
        }

        return csrActionRepository.save(action);
    }

    /**
     * Update the status of an action.
     * @param id The action ID
     * @param status The new status
     * @return The updated action
     */
    @Transactional
    public CsrAction updateStatus(Long id, CsrStatus status) {
        CsrAction action = getActionById(id);
        action.setStatus(status);

        // Auto-set progress to 100% if completed
        if (status == CsrStatus.COMPLETED) {
            action.setProgressPercent(100);
        }

        return csrActionRepository.save(action);
    }
}
