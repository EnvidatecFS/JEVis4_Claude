package org.jevis.service;

import org.jevis.model.DashboardView;
import org.jevis.repository.DashboardViewRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional(readOnly = true)
public class DashboardViewService {

    private final DashboardViewRepository repository;

    public DashboardViewService(DashboardViewRepository repository) {
        this.repository = repository;
    }

    public List<DashboardView> getViewsForUser(String username) {
        return repository.findByUsernameOrderByNameAsc(username);
    }

    public DashboardView getView(Long id, String username) {
        return repository.findByIdAndUsername(id, username)
            .orElseThrow(() -> new IllegalArgumentException("Dashboard view not found with ID: " + id));
    }

    public Optional<DashboardView> getDefaultView(String username) {
        return repository.findByUsernameAndIsDefaultTrue(username);
    }

    @Transactional
    public DashboardView createView(String username, String name, String layoutJson, boolean setAsDefault) {
        DashboardView view = new DashboardView(name, username, layoutJson);
        if (setAsDefault) {
            repository.clearDefaultForUser(username);
            view.setIsDefault(true);
        }
        return repository.save(view);
    }

    @Transactional
    public DashboardView updateView(Long id, String username, String name, String layoutJson) {
        DashboardView view = getView(id, username);
        view.setName(name);
        if (layoutJson != null) {
            view.setLayoutJson(layoutJson);
        }
        return repository.save(view);
    }

    @Transactional
    public DashboardView saveLayout(Long id, String username, String layoutJson) {
        DashboardView view = getView(id, username);
        view.setLayoutJson(layoutJson);
        return repository.save(view);
    }

    @Transactional
    public DashboardView setDefault(Long id, String username) {
        repository.clearDefaultForUser(username);
        DashboardView view = getView(id, username);
        view.setIsDefault(true);
        return repository.save(view);
    }

    @Transactional
    public void deleteView(Long id, String username) {
        DashboardView view = getView(id, username);
        repository.delete(view);
    }

    public boolean hasViews(String username) {
        return repository.countByUsername(username) > 0;
    }
}
